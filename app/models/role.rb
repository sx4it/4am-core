class Role < ActiveRecord::Base
  attr_accessible :name
  validates :name, :uniqueness => true
end
