class DeviseMailer < Devise::Mailer

def reset_password_instructions(record, token, opts={})
  opts[:subject] =  MessageTemplate.find_by(name: 'User2').subject

  super
end

end