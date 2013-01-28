class CreateProcessTimers < ActiveRecord::Migration
  def change
    create_table :process_timers do |t|
      t.string :process_state, :null => false, :default => ProcessTimer::IDLE, :limit => ProcessTimer::MAX_STATE_LEN
      t.datetime :start_time
      t.integer :elapsed_time
      t.integer :process_id
      t.string :process_type

      t.timestamps
    end
  end
end
