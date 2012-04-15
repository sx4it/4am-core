class CreateMachines < ActiveRecord::Migration
  def change
    create_table :machines do |t|
      t.string :name
      t.string :ip
      t.reference :machine_tpl

      t.timestamps
    end
  end
end
