# == Schema Information
#
# Table name: machines
#
#  id                    :integer         not null, primary key
#  model                 :string(64)      not null
#  serial_number         :string(64)      not null
#  date_installed        :date
#  treatment_facility_id :integer
#  created_at            :datetime        not null
#  updated_at            :datetime        not null
#  display_name          :string(64)      default(""), not null
#

# CHARTER
#  Represent a single installed machine, on which users can run treatments
#
# USAGE
#   Each facility can have multiple machines
#
# NOTES AND WARNINGS
#
class Machine < ActiveRecord::Base
  MAX_FIELD_LEN = 64
  
  attr_accessible :model, :serial_number, :display_name, :date_installed,
                  :treatment_facility_id
  
  belongs_to :treatment_facility
  has_many :treatment_sessions, :dependent => :restrict
  
  validates :model, :presence => true,
                    :length => { maximum: MAX_FIELD_LEN }
  validates :serial_number, :presence => true,
                            :length => { maximum: MAX_FIELD_LEN }
  validates_presence_of :date_installed
  validates_presence_of :treatment_facility_id
  validates :display_name, :presence => true,
                           :length => { maximum: MAX_FIELD_LEN }
end
