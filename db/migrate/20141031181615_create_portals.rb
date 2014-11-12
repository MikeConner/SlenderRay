class CreatePortals < ActiveRecord::Migration
  def change
    create_table :portals do |t|
      t.references :machine
      t.string :name
      t.string :rid, :null => false, :limit => 40
      t.string :cik, :null => false, :iimit => 40
      t.string :basic_auth, :null => false, :limit => 40
      t.string :wifi_key, :null => false, :limit => 16
      t.string :mac_address, :null => false, :limit => 16
      
      t.timestamps
    end
  end
end
