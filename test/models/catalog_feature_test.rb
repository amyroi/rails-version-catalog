require "test_helper"

class CatalogFeatureTest < ActiveSupport::TestCase
  test "missing version metadata falls back safely" do
    feature = CatalogFeature.new(
      slug: "demo",
      title: "Demo",
      category: "Runtime Demo",
      summary: "Demo summary",
      supported_versions: VersionCatalog.default_compare_keys,
      notes_by_version: { "7.0" => "old note" },
      highlights_by_version: {},
      demo_type: :runtime_demo,
      source_links_by_version: {}
    )

    assert_nil feature.status_for("8.1.2")
    assert_equal [], feature.files_for("8.1.2")
    assert_equal [], feature.upgrade_notes_for("8.1.2")
    assert_equal [], feature.code_examples_for("8.1.2")
    assert_equal [], feature.operational_notes_for("8.1.2")
    assert_nil feature.note_for("8.1.2")
    assert_nil feature.highlight_for("8.1.2")
    assert_nil feature.source_for("8.1.2")

    summary = feature.version_summary("8.1.2")
    assert_equal({
      status: nil,
      note: nil,
      highlight: nil,
      files: [],
      upgrade_notes: [],
      code_examples: [],
      operational_notes: [],
      source: nil
    }, summary)
  end

  test "latest version key is still resolved from supported versions" do
    feature = FeatureCatalog.fetch!("solid-queue")

    assert_equal "8.1.2", feature.latest_version_key
    assert feature.live_demo_available
    assert_equal "default", feature.status_for("8.0")
    assert_includes feature.files_for("8.0"), "config/queue.yml"
    assert_not_empty feature.upgrade_notes_for("8.0")
    assert_not_empty feature.code_examples_for("8.0")
    assert_not_empty feature.operational_notes_for("8.0")
  end

  test "priority feature metadata is populated" do
    expectations = {
      "authentication-generator" => true,
      "solid-queue" => true,
      "solid-cache" => true,
      "solid-cable" => true,
      "propshaft" => false,
      "kamal" => false
    }

    expectations.each do |slug, live_demo_available|
      feature = FeatureCatalog.fetch!(slug)

      assert_equal live_demo_available, feature.live_demo_available, slug
      assert_not_nil feature.status_for("8.0"), slug
      assert_not_empty feature.files_for("8.0"), slug
      assert_not_empty feature.upgrade_notes_for("8.0"), slug
      assert_not_empty feature.code_examples_for("8.0"), slug
      assert_not_empty feature.operational_notes_for("8.0"), slug
    end
  end
end
