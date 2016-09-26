# frozen_string_literal: true
module HTMLHelper
  def escape_html(text)
    Rack::Utils.escape_html(text)
  end

  def escape_uri(text)
    URI.escape(text)
  end
end
