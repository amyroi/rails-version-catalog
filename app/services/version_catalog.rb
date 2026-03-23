class VersionCatalog
  VERSION_KEYS = [ "7.0", "8.0", "8.1.2" ].freeze

  class << self
    def all
      @all ||= [
        version(
          key: "7.0",
          label: "Rails 7.0",
          release_date: "December 2021",
          status: :supported,
          release_notes_url: "https://guides.rubyonrails.org/7_0_release_notes.html"
        ),
        version(
          key: "8.0",
          label: "Rails 8.0",
          release_date: "November 2024",
          status: :supported,
          release_notes_url: "https://guides.rubyonrails.org/8_0_release_notes.html"
        ),
        version(
          key: "8.1.2",
          label: "Rails 8.1.2",
          release_date: "January 8, 2026",
          status: :latest,
          release_notes_url: "https://guides.rubyonrails.org/8_1_release_notes.html"
        )
      ]
    end

    def default_compare_keys
      VERSION_KEYS
    end

    def fetch(key)
      all.find { |version| version.key == key.to_s }
    end

    def normalize(keys)
      Array(keys)
        .flat_map { |value| value.to_s.split(",") }
        .map(&:strip)
        .select { |key| VERSION_KEYS.include?(key) }
        .uniq
    end

    def index_for(key)
      VERSION_KEYS.index(key.to_s) || -1
    end

    private
      def version(**attributes)
        CatalogVersion.new(**attributes)
      end
  end
end
