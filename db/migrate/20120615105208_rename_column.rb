class RenameColumn < ActiveRecord::Migration
  def up
    change_table :host_acls do |t|
      t.rename :type, :acl_type
    end
  end

  def down
    change_table :host_acls do |t|
      t.rename :acl_type, :type
    end
  end
end
