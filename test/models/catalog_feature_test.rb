require "test_helper"

class CatalogFeatureTest < ActiveSupport::TestCase
  test "returns optional metadata through public api" do
    feature = CatalogFeature.new(
      slug: "solid-queue",
      title: "Solid Queue",
      category: "Interactive Demo",
      summary: "summary",
      supported_versions: %w[7.0 8.0 8.1.3],
      notes_by_version: { "7.0" => "note 7", "8.0" => "note 8", "8.1.3" => "note 8.1.3" },
      highlights_by_version: { "7.0" => "h7", "8.0" => "h8", "8.1.3" => "h813" },
      demo_type: :runtime_demo,
      source_links_by_version: {
        "7.0" => "https://example.com/7",
        "8.0" => "https://example.com/8",
        "8.1.3" => "https://example.com/813"
      },
      status_by_version: { "8.0" => "default" },
      files_by_version: { "8.0" => [ "config/queue.yml" ] },
      upgrade_notes_by_version: { "8.0" => [ "start worker" ] },
      code_examples_by_version: { "8.0" => [ "bin/jobs start" ] },
      operational_notes_by_version: { "8.0" => [ "check queue worker" ] },
      adoption_when: [ "when durable jobs are needed" ],
      adoption_cautions: [ "when worker operations are not ready" ],
      adoption_alternatives: [ "Sidekiq" ],
      adoption_requirements: [ "worker process" ],
      live_demo_available: true
    )

    assert_equal "default", feature.status_for("8.0")
    assert_equal [ "config/queue.yml" ], feature.files_for("8.0")
    assert_equal [ "start worker" ], feature.upgrade_notes_for("8.0")
    assert_equal [ "bin/jobs start" ], feature.code_examples_for("8.0")
    assert_equal [ "check queue worker" ], feature.operational_notes_for("8.0")
    assert_equal [ "when durable jobs are needed" ], feature.adoption_when
    assert_equal [ "when worker operations are not ready" ], feature.adoption_cautions
    assert_equal [ "Sidekiq" ], feature.adoption_alternatives
    assert_equal [ "worker process" ], feature.adoption_requirements
    assert_predicate feature, :adoption_readiness_available?
    assert_predicate feature, :live_demo_available?
  end

  test "returns fallback values for missing optional metadata" do
    feature = CatalogFeature.new(
      slug: "propshaft",
      title: "Propshaft",
      category: "Config / Platform Differences",
      summary: "summary",
      supported_versions: %w[7.0 8.0 8.1.3],
      notes_by_version: { "7.0" => "note 7", "8.0" => "note 8", "8.1.3" => "note 8.1.3" },
      highlights_by_version: { "7.0" => "h7", "8.0" => "h8", "8.1.3" => "h813" },
      demo_type: :comparison_card,
      source_links_by_version: {
        "7.0" => "https://example.com/7",
        "8.0" => "https://example.com/8",
        "8.1.3" => "https://example.com/813"
      }
    )

    assert_nil feature.status_for("8.0")
    assert_equal [], feature.files_for("8.0")
    assert_equal [], feature.upgrade_notes_for("8.0")
    assert_equal [], feature.code_examples_for("8.0")
    assert_equal [], feature.operational_notes_for("8.0")
    assert_equal [], feature.adoption_when
    assert_equal [], feature.adoption_cautions
    assert_equal [], feature.adoption_alternatives
    assert_equal [], feature.adoption_requirements
    assert_not_predicate feature, :adoption_readiness_available?
    assert_not_predicate feature, :live_demo_available?
  end
end
