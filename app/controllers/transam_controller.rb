class TransamController < ApplicationController

  before_filter :authenticate_user!
  before_filter :set_timezone

  # Include the rails4 style form parameters mixin
  include TransamAttributes

  # determine which layout to use based on the current user state
  layout :layout_by_resource

  OBJECT_CACHE_EXPIRE_SECONDS = Rails.application.config.object_cache_expire_seconds

  # Enumerables for view types for index views
  VIEW_TYPE_LIST  = 1   # thumbnails
  VIEW_TYPE_TABLE = 2   # table
  VIEW_TYPE_MAP   = 3   # map

  # A set of utilities to determine the database adapter type
  def is_mysql
    get_db_adapter == 'mysql2'
  end
  def is_postgresql
    get_db_adapter == 'postgres'
  end
  # Returns the name of the database adapter
  def get_db_adapter
    ActiveRecord::Base.configurations[Rails.env]['adapter']
  end

  # Centralized message sender that can be overriden by an implementation
  def notify_user(type, message)
    # if there is a notify_user method in ApplicationController use it otherwise
    # use this one
    if defined?(super)
      super
    else
      flash[type] = message
    end
  end

  # Determine which layout to use based on the authorized state
  def layout_by_resource
    if user_signed_in?
      "application"
    else
      "unauthorized"
    end
  end

  protected

  # Stores the object keys of a list of objects in the session
  def cache_list(objs, cache_key)
    list = []
    unless objs.nil?
      objs.each do |a|
        list << a.object_key
      end
    end
    cache_objects(cache_key, list)
  end

  # Sets view vars @prev_record_key, @next_record_key, @total_rows and @row_number for
  # a current object
  def get_next_and_prev_object_keys(obj, cache_key)
    @prev_record_key = nil
    @next_record_key = nil
    @total_rows = 0
    @row_number = 0
    id_list = get_cached_objects(cache_key)
    # make sure we have a list and an object to find
    if id_list && obj
      @total_rows = id_list.size
      # get the index of the current object in the array
      current_index = id_list.index(obj.object_key)
      if current_index
        @row_number = current_index + 1
        if current_index > 0
          @prev_record_key = id_list[current_index - 1]
        end
        if current_index < id_list.size
          @next_record_key = id_list[current_index + 1]
        end
      end
    end
  end

  # Wrap the search text with db string search wildcards. This might need to be adjusted
  # depending on the database being used.
  #
  # These work for MySQL
  #
  def get_search_value(search_text, search_type)
    if search_type == "equals"
      val = search_text
    elsif search_type == "starts_with"
      val = "#{search_text}%"
    elsif search_type == "ends_with"
      val = "%#{search_text}"
    else # contains or any
      val = "%#{search_text}%"
    end
    val
  end

  # Queues a job to be executed in the background
  def fire_background_job(job, priority = 0)
    Delayed::Job.enqueue job, :priority => priority
  end

  # Cache an array of objects
  def cache_objects(key, objects, expires_in = OBJECT_CACHE_EXPIRE_SECONDS)
    Rails.logger.debug "ApplicationController CACHE put for key #{get_cache_key(current_user, key)}"
    Rails.cache.write(get_cache_key(current_user, key), objects, :expires_in => expires_in)
  end

  # Return an array of cached objects
  def get_cached_objects(key)
    Rails.logger.debug "ApplicationController CACHE get for key #{get_cache_key(current_user, key)}"
    ret = Rails.cache.read(get_cache_key(current_user, key))
    return ret.nil? ? [] : ret
  end

  def clear_cached_objects(key)
    Rails.logger.debug "ApplicationController CACHE clear for key #{get_cache_key(current_user, key)}"
    Rails.cache.delete(get_cache_key(current_user, key))
  end

  # generates a cache key that is unique for a user and key name
  def get_cache_key(user, key)
    return "%06d:%s" % [user.id, key]
  end

  # returns the viewtype for the current controller and sets the session variable
  # to store any change in view type for the controller
  def get_view_type(session_var)
    view_type = params[:view_type].nil? ? session[session_var].to_i : params[:view_type].to_i
    if view_type.nil?
      view_type = VIEW_TYPE_LIST
    end
    # remember the view type in the session
    session[session_var] = view_type
    return view_type
  end

  #
  # Set the timezone for the session. If the user has one set in the database it is used
  # otherwise one is defutled
  def set_timezone
    Time.zone = current_user.nil? ? 'Eastern Time (US & Canada)' : current_user.timezone
  end

end
