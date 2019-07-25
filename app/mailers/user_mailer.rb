class UserMailer < ActionMailer::Base

  # Default sender account set in application.yml
  default from: ENV["SYSTEM_SEND_FROM_ADDRESS"]

  def email_message(mesg)
    @message = mesg
    mail(:to => @message.to_user.email, :subject => @message.subject)
    @message.update(email_status: Message::EMAIL_STATUS_SENT)
  end

  def send_email_on_user_creation(created_user)
    @user = created_user
    mail(:to => created_user.email, :subject => MessageTemplate.find_by(name: 'User1').subject)
  end

end
