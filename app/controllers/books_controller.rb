# coding: utf-8

class BooksController < ApplicationController
  before_filter :authenticate_user!, :only => [:suggest]

  #caches_action :search,
  #              :cache_path => Proc.new { |c|
  #                c.params.merge(:city => c.cookies[:cityid])
                  #.delete_if { |k, v|                    k.starts_with?('utm_')                  }
                #},
                #:expires_in => 5.minutes,
                #:race_condition_ttl => 2.seconds,
                #:unless => Proc.new { |c| c.request.xml_http_request? }


  def suggest
    opts = {:title => strip_like_symbols(params[:title]),
            :authors => strip_like_symbols(params[:authors])}
    # title, authors
    books = OzBook.suggested(opts)
    # fill up to 4 array with current books
    books_current = Book.suggested(opts)

    if (books.length > 7) && (books_current.length > 0)
      @books = books[0..6].concat(books_current)[0..7]
    else
      @books = books.concat(books_current)[0..7]
    end

    respond_to do |type|
      type.js {}
    end
  end

  def search
    q = params[:q]
    city = get_city

    @books = Book.custom(:q => q, :city => city, :page => params[:page])
  end
end
