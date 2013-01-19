class CreateTreatmentPlans < ActiveRecord::Migration
  def change
    create_table :treatment_plan_templates do |t|
      t.references :patient
      t.integer :num_sessions, :null => false
      t.integer :treatments_per_session, :null => false
      t.text :description, :null => false
      t.decimal :price
      t.string :type
      
      t.timestamps
    end
  end
end
