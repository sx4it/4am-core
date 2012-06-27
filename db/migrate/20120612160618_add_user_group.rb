class AddUserGroup < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.references :user_group
    end
  end
end
