# frozen_string_literal: true

require 'test_helper'
require_relative '../../app'

describe 'Countries' do
  describe 'HTML validation' do
    it 'has no errors in the countries page' do
      get '/countries.html'
      last_response_must_be_valid
    end
  end
end
