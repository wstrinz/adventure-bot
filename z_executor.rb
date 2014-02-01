require 'redis'
require 'json'
require 'dorothy'

def setup_game(file='LostPig.z8')
  @game = Z::Machine.new(file)
  @game.run
  @bot_name = ["@adventure","@a"]
end

def wait_for_messages
  @from_redis ||= Redis.new
  loop do
    msg = @from_redis.brpop("to_game").last
    js = JSON.parse(msg)
    query = extract_message(js)
    command_response = check_command(query)
    if command_response
      puts "special command #{query} run"
      send_reply(response: command_response, original: js)
    else
      puts "sending '#{query}' to game"
      send_reply(response: execute_message(query), original: js)
    end
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

def check_command(message)
  case message
  when /^\/reset/
    setup_game
    @game.output.join
  when /^\/load .+/
    "loading other stories not implemented yet"
  when /^\/help/
    "special commands are '/reset', and '/load <file>'"
  else
    nil
  end
end

def execute_message(message)
  begin
    @game.output.clear
    @game.keyboard << message + "\n"
    @game.run
    @game.output.join
  rescue
    "sorry, there was an error running '#{message}':  " + $!.message.to_s
  end
end

if __FILE__ == $0
  setup_game
  wait_for_messages
end
