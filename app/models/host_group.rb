class HostGroup < ActiveRecord::Base
  attr_accessible :name
  has_and_belongs_to_many :host
  has_many :host_acl, :as => :hosts
end
