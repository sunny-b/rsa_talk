require 'openssl'
require 'json'
require 'httparty'

def main
  # GENERATE PUBLIC AND PRIVATE KEY VALUES

  puts
  puts "e: #{e} | N: #{n} | d: #{d}"

  public_key = "#{e}+#{n}"

  cipher = get_cipher_from_server(public_key)

  puts "Cipher from Server: #{cipher}"

  # DECRYPT SERVER MESSAGE

  puts "Message from Server: #{message}"
  puts
end

def get_cipher_from_server(public_key)
  req_body = {
    body: {
      key: public_key 
    }.to_json
  }
  
  results = HTTParty.post("http://localhost:4567/message", req_body)
  body = JSON.parse(results, symbolize_names: true)

  body[:cipher]
end

main
