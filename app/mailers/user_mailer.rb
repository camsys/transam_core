class UserMailer < ActionMailer::Base
  
  # Default sender account set in application.yml
  default from: ENV["SYSTEM_SEND_FROM_ADDRESS"]
    
  def email_message(mesg)  
    @message = mesg
    mail(:to => @message.to_user.email, :subject => @message.subject)      
  end

end
