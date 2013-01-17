# == Schema Information
#
# Table name: treatment_plans
#
#  id                     :integer         not null, primary key
#  patient_id             :integer
#  num_sessions           :integer         not null
#  treatments_per_session :integer         not null
#  description            :text            not null
#  created_at             :datetime        not null
#  updated_at             :datetime        not null
#

class TreatmentPlan < ActiveRecord::Base
  attr_accessible :description, :num_sessions, :treatments_per_session
  
  belongs_to :patient
  has_many :treatments, :dependent => :restrict
  
  validates_presence_of :description
  validates :num_sessions, :presence => true,
                           :numericality => { only_integer: true, greater_than: 0 }
  validates :treatments_per_session, :presence => true,
                                     :numericality => { only_integer: true, greater_than: 0 }
  validates_presence_of :patient_id
end
