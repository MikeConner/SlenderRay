class AddUniqueDisplayNames < ActiveRecord::Migration
  def change
    add_index :machines, [:treatment_facility_id, :display_name], :unique => true
    add_index :treatment_areas, [:treatment_facility_id, :area_name], :unique => true
  end
end
