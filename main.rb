require "sinatra"
require "line/bot"

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_serct = "ac909a5b07f5e6c0cb4dbccfe4a853fd"
    config.channel_token = "5lCvdOqglVDYfZM9xivTY/b6OaCyQxviDlSaXXMUvXDkC4kOiyy97mxO/6SVYeyrd2JHwEU6E7As8KjcqECq0FGx4T4qDsohMAdSj/m+q3Ubm+WVuazVPQYm8VZw1hkM1aUYCRHWCsrFpd3FM//CzAdB04t89/1O/w1cDnyilFU="
  }
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
