# == Schema Information
#
# Table name: measurements
#
#  id            :integer         not null, primary key
#  location      :string(16)      not null
#  circumference :decimal(, )     not null
#  treatment_id  :integer
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#

class Measurement < ActiveRecord::Base
  MAX_LOCATION_LEN = 16
  
  attr_accessible :location, :circumference
  
  belongs_to :treatment
  
  validates :location, :presence => true,
                       :length => { maximum: MAX_LOCATION_LEN }
  validates :circumference, :presence => true,
                            :numericality => { greater_than: 0 }
end
