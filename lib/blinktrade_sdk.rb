# coding: utf-8
require "blinktrade_sdk/version"
require "blinktrade_sdk/message"
require "blinktrade_sdk/web_socket"
require 'openssl'

if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

module BlinktradeSdk
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
  
  class Client
    def request_balance(reqId=nil)
      reqId = (Time.now.to_f * 1000.0).to_i.to_i
      message = BlinktradeSdk::Message.new({
        "MsgType": "U2",
        "BalanceReqID": reqId
      })

      result = message.send()
      body = JSON.parse(result.body)

      body["Responses"][0]["4"].each do |key, value|
        if key.include? "BTC"
          body["Responses"][0]["4"][key] = "฿ #{(value / 1e8.to_f)}"
        elsif key.include? "BRL"
          body["Responses"][0]["4"][key] = "R$ #{(value / 1e8.to_f).round(2)}"
        end
      end

      result.body = body.to_json

      return result
    end

    def request_open_orders(req_id=1, page=0, page_size=100)
      message = BlinktradeSdk::Message.new({
        "MsgType": "U4",
        "OrdersReqID": req_id,
        "Page": page,
        "PageSize": page_size,
        "Filter":["has_leaves_qty eq 1"]  # Set it to "has_leaves_qty eq 1" to get open orders, "has_cum_qty eq 1" to get executed orders, "has_cxl_qty eq 1" to get cancelled orders
      })
    end

    def send_new_order(symbol="BTCUSD", side="1", broker_id=11, price_in_satoshis, qty_in_shatoshis)
      client_order_id = (Time.now.to_f * 1000.0).to_i.to_i.to_s # must to be unique
      message = BlinktradeSdk::Message.new({
          "MsgType": "D",                                       # New Order Single message. Check for a full doc here: http://www.onixs.biz/fix-dictionary/4.4/msgType_D_68.html
          "ClOrdID": client_order_id,                           # Unique identifier for Order as assigned by you
          "Symbol": symbol,                                     # Can be BTCBRL, BTCPKR, BTCVND, BTCVEF, BTCCLP.
          "Side": side,                                         # 1 - Buy, 2-Sell
          "OrdType": "2",                                       # 2 - Limited order
          "Price": price_in_satoshis,                           # Price in satoshis
          "OrderQty": qty_in_shatoshis,                         # Qty in saothis
          "BrokerID": broker_id                                # 1=SurBitcoin, 3=VBTC, 4=FoxBit, 5=Tests , 8=UrduBit, 9=ChileBit
      })
    end

    def generate_bitcoin_deposit_address(deposit_req_id=1, currency="BTC", broker_id=11)
      message = BlinktradeSdk::Message.new({
        "MsgType": "U18",                 # Deposit request
        "DepositReqID": deposit_req_id,   # Deposit Request ID.
        "Currency": currency,             # Currency.
        "BrokerID": broker_id             # Exchange ID
      })

      return message.send()
     end

     def withdraws_list(req_id=1, page=0, page_size=100)
       message = BlinktradeSdk::Message.new({
        'MsgType': 'U26',
        'WithdrawListReqID': req_id,    # WithdrawList Request ID
        'Page': page,
        'PageSize': page_size,
        'StatusList': ['1', '2']        # 1-Pending, 2-In Progress, 4-Completed, 8-Cancelled
      })
      return message.send()
     end
  end
end
