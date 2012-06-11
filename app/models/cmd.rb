class Cmd
  attr_accessor :id, :status, :time, :command, :host, :log, :status_code

  def initialize(hash = {})
    hash.each do |k, v|
      self.instance_variable_set("@#{k}", v)
    end
    @time ||= Time.now
    @status ||= "started"
    @log ||= "-"
  end


  def self.find(machine_id, id)
      res = $redis.get "cmd:#{machine_id}:#{id}"
      return nil unless res
      Command.class
      Machine.class
      Marshal.load(res)
  end

  def self.all(id)
      cmds = []
      $redis.keys("cmd:#{id}:*").each do |c|
        cmds << self.find(id, c.split(':').last)
      end
      cmds
  end

  def destroy
        $redis.del "cmd:#{@machine.id}:#{@id}"
  end

  def self.exec(machine_id, command)
    max = $redis.incr "#{machine_id}:max"
    cmd = Cmd.new(:command => Command.find(command), :machine => Machine.find(machine_id.to_i), :id => max)
    $redis.set "cmd:#{machine_id}:#{max}", Marshal.dump(cmd)
    $redis.publish '4am-command', "cmd:#{machine_id}:#{max}"
    cmd
  end

  def stop
      @status = "stopped"
      $redis.set "cmd:#{@machine.id}:#{@id}", Marshal.dump(self)
  end

  def self.clear(machine_id)
    $redis.keys("cmd:#{machine_id}:*").each do |c|
        Command.class
        Machine.class
        cmd = Marshal.load($redis.get c)
        if %w{stopped finished}.include? cmd.status
          cmd.destroy
        end
    end
  end

end
