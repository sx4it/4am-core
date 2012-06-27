class UserToHostLogic < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.string    :email
      t.string    :crypted_password
      t.string    :password_salt
      t.string    :persistence_token
      t.string    :single_access_token
      t.string    :perishable_token
      t.integer   :failed_login_count
      t.string    :current_login_ip
      t.string    :last_login_ip
      t.remove    :pass
      t.remove    :password_digest
    end
  end

  def down
    change_table :users do |t|
      t.remove   :email
      t.remove   :crypted_password
      t.remove   :password_salt
      t.remove   :persistence_token
      t.remove   :single_access_token
      t.remove   :perishable_token
      t.remove   :failed_login_count
      t.remove   :current_login_ip
      t.remove   :last_login_ip
      t.string   :pass
      t.string   :password_digest
    end
  end
end
