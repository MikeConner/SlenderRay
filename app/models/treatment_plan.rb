# == Schema Information
#
# Table name: treatment_facilities
#
#  id                      :integer         not null, primary key
#  patient_id              :integer
#  num_sessions            :integer         not null
#  treatments_per_session  :integer         not null
#  description             :text            not null
#  price                   :decimal
#  type                    :string
#  created_at              :datetime        not null
#  updated_at              :datetime        not null
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
  attr_accessible :description, :num_sessions, :treatments_per_session, :price,
                  :treatment_facility_id
  
  belongs_to :treatment_facility
  
  validates_presence_of :description
  validates :num_sessions, :presence => true,
                           :numericality => { only_integer: true, greater_than: 0 }
  validates :treatments_per_session, :presence => true,
                                     :numericality => { only_integer: true, greater_than: 0 }
  validates :price, :numericality => { greater_than_or_equal_to: 0 }, :allow_nil => true
  
  validates_presence_of :type
end

class TreatmentPlan < TreatmentPlanTemplate
  TREATMENT_DURATION_MINUTES = 8
  
  attr_accessible :patient_id
  
  belongs_to :patient
  has_many :treatment_sessions, :dependent => :restrict
  has_many :treatments, :through => :treatment_sessions
  
  # Passed in options will override the template values (e.g., you can create a plan with an extra session or special price)
  def self.create_from_template(t, patient, options = {})
    TreatmentPlan.create({:patient_id => patient.id, :description => t.description, :num_sessions => t.num_sessions,
                         :treatments_per_session => t.treatments_per_session, :price => t.price}.merge(options))
  end
  
  def date_completed
    complete? ? self.treatments.order('updated_at desc').first.updated_at : nil
  end
  
  def pct_complete
    (self.treatments.count / (self.num_sessions * self.treatments_per_session) * 100).round
  end
  
  def complete?
    if self.num_sessions * self.treatments_per_session == self.treatments.count
      self.treatments.order('updated_at desc').each do |treatment|
        if !treatment.complete?
          return false
        end
      end
      
      true
    else
      false
    end
  end
end
