module EtsBlog
  class ReleaseNotes < RssProxy
    include ClassLogger
    include HtmlSanitizer

    def initialize(options = {})
      super(Settings.blog_latest_release_notes_feed_proxy, options)
      initialize_mocks if @fake
    end

    def default_message_on_exception
      'An error occurred retrieving release notes. Please try again later.'
    end

    def mock_xml
      read_file('fixtures', 'xml', 'release_notes_feed.xml')
    end

  end
end
