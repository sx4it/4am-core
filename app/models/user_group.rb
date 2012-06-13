class UserGroup < ActiveRecord::Base
  attr_accessible :name
  has_and_belongs_to_many :user
  has_many :host_acl, :as => :users
end
