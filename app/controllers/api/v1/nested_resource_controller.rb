#
# Use this class as the base class for API controllers which deal with polymorphic classes
# such as comments (commentable), documents (documetable), etc.
#
class Api::V1::NestedResourceController < Api::ApiController

  protected
  
  # Get the class and object key of the commentable object we are operating on. There is a special
  # case where the controller is aliased and we need to determine this and replace the correct
  # resource class name
  def find_resource
    params.permit!.to_h.reverse_each do |name, value|
      if name =~ /(.+)_id$/
        if $1 == 'asset'
          return Rails.application.config.asset_base_class_name.constantize.find_by_object_key(value)
        else
          return $1.classify.constantize.find_by_object_key(value)
        end
      end
    end
  end
    
end
