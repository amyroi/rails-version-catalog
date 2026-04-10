require "test_helper"

class CatalogFeatureTest < ActiveSupport::TestCase
  test "returns optional metadata through public api" do
    feature = CatalogFeature.new(
      slug: "solid-queue",
      title: "Solid Queue",
      category: "Interactive Demo",
      summary: "summary",
      supported_versions: %w[7.0 8.0 8.1.2],
      notes_by_version: { "7.0" => "note 7", "8.0" => "note 8", "8.1.2" => "note 8.1.2" },
      highlights_by_version: { "7.0" => "h7", "8.0" => "h8", "8.1.2" => "h812" },
      demo_type: :runtime_demo,
      source_links_by_version: {
        "7.0" => "https://example.com/7",
        "8.0" => "https://example.com/8",
        "8.1.2" => "https://example.com/812"
      },
      status_by_version: { "8.0" => "default" },
      files_by_version: { "8.0" => [ "config/queue.yml" ] },
      upgrade_notes_by_version: { "8.0" => [ "start worker" ] },
      code_examples_by_version: { "8.0" => [ "bin/jobs start" ] },
      operational_notes_by_version: { "8.0" => [ "check queue worker" ] },
      live_demo_available: true
    )

    assert_equal "default", feature.status_for("8.0")
    assert_equal [ "config/queue.yml" ], feature.files_for("8.0")
    assert_equal [ "start worker" ], feature.upgrade_notes_for("8.0")
    assert_equal [ "bin/jobs start" ], feature.code_examples_for("8.0")
    assert_equal [ "check queue worker" ], feature.operational_notes_for("8.0")
    assert_predicate feature, :live_demo_available?
  end

  test "returns fallback values for missing optional metadata" do
    feature = CatalogFeature.new(
      slug: "propshaft",
      title: "Propshaft",
      category: "Config / Platform Differences",
      summary: "summary",
      supported_versions: %w[7.0 8.0 8.1.2],
      notes_by_version: { "7.0" => "note 7", "8.0" => "note 8", "8.1.2" => "note 8.1.2" },
      highlights_by_version: { "7.0" => "h7", "8.0" => "h8", "8.1.2" => "h812" },
      demo_type: :comparison_card,
      source_links_by_version: {
        "7.0" => "https://example.com/7",
        "8.0" => "https://example.com/8",
        "8.1.2" => "https://example.com/812"
      }
    )

    assert_nil feature.status_for("8.0")
    assert_equal [], feature.files_for("8.0")
    assert_equal [], feature.upgrade_notes_for("8.0")
    assert_equal [], feature.code_examples_for("8.0")
    assert_equal [], feature.operational_notes_for("8.0")
    assert_not_predicate feature, :live_demo_available?
  end
end
