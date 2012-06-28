class AddHostGroup < ActiveRecord::Migration
  def change
    change_table :machines do |t|
      t.references :host_group
    end
  end
end
