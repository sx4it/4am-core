class User < ActiveRecord::Base

  attr_accessor :pass
  before_save :encrypt_password

  validates_uniqueness_of :login
  validates_confirmation_of :pass, :on => :create 
  validates_length_of :pass, :within => 6..40

  # If a user matching the credentials is found, returns the User object.
  # If no matching user is found, returns nil.
  def self.authenticate(user_info)
    find_by_username_and_password(user_info[:login],
				  user_info[:pass])
  end


  def encrypt_password
    if pass.present?
      self.pass += 'x'
    end
  end

end
