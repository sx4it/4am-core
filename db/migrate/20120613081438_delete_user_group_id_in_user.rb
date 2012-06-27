class DeleteUserGroupIdInUser < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.remove :user_group_id
    end
  end

  def down
    change_table :users do |t|
      t.column :user_group_id
    end
  end
end
