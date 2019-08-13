#------------------------------------------------------------------------------
class MessageTemplateMessageGenerator

  def generate(message_template, custom_fields)

    split_msg = message_template.body.split /([{}])/

    msg= []
    split_msg.each_with_index do |msg_part,idx|
      msg << msg_part unless ['{', '}'].include?(msg_part) || split_msg[idx-1] == '{'
    end


    generated_msg = ''

    (0..([msg.length, custom_fields.length].max)-1).each do |idx|
      if msg[0].first == '{'
        generated_msg << custom_fields[idx].to_s unless custom_fields[idx].blank?
        generated_msg << msg[idx].to_s unless msg[idx].blank?
      else
        generated_msg << msg[idx].to_s unless msg[idx].blank?
        generated_msg << custom_fields[idx].to_s unless custom_fields[idx].blank?
      end
    end

    return generated_msg
  end
end
