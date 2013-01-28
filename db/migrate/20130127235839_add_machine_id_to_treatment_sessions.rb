class AddMachineIdToTreatmentSessions < ActiveRecord::Migration
  def change
    add_column :treatment_sessions, :machine_id, :integer
  end
end
