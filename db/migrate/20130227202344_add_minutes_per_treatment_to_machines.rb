class AddMinutesPerTreatmentToMachines < ActiveRecord::Migration
  def up
    add_index :machines, [:treatment_facility_id, :display_name], :unique => true, :name => 'unique_by_facility'    
    add_column :machines, :minutes_per_treatment, :integer, :null => false, :default => Machine::DEFAULT_MINUTES_PER_SESSION
  end
  
  def down
    remove_index :machines, [:treatment_facility_id, :display_name]
    remove_column :machines, :minutes_per_treatment
  end
end
