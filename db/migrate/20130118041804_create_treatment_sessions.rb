class CreateTreatmentSessions < ActiveRecord::Migration
  def change
    create_table :treatment_sessions do |t|
      t.references :treatment_plan
      t.string :patient_image
      t.text :notes
      
      t.timestamps
    end
  end
end
