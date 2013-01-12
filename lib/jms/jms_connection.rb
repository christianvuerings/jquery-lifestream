require "activemq.rb"

# JMS Connection is relatively heavyweight & can be used across multiple threads.
# JMS Session and Consumer must be single-threaded.
# Connection start should be called after sessions & consumers are set up.
class JmsConnection

  def initialize(url = Settings.ist_jms.url,
      username = Settings.ist_jms.username,
      password = Settings.ist_jms.password,
      queue_name = Settings.ist_jms.queue)
    java_import "javax.jms.Session"
    java_import "org.apache.activemq.ActiveMQConnectionFactory"
    connection_factory = username ?
        ActiveMQConnectionFactory.new(username, password, url) :
        ActiveMQConnectionFactory.new(url)
    @connection = connection_factory.createConnection
    @queue_name = queue_name
    @session = @connection.createSession(false, Session.AUTO_ACKNOWLEDGE)
    @consumer = @session.createConsumer(@session.createQueue(@queue_name))
  end

  def close
    @consumer.close()
    @session.close()
    @connection.close()
  end

  def count
    defined?(@listener) ? @listener.count : nil
  end

  def finalize
    close
  end

  def handle_texts(&proc)
    @listener = JmsTextListener.new(&proc)
    @consumer.setMessageListener(@listener)
    @connection.start
  end

  # For testing.
  def send_message(message_text)
    begin
      session = @connection.createSession(false, Session.AUTO_ACKNOWLEDGE)
      producer = session.createProducer(session.createQueue(@queue_name))
      producer.send(session.createTextMessage(message_text))
    ensure
      producer.close() if producer
      session.close() if session
    end
  end
  def send_bytes_message()
    begin
      session = @connection.createSession(false, Session.AUTO_ACKNOWLEDGE)
      producer = session.createProducer(session.createQueue(@queue_name))
      producer.send(session.createBytesMessage())
    ensure
      producer.close() if producer
      session.close() if session
    end
  end

end
