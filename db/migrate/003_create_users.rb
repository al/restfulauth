

class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|
      t.string :login, :email, :null => false
      t.string :crypted_password, :salt, :activation_code, :null => false, :limit => 40
      t.string :password_reset_code, :remember_token, :limit => 40
      t.timestamps
      t.datetime :remember_token_expires_at, :activated_at
      t.boolean :enabled, :default => true
    end

    add_index :users, :login
    add_index :users, :email
  end

  def self.down
    drop_table :users
  end
end