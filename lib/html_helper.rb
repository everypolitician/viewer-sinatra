# frozen_string_literal: true
require 'sinatra/base'

module Sinatra
  module HTMLHelper
    def unescape_uri(text)
      CGI.unescape(text)
    end
  end
end
