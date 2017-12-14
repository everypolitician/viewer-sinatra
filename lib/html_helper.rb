# frozen_string_literal: true

module HTMLHelper
  def unescape_uri(text)
    CGI.unescape(text)
  end
end
