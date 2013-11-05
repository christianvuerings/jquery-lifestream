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
    book_list = ul.xpath('./li')

    book_list.each do |bl|
      temp = {
        :title => bl.xpath('.//h3[@class="material-group-title"]').text.split("\n")[0],
        :image => bl.xpath('.//span[@id="materialTitleImage"]/img/@src').text,
        :isbn => bl.xpath('.//span[@id="materialISBN"]').text.split(":")[1],
        :author => bl.xpath('.//span[@id="materialAuthor"]').text.split(":")[1],
        :edition => bl.xpath('.//span[@id="materialEdition"]').text.split(":")[1],
        :copyright_year => bl.xpath('.//span[@id="materialCopyrightYear"]').text.split(":")[1],
        :publisher => bl.xpath('.//span[@id="materialPublisher"]').text.split(":")[1]
      }
      books.push(temp)
    end 
    return books
  end

  def get_books
    puts params[:ccn]
  	require 'open-uri'

    ##########################
    ccn = params[:ccn]
    term = params[:term]
    url = "http://www.bkstr.com/webapp/wcs/stores/servlet/booklookServlet?bookstore_id-1=554&term_id-1=#{term}&crn-1=#{ccn}"
    puts url
    text_books = Nokogiri::HTML(open(url))

    required_books = []
    recommended_books = []

    text_books1 = text_books.xpath('//h2 | //ul')

    required_text_list = text_books1.xpath('//h2[contains(text(), "Required")]/following::ul[1]')
    recommended_text_list = text_books1.xpath('//h2[contains(text(), "Recommended")]/following::ul[1]')
    optional_text_list = text_books1.xpath('//h2[contains(text(), "Optional")]/following::ul')
    #puts recommended_text_list
    required_books = ul_to_dict(required_text_list)
    #recommended_books = ul_to_dict(recommended_text_list)

    puts required_books
    #puts recommended_books

    ##########################


  	# doc1 = Nokogiri::HTML(open('http://www.bkstr.com/webapp/wcs/stores/servlet/booklookServlet?bookstore_id-1=554&term_id-1=2013D&crn-1=41578'))

   #  details = doc1.xpath('//div[@class="material-group-edition"]')
   #  #puts "Rasheed book"
   #  #puts details
   #  #puts details.length
   #  #puts "Rasheed book End"

   #  entry = doc1.xpath('//span[@id="materialISBN"]').text

   #  books = []

   #  details.each do |book|
   #  	puts book.xpath('span[@id="materialISBN"]').text
   #  	puts book.xpath('span[@id="materialAuthor"]').text
   #  	puts book.xpath('span[@id="materialEdition"]').text
   #  	puts book.xpath('span[@id="materialCopyrightYear"]').text
   #  	puts book.xpath('span[@id="materialPublisher"]').text

   #  	temp = {
   #  		:ISBN => book.xpath('span[@id="materialISBN"]').text,
   #  		:Author => book.xpath('span[@id="materialAuthor"]').text,
   #  		:Edition => book.xpath('span[@id="materialEdition"]').text,
   #  		:CopyrightYear => book.xpath('span[@id="materialCopyrightYear"]').text,
   #  		:Publisher => book.xpath('span[@id="materialPublisher"]').text
   #  	}
   #  	books.push(temp)
   #  end

    response = {
    	#:books_details => books
      :required_books => required_books,
      :recommended_books => recommended_books
    }

    render :json => response.to_json
  end

end
