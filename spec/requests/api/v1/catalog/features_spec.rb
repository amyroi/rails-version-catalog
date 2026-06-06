require "rails_helper"

RSpec.describe "Api::V1::Catalog::Features", type: :request do
  describe "GET /api/v1/catalog/features" do
    it "returns runtime demos and comparison cards as camelCase JSON" do
      get api_v1_catalog_features_path

      expect(response).to have_http_status(:ok)

      features = JSON.parse(response.body)
      expect(features.keys.sort).to eq(%w[comparisonCards runtimeDemos])
      expect(features.fetch("runtimeDemos").size).to eq(FeatureCatalog.runtime_demos.size)
      expect(features.fetch("comparisonCards").size).to eq(FeatureCatalog.comparison_cards.size)

      runtime_demo = features.fetch("runtimeDemos").first
      expect(runtime_demo.keys.sort).to eq(expected_summary_keys)
      expect(runtime_demo.fetch("demoType")).to eq("runtime_demo")
      expect(runtime_demo.fetch("liveDemoAvailable")).to be(true)
      expect(runtime_demo.fetch("supportedVersions")).to be_an(Array)
      expect(runtime_demo.fetch("latestVersionKey")).to eq("8.1.3")
      expect(runtime_demo.fetch("latestHighlight")).to be_a(String)
    end

    it "separates comparison cards from runtime demos" do
      get api_v1_catalog_features_path

      expect(response).to have_http_status(:ok)

      features = JSON.parse(response.body)
      expect(features.fetch("runtimeDemos")).to all(include("demoType" => "runtime_demo"))
      expect(features.fetch("comparisonCards")).to all(include("demoType" => "comparison_card"))
    end

    it "returns summary payload only" do
      get api_v1_catalog_features_path

      expect(response).to have_http_status(:ok)

      feature = JSON.parse(response.body).fetch("runtimeDemos").first
      expect(feature.keys).not_to include("notesByVersion")
      expect(feature.keys).not_to include("filesByVersion")
      expect(feature.keys).not_to include("upgradeNotesByVersion")
    end

    it "does not include runtime demo data" do
      get api_v1_catalog_features_path

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include("QueueRun")
      expect(response.body).not_to include("DemoMessage")
    end
  end

  describe "GET /api/v1/catalog/features/:slug" do
    it "returns feature detail as camelCase JSON" do
      get api_v1_catalog_feature_path("solid-queue")

      expect(response).to have_http_status(:ok)

      feature = JSON.parse(response.body)
      expect(feature.fetch("slug")).to eq("solid-queue")
      expect(feature.keys.sort).to eq(expected_detail_keys)
      expect(feature.fetch("demoType")).to eq("runtime_demo")
      expect(feature.fetch("liveDemoAvailable")).to be(true)
      expect(feature.fetch("notesByVersion")).to be_a(Hash)
      expect(feature.fetch("highlightsByVersion")).to be_a(Hash)
      expect(feature.fetch("sourceLinksByVersion")).to be_a(Hash)
      expect(feature.fetch("filesByVersion")).to be_a(Hash)
      expect(feature.fetch("adoptionWhen")).to be_an(Array)
    end

    it "returns JSON 404 for unknown slug" do
      get api_v1_catalog_feature_path("no-such-feature")

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)).to eq({ "error" => "not_found" })
    end

    it "does not include runtime demo record collections" do
      get api_v1_catalog_feature_path("solid-queue")

      expect(response).to have_http_status(:ok)

      feature = JSON.parse(response.body)
      expect(feature.keys).not_to include("queueRuns")
      expect(feature.keys).not_to include("demoMessages")
    end
  end

  def expected_summary_keys
    %w[
      category
      demoType
      latestHighlight
      latestVersionKey
      liveDemoAvailable
      slug
      summary
      supportedVersions
      title
    ].sort
  end

  def expected_detail_keys
    %w[
      adoptionAlternatives
      adoptionCautions
      adoptionRequirements
      adoptionWhen
      category
      codeExamplesByVersion
      demoType
      filesByVersion
      highlightsByVersion
      latestHighlight
      latestVersionKey
      liveDemoAvailable
      notesByVersion
      operationalNotesByVersion
      slug
      sourceLinksByVersion
      statusByVersion
      summary
      supportedVersions
      title
      upgradeNotesByVersion
    ].sort
  end
end
