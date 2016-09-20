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

  it 'has no errors in the house/term page' do
    stub_popolo('beb21e5', 'Alderney/States')
    get '/alderney/states/term-table/2014.html'
    validate(last_response.body).must_be_nil
  end

  it 'has no errors in the house/download page' do
    get '/finland/eduskunta/download.html'
    validate(last_response.body).must_be_nil
  end

  def validate(html)
    Vnu.validate(html, errors_only: true, format: 'json')
  end
end
