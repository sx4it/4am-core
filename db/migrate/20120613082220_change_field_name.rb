class ChangeFieldName < ActiveRecord::Migration
  def up
    change_table :user_groups_users do |t|
      t.rename :users_id, :user_id
      t.rename :user_groups_id, :user_group_id
    end
  end

  def down
    change_table :user_groups_users do |t|
      t.rename :user_id, :users_id
      t.rename :user_group_id, :user_groups_id
    end
  end
end
