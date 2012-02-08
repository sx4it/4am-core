class User < ActiveRecord::Base

  has_secure_password

  attr_accessible :login

  has_many :keys

  validates_uniqueness_of :login
  validates_presence_of :password, :on => :create 
  validates_length_of :password, :within => 6..40



  def self.search(search, page)
    if search
      paginate :per_page => 3, :page => page, :conditions => ['login like ?', "%#{search}%"], :order => 'login'
    else
      scoped
    end
  end


  #def self.search(search)
  #  if search
  #    where('login LIKE ?', "%#{search}%")
  #  else
  #    scoped
  #  end
  #end

end
