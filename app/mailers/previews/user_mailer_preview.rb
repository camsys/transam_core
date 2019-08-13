class UserMailerPreview < ActionMailer::Preview
  def email_message
    UserMailer.email_message(Message.first || Message.new)
  end

  def send_email_on_user_creation
    UserMailer.send_email_on_user_creation(User.first)
  end
end