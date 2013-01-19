class CreateMeasurements < ActiveRecord::Migration
  def change
    create_table :measurements do |t|
      t.string :location, :limit => Measurement::MAX_LOCATION_LEN, :null => false
      t.decimal :circumference, :null => false
      
      t.references :treatment_session
      
      t.timestamps
    end
  end
end
