class MyClassesController < ApplicationController

  def get_feed
    if session[:user_id]
      render :json => MyClasses.new(session[:user_id], :original_user_id => session[:original_user_id]).get_feed_as_json
    else
      render :json => {}.to_json
    end
  end

  def ul_to_dict(ul)
    books = []
    amazon_url = "http://www.amazon.com/gp/search?index=books&linkCode=qs&keywords="
    chegg_url = "http://www.chegg.com/search/"

    if ul.length > 0
      book_list = ul.xpath('./li')

      book_list.each do |bl|
        isbn = bl.xpath('.//span[@id="materialISBN"]').text.split(":")[1].strip

        book_detail = {
          :title => bl.xpath('.//h3[@class="material-group-title"]').text.split("\n")[0],
          :image => bl.xpath('.//span[@id="materialTitleImage"]/img/@src').text,
          :isbn => isbn,
          :author => bl.xpath('.//span[@id="materialAuthor"]').text.split(":")[1],
          :edition => bl.xpath('.//span[@id="materialEdition"]').text.split(":")[1],
          :publisher => bl.xpath('.//span[@id="materialPublisher"]').text.split(":")[1],
          :amazon_link => amazon_url + isbn,
          :chegg_link => chegg_url + isbn
        }
        books.push(book_detail)
      end
    end
    books
  end

  def get_term(slug)
    semester = slug.split('-')[0]
    year = slug.split('-')[1]

    case semester
    when 'fall'
      term = year + 'D'
    when 'spring'
      term = year + 'B'
    when 'summer'
      term = year + 'C'
    end
    term
  end

  def get_books
    require 'open-uri'

    ccns = params[:ccns]
    slug = params[:slug]

    term = get_term(slug)

    required_books = []
    recommended_books = []
    optional_books = []

    ccns.each do |ccn|
      url = "http://www.bkstr.com/webapp/wcs/stores/servlet/booklookServlet?bookstore_id-1=554&term_id-1=#{term}&crn-1=#{ccn}"
      text_books = Nokogiri::HTML(open(url))

      text_books = text_books.xpath('//h2 | //ul')

      required_text_list = text_books.xpath('//h2[contains(text(), "Required")]/following::ul[1]')
      recommended_text_list = text_books.xpath('//h2[contains(text(), "Recommended")]/following::ul[1]')
      optional_text_list = text_books.xpath('//h2[contains(text(), "Optional")]/following::ul[1]')

      required_books.push(ul_to_dict(required_text_list))
      recommended_books.push(ul_to_dict(recommended_text_list))
      optional_books.push(ul_to_dict(optional_text_list))
    end

    response = {
      :required_books => {:type => "Required",
                          :books => required_books.flatten},
      :recommended_books => {:type => "Recommended",
                          :books => recommended_books.flatten},
      :optional_books => {:type => "Optional",
                          :books => optional_books.flatten},
    }

    response[:has_books] = !(required_books.flatten.blank? && recommended_books.flatten.blank? && optional_books.flatten.blank?)
    render :json => response.to_json
  end

end
