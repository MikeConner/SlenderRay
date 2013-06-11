# == Schema Information
#
# Table name: users
#
#  id                     :integer         not null, primary key
#  email                  :string(255)     default(""), not null
#  encrypted_password     :string(255)     default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer         default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  role_id                :integer
#  machine_id             :integer
#  created_at             :datetime        not null
#  updated_at             :datetime        not null
#  treatment_facility_id  :integer
#  time_zone              :string(32)      default("Eastern Time (US & Canada)")
#

# CHARTER
#  Represent a user of the system, uniquely identified by an email address
#
# USAGE
#   Users have roles; currently two. Super Admins are owners/administrators, who can do anything.
#   Technicians are facility users. They are administrators at particular facilities, and can
#   create patients, run treatments, configure treatment areas and names, etc.
#
# NOTES AND WARNINGS
#
class User < ActiveRecord::Base
  include ApplicationHelper
  
  MAX_TIMEZONE_LEN = 32
  
  EASTERN = 'Eastern Time (US & Canada)'
  CENTRAL = 'Central Time (US & Canada)'
  MOUNTAIN = 'Mountain Time (US & Canada)'
  PACIFIC = 'Pacific Time (US & Canada)'
  
  VALID_TIMEZONES = [EASTERN, CENTRAL, MOUNTAIN, PACIFIC]
    
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, :remember_me, :time_zone,
                  :treatment_facility_id, :machine_ids, :role_id

  belongs_to :role
  belongs_to :treatment_facility
  has_and_belongs_to_many :machines
    
  validates :email, :presence => true,
                    :uniqueness => { case_sensitive: false },
                    :format => { with: EMAIL_REGEX }
  validates :time_zone, :presence => true,
                        :length => { maximum: MAX_TIMEZONE_LEN },
                        :inclusion => { in: VALID_TIMEZONES }
  validate :technicians_have_machines
    
  def has_role?(role_name)
    return self.role.nil? ? false : self.role == Role.find_by_name(role_name)
  end

private
  def technicians_have_machines
    if !self.has_role?(Role::TECHNICIAN) && !self.machine_ids.empty?
      self.errors.add :base, 'Only technicians can be assigned to machines'
    end
  end
end
