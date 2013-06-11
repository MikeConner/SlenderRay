class AddContractFileToTreatmentFacilities < ActiveRecord::Migration
  def change
    add_column :treatment_facilities, :contract_file, :string
  end
end
