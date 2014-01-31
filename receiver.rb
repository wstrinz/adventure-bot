require 'redis'
require 'json'
require 'sinatra'

helpers do
  def to_redis(message)
    @@to_redis ||= Redis.new
    @@to_redis.lpush("to_game", message)
  end

end

post '/message' do
  puts "got message #{params.to_json}"
  to_redis(params.to_json)
  200
end

get '/replies' do
  "msgs: #{msgs.size} <br>" + msgs.join(", ")
end

get '/next' do
  "got: #{next_message}"
end
