# == Schema Information
#
# Table name: patients
#
#  id                    :integer         not null, primary key
#  name                  :string(40)
#  created_at            :datetime        not null
#  updated_at            :datetime        not null
#  treatment_facility_id :integer
#  contract_file         :string(255)
#

# CHARTER
#  Represent patient undergoing Slender Ray treatment
#
# USAGE
#  Patient name can be something descriptive; not necessarily the patient's full name. If not given, display the ID
#
# NOTES AND WARNINGS
#   Do not store any sensitive information subject to HIPAA! Just store a key to the facilties HIPAA records
#
class Patient < ActiveRecord::Base
  MAX_ID_LEN = 40
  
  attr_accessible :name, :contract_file, :remote_contract_file_url,
                  :treatment_facility_id, :treatment_plans_attributes

  mount_uploader :contract_file, ContractUploader
                  
  belongs_to :treatment_facility
  
  has_many :testimonials, :dependent => :destroy
  # Where do I start? :-)
  # We have a has_many pointing "into" an STI hierarchy. TreatmentPlan < TreatmentPlanTemplate < ActiveRecord::Base
  # Apparently the filename has to match the DB table name, but then calling treatment_plans looks for a TreatmentPlan table, which
  #   doesn't exist (the table is TreatmentPlanTemplate). So we have to tell it the class_name of what we're actually storing, and
  #   just to be safe, make it conditional to make sure we don't store any templates here. (Code should prevent it anyway.)
  has_many :treatment_plans, :class_name => 'TreatmentPlanTemplate', :conditions => { :type => ['TreatmentPlan'] }, :dependent => :restrict
  has_many :treatment_sessions, :through => :treatment_plans
  
  accepts_nested_attributes_for :treatment_plans, :allow_destroy => true, :reject_if => :all_blank

  validates :name, :presence => true,
                   :length => { maximum: MAX_ID_LEN }
  validates_presence_of :treatment_facility_id
  
  validates_associated :treatment_plans
  
  # Return the currently active plan, or nil
  def unfinished_plan
    self.treatment_plans.each do |plan|
      if !plan.complete?
        return plan
      end
    end
    
    nil    
  end
  
  # Return the currently active session, or nil
  def unfinished_session
    plan = unfinished_plan
    if !plan.nil?
      plan.treatment_sessions.each do |session|
        if !session.complete?
          return session
        end      
      end
    end
    
    nil
  end
  
  # You can edit measurements/notes on a completed session if it's the same day
  def editable_session
    if !treatment_sessions.empty?
      # Efficiently find last completed session
      treatment_sessions.reverse.each do |session|
        if session.complete?
          if session.updated_at.beginning_of_day == Time.zone.now.beginning_of_day
            return session
          else
            break
          end
        end
      end
    end
    
    nil
  end
  
  # If there's just the original plan with no sessions (initial state), it can be deleted,
  #  by deleting the plan first, then the patient
  def can_be_deleted?
    # It's created with a treatment plan, so it should never be zero
    if 0 == self.treatment_plans.count
      true
    elsif 1 == self.treatment_plans.count
      0 == self.treatment_plans.first.treatment_sessions.count
    else
      false
    end
  end
end
