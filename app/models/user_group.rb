class UserGroup < ActiveRecord::Base
  attr_accessible :name
  has_and_belongs_to_many :user, :after_add => :after_add_callback
  has_many :host_acl, :as => :users, :dependent => :destroy
  validates :name, :presence => true
  validates_uniqueness_of :name

  def after_add_callback(record)
    self.host_acl.all.each do |acl|
      dup_acl = acl.dup
      dup_acl.users = record
      Cmd::Action.add_host_acl dup_acl, User.current_user
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
