class RemoveIdKeyFromPatient < ActiveRecord::Migration
  def up
    remove_column :patients, :id_key
  end

  def down
    add_column :patients, :id_key, :string, :limit => Patient::MAX_ID_LEN
  end
end
