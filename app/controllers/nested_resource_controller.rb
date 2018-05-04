#
# Use this class as the base class for controllers which deal with polymorphic classes
# such as comments (commentable), documents (documetable), etc.
#
class NestedResourceController < OrganizationAwareController

  protected

  # Returns the URL of the resource that is being commented. There is a special case where
  # controllers which are aliased (eg asset => inventory) get the wrong controller name
  # so we have to deal with those
  def get_resource_url(resource)
    #puts resource.inspect
    controller_name = resource.class.name.underscore
    #puts controller_name
    if controller_name == 'asset'
      controller_name = 'inventory'
    end
    eval("#{controller_name}_url('#{resource.object_key}')")
  end
  
  # Get the class and object key of the commentable object we are operating on. There is a special
  # case where the controller is aliased and we need to determine this and replace the correct
  # resource class name
  def find_resource
    params.permit!.to_h.reverse_each do |name, value|
      if name =~ /(.+)_id$/
        if $1 == 'inventory'
          return 'asset'.classify.constantize.find_by_object_key(value)
        else
          return $1.classify.constantize.find_by_object_key(value)
        end
      end
    end
    
    nil
  end
    
end
