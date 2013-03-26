# == Schema Information
#
# Table name: machines
#
#  id                    :integer         not null, primary key
#  model                 :string(64)      not null
#  serial_number         :string(64)      not null
#  date_installed        :date
#  treatment_facility_id :integer
#  created_at            :datetime        not null
#  updated_at            :datetime        not null
#  display_name          :string(64)      default(""), not null
#  minutes_per_treatment :integer         default(8), not null
#  hostname              :string(32)
#  web_enabled           :boolean         default(FALSE), not null
#  license_active        :boolean         default(TRUE), not null
#

require "uri"
require "net/http"

# CHARTER
#  Represent a single installed machine, on which users can run treatments
#
# USAGE
#   Each facility can have multiple machines
#
# NOTES AND WARNINGS
#
class Machine < ActiveRecord::Base
  MAX_FIELD_LEN = 64
  DEFAULT_MINUTES_PER_SESSION = 8
  MAX_HOSTNAME_LEN = 32
  DEFAULT_PORT = 8000
  API_PORT = 27
  
  before_validation :ensure_port
  
  attr_accessible :model, :serial_number, :display_name, :date_installed, :minutes_per_treatment, 
                  :hostname, :web_enabled, :license_active,
                  :treatment_facility_id, :user_ids
  
  belongs_to :treatment_facility
  has_and_belongs_to_many :users
  has_many :treatment_sessions, :dependent => :restrict
  
  validates :model, :presence => true,
                    :length => { maximum: MAX_FIELD_LEN }
  validates :serial_number, :presence => true,
                            :length => { maximum: MAX_FIELD_LEN }
  validates_presence_of :date_installed
  validates_presence_of :treatment_facility_id
  validates :display_name, :presence => true,
                           :length => { maximum: MAX_FIELD_LEN }
  validates :minutes_per_treatment, :presence => true,
                                    :numericality => { only_integer: true, greater_than: 0 }
  validates :hostname, :length => { maximum: MAX_HOSTNAME_LEN }, :presence => { :if => :pi_machine? }
  validates_inclusion_of :web_enabled, :in => [true, false]
  validates_inclusion_of :license_active, :in => [true, false]
  
  # If a pi machine, can check
  def is_machine_running?
    if !pi_machine?
      raise I18n.t('not_web_enabled')
    end
    
    url = URI.parse(root_url)
    
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    
    if res.is_a?(Net::HTTPSuccess)
      res.body
    else
      nil
    end 
    
  rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
         Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
    puts e.message
    puts e.backtrace.inspect
  end
  
  def turn_on
    if !pi_machine?
      raise I18n.t('not_web_enabled')
    end
    
    url = URI.parse(root_url + '/1')
    
    send_post(url)
  end
  
  def turn_off
    if !pi_machine?
      raise I18n.t('not_web_enabled')
    end
    
    url = URI.parse(root_url + '/0')
    
    send_post(url)
  end
  
private
  def pi_machine?
    self.web_enabled
  end
  
  def root_url
    "http://#{self.hostname}/GPIO/#{API_PORT}/value"
  end  

  def send_post(url)
    Net::HTTP.post_form(url, {})    
  rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
         Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
    puts e.message
    puts e.backtrace.inspect
  end
  
  def ensure_port
    if !self.hostname.nil? and self.hostname !~ /:\d+$/
      self.hostname += ":#{DEFAULT_PORT}"
    end
  end
end
