class AttachmentUploader < CarrierWave::Uploader::Base
  
  include CarrierWave::MiniMagick

  # make sure to save the orignal filename
  before :cache, :save_original_filename
  # Choose what kind of storage to use for this uploader:
  storage :file
  #storage :fog

  # Move files from cache to store rather than re-uploading
  def move_to_cache
    true
  end
  
  def move_to_store
    true
  end
  
  version :thumb do
    process :resize_to_limit => [150, 150]
  end
  
  def store_dir
    "attachments/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(pdf png jpg jpeg gif)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    "#{secure_token}.#{file.extension}" if original_filename.present?   
  end

  def save_original_filename(file)
    model.original_filename ||= file.original_filename if file.respond_to?(:original_filename)
  end

protected
  
  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end  

end