class Attachment < ActiveRecord::Base

  before_save :update_file_attributes  

  # uploader
  mount_uploader :file, AttachmentUploader      
            
  # Associations
  belongs_to :asset
  belongs_to :attachment_type
  
  #attr_accessible :asset_id, :attachment_type_id, :file, :name, :notes, :original_filename, :content_type, :file_size  
    
  validates :asset_id, :presence => true
  validates :attachment_type_id, :presence => true
  validates :name, :presence => true
  validates :original_filename, :presence => true
  #validates :content_type, :presence => true
  #validates :file_size, :presence => true

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :asset_id,
    :attachment_type_id, 
    :file, 
    :name, 
    :notes,
    :original_filename,
    :content_type,
    :file_size
  ]
  
  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------
    
  def self.allowable_params
    FORM_PARAMS
  end
    
  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private
  
  def update_file_attributes
    
    if file.present? && file_changed?
      self.content_type = file.file.content_type
      self.file_size = file.file.size
    end
  end

end
