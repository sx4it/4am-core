class User < ActiveRecord::Base

  has_secure_password

  attr_accessible :login, :password, :password_confirmation

  has_many :keys

  has_and_belongs_to_many :user_group

  validates_uniqueness_of :login
  validates_presence_of :password, :on => :create
  validates_length_of :password, :within => 6..40, :on => :create



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
