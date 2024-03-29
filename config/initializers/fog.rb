CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',       # required
    :aws_access_key_id      => ENV['AWS_KEY_ID'].nil? ? 'AKIAIC2L7ROY6SDTVI5A' : ENV['AWS_KEY_ID'],       # required
    :aws_secret_access_key  => ENV['AWS_SECRET_KEY_ID'].nil? ? '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' : ENV['AWS_SECRET_KEY_ID'],       # required
    :region                 => 'us-east-1'  # optional, defaults to 'us-east-1'
  }
  config.fog_directory  = ENV['FOG_DIRECTORY'].nil? ? 'SlenderRay' : ENV['FOG_DIRECTORY']
#  config.fog_host       = 'https://assets.example.com'            # optional, defaults to nil
#  config.fog_public     = false                                   # optional, defaults to true
#  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
  if Rails.env.test?
    config.storage = :file
#    config.enable_processing = false
  else
    config.storage = :fog
#    config.enable_processing = true
  end
end