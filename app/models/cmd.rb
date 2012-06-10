class Cmd
  attr_accessor :id, :status, :time, :command, :machine_id

  def initialize(hash = {})
    self.time = Time.now.to_i
    self.status = "started"
    hash.each do |k, v|
      self.instance_variable_set("@#{k}", v)
    end
    if self.command
      self.command = Command.find(self.command['id'].to_i)
    end
  end


  def self.find(machine_id, id)
      res = $redis.get "cmd:#{machine_id}:#{id}"
      return nil unless res
      data = JSON.parse(res)
      puts res
      Cmd.new(data)
  end

  def self.all(id)
      cmds = []
      $redis.keys("cmd:#{id}:*").each do |c|
        cmds << self.find(id, c.split(':').last)
      end
      cmds
  end

  def destroy
        $redis.del "cmd:#{self.machine_id}:#{self.id}"
  end

  def self.exec(machine_id, command)
    max = $redis.incr "#{machine_id}:max"
    cmd = Cmd.new
    cmd.command = Command.find(command)
    cmd.machine_id = machine_id.to_i
    cmd.id = max
    $redis.set "cmd:#{machine_id}:#{max}", cmd.to_json
    $redis.publish '4am-command', "cmd:#{machine_id}:#{max}"
    cmd
  end

  def stop
      self.status = "stopped"
      $redis.set "cmd:#{self.machine_id}:#{self.id}", self.to_json
  end

  def self.clear(machine_id)
    $redis.keys("cmd:#{machine_id}:*").each do |c|
        data = JSON.parse($redis.get c)
        cmd = Cmd.new(data)
        if %w{stopped finished}.include? cmd.status
          cmd.destroy
        end
    end
  end

end
