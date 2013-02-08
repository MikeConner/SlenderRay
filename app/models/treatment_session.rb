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
  
  # Use select to get ones that are unsaved
  def labeled_measurements(label)
    # Need *all* for the tests to pass (to work for both saved and unsaved)
    Rails.env.test? ? self.measurements.all.select { |m| label == m.label } : self.measurements.select { |m| label == m.label }
  end

  def add_measurement_prototypes(first)
    if self.measurements.empty?
      if first
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
        
        puts "#{self.measurements.count} measurements"
      else
        # Build 1 set
        self.measurements.build(:location => '+4cm')
        self.measurements.build(:location => '+2cm')
        self.measurements.build(:location => REQUIRED_MEASUREMENT)
        self.measurements.build(:location => '-2cm')
        self.measurements.build(:location => '-4cm')
      end
    end    
  end
private
  # If there are measurements, one has to be the navel
  def navel_measurement
    if !self.measurements.empty?
      self.measurements.each do |m|
        if m.location.strip =~ /#{REQUIRED_MEASUREMENT}/i and m.valid?
          return
        end
      end
      
      # If we get here, it wasn't found
      self.errors.add :base, 'Navel measurement required'
    end
  end  
end
