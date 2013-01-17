# == Schema Information
#
# Table name: testimonials
#
#  id           :integer         not null, primary key
#  comment      :text            not null
#  date_entered :date
#  displayable  :boolean         default(TRUE)
#  patient_id   :integer
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

class Testimonial < ActiveRecord::Base
  attr_accessible :comment, :date_entered, :displayable,
                  :patient_id
                  
  belongs_to :patient
  
  validates_presence_of :comment
  validates_inclusion_of :displayable, :in => [true, false]
  
  validates_presence_of :patient_id
  
  def display_date
    self.date_entered.nil? ? self.updated_at : self.date_entered
  end
end
