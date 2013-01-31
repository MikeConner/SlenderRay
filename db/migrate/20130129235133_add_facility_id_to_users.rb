class AddFacilityIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :treatment_facility_id, :integer
  end
end
