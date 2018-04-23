class TransamController < ApplicationController

  before_filter :authenticate_user!
  before_filter :set_timezone
  before_filter :log_session

  # Include the rails4 style form parameters mixin
  include TransamAttributes

  # determine which layout to use based on the current user state
  layout :layout_by_resource

  OBJECT_CACHE_EXPIRE_SECONDS = Rails.application.config.object_cache_expire_seconds

  # Enumerables for view types for index views
  VIEW_TYPE_LIST  = 1   # thumbnails
  VIEW_TYPE_TABLE = 2   # table
  VIEW_TYPE_MAP   = 3   # map

  ACTIVE_SESSION_LIST_CACHE_VAR = 'active_sessions_cache_key'

  #-----------------------------------------------------------------------------
  # A set of utilities to determine the database adapter type
  #-----------------------------------------------------------------------------
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

  #-----------------------------------------------------------------------------
  # Customize the 401 Access Denied error message
  #-----------------------------------------------------------------------------
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to '/401', :alert => exception.message
  end

  #-----------------------------------------------------------------------------
  # Centralized message sender that can be overriden by an implementation
  #-----------------------------------------------------------------------------
  def notify_user(type, message, now = false)
    # if there is a notify_user method in ApplicationController use it otherwise
    # use this one
    if defined?(super)
      super
    else
      if now
        flash.now[type] = message
      else
        flash[type] = message
      end
    end
  end

  #-----------------------------------------------------------------------------
  # Determine which layout to use based on the authorized state
  #-----------------------------------------------------------------------------
  def layout_by_resource
    if user_signed_in?
      "application"
    else
      "unauthorized"
    end
  end

  #-----------------------------------------------------------------------------
  protected
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Stores the object keys of a list of objects in the session
  #-----------------------------------------------------------------------------
  def cache_list(objs, cache_key)
    return if objs.nil?
    begin
      # attempt to just pluck the object_keys from the objects
      list = objs.pluck(:object_key)
    rescue
      # but if the objects don't actually have an object_key field, call object_key on each
      list = objs.map(&:object_key)
    end
    cache_objects(cache_key, list)
  end

  #-----------------------------------------------------------------------------
  # Sets view vars @prev_record_key, @next_record_key, @total_rows and @row_number for
  # a current object
  #-----------------------------------------------------------------------------
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

  #-----------------------------------------------------------------------------
  # Wrap the search text with db string search wildcards. This might need to be adjusted
  # depending on the database being used.
  #
  # These work for MySQL
  #
  #-----------------------------------------------------------------------------
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

  #-----------------------------------------------------------------------------
  # Cache an object
  #-----------------------------------------------------------------------------
  def cache_objects(key, objects, expires_in = OBJECT_CACHE_EXPIRE_SECONDS)
    Rails.logger.debug "ApplicationController CACHE put for key #{get_cache_key(current_user, key)}"
    Rails.cache.fetch(get_cache_key(current_user, key), :force => true, :expires_in => expires_in) { objects }
  end

  #-----------------------------------------------------------------------------
  # Return a cached object. If the object does not exist, an empty array is
  # returned
  #-----------------------------------------------------------------------------
  def get_cached_objects(key)
    Rails.logger.debug "ApplicationController CACHE get for key #{get_cache_key(current_user, key)}"
    ret = Rails.cache.fetch(get_cache_key(current_user, key))
    ret ||= []
  end

  #-----------------------------------------------------------------------------
  # Clear an existing cache value
  #-----------------------------------------------------------------------------
  def clear_cached_objects(key)
    Rails.logger.debug "ApplicationController CACHE clear for key #{get_cache_key(current_user, key)}"
    Rails.cache.delete(get_cache_key(current_user, key))
  end

  #-----------------------------------------------------------------------------
  # generates a cache key that is unique for a user and key name
  #-----------------------------------------------------------------------------
  def get_cache_key(user, key)
    return "%06d:%s" % [user.id, key]
  end

  #-----------------------------------------------------------------------------
  # returns the viewtype for the current controller and sets the session variable
  # to store any change in view type for the controller
  #-----------------------------------------------------------------------------
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

  #-----------------------------------------------------------------------------
  # Logs a session id in the cache with the time of access. If the session already
  # exists the timestamp is updated with the time of this request otherwise
  # the session is logged
  #-----------------------------------------------------------------------------
  def log_session
    if user_signed_in?
      key = "000000:#{ACTIVE_SESSION_LIST_CACHE_VAR}"
      session_list = Rails.cache.fetch(key)
      if session_list.blank?
        h = {}
      else
        h = session_list
      end
      unless h.has_key? session.id
        h[session.id] = {:start_time => Time.now, :views => 0, :user_id => current_user.id}
      end
      h[session.id][:last_view] = Time.now
      h[session.id][:path] = request.env['ORIGINAL_FULLPATH']
      h[session.id][:views] = h[session.id][:views].to_i + 1
      h[session.id][:expire_time] = Time.now + current_user.timeout_in
      h[session.id][:ip_addr] = request.remote_ip
      Rails.cache.fetch(key, :force => true, :expires_in => 1.week) { h }
    end
  end

end
