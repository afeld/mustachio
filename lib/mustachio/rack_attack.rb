require 'active_support/cache'
require 'active_support/cache/memory_store'

class Rack::Attack
  RPM = 10

  self.cache.store = ActiveSupport::Cache::MemoryStore.new

  # Throttle all requests by IP (10rpm)
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  throttle('req/ip', :limit => RPM, :period => 1.minute) do |req|
    req.ip
  end

  blacklist('block circular requests') do |req|
    src = req.params['src']
    if src
      uri = Addressable::URI.parse(src)
      req.host == uri.host
    else
      false
    end
  end
end
