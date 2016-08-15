module Page
  class Needed
    def initialize
      make_client
    end

    def to_find
      @client.issues 'everypolitician/everypolitician-data', labels: 'New Country,To Find'
    end

    def to_scrape
      @client.issues 'everypolitician/everypolitician-data', labels: 'New Country,To Scrape'
    end

    def to_finish
      @client.issues 'everypolitician/everypolitician-data', labels: 'New Country,3 - WIP'
    end

    private

    def make_client
      if (token = ENV['GITHUB_ACCESS_TOKEN']).to_s.empty?
        warn 'No GITHUB_ACCESS_TOKEN found'
        @client = Octokit::Client.new
      else
        @client = Octokit::Client.new(access_token: token)
      end
      @client.auto_paginate = true
    end
  end
end
