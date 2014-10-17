module NoticesHelper
  def notice_endpoints(n)
    "#{n.display_datetime.strftime("%b %d, %Y %l:%M%p")} - #{n.end_datetime.strftime("%b %d, %Y %l:%M%p")}"
  end

  def notice_title(notice)
    notice_title = notice.subject
    if notice.end_datetime < DateTime.now or not notice.active
      notice_title << "<small class='text-danger'> (Inactive)</small>"
    end
    return notice_title.html_safe
  end

end
