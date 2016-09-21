# frozen_string_literal: true
require 'test_helper'
require_relative '../../app'
require 'html_validation'

describe 'HTML validation' do
  it 'has no errors in the home page' do
    get '/'
    last_response_must_be_valid
  end

  it 'has no errors in the countries page' do
    get '/countries.html'
    last_response_must_be_valid
  end

  it 'has no errors in the country page' do
    get '/finland/'
    last_response_must_be_valid
  end

  it 'has no errors in the house page' do
    get '/finland/eduskunta/'
    last_response_must_be_valid
  end

  it 'has no errors in the house/term page' do
    stub_popolo('beb21e5', 'Alderney/States')
    get '/alderney/states/term-table/2014.html'
    last_response_must_be_valid
  end

  it 'has no errors in the house/download page' do
    get '/finland/eduskunta/download.html'
    last_response_must_be_valid
  end

  def last_response_must_be_valid
    validation = PageValidations::HTMLValidation.new.validation(last_response.body, last_request.url)
    assert validation.valid?, validation.exceptions
  end
end
