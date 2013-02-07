class AddProcessDurationToTreatmentArea < ActiveRecord::Migration
  def change
    add_column :treatment_areas, :duration_minutes, :integer
  end
end
