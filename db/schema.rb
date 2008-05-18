# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 5) do

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permissions", :force => true do |t|
    t.integer  "role_id",    :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "permissions", ["user_id"], :name => "index_permissions_on_user_id"

  create_table "roles", :force => true do |t|
    t.string   "rolename"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "login",                                                     :null => false
    t.string   "email",                                                     :null => false
    t.string   "crypted_password",          :limit => 40,                   :null => false
    t.string   "salt",                      :limit => 40,                   :null => false
    t.string   "activation_code",           :limit => 40,                   :null => false
    t.string   "password_reset_code",       :limit => 40
    t.string   "remember_token",            :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "remember_token_expires_at"
    t.datetime "activated_at"
    t.boolean  "enabled",                                 :default => true
  end

  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["email"], :name => "index_users_on_email"

end
