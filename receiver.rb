require 'redis'
require 'sinatra'

helpers do
  def to_redis(message)
    @@to_redis ||= Redis.new
    @@to_redis.lpush("to_game", message)
  end

end

post '/message' do
  puts "got message #{params}"
  to_redis(params)
end

get '/replies' do
  "msgs: #{msgs.size} <br>" + msgs.join(", ")
end

get '/next' do
  "got: #{next_message}"
end
