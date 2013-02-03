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
#  protocol_id       :integer
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
                  :machine_id, :protocol_id, :measurements_attributes
  
  mount_uploader :patient_image, PatientImageUploader

  belongs_to :treatment_plan
  belongs_to :machine
  belongs_to :protocol
  
  has_one :process_timer, :as => :process, :dependent => :nullify
  has_many :measurements, :dependent => :destroy

  accepts_nested_attributes_for :measurements, :allow_destroy => true, :reject_if => :all_blank
  
  validates_presence_of :treatment_plan_id
  validates_presence_of :machine_id
  validate :navel_measurement
  
  validates_associated :measurements
  
  def complete?
    ProcessTimer::COMPLETED == self.process_timer.process_state
  end
  
  # return set of labels used (or [])
  def labels
    label_set = Hash.new
    measurements.each do |m|
      if !m.label.nil?
        label_set[m.label] = 1
      end
    end
    
    label_set.keys.sort
  end
  
  def labeled_measurements(label)
    measurements.where('label = ?', label)
  end

private
  # If there are measurements, one has to be the navel
  def navel_measurement
    if !self.measurements.empty?
      self.measurements.each do |m|
        if m.location.downcase.strip =~ /navel/
          return
        end
      end
      
      # If we get here, it wasn't found
      self.errors.add :base, 'Navel measurement required'
    end
  end  
end
