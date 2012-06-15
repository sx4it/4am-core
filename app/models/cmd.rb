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
      puts "all"
      if not id.empty?
        $redis.keys("cmd-host:#{host_id}:*").each do |c|
          cmds << self.find(host_id, c.split(':').last)
        end
      else
         puts "CMM"
        $redis.keys("cmd-host:*:*").each do |c|
          puts "Command"
          puts c.split(':')[1]
          puts c.split(':').last
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
    cmd = Cmd.new(:command => Command.find(command), :hosts => [Host.find(host_id.to_i)], :id => max, :current_user => current_user, :log => "--Executing--\n")
    $redis.set "cmd-host:#{host_id}:#{max}", cmd.get_json
    $redis.publish '4am-command', "cmd-host:#{host_id}:#{max}"
    cmd
  end

  def expand_template
      if @command
        erb = ERB.new @command.command
        @script = erb.result binding
      end
  end

  def get_json
      dup = self.dup
      dup.expand_template
      dup.command = dup.command.id
      dup.hosts_id = dup.hosts.map do |h| h.id end
      dup.hosts = dup.hosts.map do |h| h.ip end
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
    cmd.hosts_ip = cmd.hosts.dup
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
      @status = "stopped"
      $redis.set "#{@type}:#{@hosts[0].id}:#{@id}", self.get_json
  end

  def self.clear(host_id)
    $redis.keys("#{@type}:#{host_id}:*").each do |c|
        Command.class
        Host.class
        cmd = Cmd.from_json($redis.get c)
        if %w{stopped finished}.include? cmd.status
          cmd.destroy
        end
    end
  end

end
