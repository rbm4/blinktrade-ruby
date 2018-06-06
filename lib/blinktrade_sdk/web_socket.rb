require 'faye/websocket'
require 'eventmachine'

module BlinktradeSdk

  class WebSocket
    def connect
      EM.run {
        @ws = Faye::WebSocket::Client.new('wss://api.blinktrade.com/trade/', [], {
          :proxy => {
            :Origin  => "bitcambio.blinktrade.com",
            :headers => {'User-Agent' => 'ruby'}
          }
        })

        @ws.on :open do |event|
          # p [:open]
          send_login_message

          if @on_open_block
            @on_open_block.call(event)
          end
        end

        @ws.on :message do |event|
          # p [:message, event.data]

          if @on_message_block
            @on_message_block.call(event.data)
          end
        end

        @ws.on :close do |event|
          # p [:close, event.code, event.reason]
          @ws = nil
          EM.stop

          if @on_close_block
            @on_close_block.call(event.code, event.reaso)
          end
        end
      }
    end

    def on(type_event, &block)
      case type_event
        when :message
          @on_message_block = block
        when :close
          @on_close_block = block
        when :open
          @on_open_block = block
        else
          puts "No event passed"
      end
    end

    def send_login_message(params={})
      @ws.send('{
        "MsgType": "BE",
        "UserReqID": ' + generate_req_id + ',
        "BrokerID": 11,
        "Username": "' + ENV['BLINKTRADE_API_KEY'] + '",
        "Password": "' + ENV['BLINKTRADE_PASSWORD'] + '",
        "UserReqTyp": "1",
        "FingerPrint": "' + params[:fingerprint] + '"
      }')
    end

    def request_trade_history(params={})
      options = {
        "MsgType" => "U32",
        "TradeHistoryReqID" => generate_req_id
      }

      options = options.merge(params)
      @ws.send(options.to_json)
    end

    def request_execution_report
      order_id = (Time.now.to_f * 1000.0).to_i.to_i.to_s
      exec_id = (Time.now.to_f * 1000.0).to_i.to_i.to_s

      @ws.send('{
        "OrderID": ' + order_id + ',
        "ExecID": ' + exec_id + ',
        "ExecType": "0",
        "OrdStatus": "0",
        "CumQty": 0,
        "Symbol": "BTCUSD",
        "OrderQty": 5000000,
        "LastShares": 0,
        "LastPx": 0,
        "Price": 55000000000,
        "TimeInForce": "1",
        "LeavesQty": 5000000,
        "MsgType": "8",
        "ExecSide": "1",
        "OrdType": "2",
        "CxlQty": 0,
        "Side": "1",
        "ClOrdID": ' + order_id + ',
        "AvgPx": 0
      }')
    end

    def subscribe_to_order_book(subscription_request_type="1", market_depth="0", update_type="0", entry_types=["0", "1", "2"], instruments=["BTCBRL"])
      @ws.send({
        "MsgType" => "V",
        "MDReqID" => generate_req_id,
        "SubscriptionRequestType" => subscription_request_type,
        "MarketDepth" => market_depth,
        "MDUpdateType" => update_type,
        "MDEntryTypes" => entry_types,
        "Instruments" => instruments
      }.to_json)
    end

    def subscribe_to_ticker(symbols=["BTCBRL"])
      @ws.send({
        "MsgType" => "e",
        "SecurityStatusReqID" => generate_req_id,
        "SubscriptionRequestType" => "1",
        "Instruments" => symbols
      }.to_json)
    end

    private
      def generate_req_id
        (Time.now.to_f * 1000.0).to_i.to_i.to_s
      end
  end
end
