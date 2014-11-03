module NotifyHelper  
  # Use gritter for user notifications
  
  def notify_user(type, message)
    gflash type => {:value => message, :time => 5000, :class_name => alert_class(type), :image => false, :sticky => false  }
  end

  def notify_user_javascript(type, message)
    return '' unless message
    title = I18n.t("gflash.titles.#{type}")
    "$.gritter.add({title: '#{title}', text: '#{message}', time: 5000, class_name: '#{alert_class(type)}', image: false, sticky: false});".html_safe
  end

  def alert_class(type)
    case type
    when :notice
      'alert alert-info'
    when :alert
      'alert alert-warning'
    else
      'alert alert-danger'
    end
  end

end
