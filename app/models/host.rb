class Host < ActiveRecord::Base
       has_and_belongs_to_many :host_group
       has_many :host_acl, :as => :hosts
end
