class Host < ActiveRecord::Base
  validates :name, :presence => true, :uniqueness => true
  validates :ip, :presence => true
  validates :port, :presence => true, :numericality => { :only_integer => true, :greater_than => 0, :less_than => 65535 }
   has_and_belongs_to_many :host_group
   has_many :host_acl, :as => :hosts, :dependent => :destroy

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
