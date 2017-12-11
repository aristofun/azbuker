class BootstrapFormBuilder < ActionView::Helpers::FormBuilder
  delegate :content_tag, :tag, :to => :@template

  %w[text_field email_field file_field text_area password_field select].each do |meth_name|
    define_method(meth_name) do |name, *args|
      opts = args.clone.extract_options!
      original = opts[:original].present?
      return super(name, *args) if original

      naked = opts[:naked].present?
      alt_text = opts[:alt_text].html_safe unless opts[:alt_text].blank?
      label = opts[:label]

      result = ""
      result += label(name, label)
      result += content_tag :div, :class => 'input' do
        super(name, *args) + " " + content_tag(:span, :class => 'help-block') do
          res_error(name, alt_text)
        end
      end

      unless naked
        result = content_tag :div, :class => "clearfix #{field_error(name)}" do
          result.html_safe
        end
      end
      return result.html_safe
    end
  end

  def check_box(name, *args)
    opts = args.extract_options!
    original = opts[:original].present?
    return super(name, opts) if original

    content_tag :div, :class => "clearfix #{field_error(name)}" do
      content_tag :div, :class => "input" do
        super(name, opts) + ' ' + label(name, opts[:label], :class => opts[:label_class]) +
            opts[:alt_text] + ' ' + content_tag(:span, res_error(name), :class => 'help-block')
      end
    end
  end

  # resource errors checker
  def res_has_error?(field)
    valid_obj.try(:errors) && valid_obj.errors[field].present?
  end

  def res_error(field, alt_text = '')
    if res_has_error?(field)
      valid_obj.errors[field][0]
    else
      alt_text
    end
  end

  def field_error(field, alt_text = "error")
    if res_has_error?(field)
      alt_text
    else
      ''
    end
  end

  private
  # :naked => treu option - removes surrounding div tags
  # :original => true – calls original builder method
  def objectify_options(opts)
    super.except(:original, :naked, :alt_text, :label, :label_class)
  end

  def valid_obj
    #@valid_obj ||= (@object || @template.instance_variable_get("@#{@object_name}"))
    object
  end
end