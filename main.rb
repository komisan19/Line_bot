require "sinatra"
require "line/bot"

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_serct = "ac909a5b07f5e6c0cb4dbccfe4a853fd"
    config.channel_token = "BfvFnpsYUE7eW4aIQ+rOchZro4UeWocnC4t3ttv/yKHd7KfZ24ce/CT5MKonxuQ0d2JHwEU6E7As8KjcqECq0FGx4T4qDsohMAdSj/m+q3UrypoAuc08DS9htvpdD64KAXwpPTeFSyNUG3GbBPxsIgdB04t89/1O/w1cDnyilFU="
  }
end

get '/' do 
  'hello'
end

post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  events.each { |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        message = {
          type: 'text',
          text: event.message['text']
        }
        client.reply_message(event['replyToken'], message)
      when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
        response = client.get_message_content(event.message['id'])
        tf = Tempfile.open("content")
        tf.write(response.body)
      end
    end
  }

  "OK"
end
