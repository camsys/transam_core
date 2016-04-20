class UserMailer < ActionMailer::Base

  # Default sender account set in application.yml
  default from: ENV["SYSTEM_SEND_FROM_ADDRESS"]

  def email_message(mesg)
    @message = mesg
    mail(:to => @message.to_user.email, :subject => @message.subject)
  end

  def send_email_on_user_creation(created_user)
    @user = created_user
    mail(:to => created_user.email, :subject => "A CPT account has been created for you")
  end

end
