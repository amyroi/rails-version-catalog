class CacheDemoProbe
  KEY = "rails8-feature-catalog/solid-cache/demo"
  TTL = 10.minutes

  class << self
    def snapshot(force_refresh: false)
      Rails.cache.delete(KEY) if force_refresh

      hit = Rails.cache.exist?(KEY)
      payload = Rails.cache.fetch(KEY, expires_in: TTL) { build_payload }

      {
        key: KEY,
        hit: hit,
        store: Rails.cache.class.name,
        payload: payload,
        exists_after_read: Rails.cache.exist?(KEY),
        ttl: TTL
      }
    end

    def clear!
      Rails.cache.delete(KEY)
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
