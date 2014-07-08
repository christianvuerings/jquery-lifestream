module Textbooks
  class Proxy < BaseProxy

    include ClassLogger

    APP_ID = 'textbooks'

    def initialize(options = {})
      @ccns = options[:ccns]
      @slug = options[:slug]
      @term = get_term(@slug)
      # The first CCN is used as a cache key.
      @ccn = @ccns[0]
      super(Settings.textbooks_proxy, options)
    end


    def google_book(isbn)
      google_book_url = 'https://www.googleapis.com/books/v1/volumes?q=isbn:' + isbn
      google_response = ''
      response = ActiveSupport::Notifications.instrument('proxy', { url: google_book_url , class: self.class }) do
          HTTParty.get(
        google_book_url,
        timeout: Settings.application.outgoing_http_timeout
      )
      end

      if response['totalItems'] > 0
        google_response = response['items'][0]['volumeInfo']['infoLink']
      end

      return google_response
    end

    def ul_to_dict(ul, bookstore_link)
      books = []
      amazon_url = 'http://www.amazon.com/gp/search?index=books&linkCode=qs&keywords='
      chegg_url = 'http://www.chegg.com/search/'
      oskicat_url = 'http://oskicat.berkeley.edu/search~S1/?searchtype=i&searcharg='

      if ul.length > 0
        book_list = ul.xpath('./li')
        book_list.each do |bl|
          book_detail = {
            hasChoices: bl.xpath('.//h3[@class="material-group-title choice-title"]').length > 0 || bl.xpath('.//div[@class="choice-list-heading-sub"]').length > 0,
            title: bl.xpath('.//h3[@class="material-group-title"]')[0].text.split("\n")[0].strip,
            image: bl.xpath('.//span[@id="materialTitleImage"]/img/@src')[0].text.gsub('http:', '').strip,
            author: bl.xpath('.//span[@id="materialAuthor"]')[0].text.split(':')[1].strip,
            edition: bl.xpath('.//span[@id="materialEdition"]')[0].text.split(':')[1].strip,
            publisher: bl.xpath('.//span[@id="materialPublisher"]')[0].text.split(':')[1].strip,
            bookstoreLink: bookstore_link
          }
          if (isbn_node = bl.xpath('.//span[@id="materialISBN"]')[0])
            isbn = isbn_node.text.split(':')[1].strip
            book_detail.merge!({
              isbn: isbn,
              amazonLink: amazon_url + isbn,
              cheggLink: chegg_url + isbn,
              oskicatLink: oskicat_url + isbn,
              googlebookLink: google_book(isbn)
            })
          end
          books.push(book_detail)
        end
      end
      books
    end

    def has_choices(category_books)
      category_books.any? { |i| i[:hasChoices] == true }
    end

    def get_term(slug)
      term_hash = Berkeley::TermCodes.from_slug(slug)
      "#{term_hash[:term_yr]}#{term_hash[:term_cd]}"
    end

    def get_as_json
      self.class.smart_fetch_from_cache(
        {id: "#{@ccn}-#{@slug}",
         user_message_on_exception: "Currently, we can't reach the bookstore. Check again later for updates, or contact your instructor directly.",
         jsonify: true}) do
        get
      end
    end

    def get
      return {} unless Settings.features.textbooks
      required_books = []
      recommended_books = []
      optional_books = []
      bookstore_error_text = ''

      @ccns.each do |ccn|
        xml = request_bookstore_list(ccn)
        text_books = Nokogiri::HTML(xml)
        text_books_items = text_books.xpath('//h2 | //ul')
        bookstore_link = bookstore_link(ccn)

        required_text_list = text_books_items.xpath('//h2[contains(text(), "Required")]/following::ul[1]')
        recommended_text_list = text_books_items.xpath('//h2[contains(text(), "Recommended")]/following::ul[1]')
        optional_text_list = text_books_items.xpath('//h2[contains(text(), "Optional")]/following::ul[1]')
        required_books.push(ul_to_dict(required_text_list, bookstore_link))
        recommended_books.push(ul_to_dict(recommended_text_list, bookstore_link))
        optional_books.push(ul_to_dict(optional_text_list, bookstore_link))
        bookstore_error_section = text_books.xpath('//div[@id="efCourseErrorSection"]/h2')
        if bookstore_error_section.length > 0
          bookstore_error_text = bookstore_error_section[0].text.gsub('*', '').strip
        end
      end

      book_unavailable_error =
        case bookstore_error_text
          when /No Information Received For This Course./
            'Currently, there is no textbook information for this course. Check again later for updates, or contact your instructor directly.'
          when /We are unable to find the specified course./
            'Textbook information for this course could not be found.'
          when /No Store Supplied Material/
            'No materials for this course are supplied by the Cal Student Store. Contact the instructor regarding any custom materials.'
          when /No Books Required For This Course./
            'There are no required books for this course.'
          when /We are unable to find the requested term/
            'Textbook information for this term could not be found.'
          else
            bookstore_error_text
        end

      book_response = {
        :bookDetails => []
      }

      if !required_books.flatten.blank?
        book_response[:bookDetails].push({
                                            :type => 'Required',
                                            :books => required_books.flatten,
                                            :hasChoices => has_choices(required_books.flatten)
                                          })
      end

      if !recommended_books.flatten.blank?
        book_response[:bookDetails].push({
                                            :type => 'Recommended',
                                            :books => recommended_books.flatten,
                                            :hasChoices => has_choices(recommended_books.flatten)
                                          })
      end

      if !optional_books.flatten.blank?
        book_response[:bookDetails].push({
                                            :type => 'Optional',
                                            :books => optional_books.flatten,
                                            :hasChoices => has_choices(optional_books.flatten)
                                          })
      end

      book_response[:bookUnavailableError] = book_unavailable_error
      book_response[:hasBooks] = !(required_books.flatten.blank? && recommended_books.flatten.blank? && optional_books.flatten.blank?)
      {
        books: book_response
      }

    end

    def bookstore_link(ccn)
      path = "/webapp/wcs/stores/servlet/booklookServlet?bookstore_id-1=554&term_id-1=#{@term}&crn-1=#{ccn}"
      "#{Settings.textbooks_proxy.base_url}#{path}"
    end

    def request_bookstore_list(ccn)
      # We work from saved HTML since VCR does not correctly record bookstore responses.
      return fake_list(ccn) if @fake

      url = bookstore_link(ccn)
      logger.info "Fake = #@fake; Making request to #{url}; cache expiration #{self.class.expires_in}"
      response = HTTParty.get(
        url,
        timeout: Settings.application.outgoing_http_timeout
      )
      logger.debug "Remote server status #{response.code}; url = #{url}"
      if response.code >= 400
        raise Errors::ProxyError.new("Currently, we can't reach the bookstore. Check again later for updates, or contact your instructor directly.")
      end
      response.body
    end

    def fake_list(ccn)
      path = Rails.root.join('fixtures', 'html', "textbooks-#{@term}-#{ccn}.html").to_s
      logger.info "Fake = #@fake, getting data from HMTL fixture file #{path}"
      unless File.exists?(path)
        raise Errors::ProxyError.new("Unrecorded textbook response #{path}")
      end
      File.read(path)
    end

  end
end
