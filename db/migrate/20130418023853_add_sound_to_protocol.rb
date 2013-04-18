class AddSoundToProtocol < ActiveRecord::Migration
  def change
    add_column :protocols, :protocol_file, :string
  end
end
