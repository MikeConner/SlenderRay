# == Schema Information
#
# Table name: treatment_facilities
#
#  id            :integer         not null, primary key
#  facility_name :string(50)      not null
#  facility_url  :string(255)
#  first_name    :string(24)
#  last_name     :string(48)
#  email         :string(255)     not null
#  phone         :string(14)
#  fax           :string(14)
#  address_1     :string(50)
#  address_2     :string(50)
#  city          :string(50)
#  state         :string(2)
#  zipcode       :string(10)
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#  contract_file :string(255)
#  schedule_url  :string(255)
#

# CHARTER
#  Represent an install base -- facility with Slender Ray machines installed
#
# USAGE
#   Each facility can have multiple machines
#
# NOTES AND WARNINGS
#
class TreatmentFacility < ActiveRecord::Base
  include ApplicationHelper
    
  attr_accessible :facility_name, :facility_url, :first_name, :last_name, :email, :phone, :fax, :address_1, :address_2, :city, :state, :zipcode,
                  :contract_file, :remote_contract_file_url, :schedule_url,
                  :machines_attributes, :treatment_areas_attributes, :users_attributes, :treatment_plan_templates_attributes
  
  mount_uploader :contract_file, ContractUploader

  before_validation :downcase_email
  before_validation :upcase_state
  before_validation :ensure_valid_schedule
  
  has_many :patients, :dependent => :restrict
  has_many :machines, :dependent => :restrict
  has_many :treatment_areas, :dependent => :destroy
  
  has_many :treatment_sessions, :through => :machines
  has_many :users, :dependent => :destroy
  has_many :treatment_plan_templates, :dependent => :destroy
  has_many :photos, :dependent => :destroy
  
  accepts_nested_attributes_for :machines, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :treatment_areas, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :users, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :treatment_plan_templates, :allow_destroy => true, :reject_if => :all_blank
  
  validates :facility_name, :presence => true,
                            :uniqueness => { case_sensitive: false },
                            :length => { maximum: MAX_ADDRESS_LEN }
  validates :facility_url, :format => { with: URL_REGEX }, :allow_blank => true
  validates :schedule_url, :format => { with: URL_REGEX }, :allow_blank => true
  validates :first_name, :presence => true,
                         :length => { maximum: MAX_FIRST_NAME_LEN }
  validates :last_name, :presence => true,
                        :length => { maximum: MAX_LAST_NAME_LEN }
  validates :email, :presence => true,
                    :uniqueness => { case_sensitive: false },
                    :format => { with: EMAIL_REGEX }
  validates :address_1, :presence => true,
                        :length => { maximum: MAX_ADDRESS_LEN }
  validates :address_2, :length => { maximum: MAX_ADDRESS_LEN }, :allow_blank => true
  validates :city, :presence => true, 
                   :length => { maximum: MAX_ADDRESS_LEN }
  validates :state, :presence => true,
                    :inclusion => { in: US_STATES }
  validates :zipcode, :presence => true,
                      :format => { with: US_ZIP_REGEX }
  validates :phone, :presence => true,
                    :format => { with: US_PHONE_REGEX }
  validates :fax, :format => { with: US_PHONE_REGEX }, :allow_blank => true                       

  def technicians
    self.users.where('role_id = ?', Role.find_by_name(Role::TECHNICIAN).id)
  end
  
private
  def downcase_email
    self.email.downcase!
  end
  
  def upcase_state
    self.state.upcase!
  end
  
  def ensure_valid_schedule
    if !self.schedule_url.blank?
      self.schedule_url = 'http://' + self.schedule_url unless self.schedule_url.match(/^https?:\/\//)
    end
  end
end

