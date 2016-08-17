require 'octokit'

module Page
  class Needed
    def initialize(access_token: required)
      token_error if access_token.to_s.strip.empty?
      @access_token = access_token
    end

    def to_find
      client.issues 'everypolitician/everypolitician-data', labels: 'New Country,To Find'
    end

    def to_scrape
      client.issues 'everypolitician/everypolitician-data', labels: 'New Country,To Scrape'
    end

    def to_finish
      client.issues 'everypolitician/everypolitician-data', labels: 'New Country,3 - WIP'
    end

    private

    def required
      raise ArgumentError, 'No GITHUB_ACCESS_TOKEN provided'
    end

    def client
      client = Octokit::Client.new(access_token: @access_token)
      client.auto_paginate = true
      client
    end
  end
end
