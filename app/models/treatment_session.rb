# == Schema Information
#
# Table name: treatment_sessions
#
#  id                :integer         not null, primary key
#  treatment_plan_id :integer
#  patient_image     :string(255)
#  notes             :text
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  machine_id        :integer
#

# CHARTER
#  Represent an office visit associated with a treatment plan
#
# USAGE
#
# NOTES AND WARNINGS
#
class TreatmentSession < ActiveRecord::Base
  attr_accessible :notes, :patient_image, :remote_patient_image_url,
                  :machine_id
  
  mount_uploader :patient_image, PatientImageUploader

  belongs_to :treatment_plan
  belongs_to :machine
  
  has_many :measurements, :dependent => :destroy
  has_many :treatments, :dependent => :destroy
  
  validates_presence_of :treatment_plan_id
  validates_presence_of :machine_id
  
  def labeled_measurements(label)
    measurements.where('label = ?', label)
  end  
end
