class CreateProtocols < ActiveRecord::Migration
  def change
    create_table :protocols do |t|
      t.integer :frequency, :null => false
      t.string :name, :limit => Protocol::MAX_NAME_LEN
      
      t.timestamps
    end
  end
end
