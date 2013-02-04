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
  
  def current_treatment_plan
    if in_treatment?
      self.treatment_plans.each do |plan|
        if !plan.complete?
          return plan
        end
      end
    end
    
    nil
  end
  
  # Are there any incomplete treatment plans?
  def in_treatment?
    if self.treatment_plans.empty?
      false
    else
      self.treatment_plans.each do |plan|
        if !plan.complete?
          return true
        end
      end
    end
    
    false
  end
end
