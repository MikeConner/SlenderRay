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
#

# CHARTER
#  Represent a single measurement from a treatment session
#
# USAGE
#
# NOTES AND WARNINGS
#
class Measurement < ActiveRecord::Base
  MAX_LOCATION_LEN = 16
  
  attr_accessible :location, :circumference,
                  :treatment_session_id
  
  belongs_to :treatment_session
  
  validates :location, :presence => true,
                       :length => { maximum: MAX_LOCATION_LEN }
  validates :circumference, :presence => true,
                            :numericality => { greater_than: 0 }
end
