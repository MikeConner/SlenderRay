# == Schema Information
#
# Table name: protocols
#
#  id            :integer         not null, primary key
#  frequency     :integer         not null
#  name          :string(32)
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#  protocol_file :string(255)
#

# CHARTER
#  Represent a SlenderRay treatment protocol
#
# USAGE
#  Just a display name and frequency in Hz
#
# NOTES AND WARNINGS
#   Sample values are in the db/seeds file
#
class Protocol < ActiveRecord::Base
  MAX_NAME_LEN = 32
  
  attr_accessible :name, :frequency, :protocol_file, :remote_protocol_file_url
  
  mount_uploader :protocol_file, ProtocolUploader
  
  validates :name, :length => { maximum: MAX_NAME_LEN }
  validates :frequency, :presence => true,
                        :numericality => { only_integer: true, greater_than: 0 }
                        
  def display_name
    self.name.blank? ? "Protocol #{self.id}" : "#{self.id}) #{self.name}"
  end
end
