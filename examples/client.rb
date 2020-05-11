require 'openssl'
require 'json'
require 'httparty'

def main
  while true
    p = OpenSSL::BN.generate_prime(10).to_i
    q = OpenSSL::BN.generate_prime(10).to_i

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

  public_key = "#{n}+#{e}"

  req_body = {
    body: {
      key: public_key 
    }.to_json,
    headers: {
      "Content-Type": "application/json"
    }
  }
  
  results = HTTParty.post("http://localhost:4567/keys", req_body)
  body = JSON.parse(results, symbolize_names: true)

  server_key = body[:key]
  server_n, server_e = server_key.split('+').map(&:to_i)

  msg = 'hi'

  puts "Message to Server: #{msg}"

  encrypted = encrypt(msg, server_e, server_n)
  req_body = {
    body: {
      message: encrypted
    }.to_json,
    headers: {
      "Content-Type": "application/json"
    }
  }

  results = HTTParty.get("http://localhost:4567/message", req_body)
  body = JSON.parse(results, symbolize_names: true)

  puts "Cipher from Server: #{body[:message]}"

  decrypted = decrypt(body[:message], d, n)

  puts "Message from Server: #{decrypted}"
end

def encrypt(msg, e, n)
  (str_to_int(msg) ** e) % n
end

def decrypt(msg_int, d, n)
  int_to_str((msg_int.to_i ** d) % n)
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

main
