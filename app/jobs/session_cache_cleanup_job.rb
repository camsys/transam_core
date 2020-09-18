#------------------------------------------------------------------------------
#
# SessionCacheCleanupJob.rb
#
# Checks cached session data that has expired and removes it from the cache
#
#------------------------------------------------------------------------------
class SessionCacheCleanupJob < ActivityJob

  def run

    now = Time.now
    key = "000000:#{TransamController::ACTIVE_SESSION_LIST_CACHE_VAR}"
    session_list = Rails.cache.fetch(key)
    (session_list.try(:keys) || []).each do |s|
      if session_list[s][:expire_time] < now
        session_list.delete(s)
      end
    end
    Rails.cache.fetch(key, :force => true, :expires_in => 1.week) { session_list }


    # Add a row into the activity table
    ActivityLog.create({:organization_id => Organization.first.id, :user_id => User.find_by(first_name: 'system').id, :item_type => self.class.name, :activity => 'Executing Session Cache Cleanup', :activity_time => Time.now})
  end

  def prepare
    Rails.logger.info "Executing SessionCacheCleanupJob at #{Time.now.to_s}"

    super
  end

end
