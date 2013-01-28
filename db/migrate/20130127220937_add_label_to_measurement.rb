class AddLabelToMeasurement < ActiveRecord::Migration
  def change
    add_column :measurements, :label, :string, :limit => Measurement::MAX_LABEL_LEN
  end
end
