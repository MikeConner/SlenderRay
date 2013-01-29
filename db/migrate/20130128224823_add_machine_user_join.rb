class AddMachineUserJoin < ActiveRecord::Migration
  def change
    create_table :machines_users, :id => false do |t|
      t.references :machine, :user
    end
    
    add_index :machines_users, [:machine_id, :user_id], :unique => true
  end
end
