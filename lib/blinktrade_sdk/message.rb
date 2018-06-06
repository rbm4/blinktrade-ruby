require "http_client/http_client"
require 'openssl'

module BlinktradeSdk
  BLINKTRADE_API_VERSION = 'v1'
  TIMEOUT_IN_SECONDS = 10

  class Message
    def initialize(options={})
      @options = options

      env = 'prod'
      if env == 'prod'
        @blinktrade_api_url = "https://api.blinktrade.com"
      else
        @blinktrade_api_url = "https://api.testnet.blinktrade.com"
      end
    end

    def options=(options)
      @options = options
    end

    def send
      send_msg(@options)
    end

    private
      def send_msg(msg)
        key = ENV['BLINKTRADE_API_KEY']
        secret = ENV['BLINKTRADE_SECRET']

        nonce = (Time.now.to_f * 1000.0).to_i.to_i.to_s

        digest = OpenSSL::Digest.new('sha256')
        signature = OpenSSL::HMAC.hexdigest(digest, secret, nonce)

        headers = {
          'user-agent' => 'blinktrade_tools/0.1',
          'Content-Type' => 'application/json',
          'APIKey' => key,
          'Nonce' => nonce,
          'Signature' => signature
        }

        url = "#{@blinktrade_api_url}/tapi/#{BLINKTRADE_API_VERSION}/message"

        http_client = BlinktradeSdk::HttpClient.new
        return http_client.doPost(url, headers, msg)
      end
  end
end
