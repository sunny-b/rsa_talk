require 'openssl'
require 'json'
require 'httparty'

def main
  # GENERATE PUBLIC AND PRIVATE KEY VALUES

  public_key = "#{n}+#{e}"

  server_key = trade_keys(public_key)
  server_n, server_e = server_key.split('+').map(&:to_i)

  msg = 42

  puts "Message to Server: #{msg}"

  # ENCRYPT CLIENT MESSAGE

  server_cipher = trade_messages(encrypted)

  puts "Cipher from Server: #{server_cipher}"

  # DECRYPT SERVER MESSAGE

  puts "Message from Server: #{decrypted}"
end

def trade_keys(public_key)
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

  body[:key]
end

def trade_messages(msg)
  req_body = {
    body: {
      message: msg
    }.to_json,
    headers: {
      "Content-Type": "application/json"
    }
  }

  results = HTTParty.get("http://localhost:4567/message", req_body)
  body = JSON.parse(results, symbolize_names: true)
  body[:message]
end

main
