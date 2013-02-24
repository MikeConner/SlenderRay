class AddTimeZoneToUsers < ActiveRecord::Migration
  def change
    add_column :users, :time_zone, :string, :limit => User::MAX_TIMEZONE_LEN, :default => SlenderRay::Application.config.time_zone
  end
end
