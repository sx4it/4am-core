class Role < ActiveRecord::Base
  attr_accessible :name
  validates :name, :uniqueness => true, :presence => true

  def self.update_roles(attr)
    User.can! :edit, :roles
    if attr and attr.first.is_a? String
      attr = attr.first.split(',')
      roles = Role.where("name in (?)", attr)
      (attr - roles.map{|r| r.name}).each do |new|
        roles << Role.create(:name => new)
      end
      Role.where("id not in (?)", roles).delete_all
    end
  end

  def roles
    Role.all.map{|u| u.name}.join(',')
  end
end
