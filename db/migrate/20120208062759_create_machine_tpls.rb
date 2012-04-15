class CreateMachineTpls < ActiveRecord::Migration
  def change
    create_table :machine_tpls do |t|
      t.string :name

      t.timestamps
    end
  end
end
