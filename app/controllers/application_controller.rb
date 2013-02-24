class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :set_timezone  
    
  def set_timezone
    if current_user.nil?
      Time.zone = SlenderRay::Application.config.time_zone
    else
      Time.zone = current_user.time_zone || SlenderRay::Application.config.time_zone
    end
  end    
end
