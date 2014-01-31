require 'redis'
require 'sinatra'

helpers do
  def to_redis(message)
    @@to_redis ||= Redis.new
    @@to_redis.lpush("to_game", message)
  end

end

post '/message' do
  to_redis(params[:message])
end

get '/replies' do
  "msgs: #{msgs.size} <br>" + msgs.join(", ")
end

get '/next' do
  "got: #{next_message}"
end
