class Machine < ActiveRecord::Base
  def execute(command)
    max = $redis.incr "#{self.id}:max"
    $redis.set "cmd:#{self.id}:#{max}", {:command => command, :time => Time.now.to_i, :status => "started"}.to_json
    $redis.publish '4am-command', "cmd:#{self.id}:#{max}"
  end
  def cmd_all()
      cmds = []
      $redis.keys("cmd:#{self.id}:*").each do |c|
        data = JSON.parse($redis.get c)
        command = Command.new(data['command'])
        command.id = data['command']['id']
        status = data['status']
        time = Time.at(data['time'])
        cmds << [command, time, status, c.split(':').last]
      end
      return cmds
  end
  def stop_command(id)
    logger.info "stopping cmd #{self.id}:#{id}"
    if $redis.exists "cmd:#{self.id}:#{id}"
      data = JSON.parse($redis.get "cmd:#{self.id}:#{id}")
      data['status'] = "finished"
      $redis.set "cmd:#{self.id}:#{id}", data.to_json
    end
  end
  def clear_olds_commands()
    cmds = []
    $redis.keys("cmd:#{self.id}:*").each do |c|
        data = JSON.parse($redis.get c)
        status = data['status']
        if status == "finished"
          $redis.del c
        end
    end
  end
end
