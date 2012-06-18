class AddPortToHost < ActiveRecord::Migration
  def change
    add_column :hosts, :port, :int
  end
end
