class UserGroup < ActiveRecord::Base
  attr_accessible :name, :user_attributes
  has_and_belongs_to_many :user, :after_add => :after_add_callback, :after_remove => :after_remove_callback, :uniq => true
  has_many :host_acl, :as => :users, :dependent => :destroy
  validates :name, :presence => true
  validates_uniqueness_of :name
  accepts_nested_attributes_for :user, :allow_destroy => true

  # public activity tracking
  include PublicActivity::Model
  tracked

  def user_attributes=(attrs)
    users = []
    attrs.each do |key, attr|
      break if attrs[key][:id] == ""
      if attrs[key][:_destroy] == "1"
        self.user.delete User.find(attrs[key][:id])
      else
        users << User.find(attrs[key][:id])
      end
      # trick to be sure the final action is adding
      # and not deleting (in case we delete and add in the same submit)
      users.each do |user|
        self.user << user
      end
    end
  end
  def after_add_callback(record)
    self.host_acl.all.each do |acl|
      dup_acl = acl.dup
      dup_acl.users = record
      Cmd::Action.add_host_acl dup_acl, User.current_user
    end
  end

  def after_remove_callback(record)
    self.host_acl.all.each do |acl|
      dup_acl = acl.dup
      dup_acl.users = record
      Cmd::Action.delete_host_acl dup_acl, User.current_user
    end
  end

  def self.with_permissions_to(permission, *args)
    options = args.extract_options!.dup
    self.all(options).select do |t|
      t.permitted_to? permission
    end
  end
  def type
    t = self.class.to_s
  end
end
