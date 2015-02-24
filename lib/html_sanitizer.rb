module HtmlSanitizer

  module ClassMethods
    def sanitize_html(str)
      if str
        stripped = ActionController::Base.helpers.strip_tags str
        #ActionController's strip_tags doesn't unescape HTML, and CGI.unescape_html doesn't convert the space entity
        CGI.unescape_html(stripped).gsub('&nbsp;', ' ')
      end
    end
  end

  def self.included(klass)
    klass.extend ClassMethods
  end

  def sanitize_html(str)
    self.class.sanitize_html(str)
  end

end
