reset:
	cp templates/client_temp.rb client.rb
	cp templates/server_temp.rb server.rb
	rm rsa.rb

.PHONY: reset
