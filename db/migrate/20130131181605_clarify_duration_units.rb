class ClarifyDurationUnits < ActiveRecord::Migration
  def change
    rename_column :treatments, :duration, :duration_minutes
  end
end
