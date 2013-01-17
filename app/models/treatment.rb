# == Schema Information
#
# Table name: treatments
#
#  id                :integer         not null, primary key
#  treatment_plan_id :integer
#  protocol_id       :integer
#  patient_image     :string(255)
#  notes             :text
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#

class Treatment < ActiveRecord::Base
  attr_accessible :notes
  
  mount_uploader :patient_image, PatientImageUploader

  belongs_to :treatment_plan
  belongs_to :protocol

  has_many :measurements, :dependent => :destroy
  
  validates_presence_of :treatment_plan_id
  validates_presence_of :protocol_id
end
