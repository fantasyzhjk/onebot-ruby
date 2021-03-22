lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name = 'ruby-cqhttp'
  s.version       = '0.0.4'
  s.date          = '2021-03-22'
  s.summary       = 'ruby-cqhttp for osucat'
  s.description   = 'ruby-cqhttp for osucat'
  s.authors       = ['fantasyzhjk']
  s.email         = 'fantasyzhjk@outlook.com'
  s.files         = ['lib/ruby-cqhttp.rb']
  s.platform    = Gem::Platform::RUBY
  s.homepage      = 'http://rubygems.org/gems/ruby-cqhttp'
  s.license       = 'MIT'
  s.files         = `git ls-files -z`.split("\x0")
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 3.0'

  s.add_runtime_dependency  'json'
  s.add_runtime_dependency  'logger'
  s.add_runtime_dependency  'uri'
  s.add_runtime_dependency  'eventmachine'
  s.add_runtime_dependency  'faye-websocket'
  s.add_runtime_dependency  'event_emitter'
end
