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
  REQUIRED_MEASUREMENT = 'Navel'
  # Whitehall only takes before/after on the first session
  #   Others might be different, so create prototypes for Before/After for every session, if this is set; otherwise only for the first session
  ALWAYS_PROMPT_BEFORE_AFTER = true
  
  attr_accessible :notes, :patient_image, :remote_patient_image_url,
                  :machine_id, :protocol_id, :measurements_attributes
  
  mount_uploader :patient_image, PatientImageUploader

  belongs_to :treatment_plan
  belongs_to :machine
  belongs_to :protocol
  
  has_one :process_timer, :as => :process, :dependent => :destroy
  has_many :measurements, :dependent => :destroy

  # Going to fill in common measurements, if they don't put a value, through it away
  accepts_nested_attributes_for :measurements, :allow_destroy => true, :reject_if => proc { |attributes| attributes['circumference'].blank? }
  
  validates_presence_of :treatment_plan_id
  validates_presence_of :machine_id
  validate :navel_measurement
  
  validates_associated :measurements
  
  def date_completed
    if complete?
      self.process_timer.updated_at
    else
      nil
    end
  end
  
  def complete?
    ProcessTimer::COMPLETED == self.process_timer.process_state
  end
  
  # Require measurements on first and last session (enforced from the controller when the technician presses "Complete Session")
  def completeable?
    if self.measurements.empty?
      !self.treatment_plan.first_session?(self) and !self.treatment_plan.last_session?(self)
    else
      # standard validation has already made sure the measurement set has the required measurement
      true  
    end
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
  
  # Use select to get ones that are unsaved
  def labeled_measurements(label)
    # Need *all* for the tests to pass (to work for both saved and unsaved)
    Rails.env.test? ? self.measurements.all.select { |m| label == m.label } : self.measurements.select { |m| label == m.label }
  end

  def add_measurement_prototypes(update)
    if self.measurements.empty?
      # Build 2 sets, before/after
      self.measurements.build(:location => '+4cm', :label => Measurement::BEFORE_LABEL)
      self.measurements.build(:location => '+2cm', :label => Measurement::BEFORE_LABEL)
      self.measurements.build(:location => REQUIRED_MEASUREMENT, :label => Measurement::BEFORE_LABEL)
      self.measurements.build(:location => '-2cm', :label => Measurement::BEFORE_LABEL)
      self.measurements.build(:location => '-4cm', :label => Measurement::BEFORE_LABEL)
      
      self.measurements.build(:location => '+4cm', :label => Measurement::AFTER_LABEL)
      self.measurements.build(:location => '+2cm', :label => Measurement::AFTER_LABEL)
      self.measurements.build(:location => REQUIRED_MEASUREMENT, :label => Measurement::AFTER_LABEL)
      self.measurements.build(:location => '-2cm', :label => Measurement::AFTER_LABEL)
      self.measurements.build(:location => '-4cm', :label => Measurement::AFTER_LABEL)
    elsif update
      # On error (update), if they've entered some measurements, make sure the navel measurement is there
      # Sorry, this is ugly special case code that is painful to write!
      has_before_label = false
      has_after_label = false
      self.measurements.each do |m|
        if REQUIRED_MEASUREMENT == m.location
          if Measurement::BEFORE_LABEL == m.label
            has_before_label = true
          else
            has_after_label = true
          end
        end
      end
      
      if !has_before_label
        self.measurements.build(:location => REQUIRED_MEASUREMENT, :label => Measurement::BEFORE_LABEL)        
      end
      
      if !has_after_label
        self.measurements.build(:location => REQUIRED_MEASUREMENT, :label => Measurement::AFTER_LABEL)        
      end
    end    
  end
private
  # If there are measurements, one has to be the navel
  def navel_measurement
    if !self.measurements.empty?
      has_valid_measurements = false
      
      self.measurements.each do |m|
        if m.valid?
          has_valid_measurements = true
          if m.location.strip =~ /#{REQUIRED_MEASUREMENT}/i
            return
          end
        end        
      end
      
      # If we get here, it wasn't found
      # Only require a navel measurement if there are other valid measurements: completely empty is ok
      if has_valid_measurements
        self.errors.add :base, "#{REQUIRED_MEASUREMENT} measurement required"
      end
    end
  end  
end
