require "test_helper"

class Api::V1::Catalog::FeaturesTest < ActionDispatch::IntegrationTest
  test "index returns runtime demos and comparison cards as camelCase JSON" do
    get api_v1_catalog_features_url

    assert_response :success

    features = JSON.parse(response.body)
    assert_equal %w[comparisonCards runtimeDemos], features.keys.sort
    assert_equal FeatureCatalog.runtime_demos.size, features.fetch("runtimeDemos").size
    assert_equal FeatureCatalog.comparison_cards.size, features.fetch("comparisonCards").size

    runtime_demo = features.fetch("runtimeDemos").first
    assert_equal expected_summary_keys, runtime_demo.keys.sort
    assert_equal "runtime_demo", runtime_demo.fetch("demoType")
    assert_equal true, runtime_demo.fetch("liveDemoAvailable")
    assert_kind_of Array, runtime_demo.fetch("supportedVersions")
    assert_equal "8.1.3", runtime_demo.fetch("latestVersionKey")
    assert_kind_of String, runtime_demo.fetch("latestHighlight")
  end

  test "index separates comparison cards from runtime demos" do
    get api_v1_catalog_features_url

    assert_response :success

    features = JSON.parse(response.body)
    assert features.fetch("runtimeDemos").all? { |feature| feature.fetch("demoType") == "runtime_demo" }
    assert features.fetch("comparisonCards").all? { |feature| feature.fetch("demoType") == "comparison_card" }
  end

  test "index returns summary payload only" do
    get api_v1_catalog_features_url

    assert_response :success

    feature = JSON.parse(response.body).fetch("runtimeDemos").first
    refute_includes feature.keys, "notesByVersion"
    refute_includes feature.keys, "filesByVersion"
    refute_includes feature.keys, "upgradeNotesByVersion"
  end

  test "index does not include runtime demo data" do
    get api_v1_catalog_features_url

    assert_response :success
    refute_includes response.body, "QueueRun"
    refute_includes response.body, "DemoMessage"
  end

  private
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
end
