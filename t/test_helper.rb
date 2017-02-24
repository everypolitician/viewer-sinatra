# frozen_string_literal: true
ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'nokogiri'
require 'pathname'
require 'rack/test'
require 'pry'
require 'webmock/minitest'
require 'everypolitician'
require 'html_validation'

module Minitest
  class Spec
    include Rack::Test::Methods

    def app
      Sinatra::Application
    end

    def stub_json(url, file = nil)
      stub_request(:get, url)
        .to_return(
          body:    file ? File.read("t/fixtures/#{file}.json") : '{}',
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    before do
      cj_file = %r{#{ep_repo}/raw/\w+/countries.json}
      fixture = Pathname.new('t/fixtures/d8a4682f-countries.json')
      stub_request(:get, cj_file).to_return(body: fixture.read)
    end

    def index_at_known_sha
      @shaidx ||= EveryPolitician::Index.new(index_url: countries_json_url)
    end

    def stub_everypolitician_data_request(path)
      stub_request(:get, "https://cdn.rawgit.com/everypolitician/everypolitician-data/#{path}")
        .to_return(body: File.read("t/fixtures/everypolitician-data/#{path}"))
    rescue Errno::ENOENT => error
      raise "#{error.message}\n\nTo download this fixture run the following\n\n\tbundle exec rake 'everypolitician-data[#{path}]'\n"
    end

    def stub_popolo(sha, legislature)
      stub_everypolitician_data_request("#{sha}/data/#{legislature}/ep-popolo-v1.0.json")
    end

    def stub_github_api
      stub_json(
        'https://api.github.com/repos/everypolitician/everypolitician-data/issues?labels=New%20Country,To%20Find&per_page=100',
        'github-issues-to-find'
      )
      stub_json('https://api.github.com/repos/everypolitician/everypolitician-data/issues?labels=New%20Country,To%20Scrape&per_page=100')
      stub_json('https://api.github.com/repos/everypolitician/everypolitician-data/issues?labels=New%20Country,3%20-%20WIP&per_page=100')
    end

    def stub_term_table(sha, legislature)
      stub_everypolitician_data_request("#{sha}/data/#{legislature}/ep-popolo-v1.0.json")
      stub_everypolitician_data_request("#{sha}/data/#{legislature}/unstable/positions.csv")
    end

    def last_response_must_be_valid
      skip unless supported_html_tidy_version?
      validation = PageValidations::HTMLValidation.new.validation(last_response.body, last_request.url)
      assert validation.valid?, validation.exceptions
    end

    private

    # If an old version of html-tidy is installed then this HTML string will
    # cause `tidy(1)` to exit with a non-zero status, which will cause `system`
    # to return `false`.
    def supported_html_tidy_version?
      system("echo '<!DOCTYPE html><title>Test</title><body><header>Test</header>' | tidy -eq > /dev/null 2>&1")
    end

    def ep_repo
      'https://github.com/everypolitician/everypolitician-data'
    end

    def countries_json_url
      URI.join(ep_repo + '/', 'raw/d8a4682f/countries.json').to_s
    end
  end
end
