class NotificationsController < OrganizationAwareController

  prepend_before_action :skip_timeout, :only => [:count]

  before_action :set_notification, :only => [:show, :update]

  # Lock down the controller
  authorize_resource only: [:index, :show, :update]

  # always get all notifications only for the current user logged in
  def index
    @notifications = current_user ? current_user.user_notifications.unopened : []

    respond_to do |format|
      format.js { render :partial => "shared/notifications_list", locals: { :notifications => @notifications } }
    end

  end

  def count
    request.env["devise.skip_trackable"] = true

    @count = current_user ? current_user.user_notifications.unopened.count : 0

    respond_to do |format|
      format.json { render :json => @count.to_json }
    end
  end

  def read_all
    current_user.user_notifications.unopened.update_all(opened_at: Time.now) if current_user

    respond_to do |format|
      format.js { render text: 'countNotifications(); $("#notificationContainer").hide();' } # run JS function on main notification nav to recount notifications
    end
  end

  def show

    # reset filter if necessary so you go to notification link
    if @notification.notifiable_type == 'Organization' && !(@organization_list.include? @notification.notifiable_id)
      set_current_user_organization_filter_(current_user, current_user.user_organization_filters.system_filters.first)
    end

    # if all users of that notification have seen it make notification inactive
    if @notification.user_notifications.count == @notification.user_notifications.opened.count
      @notification.update(active: false)
    end

    redirect_to @notification.link
  end

  def update

    respond_to do |format|
      format.js { render text: 'countNotifications(); getNotifications();' } # run JS function on main notification nav to recount notifications
    end
  end

  private

  def set_notification
    @notification = Notification.find_by_object_key(params[:id]) unless params[:id].nil?
    if @notification.nil?
      redirect_to '/404'
      return
    else
      # update the noification as opend at by the logged in user
      @notification.user_notifications.find_by(user: current_user).update!(opened_at: Time.now)
    end
  end

  def skip_timeout
    request.env["devise.skip_trackable"] = true
  end

end
