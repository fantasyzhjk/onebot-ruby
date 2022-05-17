lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name = 'ruby-cqhttp'
  s.version = '0.1.0'
  s.summary = '一个基于 OneBot 标准的 QQ 机器人框架'
  s.description = '一个基于 OneBot 标准的 QQ 机器人框架'
  s.authors = ['fantasyzhjk']
  s.email = 'fantasyzhjk@outlook.com'
  s.platform = Gem::Platform::RUBY
  s.homepage = 'https://github.com/fantasyzhjk/ruby-cqhttp/'
  s.license = 'MIT'
  s.files = `git ls-files -z`.split("\x0")
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 2.7.0'

  s.add_runtime_dependency 'event_emitter'
  s.add_runtime_dependency 'faye-websocket'
  s.add_runtime_dependency 'json'
  s.add_runtime_dependency 'logger'
  s.add_runtime_dependency 'rack'
end
