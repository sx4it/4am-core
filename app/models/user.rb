class User < ActiveRecord::Base

  has_secure_password

  has_many :keys

  validates_uniqueness_of :login
  validates_presence_of :password, :on => :create 
  validates_length_of :password, :within => 6..40

end
