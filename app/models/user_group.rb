class UserGroup < ActiveRecord::Base
  attr_accessible :name
  has_and_belongs_to_many :user
  has_many :host_acl, :as => :users, :dependent => :delete_all

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
