class HostGroup < ActiveRecord::Base
  attr_accessible :name
  has_many :machine
end
