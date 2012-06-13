class ChangeJoinTableName < ActiveRecord::Migration
  def up
    rename_table :hosts_host_groups, :host_groups_hosts
  end

  def down
    rename_table :host_groups_hosts, :hosts_host_groups
  end
end
