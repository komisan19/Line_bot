require "sinatra"
require "line/bot"

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_serct = "78b14159437a3988cac0a300acbff5ad"
    config.channel_token = "NqN/IUk8abjMaYgG+LPkSMu6l2uBcAxWzDt/2iuGv6tb5/VR579RjTGHbynlPTI7JJ+7V2nW7pYZCRc0Tk9djCzDOrBWNmcg8YsDAeczW2OhSji86m9lSLYmaIQ7mrpVBAI/VgYgAmnfqKjxvLkzkQdB04t89/1O/w1cDnyilFU="
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
