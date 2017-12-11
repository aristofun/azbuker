module Paperclip
  module Interpolations
    def user_id(attachment, style_name)
      attachment.instance.user_id.to_s
    end

    def user_partition(attachment, style_name)
      attachment.instance.user_id.to_i % 1000
    end
  end
end