class Host < ActiveRecord::Base
  using_access_control
  validates :name, :presence => true
  validates :ip, :presence => true
  validates_uniqueness_of :name
   has_and_belongs_to_many :host_group
   has_many :host_acl, :as => :hosts, :dependent => :delete_all

  def self.with_permissions_to(permission, *args)
    options = args.extract_options!.dup
    self.all(options).select do |t|
      t.permitted_to? permission
    end
  end
  def type
    t = self.class.to_s
  end
end
