class CreateKeys < ActiveRecord::Migration
  def change
    create_table :keys do |t|
      t.string :name
      t.string :value
      t.references :user

      t.timestamps
    end
  end
end
