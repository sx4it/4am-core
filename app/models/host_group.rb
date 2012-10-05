class HostGroup < ActiveRecord::Base
  attr_accessible :name
  has_and_belongs_to_many :host
  validates :name, :presence => true
  validates_uniqueness_of :name
  has_many :host_acl, :as => :hosts, :dependent => :destroy

  def self.with_permissions_to(permission, *args)
    options = args.extract_options!.dup
    self.all.select do |t|
      t.permitted_to? permission, options
    end
  end
  def type
    t = self.class.to_s
  end
  def host_group
    []
  end
end
