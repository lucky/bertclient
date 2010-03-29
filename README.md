# BERT::Client

BERT::Client is a threadsafe BERT-RPC client with support for persistent 
connections, ssl, and it currently exposes BERT-RPC's cast and call.

# Usage

    require 'bertclient'
    client = BERT::Client.new(:host => 'localhost',
                              :port => 9999,
                              :ssl => true,
                              :verify_ssl => false,
                              :gzip => true,
                              :gzip_threshold => 2048)

    client.call(:calc, :add, 1, 2)

You can also use blocks to create ephemeral connections:

    BERT::Client.new(opts) do |client|
      client.call(:auth, :authenticate, user, password)
      client.call(:calc, :add, 1, 2)
    end
