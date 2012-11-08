class Command < ActiveRecord::Base
  attr_accessible :name, :command
  validates :name, :command, :presence => true

  #public activity tracking
  include PublicActivity::Model
  tracked :owner => proc { User.current_user }, :params => {
      :trackable_name => proc { |c, model| model.name },
      :owner_name => proc {
        if User.current_user
          User.current_user.login 
        else
          # seed.rb case
          "Setup"
        end
      }}
end
