class ChangeHostTplTableName < ActiveRecord::Migration
  def up
    rename_table :hosts_tpls, :host_tpls
  end

  def down
    rename_table :host_tpls, :hosts_tpls
  end
end
