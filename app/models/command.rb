class Command < ActiveRecord::Base
  attr_accessible :name, :command
  validates :name, :command, :presence => true
end
