# coding: utf-8
# User: aristofun
# Date: 19.05.12
# Time: 11:31

module HtmlHelper

  def plurize(number, zero, single, two_3_4)
    return "#{number} #{zero}" if (10..20).include?(number%100)

    case number%10
      when 1
        "#{number} #{single}"
      when 2..4
        "#{number} #{two_3_4}"
      else
        "#{number} #{zero}"
    end
  end

  #----- HTML page HELPERS --------
  def delivery_types_string(lot)
    delarr = []
    delarr << (lot.can_postmail ? 'по почте' : nil)
    delarr << (lot.can_deliver ? 'по городу' : nil)
    str = delarr.compact.to_sentence(:two_words_connector => ', ')

    return "<small>есть доставка #{str}</small><br/>".html_safe if str.present?
    ''
  end


  def page_description
    @page_description ||= "Азбукер, место где продают и покупают хорошие книги. Деловая и учебная
литература дешевле, чем где бы то ни было. Прочитал – дай другим прочитать."
  end

  def authors_list(book)
    result = ''
    book.authors[0..1].each do |author|
      result += link_to(content_tag(:nobr, author.short), author_path(author.id),
                        :title => 'Все книги этого автора')+ ', '
    end
    result.chomp!(', ')
    result += " и&nbsp;др." if book.authors.length > 2
    result.html_safe
  end

  def city_chooser(except = [], cssclass = '')
    res = form_tag({}, {:method => :get, :id => 'city_filter_form', :class => cssclass}) do
      params2hidden_form(except) + select_tag(:cityid,
                                              options_for_select(cities_rev, cookies[:cityid]),
                                              :class => "span3", :onchange => "this.form.submit();")
    end
    res
  end

  def params2hidden_form(except)
    res = ''
    exc = [:controller, :action, :utf8, :id].concat(Array.wrap(except))
    params.except(*exc).each do |key, value|
      res += content_tag(:input, nil, :type => :hidden, :value => value, :name => key)
    end
    res.html_safe
  end

  # Generates link to current url with updated *order_by* and *order_to*
  # parameters.
  # Uses current _params[:order_by]_ and ..._:order_to_
  def filter_link(title, key, default_desc = true, default = false)
    draw_arrow = (params[:order_by] == key || (default && params[:order_by].blank?))
    desc_order = (params[:order_to] == 'desc' || (params[:order_to].blank?))
    arrow, new_order = desc_order ? %w(&#9660; asc) : %w(&#9650; desc)

    link_to(
        "#{title} #{draw_arrow ? arrow : ''}".html_safe,
        params.merge(:order_to => draw_arrow ? new_order : (default_desc ? '' : 'asc'), :order_by => key))
  end


  def flash_notice(cssclass = 'span9 offset3 alert-message')
    base_errors_block = base_errors_get
    f_names = [:notice, :warning, :message, :info, :alert]
    fl = ''
    for name in f_names
      if flash[name].present?
        fl = fl +
            "<div class=\"#{cssclass} #{getalertcss(name)} fade in\" data-alert=\"alert\">
                 <a class=\"close\" href=\"#\">×</a>
                 <p>#{flash[name]}</p>
                 <p>#{base_errors_block}</p>
                </div>"
      end
      flash.delete(name)
    end
    fl
    #"<div class='row'><br/>#{fl}</div>" if fl.present?
    #''
  end

  def getalertcss(name)
    case name
      when :alert
        'error'
      when :warning
        'warning'
      when :notice
        'info'
      else
        'success'
    end
  end


  def base_errors_get
    errs = session[:base_errors].present? ? "<ul> <li>" + session[:base_errors].join("</li><li>") + " </li> </ul>" : ''
    session.delete(:base_errors)
    errs
  end

end