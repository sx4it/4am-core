class Cmd
  attr_accessor :id, :status, :time, :command, :log, :status_code, :hosts, :current_user, :hosts_id, :script

  def initialize(hash = {})
    hash.each do |k, v|
      self.instance_variable_set("@#{k}", v)
    end
    @time ||= Time.now
    @status ||= "started"
    @log ||= "-"
  end


  def self.find(machine_id, id)
      res = $redis.get "cmd-host:#{machine_id}:#{id}"
      return nil unless res
      Cmd.from_json(res)
  end

  def self.all(id)
      cmds = []
      $redis.keys("cmd-host:#{id}:*").each do |c|
        cmds << self.find(id, c.split(':').last)
      end
      cmds
  end

  def destroy
        $redis.del "cmd-host:#{@hosts[0].id}:#{@id}"
  end

  def self.exec(machine_id, command, current_user)
    max = $redis.incr "#{machine_id}:max"
    cmd = Cmd.new(:command => Command.find(command), :hosts => [Machine.find(machine_id.to_i)], :id => max, :current_user => current_user)
    $redis.set "cmd-host:#{machine_id}:#{max}", cmd.get_json
    $redis.publish '4am-command', "cmd-host:#{machine_id}:#{max}"
    cmd
  end

  def expand_template
      erb = ERB.new @command.command
      @script = erb.result binding
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
    cmd.command = Command.find(cmd.command)
    cmd.hosts = Machine.find(cmd.hosts_id)
    cmd.current_user = User.find(cmd.current_user)
    cmd.expand_template
    cmd
  end

  def stop
      @status = "stopped"
      $redis.set "cmd-host:#{@hosts[0].id}:#{@id}", self.get_json
  end

  def self.clear(machine_id)
    $redis.keys("cmd-host:#{machine_id}:*").each do |c|
        Command.class
        Machine.class
        cmd = Cmd.from_json($redis.get c)
        if %w{stopped finished}.include? cmd.status
          cmd.destroy
        end
    end
  end

end
