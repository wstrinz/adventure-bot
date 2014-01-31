require 'redis'
require 'rest-client'
#require 'pry'; binding.pry
def wait_for_replies
  loop do
    message = (@from_redis ||= Redis.new).brpop "to_user"
    to_slack message.last
  end
end

def to_slack(message)
  puts "said #{message} to slack"
  args = {
    "channel" => "#metal-graveyard",
    "username" => "adventure-bot",
    "text" => message
  }

  url = 'https://bendyworks.slack.com/services/hooks/incoming-webhook?token=' + ENV["SLACK_TOKEN"]
  RestClient.post url, args.to_json, content_type: :json
end

if __FILE__ == $0
  wait_for_replies
end
