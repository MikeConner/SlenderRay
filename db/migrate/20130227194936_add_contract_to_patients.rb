class AddContractToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :contract_file, :string
  end
end
