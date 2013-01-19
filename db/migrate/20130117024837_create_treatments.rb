class CreateTreatments < ActiveRecord::Migration
  def change
    create_table :treatments do |t|
      t.references :treatment_session
      t.references :protocol
      t.integer :duration
      
      t.timestamps
    end
  end
end
