require 'omniauth/strategies/oauth2'
require 'openssl'
require 'rack/utils'
require 'uri'

module OmniAuth
  module Strategies
    class Discord < OmniAuth::Strategies::OAuth2
      DEFAULT_SCOPE = "identify"

      option :client_options, {
        :site          => 'https://discordapp.com/api',
        :authorize_url => 'https://discordapp.com/api/oauth2/authorize',
        :token_url     => 'https://discordapp.com/api/oauth2/token'
      }

      option :authorize_options, [:scope, :permissions]

      uid { raw_info['id'] }

      info do
        {
          :name  => raw_info['username'],
          :email => raw_info['verified'] ? raw_info['email'] : nil,
          :image => "https://cdn.discordapp.com/avatars/#{raw_info['id']}/#{raw_info['avatar']}"
        }
      end

      extra do
        {
          'raw_info' => raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.get('users/@me').parsed
      end

      def callback_url
        full_host + script_name + callback_path
      end

      def authorize_params
        super.tap do |params|
          options[:authorize_options].each do |option|
            params[option] = request.params[option.to_s] if request.params[option.to_s]
          end

          params[:redirect_uri] = options[:redirect_uri] unless options[:redirect_uri].nil?
          params[:scope] ||= DEFAULT_SCOPE
        end
      end
    end
  end
end