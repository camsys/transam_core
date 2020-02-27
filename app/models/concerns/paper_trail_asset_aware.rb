module PaperTrailAssetAware

  extend ActiveSupport::Concern

  included do

    has_paper_trail on: [:create, :destroy, :update] # not touch as this creates an empty object_changes row in versions

  end

  module ClassMethods

  end


  protected

  private

end