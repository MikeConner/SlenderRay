class AddDisplayNameToMachine < ActiveRecord::Migration
  def change
    add_column :machines, :display_name, :string, :null => false, :default => '', :limit => Machine::MAX_FIELD_LEN
  end
end
