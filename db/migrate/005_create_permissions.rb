

class CreatePermissions < ActiveRecord::Migration

  def self.up
    create_table :permissions do |t|
      t.integer :role_id, :user_id, :null => false
      t.timestamps
    end

    add_index :permissions, :user_id

    Role.create(:rolename => 'administrator')
    user = User.new
    user.login = 'admin'
    user.email = 'admin@domain.tld'
    user.password = 'admin'
    user.password_confirmation = 'admin'
    user.save(false)
    user.send(:activate!)
    role = Role.find_by_rolename('administrator')
    user = User.find_by_login('admin')
    permission = Permission.new
    permission.role = role
    permission.user = user
    permission.save(false)
  end

  def self.down
    drop_foreign_key(:permissions, :role_id)
    drop_foreign_key(:permissions, :user_id)
    drop_table :permissions
    Role.find_by_rolename('administrator').destroy   
    User.find_by_login('admin').destroy   
  end
end