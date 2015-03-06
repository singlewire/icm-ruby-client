require 'icm_ruby_client/version'
require 'rest_client'
require 'forwardable'
require 'json'

# This module provides an entry point for interacting with the InformaCast REST API
module ICMClient
  class Client
    # Extend forwardable to delegate to RestClient::Resource's get, post, put, delete, head, and options
    extend Forwardable

    def_delegators :@client, :get, :post, :put, :delete, :head, :options

    attr_reader :url, :client, :access_token

    # The default limit for list/pagination
    DEFAULT_LIMIT = 100

    # Creates a new instance of an InformaCast Mobile REST client
    # Params:
    # +access_token+:: Required argument for interacting with the REST API
    # +url+:: Optional argument for overriding the default base url. Useful for testing.
    def initialize(access_token='', url='https://api.icmobile.singlewire.com/api/v1-DEV')
      @access_token = access_token
      @url = url
      @client = RestClient::Resource.new(url, :headers => {:Authorization => "Bearer #{access_token}"})
    end

    # Provides the magic necessary to chain method calls
    # ==== Examples
    #     client = ICMClient::Client.new('<My Access Token>')
    #     puts client.users('<User Id>').devices.get
    def method_missing(symbol, *args)
      Client.new(@access_token, "#{@url}/#{symbol.to_s.gsub('_', '-')}#{"/#{args.first}" unless args.empty?}")
    end

    # Builds a lazy enumerator for paging through resources defined in the InformaCast Mobile API
    def list(*args)
      args = [{:params => {:limit => DEFAULT_LIMIT}}] if args.empty? or !args.first.respond_to?(:has_key?)
      args.first[:params] = {:limit => DEFAULT_LIMIT} unless args.first[:params]
      args.first[:params][:limit] = DEFAULT_LIMIT unless args.first[:params][:limit]
      next_token = nil
      Enumerator.new do |y|
        while true
          args.first[:params][:start] = next_token if next_token
          raw_response_str = @client.get(*args)
          response = JSON.parse(raw_response_str)
          resources = response['data']
          resources.each { |resource| y.yield resource }
          next_token = response['next']
          break unless next_token
        end
      end
    end
  end
end

