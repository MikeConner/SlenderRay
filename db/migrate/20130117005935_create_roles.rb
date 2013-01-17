class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name, :limit => Role::MAX_ROLE_LEN, :null => false
      
      t.timestamps
    end
    
    add_index :roles, :name, :unique => true
  end
end
