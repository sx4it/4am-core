class User < ActiveRecord::Base

  attr_accessible :roles, :user_group, :password, :password_confirmation, :login, :email

  validates :login, :exclusion => {:in => %w{root}, :message => "is reserved"}

  acts_as_authentic do |c|
    # only for tests
    #c.validate_email_field = false
  end

  has_many :keys, :dependent => :delete_all

  has_and_belongs_to_many :user_group, :uniq => true
  has_many :host_acl, :as => :users, :dependent => :destroy
  has_and_belongs_to_many :roles, :uniq => true
  accepts_nested_attributes_for :roles, :allow_destroy => true
  accepts_nested_attributes_for :user_group, :allow_destroy => true

  #public activity tracking
  include PublicActivity::Model
  tracked :owner => proc { Authorization.current_user if Authorization.current_user.respond_to? :login }, :except => [:update], :params => {
    :trackable_name => proc { |c, model| model.login },
    :owner_name => proc { 
      if Authorization.current_user.respond_to? :login
        Authorization.current_user.login
      else
        # seed.rb case
        "Setup"
      end
  }}

  before_destroy do |record|
    record.user_group.each do |group|
      group.host_acl.each do |acl|
        dup_acl = acl.dup
        dup_acl.users = record
        Cmd::Action.delete_host_acl dup_acl, Authorization.current_user
      end
    end
  end


  def self.can?(what, context)
    Authorization::Engine.new.permit? what.to_sym, :context => context.to_sym
  end

  def self.can!(what, context)
    Authorization::Engine.new.permit! what.to_sym, :context => context.to_sym
  end

  def roles=(attr)
    User.can! :edit, :roles
    if attr and attr.first.is_a? String
      roles = []
      attr.each do |a|
       role = Role.find_by_id(a)
       roles << role if role
      end
      attr = roles
    end
    super(attr)
  end

  def user_group=(attr)
    User.can! :edit, :user_group
    if attr and attr.first.is_a? String
      grps = []
      attr.each do |a|
       grp = UserGroup.find_by_id(a)
       grps << grp if grp
      end
      attr = grps
    end
    super(attr)
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
    self.class.to_s
  end

  def self.find_by_x509(cert_str)
    logger.debug "Searching the user matching to the certificate:\n#{cert_str}"
    cert = OpenSSL::X509::Certificate.new cert_str
    User.joins(:keys).where(:keys => {:keytype => cert.public_key.ssh_type, :value => [ cert.public_key.to_blob ].pack('m0')}).first
  end
  def acl_id
    "#{id}:#{type}"
  end

end
