# frozen_string_literal: true

require 'capybara-webkit'
require 'pathname'
require 'uri'

class StaticSiteGenerator
  attr_reader :page, :urls

  def initialize(urls:)
    Capybara::Webkit.configure(&:allow_unknown_urls)
    @page = Capybara::Session.new(:webkit)
    @urls = urls.map { |u| URI.parse(u) }
  end

  def build
    urls.each do |u|
      save(u)
      puts "Saved #{filename(u)}"
    end
  end

  private

  def save(url)
    file_write(filename(url), page_body(url))
  end

  def file_write(file, contents)
    file.dirname.mkpath
    file.write(contents)
  end

  def page_body(url)
    page.visit(url)
    wait_for_ajax
    restore_pre_js_page_classes
    page.body
  end

  def filename(url)
    Pathname.new(url.path[1..-1]).sub_ext('.html')
  end

  # Restores page classes modified by running JS on the page
  def restore_pre_js_page_classes
    page.execute_script("$('html').addClass('no-js')")
    page.execute_script("$('html').removeClass('flexwrap')")
  end

  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end
end
