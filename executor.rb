require 'redis'
require 'json'
require_relative 'text-adventure/lib/bootstrap'
require_relative 'text-adventure/lib/game'

def setup_game
  b = Bootstrap.new 'text-adventure/data/epic_adventure/locations.yml', 'text-adventure/data/epic_adventure/messages.yml'
  @game = Game.new(b)
  @bot_name = ["@adventure","@a"]
end

def wait_for_messages
  @from_redis ||= Redis.new
  loop do
    msg = @from_redis.brpop("to_game").last
    js = JSON.parse(msg)
		query = extract_message(js)
		puts "sending '#{query}' to game"
    send_reply(response: execute_message(query), original: js)
  end
end

def extract_message(json)
  @bot_name.each do |name|
    json["text"] = json["text"].gsub(/^#{name}/,"").strip
  end
  json["text"]
end

def send_reply(message)
  puts "sending #{message.to_json}"
  (@to_redis ||= Redis.new).lpush("to_user",message.to_json)
end

def execute_message(message)
  @game.engine.eval_msg(message)
end

if __FILE__ == $0
  setup_game
  wait_for_messages
end
