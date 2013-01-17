class CreateTreatmentPlans < ActiveRecord::Migration
  def change
    create_table :treatment_plans do |t|
      t.references :patient
      t.integer :num_sessions, :null => false
      t.integer :treatments_per_session, :null => false
      t.text :description, :null => false
      
      t.timestamps
    end
  end
end
