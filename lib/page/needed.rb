require 'octokit'

module Page
  class Needed
    def initialize(access_token:)
      @access_token = access_token
    end

    def to_find
      issues 'New Country,To Find'
    end

    def to_scrape
      issues 'New Country,To Scrape'
    end

    def to_finish
      issues 'New Country,3 - WIP'
    end

    private

    attr_reader :access_token

    def issues(labels)
      client.issues 'everypolitician/everypolitician-data', labels: labels
    end

    def client
      client = Octokit::Client.new(access_token: @access_token)
      client.auto_paginate = true
      client
    end
  end
end
