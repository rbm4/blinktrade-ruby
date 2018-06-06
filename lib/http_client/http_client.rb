module BlinktradeSdk

  require 'net/http'
  require 'uri'
  require 'json'
  require 'openssl'


  class HttpClient
    def doPost(url, headers, data)
      uri = URI.parse(url)

      # Create the HTTP objects
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER

      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.body = data.to_json

      # Send the request
      response = http.request(request)

      return response
    end
  end
end
