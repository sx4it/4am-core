class CreateHostGroups < ActiveRecord::Migration
  def change
    create_table :host_groups do |t|
      t.string :name

      t.timestamps
    end
  end
end
