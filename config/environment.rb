# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
SlenderRay::Application.initialize!

ActionMailer::Base.smtp_settings = { 
  :address => 'smtp.webfaction.com', 
  :domain  => 'slenderray.com',
  :port      => 587, 
  :user_name => ApplicationHelper::SMTP_USERNAME,
  :password => ApplicationHelper::SMTP_PASSWORD, 
  :authentication => :login,
  :enable_starttls_auto => true
} 
