lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name = 'ruby-cqhttp'
  s.version       = '0.0.2'
  s.date          = '2020-11-04'
  s.summary       = 'ruby-cqhttp for osucat'
  s.description   = 'ruby-cqhttp for osucat'
  s.authors       = ['fantasyzhjk']
  s.email         = 'fantasyzhjk@outlook.com'
  s.files         = ['lib/ruby-cqhttp.rb']
  s.homepage      = 'http://rubygems.org/gems/ruby-cqhttp'
  s.license       = 'MIT'
  s.files         = `git ls-files -z`.split("\x0")
  s.require_paths = ['lib']

  #   s.add_runtime_dependency  'json', '~> 1.1'
  #   s.add_runtime_dependency  'eventmachine', '~> 1.1'
  #   s.add_runtime_dependency  'faye-websocket', '~> 1.1'
end
