class DeleteTimestamInRolesUser < ActiveRecord::Migration
  def up
    change_table :roles_users do |t|
      t.remove :created_at
      t.remove :updated_at
    end
  end

  def down
    change_table :roles_users do |t|
      t.integer :created_at
      t.integer :updated_at
    end
  end
end
