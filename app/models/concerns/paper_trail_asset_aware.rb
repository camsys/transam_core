module PaperTrailAssetAware

  extend ActiveSupport::Concern

  included do

    has_paper_trail

  end

  module ClassMethods

  end


  protected

  private

end