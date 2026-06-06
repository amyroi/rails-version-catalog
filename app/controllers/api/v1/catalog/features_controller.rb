class Api::V1::Catalog::FeaturesController < Api::V1::BaseController
  def index
    runtime_demos = FeatureCatalog.runtime_demos
    comparison_cards = FeatureCatalog.comparison_cards
    latest_highlights = latest_highlights_for(runtime_demos + comparison_cards)

    render json: {
      runtimeDemos: feature_summary_json(runtime_demos, latest_highlights:),
      comparisonCards: feature_summary_json(comparison_cards, latest_highlights:)
    }
  end

  def show
    feature = FeatureCatalog.fetch!(params[:slug])

    render json: Api::V1::Catalog::FeatureDetailResource.new(
      feature,
      params: { latest_highlight: feature.highlight_for(feature.latest_version_key) }
    ).as_json
  rescue ActionController::RoutingError => _error
    render json: { error: "not_found" }, status: :not_found
  end

  private
    def feature_summary_json(features, latest_highlights:)
      Api::V1::Catalog::FeatureSummaryResource.new(features, params: { latest_highlights: }).as_json
    end

    def latest_highlights_for(features)
      features.to_h do |feature|
        [ feature.slug, feature.highlight_for(feature.latest_version_key) ]
      end
    end
end
