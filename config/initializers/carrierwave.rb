CarrierWave.configure do |config|
  config.root = Rails.root.join('tmp') # adding these...
  config.cache_dir = 'carrierwave' # ...two lines

  # For testing, upload files to local `tmp` folder.
  if Rails.env.test? || Rails.env.cucumber?
    config.storage = :file
    config.enable_processing = false
    config.root = "#{Rails.root}/tmp"
  else
    # config.storage = :fog
    config.storage = :aws
    config.aws_bucket = ENV.fetch('AWS_S3_BUCKET') # for AWS-side bucket access permissions config, see section below
    config.aws_acl    = 'private'

    if Rails.env.development?
      config.aws_credentials = {
        access_key_id:     ENV.fetch('AWS_ACCESS_KEY'),
        secret_access_key: ENV.fetch('AWS_SECRET_KEY'),
        region:            ENV.fetch('AWS_S3_REGION'), # Required
        stub_responses:    Rails.env.test? # Optional, avoid hitting S3 actual during tests
      }
    else
      config.aws_credentials = {
        region:            ENV.fetch('AWS_S3_REGION'), # Required
        stub_responses:    Rails.env.test? # Optional, avoid hitting S3 actual during tests
      }
    end
  end

  config.cache_dir = "#{Rails.root}/tmp/uploads"                  # To let CarrierWave work on heroku

  config.fog_directory    = ENV['AWS_S3_BUCKET']
  config.fog_use_ssl_for_aws = false
  #config.s3_access_policy = :public_read                          # Generate http:// urls. Defaults to :authenticated_read (https://)
end
