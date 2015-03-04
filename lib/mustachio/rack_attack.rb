require 'active_support/cache'
require 'active_support/cache/memory_store'

class Rack::Attack
  self.cache.store = ActiveSupport::Cache::MemoryStore.new

  # Throttle all requests by IP (10rpm)
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  throttle('req/ip', :limit => 10, :period => 1.minute) do |req|
    req.ip # unless req.path.starts_with?('/assets')
  end
end
