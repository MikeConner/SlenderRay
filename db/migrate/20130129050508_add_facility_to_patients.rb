class AddFacilityToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :treatment_facility_id, :integer
  end
end
