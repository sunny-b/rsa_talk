require 'sinatra'
require 'json'

before do
    request.body.rewind
    @request_payload = JSON.parse(request.body.read, symbolize_names: true)
end


post '/message' do
  client_key = @request_payload[:key]

  puts
  puts "Public Key from Client: #{client_key}"

  e, n = client_key.split('+').map(&:to_i)

  msg = 42

  puts "Message for Client: #{msg}"
  puts

  { cipher: encrypt(msg, e, n) }.to_json 
end

def encrypt(msg, e, n)
  (msg ** e) % n
end
