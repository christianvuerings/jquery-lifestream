require "activemq.rb"

class JmsTextListener
  java_implements "javax.jms.MessageListener"

  def initialize(&proc)
    @proc = proc
    @message_count = 0
  end

  def onMessage(jms_message)
    @message_count += 1
    Rails.logger.debug("Message #{@message_count} : #{jms_message}")
    parsed_message = {
        timestamp: Time.at(jms_message.getJMSTimestamp() / 1000),
        text: jms_message.getText()
    }
    @proc.call(parsed_message)
  rescue => exception
    Rails.logger.error("#{exception} while processing #{jms_message}")
    Rails.logger.error(exception.backtrace.join("\n"))
  end

  def count
    @message_count
  end

end
