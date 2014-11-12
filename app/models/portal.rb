# CHARTER
#  Represent a BOSS device portal, used to interact programmatically with a Machine
#
# USAGE
#   Admin must assign 
#
# NOTES AND WARNINGS
#
class Portal < ActiveRecord::Base
  API_KEY_LEN = 40
  DEVICE_KEY_LEN = 16
  
  attr_accessible :cik, :name, :rid, :basic_auth, :wifi_key, :mac_address
  
  belongs_to :machine
  
  validates :rid, :presence => true,
                  :length => { :maximum => API_KEY_LEN }
  validates :cik, :presence => true,
                  :length => { :maximum => API_KEY_LEN }
  validates :basic_auth, :presence => true,
                         :length => { :maximum => API_KEY_LEN }
  validates :wifi_key, :presence => true,
                       :length => { :maximum => DEVICE_KEY_LEN }
  validates :mac_address, :presence => true,
                          :length => { :maximum => DEVICE_KEY_LEN }
end
