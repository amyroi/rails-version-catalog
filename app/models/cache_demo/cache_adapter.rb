class CacheDemo::CacheAdapter
  class << self
    def delete(key)
      Rails.cache.delete(key)
    end

    def exist?(key)
      Rails.cache.exist?(key)
    end

    def fetch(key, expires_in:, &block)
      Rails.cache.fetch(key, expires_in: expires_in, &block)
    end

    def store_name
      Rails.cache.class.name
    end
  end
end
