class Host < ActiveRecord::Base
  using_access_control
       has_and_belongs_to_many :host_group
       has_many :host_acl, :as => :hosts

  def self.with_permissions_to(permission, *args)
    options = args.extract_options!.dup
    self.all(options).select do |t|
      t.permitted_to? permission
    end
  end
end
