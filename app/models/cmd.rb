class Cmd
  attr_accessor :id, :status, :time, :command, :log, :status_code, :hosts, :current_user, :hosts_id, :script, :type, :hosts_ip, :group, :users, :user_groups

  def initialize(hash = {})
    hash.each do |k, v|
      self.instance_variable_set("@#{k}", v)
    end
    @users ||= {}
    @time ||= Time.now
    @status ||= "started"
    @log ||= "-"
    @type ||= "cmd-host"
  end


  def self.find(host_id, id)
      res = $redis.get "cmd-host:#{host_id}:#{id}"
      return nil unless res
      Cmd.from_json(res)
  end

  def self.all(*id)
      host_id = id.first
      cmds = []
      if not id.empty?
        $redis.keys("cmd-host:#{host_id}:*").each do |c|
          cmds << self.find(host_id, c.split(':').last)
        end
      else
        $redis.keys("cmd-host:*:*").each do |c|
          cmds << self.find(c.split(':')[1], c.split(':').last)
        end
      end
      cmds
  end

  def destroy
        $redis.del "#{@type}:#{@hosts[0].id}:#{@id}"
  end

  def self.add_user

  end

  def launch_command
    if @hosts.nil?
      @hosts = @group.hosts
      @id = $redis.incr "group-#{@group.id}:max"
      $redis.set "cmd-grp:#{@group.id}:#{@id}", self.get_json
      $redis.publish '4am-command', "cmd-grp:#{@group.id}:#{@id}"
    else
      @id = $redis.incr "host-#{@hosts[0].id}:max"
      $redis.set "cmd-host:#{@hosts[0].id}:#{@id}", self.get_json
      $redis.publish '4am-command', "cmd-host:#{@hosts[0].id}:#{@id}"
    end
  end

  def self.exec(host_id, command, current_user)
    cmd = Cmd.new(:command => Command.find(command), :hosts => [Host.find(host_id.to_i)], :current_user => current_user, :log => "--contacting remote executor--\n")
    cmd.launch_command
    cmd
  end

  def self.exec_group(group_id, command, current_user)
    cmd = Cmd.new(:command => Command.find(command), :group => HostGroup.find(group_id.to_i), :current_user => current_user, :log => "--contacting remote executor--\n")
    cmd.launch_command
    cmd
  end

  class Safe
    attr_reader :current_host, :current_user, :users
    def binding
      super
    end
    def initialize s
      @current_host = s[:hosts][0]
      @current_user = s[:current_user]
      @users = s[:users]
      @hosts = s[:hosts]
    end
  end

  def expand_template
      if @command
        erb = ERB.new @command.command
        begin
          context = {
            :current_user =>
              {
                :login => @current_user.login,
                :email => @current_user.email,
                :id => @current_user.id,
                :groups => @current_user.user_group.map {|g| g.name },
                :keys => @current_user.keys.map {|k| k.value }
              },
            :users => @users.map { |u|
                {
                  :login => u.login,
                  :email => u.email,
                  :id => u.id,
                  :groups => @current_user.user_group.map {|g| g.name },
                  :keys => u.keys.map {|k| k.value }
                }
            },
            :hosts => @hosts.map { |h|
              {
                :ip => h.ip,
                :name => h.name
              }
            }

          }

          t = Thread.new {
              $SAFE = 4
              s = Safe.new context
              Thread.current[:script] = erb.result s.binding
          }
          t.join
          @script = t[:script]
        rescue Exception => error
          @script = "#- #{error} -"
        end
      end
  end

  def get_json
      dup = self.dup
      dup.expand_template
      dup.command = dup.command.id
      dup.hosts_id = dup.hosts.map do |h| h.id end
      dup.hosts = dup.hosts.map do |h| {:ip => h.ip, :port => h.port} end
      dup.current_user = dup.current_user.id
      dup.to_json
  end

  def self.from_json json
    cmd = Cmd.new JSON.parse(json)
    cmd.command = if Command.exists?(cmd.command)
                    Command.find(cmd.command)
                  else
                    nil
                  end
    cmd.hosts_ip = cmd.hosts.map do |h| "#{h['ip']}:#{h['port']}" end
    cmd.hosts = []
    cmd.hosts_id.each do |h|
      cmd.hosts << Host.find(cmd.hosts_id).first if Host.exists?(h)
    end
    cmd.current_user = if User.exists?(cmd.current_user)
                        User.find(cmd.current_user)
                       else
                         nil
                       end
    cmd.expand_template
    cmd
  end

  def stop
      $redis.publish "4am-command", "#{@type}:#{@hosts[0].id}:#{@id}:stop"
  end

  def self.clear(host_id)
    $redis.keys("cmd-host:#{host_id}:*").each do |c|
        cmd = JSON.parse($redis.get c)
        if %w{stopped killed finished}.include? cmd['status']
          cmd = Cmd.from_json($redis.get c)
          cmd.destroy
        end
    end
  end

end
