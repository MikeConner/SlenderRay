# == Schema Information
#
# Table name: treatments
#
#  id                   :integer         not null, primary key
#  protocol_id          :integer
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#  duration             :integer
#  treatment_session_id :integer
#

# CHARTER
#  Represent a single treatment (e.g., 8-minute SlenderRay session), associated with a particular session (office visit)
#
# USAGE
#
# NOTES AND WARNINGS
#
class Treatment < ActiveRecord::Base
  attr_accessible :duration_minutes,
                  :protocol_id, :treatment_session_id
  
  belongs_to :protocol
  belongs_to :treatment_session
  has_one :process_timer, :as => :process, :dependent => :nullify
  
  validates :duration_minutes, :presence => true,
                               :numericality => { only_integer: true, greater_than: 0 }
  validates_presence_of :protocol_id  
  validates_presence_of :treatment_session_id  
  
  def complete?
    ProcessTimer::COMPLETED == self.process_timer.process_state
  end
end
