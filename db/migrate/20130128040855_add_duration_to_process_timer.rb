class AddDurationToProcessTimer < ActiveRecord::Migration
  def change
    add_column :process_timers, :duration_seconds, :integer
    rename_column :process_timers, :elapsed_time, :elapsed_seconds
  end
end
