spec = Gem::Specification.new do |s|
  s.name = 'bertclient'
  s.rubyforge_project = 'bertclient'
  s.version = '0.2'
  s.summary = 'A threadsafe BERT-RPC client with ssl support and persistent connections'
  s.description = 'BERT::Client is a threadsafe BERT-RPC client with support for persistent connections, ssl, and it currently exposes BERT-RPC\'s cast and call'
  s.files = ['lib/bertclient.rb']
  s.require_path = 'lib'
  s.authors = ['Jared Kuolt']
  s.email = 'luckythetourist@gmail.com'
  s.homepage = 'http://github.com/luckythetourist/bertclient'
end

