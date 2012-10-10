class HostAcl < ActiveRecord::Base

  attr_accessible :acl_type, :hosts, :users
  belongs_to :hosts, :polymorphic => true
  belongs_to :users, :polymorphic => true
  validates :acl_type, :presence => true, :inclusion => {:in => %w{Sudo Edit Read Exec}}
  validates :hosts, :presence => true
  validates :users, :presence => true

  #public activity tracking
  include PublicActivity::Model
  tracked :owner => proc { User.current_user }, :params => {
      :hosts => proc { |c, model| model.hosts.name },
      :users => proc { |c, model| model.users.name },
      :acl_type => proc { |c, model| model.acl_type },
      :owner_name => proc { User.current_user.login }}

  before_destroy do |record|
    Cmd::Action.delete_host_acl record, User.current_user
  end

  validates_uniqueness_of :acl_type, :scope => [:users_id, :hosts_id, :users_type, :hosts_type], :message => "has already been set"
  validates_each :hosts_type do |record, attr, value|
    record.errors.add(attr, 'invalid type') unless %w{Host HostGroup}.include?(value)
  end
  validates_each :users_type do |record, attr, value|
    record.errors.add(attr, 'invalid type') unless %w{User UserGroup}.include?(value)
  end

end
