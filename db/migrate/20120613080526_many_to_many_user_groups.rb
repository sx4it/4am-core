class ManyToManyUserGroups < ActiveRecord::Migration
  def change
    create_table :users_user_groups, :id => false do |t|
      t.references :users, :user_groups
    end
  end
end
