class Cmd
  attr_accessor :id, :status, :time, :command, :log, :status_code, :hosts, :current_user, :hosts_id, :script, :type, :hosts_ip

  def initialize(hash = {})
    hash.each do |k, v|
      self.instance_variable_set("@#{k}", v)
    end
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

  def self.exec(host_id, command, current_user)
    max = $redis.incr "#{host_id}:max"
    cmd = Cmd.new(:command => Command.find(command), :hosts => [Host.find(host_id.to_i)], :id => max, :current_user => current_user, :log => "--contacting remote executor--\n")
    $redis.set "cmd-host:#{host_id}:#{max}", cmd.get_json
    $redis.publish '4am-command', "cmd-host:#{host_id}:#{max}"
    cmd
  end
  class Safe
    attr_reader :current_host, :current_user
    class SafeUser
      attr_accessor :login, :email, :id
      def initialize w
        @login = w[:login]
        @email = w[:email]
        @id = w[:id]
      end
    end
    def binding
      super
    end
    def initialize s
      @current_host = s.hosts[0]
      @current_user = SafeUser.new :login => s.current_user.login, :email => s.current_user.email, :id => s.current_user.id
    end
  end
  def expand_template
      if @command
        erb = ERB.new @command.command
        begin
          t = Thread.start {
              $SAFE = 4
              s = Safe.new self
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
