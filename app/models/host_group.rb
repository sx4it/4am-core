class HostGroup < ActiveRecord::Base
  attr_accessible :name
  has_and_belongs_to_many :host
  has_many :host_acl, :as => :hosts

  def self.with_permissions_to(permission, *args)
    options = args.extract_options!.dup
    self.all(options).select do |t|
      t.permitted_to? permission
    end
  end
end
