#------------------------------------------------------------------------------
#
# SessionCacheCleanupJob.rb
#
# Checks cached session data that has expired and removes it from the cache
#
#------------------------------------------------------------------------------
class SessionCacheCleanupJob < Job

  def run

    now = Time.now
    key = "000000:#{TransamController::ACTIVE_SESSION_LIST_CACHE_VAR}"
    session_list = Rails.cache.fetch(key)
    session_list.keys.each do |s|
      if session_list[s][:expire_time] < now
        session_list.delete(s)
      end
    end
    Rails.cache.fetch(key, :force => true, :expires_in => 1.week) { session_list }

  end

  def prepare
    Rails.logger.info "Executing SessionCacheCleanupJob at #{Time.now.to_s}"
  end

  def check

  end

  def initialize
    super
  end

end
