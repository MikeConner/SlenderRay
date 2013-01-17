# == Schema Information
#
# Table name: protocols
#
#  id         :integer         not null, primary key
#  frequency  :integer         not null
#  name       :string(32)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Protocol < ActiveRecord::Base
  MAX_NAME_LEN = 32
  
  attr_accessible :name, :frequency
  
  validates :name, :length => { maximum: MAX_NAME_LEN }
  validates :frequency, :presence => true,
                        :numericality => { only_integer: true, greater_than: 0 }
                        
  def display_name
    self.name.blank? ? "Protocol #{self.id}" : "#{self.id}) #{self.name}"
  end
end
