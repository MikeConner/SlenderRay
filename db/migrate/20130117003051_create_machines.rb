class CreateMachines < ActiveRecord::Migration
  def change
    create_table :machines do |t|
      t.string :model, :limit => Machine::MAX_FIELD_LEN, :null => false
      t.string :serial_number, :limit => Machine::MAX_FIELD_LEN, :null => false
      t.date :date_installed
      
      t.references :treatment_facility
      
      t.timestamps
    end
  end
end
