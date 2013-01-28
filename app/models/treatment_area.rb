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

class TreatmentArea < ActiveRecord::Base
  MAX_FIELD_LEN = 64
  
  attr_accessible :area_name, :process_name
  
  belongs_to :treatment_facility
  has_one :process_timer, :as => :process, :dependent => :nullify
  
  validates :area_name, :presence => true,
                        :length => { maximum: MAX_FIELD_LEN }
  validates :process_name, :length => { maximum: MAX_FIELD_LEN }
end
