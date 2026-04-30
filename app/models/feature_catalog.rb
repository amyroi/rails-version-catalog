class FeatureCatalog
  DATA_PATH = Rails.root.join("config/catalog/features.yml").freeze
  REQUIRED_KEYS = %w[
    slug
    category
    demo_type
    title
    summary
    notes_by_version
    highlights_by_version
    source_links_by_version
  ].freeze
  VERSIONED_KEYS = %w[notes_by_version highlights_by_version source_links_by_version].freeze
  OPTIONAL_VERSIONED_KEYS = %w[
    status_by_version
    files_by_version
    upgrade_notes_by_version
    code_examples_by_version
    operational_notes_by_version
  ].freeze
  OPTIONAL_ARRAY_KEYS = %w[
    adoption_when
    adoption_cautions
    adoption_alternatives
    adoption_requirements
  ].freeze
  ALLOWED_DEMO_TYPES = %w[runtime_demo comparison_card].freeze

  class << self
    def all
      @all ||= load_features
    end

    def runtime_demos
      all.select(&:runtime_demo?)
    end

    def comparison_cards
      all.select(&:comparison_card?)
    end

    def fetch!(slug)
      all.find { |feature| feature.slug == slug } || raise(ActionController::RoutingError, "Not Found")
    end

    private
      def load_features
        raw_features.map do |attributes|
          validate_feature!(attributes)

          CatalogFeature.new(
            slug: attributes.fetch("slug"),
            title: attributes.fetch("title"),
            category: attributes.fetch("category"),
            summary: attributes.fetch("summary"),
            supported_versions: VersionCatalog.default_compare_keys,
            notes_by_version: stringify_hash(attributes.fetch("notes_by_version")),
            highlights_by_version: stringify_hash(attributes.fetch("highlights_by_version")),
            demo_type: attributes.fetch("demo_type").to_sym,
            source_links_by_version: stringify_hash(attributes.fetch("source_links_by_version")),
            status_by_version: stringify_hash(attributes.fetch("status_by_version", {})),
            files_by_version: stringify_hash(attributes.fetch("files_by_version", {})),
            upgrade_notes_by_version: stringify_hash(attributes.fetch("upgrade_notes_by_version", {})),
            code_examples_by_version: stringify_hash(attributes.fetch("code_examples_by_version", {})),
            operational_notes_by_version: stringify_hash(attributes.fetch("operational_notes_by_version", {})),
            adoption_when: attributes.fetch("adoption_when", []),
            adoption_cautions: attributes.fetch("adoption_cautions", []),
            adoption_alternatives: attributes.fetch("adoption_alternatives", []),
            adoption_requirements: attributes.fetch("adoption_requirements", []),
            live_demo_available: attributes.fetch("live_demo_available", false)
          )
        end.tap { |features| validate_uniqueness!(features) }
      end

      def raw_features
        data = YAML.safe_load_file(DATA_PATH, aliases: false)
        features = data.fetch("features")
        raise ArgumentError, "config/catalog/features.yml must contain an array of features" unless features.is_a?(Array)

        features.map do |attributes|
          raise ArgumentError, "each feature entry must be a hash" unless attributes.is_a?(Hash)

          stringify_hash(attributes)
        end
      end

      def validate_feature!(attributes)
        missing_keys = REQUIRED_KEYS.reject { |key| attributes[key].present? }
        raise ArgumentError, "feature entry is missing keys: #{missing_keys.join(', ')}" if missing_keys.any?

        demo_type = attributes.fetch("demo_type")
        raise ArgumentError, "invalid feature demo_type: #{demo_type}" unless ALLOWED_DEMO_TYPES.include?(demo_type)

        validate_versioned_hashes!(attributes)
        validate_optional_arrays!(attributes)
      end

      def validate_versioned_hashes!(attributes)
        VERSIONED_KEYS.each do |key|
          values = attributes.fetch(key)
          raise ArgumentError, "#{key} must be a hash" unless values.is_a?(Hash)

          validate_version_keys!(key, values.keys)
        end

        OPTIONAL_VERSIONED_KEYS.each do |key|
          next unless attributes.key?(key)

          values = attributes.fetch(key)
          raise ArgumentError, "#{key} must be a hash" unless values.is_a?(Hash)

          validate_optional_version_keys!(key, values.keys)
        end

        attributes.fetch("source_links_by_version").each do |version_key, url|
          validate_url!(url, key: "source_links_by_version.#{version_key}")
        end

        validate_live_demo_available!(attributes)
      end

      def validate_optional_arrays!(attributes)
        OPTIONAL_ARRAY_KEYS.each do |key|
          next unless attributes.key?(key)

          value = attributes.fetch(key)
          raise ArgumentError, "#{key} must be an array" unless value.is_a?(Array)
        end
      end

      def validate_version_keys!(attribute_key, keys)
        keys = keys.map(&:to_s)
        known_keys = VersionCatalog.default_compare_keys

        unknown_keys = keys - known_keys
        raise ArgumentError, "#{attribute_key} has unknown version keys: #{unknown_keys.join(', ')}" if unknown_keys.any?

        missing_keys = known_keys - keys
        raise ArgumentError, "#{attribute_key} is missing version keys: #{missing_keys.join(', ')}" if missing_keys.any?
      end

      def validate_optional_version_keys!(attribute_key, keys)
        keys = keys.map(&:to_s)
        known_keys = VersionCatalog.default_compare_keys

        unknown_keys = keys - known_keys
        raise ArgumentError, "#{attribute_key} has unknown version keys: #{unknown_keys.join(', ')}" if unknown_keys.any?
      end

      def validate_live_demo_available!(attributes)
        return unless attributes.key?("live_demo_available")

        value = attributes.fetch("live_demo_available")
        return if value.in?([ true, false ])

        raise ArgumentError, "live_demo_available must be a boolean"
      end

      def validate_uniqueness!(features)
        duplicate_slugs = features.group_by(&:slug).select { |_slug, items| items.size > 1 }.keys
        raise ArgumentError, "duplicate feature slugs: #{duplicate_slugs.join(', ')}" if duplicate_slugs.any?
      end

      def validate_url!(value, key:)
        uri = URI.parse(value)
        return if uri.is_a?(URI::HTTP) && uri.host.present?

        raise ArgumentError, "#{key} must be an absolute http(s) URL"
      rescue URI::InvalidURIError
        raise ArgumentError, "#{key} must be an absolute http(s) URL"
      end

      def stringify_hash(hash)
        hash.to_h.each_with_object({}) do |(key, value), result|
          result[key.to_s] = value.is_a?(Hash) ? stringify_hash(value) : value
        end
      end

      def reset_cache!
        remove_instance_variable(:@all) if instance_variable_defined?(:@all)
      end
  end
end
