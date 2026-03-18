class CatalogFeature
  attr_reader :slug, :title, :category, :summary, :supported_versions, :notes_by_version,
              :highlights_by_version, :demo_type, :source_links_by_version

  def initialize(slug:, title:, category:, summary:, supported_versions:, notes_by_version:, highlights_by_version:, demo_type:, source_links_by_version:)
    @slug = slug
    @title = title
    @category = category
    @summary = summary
    @supported_versions = supported_versions
    @notes_by_version = notes_by_version
    @highlights_by_version = highlights_by_version
    @demo_type = demo_type
    @source_links_by_version = source_links_by_version
  end

  def runtime_demo?
    demo_type == :runtime_demo
  end

  def comparison_card?
    demo_type == :comparison_card
  end

  def partial_name
    slug.tr("-", "_")
  end

  def category_label
    runtime_demo? ? "Runtime Demo" : "Platform / Defaults"
  end

  def available_versions
    supported_versions.filter_map { |key| VersionCatalog.fetch(key) }
  end

  def comparison_versions(selected_keys)
    keys = selected_keys & supported_versions
    keys = supported_versions if keys.empty?
    keys.filter_map { |key| VersionCatalog.fetch(key) }
  end

  def note_for(version_key)
    notes_by_version.fetch(version_key)
  end

  def highlight_for(version_key)
    highlights_by_version[version_key]
  end

  def source_for(version_key)
    source_links_by_version[version_key]
  end

  def source_url
    source_for(latest_version_key)
  end

  def latest_version_key
    supported_versions.max_by { |key| VersionCatalog.index_for(key) }
  end
end
