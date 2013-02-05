# == Schema Information
#
# Table name: patients
#
#  id                    :integer         not null, primary key
#  name                  :string(40)
#  created_at            :datetime        not null
#  updated_at            :datetime        not null
#  treatment_facility_id :integer
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
  
  attr_accessible :name,
                  :treatment_facility_id, :treatment_plans_attributes
                  
  belongs_to :treatment_facility
  
  has_many :testimonials, :dependent => :destroy
  has_many :treatment_plans, :dependent => :restrict
  
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
end
