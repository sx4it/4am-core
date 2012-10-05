class User < ActiveRecord::Base

  cattr_accessor :current_user

  acts_as_authentic do |c|
    # only for tests
    c.validate_email_field = false
  end

  has_many :keys, :dependent => :delete_all

  has_and_belongs_to_many :user_group
  has_many :host_acl, :as => :users, :dependent => :destroy
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
  def name
    return self.login
  end
  def as_json(options = {})
    options[:only] ||= [:login, :email, :id, :password]
    super(options)
  end
  def type
    t = self.class.to_s
  end

  def self.find_by_x509(cert_str)
    logger.debug "Searching the user matching to the certificate:\n#{cert_str}"
    cert = OpenSSL::X509::Certificate.new cert_str
    User.joins(:keys).where(:keys => {:keytype => cert.public_key.ssh_type, :value => [ cert.public_key.to_blob ].pack('m0')}).first
  end

end
