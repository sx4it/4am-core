class RenameMachineTplIdToHostTplId < ActiveRecord::Migration
  def up
    change_table :hosts do |t|
      t.rename :machine_tpl_id, :host_tpl_id
    end
  end

  def down
    change_table :hosts do |t|
      t.rename :host_tpl_id, :machine_tpl_id
    end
  end
end
