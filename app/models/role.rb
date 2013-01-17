# == Schema Information
#
# Table name: roles
#
#  id         :integer         not null, primary key
#  name       :string(16)      not null
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

# CHARTER
#   What role a user (login) has in the system; affects access control and permissions
#
# USAGE
#   SuperAdmin can do anything; InstrumentAdmins can operate machines (i.e., initiate treatments)
#
# NOTES AND WARNINGS
#   A user does not need to have a role; role-less users are "customers"
#   There are no such users now, since the application is not public-facing
#
class Role < ActiveRecord::Base
  MAX_ROLE_LEN = 16
  
  SUPER_ADMIN = "SuperAdmin"
  INSTRUMENT_ADMIN = "InstrumentAdmin"
  
  ROLES = [SUPER_ADMIN, INSTRUMENT_ADMIN]
  
  attr_accessible :name

  validates :name, :presence => true,
                   :uniqueness => { case_sensitive: false },
                   :inclusion => { in: ROLES }
end
