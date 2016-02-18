require 'omniauth-oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class SmugMug < OmniAuth::Strategies::OAuth
      option :name, 'smugmug'
      option :client_options, {
        :site => 'https://api.smugmug.com',
        :request_token_path => "/services/oauth/1.0a/getRequestToken",
        :access_token_path  => "/services/oauth/1.0a/getAccessToken",
        :authorize_path     => "/services/oauth/1.0a/authorize"
      }

      uid { user['id'] }

      info do
        {
          'uid' => user['id'],
          'nickname' => user['NickName'],
          'name' => user['Name'],
          'urls' => {
              'website' => user['URL'],
          }
        }
      end

      extra do
        { 'raw_info' => user }
      end

      def user
        @user_hash ||= MultiJson.decode(@access_token.get('https://api.smugmug.com/services/api/json/1.3.0/?method=smugmug.auth.checkAccessToken').body)['Auth']['User']
#         @user_hash ||= MultiJson.decode(@access_token.get('/api/v2!authuser',header={'accept'=>'application/json'}).body)['Response']['User']
      end
      def request_phase
        if options[:access] or options[:permissions]
          options[:authorize_params] = {}
          options[:authorize_params][:Access] = options[:access] if options[:access]
          options[:authorize_params][:Permissions] = options[:permissions] if options[:permissions]
        end
        super
      end
    end
  end
end

OmniAuth.config.add_camelization 'smugmug', 'SmugMug'
