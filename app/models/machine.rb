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
#  minutes_per_treatment :integer         default(8), not null
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
  DEFAULT_MINUTES_PER_SESSION = 8
  
  attr_accessible :model, :serial_number, :display_name, :date_installed, :minutes_per_treatment,
                  :treatment_facility_id, :user_ids
  
  belongs_to :treatment_facility
  has_and_belongs_to_many :users
  has_many :treatment_sessions, :dependent => :restrict
  
  validates :model, :presence => true,
                    :length => { maximum: MAX_FIELD_LEN }
  validates :serial_number, :presence => true,
                            :length => { maximum: MAX_FIELD_LEN }
  validates_presence_of :date_installed
  validates_presence_of :treatment_facility_id
  validates :display_name, :presence => true,
                           :length => { maximum: MAX_FIELD_LEN }
  validates :minutes_per_treatment, :presence => true,
                                    :numericality => { only_integer: true, greater_than: 0 }
end
