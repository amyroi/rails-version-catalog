class CacheDemo::Snapshot
  class << self
    def call(force_refresh: false)
      CacheDemo::Refresh.call(force_refresh: force_refresh)
    end
  end
end
