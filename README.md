# BERT::Client

BERT::Client is a threadsafe BERT-RPC client with support for persistent 
connections, ssl, and it currently exposes BERT-RPC's cast and call.

# Usage

    require 'bertclient'
    client = BERT::Client.new(:host => 'localhost',
                              :port => 9999,
                              :ssl => true,
                              :verify_ssl => false)

    client.call(:calc, :add, 1, 2)


