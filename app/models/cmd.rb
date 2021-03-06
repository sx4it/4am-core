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
    @type ||= "#{Rails.env}_cmd-host"
  end


  def self.find(host_id, id)
      res = Redis.current.get "#{Rails.env}_cmd-host:#{host_id}:#{id}"
      return nil unless res
      Cmd.from_json(res)
  end

  def self.find_grp(host_id, id)
      res = Redis.current.get "#{Rails.env}_cmd-grp:#{host_id}:#{id}"
      return nil unless res
      Cmd.from_json(res)
  end

  def self.count(*id)
      host_id = id.first
      if not id.empty?
        Redis.current.keys("#{Rails.env}_cmd-host:#{host_id}:*").count
      else
        Redis.current.keys("#{Rails.env}_cmd-host:*:*").count + Redis.current.keys("#{Rails.env}_cmd-grp:*:*").count
      end
  end

  def self.all(*id)
      host_id = id.first
      cmds = []
      if not id.empty?
        Redis.current.keys("#{Rails.env}_cmd-host:#{host_id}:*").each do |c|
          cmds << self.find(host_id, c.split(':').last)
        end
      else
        Redis.current.keys("#{Rails.env}_cmd-host:*:*").each do |c|
          cmds << self.find(c.split(':')[1], c.split(':').last)
        end
        Redis.current.keys("#{Rails.env}_cmd-grp:*:*").each do |c|
          cmds << self.find_grp(c.split(':')[1], c.split(':').last)
        end
      end
      cmds
  end

  def self.exec(host_id, command, current_user)
    cmd = Cmd.new(:command => Command.find(command), :hosts => [Host.find(host_id.to_i)],
                  :current_user => current_user, :log => "--contacting remote executor--\n")
    cmd.launch_command
    cmd
  end

  def self.exec_group(group_id, command, current_user)
    cmd = Cmd.new(:command => Command.find(command), :group => HostGroup.find(group_id.to_i),
                  :current_user => current_user, :log => "--contacting remote executor--\n")
    cmd.launch_command
    cmd
  end

  def destroy
        Redis.current.del "#{@type}:#{@hosts[0].id}:#{@id}"
  end

  def launch_command
    if @hosts.empty?
      @hosts = @group.host
      @id = Redis.current.incr "#{Rails.env}_group-#{@group.id}:max"
      Redis.current.set "#{Rails.env}_cmd-grp:#{@group.id}:#{@id}", self.get_json
      Redis.current.publish "#{Rails.env}:4am-command", "#{Rails.env}_cmd-grp:#{@group.id}:#{@id}"
    else
      @id = Redis.current.incr "#{Rails.env}_host-#{@hosts[0].id}:max"
      Redis.current.set "#{Rails.env}_cmd-host:#{@hosts[0].id}:#{@id}", self.get_json
      Redis.current.publish "#{Rails.env}:4am-command", "#{Rails.env}_cmd-host:#{@hosts[0].id}:#{@id}"
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
    cmd.command = Command.find(cmd.command) if Command.exists?(cmd.command)
    cmd.hosts_ip = cmd.hosts.map { |h| "#{h['ip']}:#{h['port']}" }
    cmd.users = cmd.users.map { |u| User.where(:id => u).first_or_create() }
    cmd.hosts = []
    cmd.hosts_id.each { |h| cmd.hosts << Host.find(h) if Host.exists?(h) }
    cmd.current_user = User.where(:id => cmd.current_user).first_or_create()
    cmd.expand_template
    cmd
  end

  def stop
      Redis.current.publish "#{Rails.env}:4am-command", "#{@type}:#{@hosts[0].id}:#{@id}:stop"
  end

  def self.clear(host_id)
    Redis.current.keys("#{Rails.env}_cmd-host:#{host_id}:*").each do |c|
        cmd = JSON.parse(Redis.current.get c)
        if %w{stopped killed finished}.include? cmd['status']
          cmd = Cmd.from_json(Redis.current.get c)
          cmd.destroy
        end
    end
  end

  class Safe
    attr_reader :current_host, :current_user, :users, :hosts, :group_name, :user
    def binding
      super
    end
    def initialize s
      @current_host = s[:hosts].first
      @current_user = s[:current_user]
      @user = s[:users].first
      @users = s[:users]
      @hosts = s[:hosts]
      @group_name = s[:group_name]
    end
  end

  def expand_template
    if @command
      erb = ERB.new @command.command
      context = {
        :current_user => {
            :login => @current_user.login,
            :email => @current_user.email,
            :id => @current_user.id,
            :groups => @current_user.user_group.map {|g| g.name },
            :keys => @current_user.keys.map {|k| k.ssh_key }
        },
        :users => @users.map { |u|
            {
              :login => u.login,
              :email => u.email,
              :id => u.id,
              :groups => u.user_group.map {|g| g.name },
              :keys => u.keys.map {|k| k.ssh_key }
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
        t = Thread.new do
            $SAFE = 4
            s = Safe.new context
            Thread.current[:script] = erb.result s.binding
        end
        t.join
        @script = t[:script]
      rescue Exception => error
        @script = "#- #{error} -"
      end
    end
  end #end expand_template

  class Action

    def self.add_host_acl acl, current_user
      if acl.users.type == "User"
        users = [acl.users]
        group_name = ""
      else
        users = acl.users.user
        group_name = acl.users.name
      end
      if acl.hosts.type == "Host"
        hosts = [acl.hosts]
      else
        hosts = acl.hosts.host
      end
      hosts.each do |host|
        users.each do |user|
          add_user user, host, group_name, current_user
        end
      end
    end

    def self.delete_host_acl acl, current_user
      if acl.users.type == "User"
        users = [acl.users]
        group_name = ""
      else
        users = acl.users.user
        group_name = acl.users.name
      end
      if acl.hosts.type == "Host"
        hosts = [acl.hosts]
      else
        hosts = acl.hosts.host
      end
      hosts.each do |host|
        users.each do |user|
          del_user user, host, group_name, current_user
        end
      end
    end

    private

    def self.has_other_rights? user, host
      Host.get_number_of_permissions(:execute, :user => user, :host => host) > 1
    end

    def self.add_user user, host, group_name, current_user
      unless has_other_rights?(user, host)
        cmd = Command.find_by_name(__method__)
        unless cmd.nil?
          cmd = Cmd.new(:command => cmd, :users => [user], :group_name => group_name, :hosts => [host], :current_user => current_user, :log => "--adding new acl--\n--contacting remote executor--\n")
          cmd.launch_command
        else
          puts "Error cannot find command #{__method__}"
        end
      end
    end

    def self.del_user user, host, group_name, current_user
      unless has_other_rights?(user, host)
        cmd = Command.find_by_name(__method__)
        unless cmd.nil?
          cmd = Cmd.new(:command => cmd, :users => [user], :group_name => group_name, :hosts => [host], :current_user => current_user, :log => "--adding new acl--\n--contacting remote executor--\n")
          cmd.launch_command
        else
          puts "Error cannot find command #{__method__}"
        end
      end
    end

  end #End class action

end
