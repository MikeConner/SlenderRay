class CreateTreatmentAreas < ActiveRecord::Migration
  def change
    create_table :treatment_areas do |t|
      t.string :area_name, :null => false, :limit => TreatmentArea::MAX_FIELD_LEN
      t.string :process_name, :limit => TreatmentArea::MAX_FIELD_LEN
      t.references :treatment_facility
      
      t.timestamps
    end
  end
end
