class Api::V1::Catalog::FeatureSummaryResource
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

  attribute :latestHighlight do |feature|
    params.fetch(:latest_highlights).fetch(feature.slug)
  end
end
