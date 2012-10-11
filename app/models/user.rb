class User < ActiveRecord::Base

  cattr_accessor :current_user

  attr_accessible :roles_attributes, :password, :password_confirmation, :login, :email

  acts_as_authentic do |c|
    # only for tests
    c.validate_email_field = false
  end

  has_many :keys, :dependent => :delete_all

  has_and_belongs_to_many :user_group
  has_many :host_acl, :as => :users, :dependent => :destroy
  has_and_belongs_to_many :roles, :uniq => true
  accepts_nested_attributes_for :roles, :allow_destroy => true

  #public activity tracking
  include PublicActivity::Model
  tracked :owner => proc { User.current_user }, :except => [:update], :params => {
    :trackable_name => proc { |c, model| model.login },
    :owner_name => proc { User.current_user.login if User.current_user }}

  before_destroy do |record|
    record.user_group.each do |group|
      group.host_acl.each do |acl|
        dup_acl = acl.dup
        dup_acl.users = record
        Cmd::Action.delete_host_acl dup_acl, User.current_user
      end
    end
  end

  def roles_attributes=(attrs)
    roles = []
    attrs.each do |key, attr|
      break if attrs[key][:id] == ""
      if attrs[key][:_destroy] == "1"
        self.roles.delete Role.find(attrs[key][:id])
      else
        roles << Role.find(attrs[key][:id])
      end
      # trick to be sure the final action is adding
      # and not deleting (in case we delete and add in the same submit)
      roles.each do |role|
        self.roles << role
      end
    end
  end
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
