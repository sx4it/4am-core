class HostGroup < ActiveRecord::Base
  attr_accessible :name
  has_many :host
end
