class TransamAbstractUploader < CarrierWave::Uploader::Base
  
  # make sure to save the orignal filename
  before :cache, :save_original_filename
  
  # Move files from cache to store rather than re-uploading
  def move_to_cache
    true
  end
  
  def move_to_store
    true
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