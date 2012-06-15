class HostAcl < ActiveRecord::Base

  attr_accessible :acl_type, :hosts, :users
  belongs_to :hosts, :polymorphic => true
  belongs_to :users, :polymorphic => true

end
