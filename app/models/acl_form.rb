class AclForm
  attr_accessor :user_id, :user_type, :host_id, :host_type, :users, :type, :hosts
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  validates :type, :inclusion => {:in => %w{Read Edit Exec Sudo}}
  validates :user_id, :numericality => { :only_integer => true, :greater_than => 0, :message => "is not a valid user" }
  validates :user_type, :inclusion => {:in => %w{User UserGroup}, :message => "is not a valid user type"}, :if => :no_errors
  validates :host_id, :numericality => { :only_integer => true, :greater_than => 0, :message => "is not a valid host" }
  validates :host_type, :inclusion => {:in => %w{Host HostGroup}, :message => "is not a valid host type"}, :if => :no_errors

  def no_errors
    self.errors.empty?
  end
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
  def persisted?
    false
  end
end
