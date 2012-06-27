class ManyToManyHostHostGroup < ActiveRecord::Migration
  def up
    create_table :hosts_host_groups, :id => false do |t|
      t.references :host, :host_group
    end
    change_table :hosts do |t|
      t.remove :host_group_id
    end
  end

  def down
    drop_table :hosts_host_groups
    change_table :hosts do |t|
      t.column :host_group_id
    end
  end
end
