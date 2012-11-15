class Host < ActiveRecord::Base
  validates :name, :presence => true, :uniqueness => true
  validates :ip, :presence => true
  validates :port, :presence => true, :numericality => { :only_integer => true, :greater_than => 0, :less_than => 65535 }
  has_and_belongs_to_many :host_group, :uniq => true
  has_many :host_acl, :as => :hosts, :dependent => :destroy

  #public activity tracking
  include PublicActivity::Model
  tracked :owner => proc { User.current_user }, :params => {
      :trackable_name => proc { |c, model| model.name },
      :owner_name => proc { User.current_user.login }}

  before_destroy do |record|
    record.host_group.each do |group|
      group.host_acl.each do |acl|
        dup_acl = acl.dup
        dup_acl.hosts = record
        Cmd::Action.delete_host_acl dup_acl, User.current_user
      end
    end
  end

  def self.with_permissions_to(permission, *args)
    options = args.extract_options!.dup
    self.all.select do |t|
      t.permitted_to? permission, options
    end
  end

  def self.get_number_of_permissions(permission, *args)
    options = args.extract_options!.dup
    puts "Getting number of permissions for : #{options[:host].name} user :#{options[:user].login} "
    h = HostAcl.all.select do |acl|
      (acl.acl_type == "Sudo" or acl.acl_type == "Exec") and (acl.hosts == options[:host] or (acl.hosts.type == "HostGroup" and acl.hosts.host.include? options[:host])) and (acl.users == options[:user] or (acl.users.type == "UserGroup" and acl.users.user.include? options[:user]))
    end
    h.size
  end
  def type
    t = self.class.to_s
  end
end
