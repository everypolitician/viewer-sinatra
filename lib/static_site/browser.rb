# frozen_string_literal: true

require 'capybara-webkit'

module StaticSite
  class Browser < Capybara::Webkit::Browser
    JQUERY_WAIT_TIME = 2

    def initialize
      super(Capybara::Webkit::Connection.new(server: Capybara::Webkit::Server.new))
      allow_unknown_urls
    end

    def body_after_jquery_ajax
      wait_for_jquery_ajax
      restore_pre_js_page_classes
      body
    end

    def wait_for_jquery_ajax
      Timeout.timeout(JQUERY_WAIT_TIME) do
        # Errors if jQuery isn't on the page - should we check for that?
        loop until evaluate_script('jQuery.active').zero?
      end
    end

    # Restores page classes modified by running JS on the page
    def restore_pre_js_page_classes
      execute_script("$('html').addClass('no-js')")
      execute_script("$('html').removeClass('flexwrap')")
    end
  end
end
