class AddScheduleLinkToTreatmentFacilities < ActiveRecord::Migration
  def change
    add_column :treatment_facilities, :schedule_url, :string
  end
end
