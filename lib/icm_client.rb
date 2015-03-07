require 'icm_ruby_client/version'
require 'rest_client'
require 'forwardable'
require 'json'

# This module provides an entry point for interacting with the InformaCast REST API
module ICMClient
  class Client
    # Extend forwardable to delegate to RestClient::Resource's get, post, put, delete, head, and options
    extend Forwardable
    def_delegators :nested_resource, :get, :post, :put, :delete, :head, :options

    attr_reader :base_url, :access_token, :path

    # The default limit for list/pagination
    DEFAULT_LIMIT = 100

    # Creates a new instance of an InformaCast Mobile REST client
    # Params:
    # +access_token+:: Required argument for interacting with the REST API
    # +client_options+:: Optional argument for supplying additional options to RestClient.
    # +base_url+:: Optional argument for overriding the default base base_url. Useful for testing.
    # +path+:: Optional argument for overriding the base path.
    # +resource+:: Optional argument for overriding the default RestClient.
    def initialize(access_token, client_options={}, base_url='https://api.icmobile.singlewire.com/api/v1-DEV', path=nil, resource=nil)
      @access_token = access_token.freeze or raise ArgumentError, 'must pass :access_token'
      @base_url = base_url.freeze or raise ArgumentError, 'must pass :base_url'
      @path = path.freeze
      @resource = resource || RestClient::Resource.new(base_url, {:headers => {
                                                                         :authorization => "Bearer #{access_token}",
                                                                         :x_client_version => 'RubyClient 0.0.1'
                                                                     }}.merge(client_options || {}))
    end

    # Provides the magic necessary to chain method calls
    # ==== Examples
    #     client = ICMClient::Client.new('<My Access Token>')
    #     puts client.users('<User Id>').devices.get
    def method_missing(symbol, *args)
      raise ArgumentError, 'only one argument may be provided' if args.length > 1
      formatted_resource_name = symbol.to_s.gsub('_', '-')
      resource_id = ("/#{args.first}" unless args.empty?)
      new_path = "#{@path}/#{formatted_resource_name}#{resource_id}"
      Client.new(@access_token, nil, @base_url, new_path, @resource)
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
          raw_response_str = nested_resource.get(*args)
          response = JSON.parse(raw_response_str)
          resources = response['data']
          resources.each { |resource| y.yield resource }
          next_token = response['next']
          break unless next_token
        end
      end
    end

    private

    # Grabs a nested resource based on the path for this client
    def nested_resource
      @resource[@path]
    end
  end
end
