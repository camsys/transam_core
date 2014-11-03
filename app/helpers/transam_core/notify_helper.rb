module TransamCore
  module NotifyHelper
    # Default implementations.  Applications should provide their own implementations.

    def notify_user(type, message)
      flash[type] = message
    end

    def notify_user_javascript(type, message)
      # No implementation
    end

  end
end
