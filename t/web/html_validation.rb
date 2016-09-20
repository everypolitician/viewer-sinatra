# frozen_string_literal: true
require 'test_helper'
require_relative '../../app'
require 'vnu'

describe 'HTML validation' do
  it 'has no errors in the home page' do
    get '/'
    validate(last_response.body).must_be_nil
  end

  it 'has no errors in the country page' do
    get '/finland/'
    validate(last_response.body).must_be_nil
  end

  def validate(html)
    Vnu.validate(html, errors_only: true, format: 'json')
  end
end
