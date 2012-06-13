class AddedHostAcl < ActiveRecord::Migration
  def up
    create_table :host_acls do |t|
      t.references :hosts, :polymorphic => true
      t.references :users, :polymorphic => true
    end
  end

  def down
    drop_table :host_acls
  end
end
