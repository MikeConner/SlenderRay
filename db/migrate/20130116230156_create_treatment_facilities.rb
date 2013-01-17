class CreateTreatmentFacilities < ActiveRecord::Migration
  def change
    create_table :treatment_facilities do |t|
      t.string :facility_name, :limit => ApplicationHelper::MAX_ADDRESS_LEN, :null => false
      t.string :facility_url
      t.string :first_name, :limit => ApplicationHelper::MAX_FIRST_NAME_LEN
      t.string :last_name, :limit => ApplicationHelper::MAX_LAST_NAME_LEN
      t.string :email, :null => false
      t.string :phone, :limit => ApplicationHelper::MAX_PHONE_LEN
      t.string :fax, :limit => ApplicationHelper::MAX_PHONE_LEN
      t.string :address_1, :limit => ApplicationHelper::MAX_ADDRESS_LEN
      t.string :address_2, :limit => ApplicationHelper::MAX_ADDRESS_LEN
      t.string :city, :limit => ApplicationHelper::MAX_ADDRESS_LEN
      t.string :state, :limit => ApplicationHelper::MAX_STATE_LEN
      t.string :zipcode, :limit => ApplicationHelper::MAX_ZIPCODE_LEN

      t.timestamps
    end
    
    add_index :treatment_facilities, :facility_name, :unique => true
    add_index :treatment_facilities, :email, :unique => true
  end
end
