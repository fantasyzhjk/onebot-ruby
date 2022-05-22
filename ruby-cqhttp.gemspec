Gem::Specification.new do |s|
  s.name = 'ruby-cqhttp'
  s.version = '0.1.3'
  s.summary = '一个基于 OneBot 标准的 QQ 机器人框架'
  s.description = '一个基于 OneBot 标准的 QQ 机器人框架'
  s.authors = ['fantasyzhjk']
  s.email = 'fantasyzhjk@outlook.com'
  s.platform = Gem::Platform::RUBY
  s.homepage = 'https://github.com/fantasyzhjk/ruby-cqhttp/'
  s.license = 'MIT'
  s.required_ruby_version = '>= 2.7.0'
  
  s.extra_rdoc_files = %w[README.md]
  s.rdoc_options     = %w[--main README.md --markup markdown]
  s.require_paths    = %w[lib]

  s.files = %w[LICENSE README.md] + Dir.glob('lib/**/*.rb')

  s.add_runtime_dependency 'event_emitter'
  s.add_runtime_dependency 'faye-websocket'
  s.add_runtime_dependency 'json'
  s.add_runtime_dependency 'logger'

  s.add_development_dependency 'solargraph'
  s.add_development_dependency 'rack'
  s.add_development_dependency 'puma', '>= 2.0.0'

  jruby = RUBY_PLATFORM =~ /java/
  rbx   = defined?(RUBY_ENGINE) && RUBY_ENGINE =~ /rbx/
  windows = RUBY_PLATFORM =~ /mingw/

  unless jruby
    s.add_development_dependency 'thin', '>= 1.2.0'
    s.add_development_dependency 'rainbows', '>= 4.4.0' unless windows
  end

  unless rbx
    s.add_development_dependency 'goliath'
  end

  unless jruby or rbx
    s.add_development_dependency 'passenger', '>= 4.0.0'
  end
end
