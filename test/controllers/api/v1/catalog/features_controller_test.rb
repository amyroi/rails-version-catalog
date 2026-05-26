require "test_helper"

class Api::V1::Catalog::FeaturesControllerTest < ActionDispatch::IntegrationTest
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

class Api::V1::Catalog::FeaturesControllerDetailTest < ActionDispatch::IntegrationTest
  test "show returns feature detail as camelCase JSON" do
    get api_v1_catalog_feature_url("solid-queue")

    assert_response :success

    feature = JSON.parse(response.body)
    assert_equal "solid-queue", feature.fetch("slug")
    assert_equal expected_detail_keys, feature.keys.sort
    assert_equal "runtime_demo", feature.fetch("demoType")
    assert_equal true, feature.fetch("liveDemoAvailable")
    assert_kind_of Hash, feature.fetch("notesByVersion")
    assert_kind_of Hash, feature.fetch("highlightsByVersion")
    assert_kind_of Hash, feature.fetch("sourceLinksByVersion")
    assert_kind_of Hash, feature.fetch("filesByVersion")
    assert_kind_of Array, feature.fetch("adoptionWhen")
  end

  test "show returns JSON 404 for unknown slug" do
    get api_v1_catalog_feature_url("no-such-feature")

    assert_response :not_found
    assert_equal({ "error" => "not_found" }, JSON.parse(response.body))
  end

  test "show does not include runtime demo record collections" do
    get api_v1_catalog_feature_url("solid-queue")

    assert_response :success

    feature = JSON.parse(response.body)
    refute_includes feature.keys, "queueRuns"
    refute_includes feature.keys, "demoMessages"
  end

  private
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
