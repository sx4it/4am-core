class ChangeTableNameUserGroups < ActiveRecord::Migration
  def up
    rename_table :users_user_groups, :user_groups_users
  end

  def down
    rename_table :user_groups_users, :users_user_groups
  end
end
