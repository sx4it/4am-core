class AddTypeInHostAcl < ActiveRecord::Migration
  def up
    change_table :host_acls do |t|
      t.string :type
    end
  end

  def down
    change_table :host_acls do |t|
      t.remove :type
    end
  end
end
