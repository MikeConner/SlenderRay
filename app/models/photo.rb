# == Schema Information
#
# Table name: photos
#
#  id                    :integer         not null, primary key
#  title                 :string(64)
#  caption               :string(255)
#  facility_image        :string(255)
#  treatment_facility_id :integer
#  created_at            :datetime        not null
#  updated_at            :datetime        not null
#

class Photo < ActiveRecord::Base
  MAX_TITLE_LEN = 64
  
  attr_accessible :title, :caption, :facility_image, :remote_facility_image_url,
                  :treatment_facility_id
  
  belongs_to :treatment_facility
  
  mount_uploader :facility_image, PatientImageUploader
  
  validates :title, :presence => true,
                    :length => { maximum: MAX_TITLE_LEN }
  validates_presence_of :facility_image
  validates_presence_of :treatment_facility_id
end
