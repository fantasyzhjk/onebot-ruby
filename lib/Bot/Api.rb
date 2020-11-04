module CQHttp
  class Api
    class << self
      def httpPost(*args)
        url = URI.parse args[0]
        req = Net::HTTP::Post.new(url.path, { 'Content-Type' => 'application/json' })
        req.body = args[1]
        res = Net::HTTP.start(url.hostname, url.port) do |http|
          http.request(req)
        end
        res.body
      end
    end
  end
end
