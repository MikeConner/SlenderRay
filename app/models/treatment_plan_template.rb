# == Schema Information
#
# Table name: treatment_plan_templates
#
#  id                     :integer         not null, primary key
#  patient_id             :integer
#  num_sessions           :integer         not null
#  treatments_per_session :integer         not null
#  description            :text            not null
#  price                  :decimal(, )
#  type                   :string(255)
#  created_at             :datetime        not null
#  updated_at             :datetime        not null
#  treatment_facility_id  :integer
#

# CHARTER
#  Represent a "package" patients can purchase, consisting of sessions and treatments
#
# USAGE
#   Use STI, since facility setup will create a set of treatment plan templates (catalog of products)
# These are then instantiated as treatment plans tied to individual users. Note this means you could
# possibly modify parts of it for individual patients (e.g., give somebody a discount so the price is different)
#
# NOTES AND WARNINGS
#
class TreatmentPlanTemplate < ActiveRecord::Base
  attr_accessible :description, :num_sessions, :treatments_per_session, :price, :type,
                  :treatment_facility_id
  
  belongs_to :treatment_facility
  # Necessary to support has_many :through associations through STI on treatment_plans (e.g., in Patient)
  has_many :treatment_sessions, :foreign_key => 'treatment_plan_id', :dependent => :restrict
  
  validates_presence_of :description
  validates :num_sessions, :presence => true,
                           :numericality => { only_integer: true, greater_than: 0 }
  validates :treatments_per_session, :presence => true,
                                     :numericality => { only_integer: true, greater_than: 0 }
  validates :price, :numericality => { greater_than_or_equal_to: 0 }, :allow_nil => true
  
  validates_presence_of :type
end

class TreatmentPlan < TreatmentPlanTemplate
  attr_accessible :patient_id, :treatment_sessions_attributes
  
  belongs_to :patient
  has_many :treatment_sessions, :dependent => :restrict

  accepts_nested_attributes_for :treatment_sessions, :allow_destroy => true, :reject_if => :all_blank
  
  validates_associated :treatment_sessions
  
  # Passed in options will override the template values (e.g., you can create a plan with an extra session or special price)
  def self.create_from_template(t, patient, options = {})
    TreatmentPlan.create({:patient_id => patient.id, :description => t.description, :num_sessions => t.num_sessions,
                          :treatment_facility_id => t.treatment_facility.id, 
                          :treatments_per_session => t.treatments_per_session, :price => t.price}.merge(options))
  end
  
  def date_completed
    complete? ? self.treatment_sessions.order('updated_at desc').first.updated_at : nil
  end
  
  def pct_complete
    (self.treatment_sessions.count.to_f / self.num_sessions.to_int  * 100)
  end
  
  def complete?
    if self.num_sessions == self.treatment_sessions.count
      self.treatment_sessions.order('updated_at desc').each do |session|
        if !session.complete?
          return false
        end
      end
      
      true
    else
      false
    end
  end
  
  # Detect first/last to validate measurements
  def first_session?(session)
    !session.nil? and (self.treatment_sessions.first == session)
  end
  
  # Detect first/last to validate measurements
  def last_session?(session)
    !session.nil? and (self.treatment_sessions.last == session) and (self.num_sessions == self.treatment_sessions.count)    
  end
end
