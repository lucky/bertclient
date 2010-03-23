require 'openssl'
require 'bert'
require 'resolv-replace' # TCPSocket

module BERT
  class Client
    class RPCError < StandardError; end
    class NoSuchModule < RPCError; end
    class NoSuchFunction < RPCError; end
    class UserError < RPCError; end
    class UnknownError < RPCError; end
    class InvalidResponse < RPCError; end
    class BadHeader < RPCError; end
    class BadData < RPCError; end

    def initialize(opts={})
      @host = opts[:host] || 'localhost'
      @port = opts[:port] || 9999 
      @ssl = opts[:ssl] || false 
      @verify_ssl = opts.has_key?(:verify_ssl) ? opts[:verify_ssl] : true
      @socket = {}
      connect
    end

    def call(mod, fun, *args)
      response = cast_or_call(:call, mod, fun, *args)
      return response[1] if response[0] == :reply

      handle_error(response)
    end

    def cast(mod, fun, *args)
      response = cast_or_call(:cast, mod, fun, *args)
      return nil if response[0] == :noreply

      handle_error(response)
    end

    # Wrapper for both cast and call mechanisms
    def cast_or_call(cc, mod, fun, *args)
      req = t[cc, mod.to_sym, fun.to_sym, args]
      write_berp(req)
      read_berp
    end

    # See bert-rpc.org for error response mechanisms
    def handle_error(response)
      unless response[0] == :error
        raise InvalidReponse, "Expected error response, got: #{response.inspect}"
      end

      type, code, klass, detail, backtrace = response[1]
      case type 
      when :server
        if code == 1
          raise NoSuchModule
        elsif code == 2
          raise NoSuchFunction
        else
          raise UnknownError, "Unknown server error: #{response.inspect}"
        end
      when :user
        raise UserError.new("#{klass}: #{detail}\n#{backtrace.join()}")
      when :protocol
        if code == 1
          raise BadHeader
        elsif code == 2
          raise BadData
        else
          raise UnknownError, "Unknown protocol error: #{reponse.inspect}"
        end
      else
        raise UnknownError, "Unknown error: #{response.inspect}"
      end
    end

    def socket
      @socket[Thread.current]
    end

    # Open socket to service, use SSL if necessary
    def connect
      sock = TCPSocket.new(@host, @port)
      if @ssl
        sock = OpenSSL::SSL::SSLSocket.new(sock)
        sock.sync_close = true
        sock.connect
        sock.post_connection_check(@host) if @verify_ssl
      end
      @socket[Thread.current] = sock
      true
    end

    # Reads a new berp from the socket and returns the decoded object
    def read_berp
      length = socket.read(4).unpack('N')[0]
      data = socket.read(length)
      BERT.decode(data)
    end

    # Accepts a Ruby object, converts to a berp and sends through the socket
    def write_berp(obj)
      socket.write(Client.create_berp(obj))
    end

    # Accepts a Ruby object and returns an encoded berp
    def Client.create_berp(obj)
      data = BERT.encode(obj)
      length = [data.bytesize].pack('N')
      "#{length}#{data}"
    end
  end

end
