class NotificationsController < OrganizationAwareController

  before_action :set_notification, :only => [:show, :update]

  # always get all notifications only for the current user logged in
  def index
    @notifications = current_user ? current_user.user_notifications.unopened : []

    respond_to do |format|
      format.js { render :partial => "shared/notifications_list", locals: { :notifications => @notifications } }
    end

  end

  def count
    @count = current_user ? current_user.user_notifications.unopened.count : 0

    respond_to do |format|
      format.js { render text: @count }
    end
  end

  def read_all
    current_user.user_notifications.unopened.update_all(opened_at: Time.now) if current_user

    respond_to do |format|
      format.js { render text: 'countNotifications(); getNotifications();' } # run JS function on main notification nav to recount notifications
    end
  end

  def show

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

end
