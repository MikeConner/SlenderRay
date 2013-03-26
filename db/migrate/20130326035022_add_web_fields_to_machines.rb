class AddWebFieldsToMachines < ActiveRecord::Migration
  def change
    add_column :machines, :hostname, :string, :limit => Machine::MAX_HOSTNAME_LEN
    add_column :machines, :web_enabled, :boolean, :null => false, :default => false
    add_column :machines, :license_active, :boolean, :null => false, :default => true
  end
end
