# == Schema Information
#
# Table name: treatment_areas
#
#  id                    :integer         not null, primary key
#  area_name             :string(64)      not null
#  process_name          :string(64)
#  treatment_facility_id :integer
#  created_at            :datetime        not null
#  updated_at            :datetime        not null
#

# CHARTER
#  Represent an area within a treatment facility where timed services are performed
#
# USAGE
#  Technicians can create these at each facility. There is an area name (e.g., Room 1), and an optional process name, for max flexibility.
#  If they have a dedicated "massage room," that could create one called that and leave the process name blank.
#  If they have a large room with three tables on which they do different things, they could set the area name to "Room 1"
#  for all, and use individual process names. The process names should be editable dynamically, in case they use the
#  same area for different things.
#
# NOTES AND WARNINGS
#
#
class TreatmentArea < ActiveRecord::Base
  MAX_FIELD_LEN = 64
  
  attr_accessible :area_name, :process_name, :duration_minutes,
                  :treatment_facility_id
  
  belongs_to :treatment_facility
  has_one :process_timer, :as => :process, :dependent => :destroy
  
  validates :area_name, :presence => true,
                        :length => { maximum: MAX_FIELD_LEN }
  validates :process_name, :length => { maximum: MAX_FIELD_LEN }
  validates :duration_minutes, :presence => true,
                               :numericality => { only_integer: true, greater_than: 0 }
end
