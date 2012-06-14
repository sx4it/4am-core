class User < ActiveRecord::Base
  using_access_control
  has_secure_password

  attr_accessible :login, :password, :password_confirmation

  has_many :keys

  has_and_belongs_to_many :user_group
  has_many :host_acl, :as => :users
  has_and_belongs_to_many :roles, :uniq => true

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

  def role_symbols
    roles.map do |role|
      role.name.underscore.to_sym
    end
  end

  def user
    []
  end

  #def self.search(search)
  #  if search
  #    where('login LIKE ?', "%#{search}%")
  #  else
  #    scoped
  #  end
  #end

end
