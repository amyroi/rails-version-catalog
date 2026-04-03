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
            source_links_by_version: stringify_hash(attributes.fetch("source_links_by_version"))
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
      end

      def validate_uniqueness!(features)
        duplicate_slugs = features.group_by(&:slug).select { |_slug, items| items.size > 1 }.keys
        raise ArgumentError, "duplicate feature slugs: #{duplicate_slugs.join(', ')}" if duplicate_slugs.any?
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
