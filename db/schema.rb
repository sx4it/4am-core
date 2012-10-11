# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121009213630) do

  create_table "activities", :force => true do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "key"
    t.text     "parameters"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "commands", :force => true do |t|
    t.string   "name"
    t.string   "command"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "host_acls", :force => true do |t|
    t.integer "hosts_id"
    t.string  "hosts_type"
    t.integer "users_id"
    t.string  "users_type"
    t.string  "acl_type"
  end

  create_table "host_groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "host_groups_hosts", :id => false, :force => true do |t|
    t.integer "host_id"
    t.integer "host_group_id"
  end

  create_table "host_tpls", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "hosts", :force => true do |t|
    t.string   "name"
    t.string   "ip"
    t.integer  "host_tpl_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "port"
  end

  create_table "keys", :force => true do |t|
    t.string   "name"
    t.binary   "value"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "keytype"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "roles_users", :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "user_groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "user_groups_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "user_group_id"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.string   "single_access_token"
    t.string   "perishable_token"
    t.integer  "failed_login_count"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
  end

end
