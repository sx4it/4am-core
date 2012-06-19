class Cmd
  attr_accessor :id, :status, :time, :command, :log, :status_code, :hosts, :current_user, :hosts_id, :script, :type, :hosts_ip, :group, :users, :user_groups, :group_name

  def initialize(hash = {})
    hash.each do |k, v|
      self.instance_variable_set("@#{k}", v)
    end
    @group_name ||= ""
    @users ||= []
    @group ||= []
    @hosts ||= []
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

  def self.find_grp(host_id, id)
      res = $redis.get "cmd-grp:#{host_id}:#{id}"
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
        $redis.keys("cmd-grp:*:*").each do |c|
          cmds << self.find_grp(c.split(':')[1], c.split(':').last)
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
    if @hosts.empty?
      @hosts = @group.host
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
    attr_reader :current_host, :current_user, :users, :hosts, :group_name
    def binding
      super
    end
    def initialize s
      @current_host = s[:hosts][0]
      @current_user = s[:current_user]
      @users = s[:users]
      @hosts = s[:hosts]
      @group_name = s[:group_name]
    end
  end

  def expand_template
      if @command
        erb = ERB.new @command.command
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
                  :groups => u.user_group.map {|g| g.name },
                  :keys => u.keys.map {|k| k.value }
                }
            },
            :hosts => @hosts.map { |h|
              {
                :ip => h.ip,
                :name => h.name
              }
            },
            :group_name => @group_name


          }

        begin
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
      dup.users = dup.users.map do |u| u.id end
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
    cmd.users = cmd.users.map do |u| if User.exists?(u)
                                        User.find(u)
                                      else
                                        User.new
                                      end
    end
    cmd.hosts = []
    cmd.hosts_id.each do |h|
      cmd.hosts << Host.find(cmd.hosts_id).first if Host.exists?(h)
    end
    cmd.current_user = if User.exists?(cmd.current_user)
                        User.find(cmd.current_user)
                       else
                        User.new
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

  class Action
    def self.add_host_in_group group, host
    end

    def self.del_host_in_group group, host
    end

    def self.add_user_in_group group, user
    end

    def self.del_user_in_group group, user
    end

    def self.update_user_group group
    end

    def self.delete_user_group group
    end

    def self.update_user user
      #cmd = Command.find_by_name(__method__.to_s)
      #if cmd.nil?
      #  throw "command #{__method__} missing."
      #end
    end

    def self.new_user_key user, key
    end

    def self.update_user_key user, key
    end

    def self.delete_user_key user, key
    end

    def self.delete_user user
    end

    def self.add_host_acl acl, current_user
#      cmd = Command.find_by_name(__method__.to_s)
#      if cmd.nil?
#        throw "command #{__method__} missing."
#      end
#      if acl.users.type == "User"
#        users = [acl.users]
#        group_name = ""
#      else
#        users = acl.users.user
#        group_name = acl.users.name
#      end
#      if acl.hosts.type == "Host"
#        hosts = [acl.hosts]
#        group = []
#      else
#        hosts = []
#        group = acl.hosts
#      end
#      cmd = Cmd.new(:command => cmd, :users => users, :group_name => group_name, :group => group, :hosts => hosts, :current_user => current_user, :log => "--adding new acl--\n--contacting remote executor--\n")
#      cmd.launch_command
    end

    def self.delete_host_acl acl, current_user
#      cmd = Command.find_by_name(__method__.to_s)
#      if cmd.nil?
#        throw "command #{__method__} missing."
#      end
#      if acl.users.type == "User"
#        users = [acl.users]
#        group_name = ""
#      else
#        users = acl.users.user
#        group_name = acl.users.name
#      end
#      if acl.hosts.type == "Host"
#        hosts = [acl.hosts]
#        group = []
#      else
#        hosts = []
#        group = acl.hosts
#      end
#      cmd = Cmd.new(:command => cmd, :users => users, :group_name => group_name, :group => group, :hosts => hosts, :current_user => current_user, :log => "--adding new acl--\n--contacting remote executor--\n")
#      cmd.launch_command
    end

    def self.delete_host host
    end
  end

end
