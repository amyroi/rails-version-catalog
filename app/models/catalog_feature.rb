class CatalogFeature
  attr_reader :slug, :title, :category, :summary, :supported_versions, :notes_by_version,
              :highlights_by_version, :demo_type, :source_links_by_version, :status_by_version,
              :files_by_version, :upgrade_notes_by_version, :code_examples_by_version,
              :operational_notes_by_version, :live_demo_available

  def initialize(slug:, title:, category:, summary:, supported_versions:, notes_by_version:, highlights_by_version:, demo_type:, source_links_by_version:, status_by_version: {}, files_by_version: {}, upgrade_notes_by_version: {}, code_examples_by_version: {}, operational_notes_by_version: {}, live_demo_available: false)
    @slug = slug
    @title = title
    @category = category
    @summary = summary
    @supported_versions = supported_versions
    @notes_by_version = notes_by_version
    @highlights_by_version = highlights_by_version
    @demo_type = demo_type
    @source_links_by_version = source_links_by_version
    @status_by_version = status_by_version
    @files_by_version = files_by_version
    @upgrade_notes_by_version = upgrade_notes_by_version
    @code_examples_by_version = code_examples_by_version
    @operational_notes_by_version = operational_notes_by_version
    @live_demo_available = live_demo_available
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
    version_value_for(notes_by_version, version_key)
  end

  def highlight_for(version_key)
    version_value_for(highlights_by_version, version_key)
  end

  def source_for(version_key)
    version_value_for(source_links_by_version, version_key)
  end

  def status_for(version_key)
    version_value_for(status_by_version, version_key)
  end

  def files_for(version_key)
    version_array_for(files_by_version, version_key)
  end

  def upgrade_notes_for(version_key)
    version_array_for(upgrade_notes_by_version, version_key)
  end

  def code_examples_for(version_key)
    version_array_for(code_examples_by_version, version_key)
  end

  def operational_notes_for(version_key)
    version_array_for(operational_notes_by_version, version_key)
  end

  def source_url
    source_for(latest_version_key)
  end

  def latest_version_key
    supported_versions.max_by { |key| VersionCatalog.index_for(key) }
  end

  def version_summary(version_key)
    {
      status: status_for(version_key),
      note: note_for(version_key),
      highlight: highlight_for(version_key),
      files: files_for(version_key),
      upgrade_notes: upgrade_notes_for(version_key),
      code_examples: code_examples_for(version_key),
      operational_notes: operational_notes_for(version_key),
      source: source_for(version_key)
    }
  end

  private
    def version_value_for(hash, version_key, default = nil)
      hash.fetch(version_key, default)
    end

    def version_array_for(hash, version_key)
      Array(version_value_for(hash, version_key, []))
    end
end
