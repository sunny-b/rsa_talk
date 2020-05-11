require 'sinatra'
require 'json'

before do
    request.body.rewind
    @request_payload = JSON.parse(request.body.read, symbolize_names: true)
end

post '/keys' do
  client_key = @request_payload[:key]
  
  puts "Client Key: #{client_key}"

  n, e, d = generate_keys(11)

  File.write('./client_key.txt', client_key)
  File.write('./server_public.txt', "#{n}+#{e}")
  File.write('./server_private.txt', "#{d}")

  { key: "#{n}+#{e}" }.to_json
end

get '/message' do
  cipher = @request_payload[:message]

  puts "Cipher from Client: #{cipher}"

  d = File.read('./server_private.txt').to_i
  n, _ = File.read('./server_public.txt').split('+').map(&:to_i)

  decrypted = int_to_str((cipher ** d) % n)

  puts "Message from Client: #{decrypted}"

  msg = 'yo'

  puts "Message to Client: #{msg}"

  client_n, client_e = File.read('./client_key.txt').split('+').map(&:to_i)

  encrypted = (str_to_int(msg) ** client_e) % client_n

  { message: encrypted }.to_json 
end

def generate_keys(bits)
  while true
    p = OpenSSL::BN.generate_prime(bits).to_i
    q = OpenSSL::BN.generate_prime(bits).to_i

    break if p != q
  end

  n = p * q
  totient = (p - 1) * (q - 1)

  e = 7
  i = 1

  while true
    ed = i * e

    if ed % totient == 1
      d = i
      break
    end

    i += 1
  end

  [n, e, d]
end

def str_to_int(msg)
  msg.bytes.inject(0) do |sum, b|
    (sum << 8) + b
  end
end

def int_to_str(msg_int)
  str = ""

  while msg_int > 0 do
    b = (msg_int & 0xFF).chr
    msg_int >>= 8
    str << b
  end

  str.reverse
end
