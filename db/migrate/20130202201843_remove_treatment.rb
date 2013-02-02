class RemoveTreatment < ActiveRecord::Migration
  def up
    drop_table :treatments
    add_column :treatment_sessions, :protocol_id, :integer
  end

  def down
    create_table :treatments do |t|
      t.references :treatment_session
      t.references :protocol
      t.integer :duration
      
      t.timestamps
    end
    remove_column :treatment_sessions, :protocol_id
  end
end
