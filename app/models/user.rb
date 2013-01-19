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
#

class User < ActiveRecord::Base
  include ApplicationHelper
    
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :role
  belongs_to :machine
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :role_id, :machine_id
  
  validates :email, :presence => true,
                    :uniqueness => { case_sensitive: false },
                    :format => { with: EMAIL_REGEX }
  validates :machine_id, :presence => { :if => :instrument_admin? }
  
  def has_role?(role_name)
    return self.role.nil? ? false : self.role == Role.find_by_name(role_name)
  end

private
  def instrument_admin?
    self.has_role?(Role::INSTRUMENT_ADMIN)
  end
end
