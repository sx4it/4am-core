class AddTypeToKeys < ActiveRecord::Migration
  def change
    add_column :keys, :type, :string
    change_column :keys, :value, :binary
  end
end
