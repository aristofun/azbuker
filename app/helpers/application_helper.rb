# coding: utf-8

require 'ya2yaml'

module ApplicationHelper
  #------ GLOBAL VARS ------
  def cities
    Globals::CITIES
  end

  def cities_rev
    Globals::CITIES_REV
  end

  def genres_rev
    Globals::GENRES_REV
  end

  def genres
    Globals::GENRES
  end

  def abuses
    Globals::ABUSES
  end

  def abuses_rev
    Globals::ABUSES_REV
  end

  def cache_unless_lotowner_admin *args
    if owner_or_admin?
      yield
    else
      cache args do
        yield
      end
    end
  end

  def cache_unless_admin(name = {}, options = nil)
    if admin?
      yield
    else
      cache(name, options) do
        yield
      end
    end
  end

  #-------  LOGIC HELPERS -----------
  def owner?(lot = @lot)
    current_user && (current_user == lot.user)
  end

  def owner_or_admin?(lot = @lot)
    owner?(lot) || admin?
  end

  def myself_or_admin?
    myself? || admin?
  end

  def myself?
    current_user && (current_user == @user)
  end

  def admin?
    current_user && current_user.admin?
  end

  # WARNING: very slow method, dumping all object content from DB
  def ru_debug(object)
    begin
      "<pre class='debug_dump'>#{object.to_yaml}</pre> <p><em>Raw dump</em></p>".html_safe
    rescue Exception => e # errors from Marshal or YAML
                          # Object couldn't be dumped, perhaps because of singleton methods -- this is the fallback
      "<code class='debug_dump'>#{object.inspect}</code>".html_safe
    end
  end


    # Return a title on a per-page basis.
  def set_page_title(title)
    @page_title = title
  end

  def page_title
    @page_title || 'Азбукер: продаем и покупаем хорошие книги'
  end

  def set_meta_tags(metatags)
    @page_metatags = metatags
  end

  def meta_tags
    result = ''
    if @page_metatags.present?
      @page_metatags.each { |k, v|
        result += "<meta property=\"#{k}\" content=\"#{v}\"/>"
      }
    end
    result.html_safe
        #<meta property="og:title" content="Заголовок статьи или новости"/>
    #  <meta property="og:type" content="article"/>
    #  <meta property="og:url" content="http://devaka.ru/articles/opengraph-for-like-buttons"/>
    #  <meta property="og:image" content="http://devaka.ru/images/816.png"/>
    #  <meta property="og:site_name" content="Devaka.ru"/>
    #  <meta property="fb:admins" content="USER_ID"/>
    #  <meta property="og:description" content="Короткое описание для анонса ссылки."/>

  end

end

# XXX fucking string parameters converter! todo: extract helpers library
module Kernel
  def param_bool(param)
    return true if param == true || param =~ (/(true|t|yes|y|1)$/i) || param.nil?
    false
  end
end
