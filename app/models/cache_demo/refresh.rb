class CacheDemo::Refresh
  KEY = "rails8-feature-catalog/solid-cache/demo".freeze
  TTL = 10.minutes

  class << self
    def call(force_refresh: false)
      CacheDemo::CacheAdapter.delete(KEY) if force_refresh

      hit = CacheDemo::CacheAdapter.exist?(KEY)
      payload = CacheDemo::CacheAdapter.fetch(KEY, expires_in: TTL) { build_payload }

      {
        key: KEY,
        hit: hit,
        store: CacheDemo::CacheAdapter.store_name,
        payload: payload,
        exists_after_read: CacheDemo::CacheAdapter.exist?(KEY),
        ttl: TTL
      }
    end

    private
      def build_payload
        {
          generated_at: Time.current.iso8601,
          checksum: SecureRandom.hex(4),
          explanation: "This payload is intentionally regenerated only on cache miss."
        }
      end
  end
end
