class DeleteKeyLimit < ActiveRecord::Migration
  def change
    change_column :keys, :value, :binary, :limit => nil
  end
end
