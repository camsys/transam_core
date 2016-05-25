class ImageUploader < TransamAbstractUploader

  include CarrierWave::RMagick

  version :thumb do
    process :resize_to_fill => [150, 150]
  end

  def store_dir
    "image_uploads/#{model.object_key}"
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(png jpg jpeg gif)
  end

end
