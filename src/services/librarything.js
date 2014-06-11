(function($) {
$.fn.lifestream.feeds.librarything = function( config, callback ) {

  var template = $.extend({},
    {
      book: 'added <a href="http://www.librarything.com/work/book/${book.book_id}"' +
        ' title="${book.title} by ${book.author_fl}">' +
        '${book.title} by ${book.author_fl}</a> to my library'
    },
    config.template),

  parseLibraryThing = function( input ) {
    var output = [], i = "";

    if(input.books) {
      // LibraryThing returns a hash that maps id to Book objects
      // which leads to the following slightly weird for loop.
      for (i in input.books) {
        if (input.books.hasOwnProperty(i)) {
          var book = input.books[i];
          output.push({
            date : new Date(book.entry_stamp * 1000),
            config : config,
            html : $.tmpl(template.book, {book : book}),
            url : 'http://www.librarything.com/profile/' + config.user
          });
        }
      }
    }
    return output;
  };

  $.ajax({
    url: 'https://www.librarything.com/api_getdata.php?booksort=entry_REV&userid=' + config.user,
    dataType: 'jsonp',
    success: function( data ) {
      callback(parseLibraryThing(data));
    }
  });

  return {
    "template" : template
  };

};
})(jQuery);
