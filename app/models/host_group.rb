class HostGroup < ActiveRecord::Base
  attr_accessible :name, :host_attributes
  has_and_belongs_to_many :host, :after_add => :after_add_callback, :after_remove => :after_remove_callback, :uniq => true
  validates :name, :presence => true
  validates_uniqueness_of :name
  has_many :host_acl, :as => :hosts, :dependent => :destroy
  accepts_nested_attributes_for :host, :allow_destroy => true

  #public activity tracking
  include PublicActivity::Model
  tracked :owner => proc { Authorization.current_user }, :params => {
      :trackable_name => proc { |c, model| model.name },
      :owner_name => proc { Authorization.current_user.login }}

  def host_attributes=(attrs)
    hosts = []
    attrs.each do |key, attr|
      break if attrs[key][:id] == ""
      if attrs[key][:_destroy] == "1"
        self.host.delete Host.find(attrs[key][:id])
      else
        hosts << Host.find(attrs[key][:id])
      end
      # trick to be sure the final action is adding
      # and not deleting (in case we delete and add in the same submit)
      hosts.each do |host|
        self.host << host
      end
    end
  end

  def after_add_callback(record)
    self.host_acl.all.each do |acl|
      dup_acl = acl.dup
      dup_acl.hosts = record
      Cmd::Action.add_host_acl dup_acl, Authorization.current_user
    end
  end

  def after_remove_callback(record)
    self.host_acl.all.each do |acl|
      dup_acl = acl.dup
      dup_acl.hosts = record
      Cmd::Action.delete_host_acl dup_acl, Authorization.current_user
    end
  end

  def self.with_permissions_to(permission, *args)
    options = args.extract_options!.dup
    self.all.select do |t|
      t.permitted_to? permission, options
    end
  end
  def type
    self.class.to_s
  end
  def host_group
    []
  end
  def acl_id
    "#{id}:#{type}"
  end
end
