class Command < ActiveRecord::Base
  attr_accessible :name, :command
  validates :name, :command, :presence => true

  #public activity tracking
  include PublicActivity::Model
  tracked :owner => proc { Authorization.current_user if Authorization.current_user.respond_to? :login }, :params => {
      :trackable_name => proc { |c, model| model.name },
      :owner_name => proc {
        if Authorization.current_user.respond_to? :login
          Authorization.current_user.login 
        else
          # seed.rb case
          "Setup"
        end
      }}
end
