class Api::V1::Catalog::FeatureDetailResource
  include Alba::Resource

  attributes :slug, :title, :category, :summary

  attribute :demoType do |feature|
    feature.demo_type.to_s
  end

  attribute :liveDemoAvailable do |feature|
    feature.live_demo_available?
  end

  attribute :supportedVersions do |feature|
    feature.supported_versions
  end

  attribute :latestVersionKey do |feature|
    feature.latest_version_key
  end

  attribute :latestHighlight do |_feature|
    params.fetch(:latest_highlight)
  end

  attribute :notesByVersion do |feature|
    feature.notes_by_version
  end

  attribute :highlightsByVersion do |feature|
    feature.highlights_by_version
  end

  attribute :sourceLinksByVersion do |feature|
    feature.source_links_by_version
  end

  attribute :statusByVersion do |feature|
    feature.status_by_version
  end

  attribute :filesByVersion do |feature|
    feature.files_by_version
  end

  attribute :upgradeNotesByVersion do |feature|
    feature.upgrade_notes_by_version
  end

  attribute :codeExamplesByVersion do |feature|
    feature.code_examples_by_version
  end

  attribute :operationalNotesByVersion do |feature|
    feature.operational_notes_by_version
  end

  attribute :adoptionWhen do |feature|
    feature.adoption_when
  end

  attribute :adoptionCautions do |feature|
    feature.adoption_cautions
  end

  attribute :adoptionAlternatives do |feature|
    feature.adoption_alternatives
  end

  attribute :adoptionRequirements do |feature|
    feature.adoption_requirements
  end
end
