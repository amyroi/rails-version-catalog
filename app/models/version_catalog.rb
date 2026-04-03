class VersionCatalog
  DATA_PATH = Rails.root.join("config/catalog/versions.yml").freeze
  REQUIRED_KEYS = %w[key label release_date status release_notes_url].freeze
  ALLOWED_STATUSES = %w[supported latest planned].freeze

  class << self
    def all
      @all ||= load_versions
    end

    def default_compare_keys
      all.map(&:key)
    end

    def fetch(key)
      all.find { |version| version.key == key.to_s }
    end

    def normalize(keys)
      Array(keys)
        .flat_map { |value| value.to_s.split(",") }
        .map(&:strip)
        .select { |key| default_compare_keys.include?(key) }
        .uniq
    end

    def index_for(key)
      default_compare_keys.index(key.to_s) || -1
    end

    private
      def load_versions
        raw_versions.map do |attributes|
          validate_version!(attributes)

          CatalogVersion.new(
            key: attributes.fetch("key"),
            label: attributes.fetch("label"),
            release_date: attributes.fetch("release_date"),
            status: attributes.fetch("status").to_sym,
            release_notes_url: attributes.fetch("release_notes_url")
          )
        end.tap { |versions| validate_uniqueness!(versions) }
      end

      def raw_versions
        data = YAML.safe_load_file(DATA_PATH, aliases: false)
        versions = data.fetch("versions")
        raise ArgumentError, "config/catalog/versions.yml must contain an array of versions" unless versions.is_a?(Array)

        versions.map do |attributes|
          raise ArgumentError, "each version entry must be a hash" unless attributes.is_a?(Hash)

          attributes.transform_keys(&:to_s)
        end
      end

      def validate_version!(attributes)
        missing_keys = REQUIRED_KEYS.reject { |key| attributes[key].present? }
        raise ArgumentError, "version entry is missing keys: #{missing_keys.join(', ')}" if missing_keys.any?

        status = attributes.fetch("status")
        return if ALLOWED_STATUSES.include?(status)

        raise ArgumentError, "invalid version status: #{status}"
      end

      def validate_uniqueness!(versions)
        duplicate_keys = versions.group_by(&:key).select { |_key, items| items.size > 1 }.keys
        raise ArgumentError, "duplicate version keys: #{duplicate_keys.join(', ')}" if duplicate_keys.any?
      end

      def reset_cache!
        remove_instance_variable(:@all) if instance_variable_defined?(:@all)
      end
  end
end
