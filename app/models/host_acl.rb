class HostAcl < ActiveRecord::Base

  belongs_to :hosts, :polymorphic => true
  belongs_to :users, :polymorphic => true

end
