class AppAlertsProxy < BaseProxy
  include DatedFeed
  require 'open-uri'

  def initialize(options = {})
    super(Settings.app_alerts_proxy, options)
  end

  def get_latest
    self.class.smart_fetch_from_cache({id: "global-alert", user_message_on_exception: "Remote server unreachable", return_nil_on_generic_error: true}) do
      (get_alerts.nil?) ? nil : get_alerts.first
    end
  end

  private

  def get_alerts
    result = []
    begin
      xml=fetch_xml_content
      doc = Nokogiri::XML(xml, &:strict)
      nodes = doc.css('node')
      nodes.each do |node|
        timestamp = node.css('PostDate').text.to_i
        result << {
          # title and teaser seem to always have the same value
          title: node.css('Title').text,
          teaser: node.css('Teaser').text,
          url: node.css('Link').text,
          timestamp: format_date(Time.zone.at(timestamp).to_datetime),
        }
      end
    rescue Exception => e  # possible Nokogiri::XML::SyntaxError
      logger.error("Error parsing XML data: #{e.inspect}")
    end
    # to-do: sort the results by epoch unless feed can guarantee to sort alerts by PostDate in descending order
    #result.sort_by { |k| k[:timestamp][:epoch] }.reverse
    (result.empty?) ? nil : result
  end

  def fetch_xml_content
    logger.info "#{self.class.name} Fetching alerts from blog (fake=#{@fake}, cache expiration #{self.class.expires_in}"
    if @fake == true
      begin
        xml = File.read(get_fetch_url)
      rescue Exception => e # possible exceptions ENOENT
        logger.error("Unable to read fake data: #{e.inspect}")
      end
    else
      begin
        response = open(get_fetch_url)
        xml = response.base_uri.read
      rescue Exception => e  # possible exceptions SocketError
        logger.error("Http error: #{e.inspect}")
      end
      return nil unless xml
    end
    xml
  end

  def get_fetch_url
    url ||= (@fake) ? Rails.root.join('fixtures', 'xml', 'app_alerts_feed.xml').to_s : @settings.feed_url
  end
end
