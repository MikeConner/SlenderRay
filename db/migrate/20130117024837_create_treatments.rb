class CreateTreatments < ActiveRecord::Migration
  def change
    create_table :treatments do |t|
      t.references :treatment_plan
      t.references :protocol
      t.string :patient_image
      t.text :notes
      
      t.timestamps
    end
  end
end
