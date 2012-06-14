class User < ActiveRecord::Base

  acts_as_authentic do |c|
  end

  has_many :keys

  has_and_belongs_to_many :user_group
  has_many :host_acl, :as => :users
  has_and_belongs_to_many :roles, :uniq => true

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

end
