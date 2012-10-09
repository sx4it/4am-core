class HostGroup < ActiveRecord::Base
  attr_accessible :name
  has_and_belongs_to_many :host, :after_add => :after_add_callback, :after_remove => :after_remove_callback
  validates :name, :presence => true
  validates_uniqueness_of :name
  has_many :host_acl, :as => :hosts, :dependent => :destroy

  def after_add_callback(record)
    self.host_acl.all.each do |acl|
      dup_acl = acl.dup
      dup_acl.hosts = record
      Cmd::Action.add_host_acl dup_acl, User.current_user
    end
  end

  def after_remove_callback(record)
    self.host_acl.all.each do |acl|
      dup_acl = acl.dup
      dup_acl.hosts = record
      Cmd::Action.delete_host_acl dup_acl, User.current_user
    end
  end

  def self.with_permissions_to(permission, *args)
    options = args.extract_options!.dup
    self.all.select do |t|
      t.permitted_to? permission, options
    end
  end
  def type
    t = self.class.to_s
  end
  def host_group
    []
  end
end
