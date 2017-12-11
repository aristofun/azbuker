class BootstrapPaginateRenderer < WillPaginate::ActionView::LinkRenderer

  protected

  def gap
    tag(:li, link('&hellip;','javascript:void(0)'))
  end

  def page_number(page)
    if page == current_page
      tag(:li, link(page,page), :class => "active")
    else
      tag(:li, link(page, page))#, :rel => rel_value(page)))
    end
  end

  def previous_or_next_page(page, text, classname)
    if page
      tag(:li, link(text, page), :class => classname)
    else
      tag(:li, link(text, '#'), :class => classname + ' disabled')
    end
  end

  # XXX: copypaste from gem to set Bootstrap prev CSS class
  def previous_page
    num = @collection.current_page > 1 && @collection.current_page - 1
    previous_or_next_page(num, @options[:previous_label], 'prev')
  end

  # XXX: copypaste from gem to set Bootstrap next CSS class
  def next_page
    num = @collection.current_page < @collection.total_pages && @collection.current_page + 1
    previous_or_next_page(num, @options[:next_label], 'next')
  end


  def html_container(html)
    tag(:div, tag(:ul, html), :class => 'pagination')#, container_attributes)
  end

end