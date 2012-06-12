class Cmd
  attr_accessor :id, :status, :time, :command, :log, :status_code, :hosts, :current_user

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
      Command.class
      Machine.class
      Marshal.load(res)
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
    $redis.set "cmd-host:#{machine_id}:#{max}", Marshal.dump(cmd)
    $redis.publish '4am-command', "cmd-host:#{machine_id}:#{max}"
    cmd
  end

  def self.exec_group(machine_ids, command)
    max = $redis.incr "#{machine_id}:max"
    cmd = Cmd.new(:command => Command.find(command), :hosts => Machine.find_all_id(machine_ids), :id => max)
    $redis.set "cmd-group:#{machine_id}:#{max}", Marshal.dump(cmd)
    $redis.publish '4am-command', "cmd-group:#{machine_id}:#{max}"
    cmd
  end

  def stop
      @status = "stopped"
      $redis.set "cmd-host:#{@hosts[0].id}:#{@id}", Marshal.dump(self)
  end

  def self.clear(machine_id)
    $redis.keys("cmd-host:#{machine_id}:*").each do |c|
        Command.class
        Machine.class
        cmd = Marshal.load($redis.get c)
        if %w{stopped finished}.include? cmd.status
          cmd.destroy
        end
    end
  end

end
