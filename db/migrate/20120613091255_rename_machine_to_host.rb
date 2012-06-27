class RenameMachineToHost < ActiveRecord::Migration
  def up
    rename_table :machines, :hosts
    rename_table :machine_tpls, :hosts_tpls
  end

  def down
    rename_table :hosts, :machines
    rename_table :hosts_tpls, :machine_tpls
  end
end
