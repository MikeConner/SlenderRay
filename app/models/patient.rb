# == Schema Information
#
# Table name: patients
#
#  id         :integer         not null, primary key
#  id_key     :string(40)      not null
#  name       :string(40)
#  created_at :datetime        not null
#  updated_at :datetime        not null
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
  
  attr_accessible :id_key, :name
  
  has_many :testimonials, :dependent => :destroy
  has_many :treatment_plans, :dependent => :restrict
  
  validates :id_key, :presence => true,
                     :length => { maximum: MAX_ID_LEN }
  validates :name, :length => { maximum: MAX_ID_LEN }
  
  def display_name
    self.name.blank? ? self.id_key : self.name
  end
end
