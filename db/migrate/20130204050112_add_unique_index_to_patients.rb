class AddUniqueIndexToPatients < ActiveRecord::Migration
  def change
    add_index :patients, [:treatment_facility_id, :name], :unique => true
  end
end
