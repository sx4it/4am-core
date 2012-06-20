class RenameTypeToKeytypeFromKeys < ActiveRecord::Migration
  def up
    change_table :keys do |t|
      t.rename :type, :keytype
    end
  end

  def down
    change_table :keys do |t|
      t.rename :keytype, :type
    end
  end
end
