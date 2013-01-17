class CreatePatients < ActiveRecord::Migration
  def change
    create_table :patients do |t|
      t.string :id_key, :limit => Patient::MAX_ID_LEN, :null => false
      t.string :name, :limit => Patient::MAX_ID_LEN
      
      t.timestamps
    end
  end
end
