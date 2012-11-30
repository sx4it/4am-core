class UserGroup < ActiveRecord::Base
  attr_accessible :name, :user_attributes, :user
  has_and_belongs_to_many :user, :after_add => :after_add_callback, :after_remove => :after_remove_callback, :uniq => true
  has_many :host_acl, :as => :users, :dependent => :destroy
  validates :name, :presence => true
  validates_uniqueness_of :name
  accepts_nested_attributes_for :user, :allow_destroy => true

  # public activity tracking
  include PublicActivity::Model
  tracked :owner => proc { Authorization.current_user }, :params => {
      :trackable_name => proc { |c, model| model.name },
      :owner_name => proc { Authorization.current_user.login }}

  def user=(attr)
    User.can! :edit, :user_group
    if attr and attr.first.is_a? String
      users = []
      attr.each do |a|
       user = User.find_by_id(a)
       users << user if user
      end
      attr = users
    end
    super(attr)
  end

  def after_add_callback(record)
    self.host_acl.all.each do |acl|
      dup_acl = acl.dup
      dup_acl.users = record
      Cmd::Action.add_host_acl dup_acl, Authorization.current_user
    end
  end

  def after_remove_callback(record)
    self.host_acl.all.each do |acl|
      dup_acl = acl.dup
      dup_acl.users = record
      Cmd::Action.delete_host_acl dup_acl, Authorization.current_user
    end
  end

  def self.with_permissions_to(permission, *args)
    options = args.extract_options!.dup
    self.all(options).select do |t|
      t.permitted_to? permission
    end
  end
  def type
    self.class.to_s
  end
  def acl_id
    "#{id}:#{type}"
  end
end
