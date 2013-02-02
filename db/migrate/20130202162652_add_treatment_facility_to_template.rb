class AddTreatmentFacilityToTemplate < ActiveRecord::Migration
  def change
    add_column :treatment_plan_templates, :treatment_facility_id, :integer
  end
end
