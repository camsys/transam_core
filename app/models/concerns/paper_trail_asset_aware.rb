module PaperTrailAssetAware

  extend ActiveSupport::Concern

  included do

    has_paper_trail except: [:created_at, :updated_at]

  end

  module ClassMethods

  end


  protected

  private

end