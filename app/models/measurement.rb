# == Schema Information
#
# Table name: measurements
#
#  id                   :integer         not null, primary key
#  location             :string(16)      not null
#  circumference        :decimal(, )     not null
#  treatment_session_id :integer
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#  label                :string(16)
#

# CHARTER
#  Represent a single measurement from a treatment session
#
# USAGE
#  It is possible for technicians to make two sets of measurements in one session (e.g., "Before" and "After").
#  This is common in the first session. Rather than introduce a "measurement set", handle this by labeling each
#  measurement. Measurements can then be grouped by unique tags.
#
# NOTES AND WARNINGS
#
class Measurement < ActiveRecord::Base
  MAX_LOCATION_LEN = 16
  MAX_LABEL_LEN = 16
  
  attr_accessible :location, :circumference, :label,
                  :treatment_session_id
  
  belongs_to :treatment_session
  
  validates :location, :presence => true,
                       :length => { maximum: MAX_LOCATION_LEN }
  validates :circumference, :presence => true,
                            :numericality => { greater_than: 0 }
  validates :label, :length => { maximum: MAX_LABEL_LEN }
end
