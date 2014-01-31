require 'redis'
require 'rest-client'
require 'json'
#require 'pry'; binding.pry
def wait_for_replies
  loop do
    message = (@from_redis ||= Redis.new).brpop "to_user"
    to_slack JSON.parse(message.last)
  end
end

def to_slack(json_message)
  puts "said #{json_message} to slack"
  args = {
    "channel" => "#metal-graveyard",
    "username" => "adventure-bot",
    "text" => json_message["response"]
  }

  url = 'https://bendyworks.slack.com/services/hooks/incoming-webhook?token=' + ENV["SLACK_TOKEN"]
  RestClient.post url, args.to_json, content_type: :json
end

if __FILE__ == $0
  wait_for_replies
end
