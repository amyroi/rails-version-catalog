require "test_helper"

class FeatureCatalogTest < ActiveSupport::TestCase
  teardown do
    FeatureCatalog.send(:reset_cache!)
  end

  test "loads all features from yaml" do
    assert_equal 14, FeatureCatalog.all.size
  end

  test "returns runtime demos and comparison cards" do
    assert_equal 5, FeatureCatalog.runtime_demos.size
    assert_equal 9, FeatureCatalog.comparison_cards.size
  end

  test "fetch returns configured feature" do
    feature = FeatureCatalog.fetch!("solid-queue")

    assert_equal "Solid Queue", feature.title
    assert_equal :runtime_demo, feature.demo_type
    assert_equal "Continuations-ready durable queue", feature.highlight_for("8.1.3")
    assert_equal "Production default durable queue", feature.status_for("8.0")
    assert_equal [ "config/queue.yml", "db/queue_schema.rb", "bin/jobs" ], feature.files_for("8.0")
    assert_equal [ "config.active_job.queue_adapter = :solid_queue" ], feature.code_examples_for("8.0")
    assert_equal [ "Keep `bin/jobs start` or an equivalent worker command running." ], feature.operational_notes_for("8.0")
    assert_equal "https://guides.rubyonrails.org/8_1_release_notes.html", feature.source_for("8.1.3")
    assert_equal "Durable queue with continuations baseline", feature.status_for("8.1.3")
    assert_equal [ "app/views/features/demos/_solid_queue.html.erb", "app/models/queue_run.rb", "app/jobs/queue_run_job.rb" ], feature.files_for("8.1.3")
    assert_predicate feature, :live_demo_available?
  end

  test "loads solid cache and solid cable metadata from yaml" do
    solid_cache = FeatureCatalog.fetch!("solid-cache")
    solid_cable = FeatureCatalog.fetch!("solid-cable")

    assert_equal "DB-backed cache enters the default stack", solid_cache.status_for("8.0")
    assert_equal [ "config/cache.yml", "app/views/features/demos/_solid_cache.html.erb", "app/controllers/features_controller.rb" ], solid_cache.files_for("8.0")
    assert_equal [ "cache do" ], solid_cache.code_examples_for("8.0")
    assert_equal [ "Confirm the cache database and retention settings match the workload." ], solid_cache.operational_notes_for("8.0")
    assert_predicate solid_cache, :live_demo_available?

    assert_equal "DB-backed realtime enters the default stack", solid_cable.status_for("8.0")
    assert_equal [ "config/cable.yml", "app/views/features/demos/_solid_cable.html.erb", "app/controllers/features_controller.rb" ], solid_cable.files_for("8.0")
    assert_equal [ "adapter: solid_cable" ], solid_cable.code_examples_for("8.0")
    assert_equal [ "Keep the cable database migrated and reachable in development and production." ], solid_cable.operational_notes_for("8.0")
    assert_predicate solid_cable, :live_demo_available?
  end

  test "loads authentication generator metadata from yaml" do
    feature = FeatureCatalog.fetch!("authentication-generator")

    assert_equal "First-party authentication generator", feature.highlight_for("8.0")
    assert_equal "First-party generator baseline", feature.status_for("8.0")
    assert_equal [ "app/models/user.rb", "app/models/session.rb", "app/controllers/sessions_controller.rb", "app/controllers/passwords_controller.rb" ], feature.files_for("8.0")
    assert_equal [ "bin/rails generate authentication" ], feature.code_examples_for("7.0")
    assert_equal [ "Confirm password reset mail delivery and signed session cookies." ], feature.operational_notes_for("8.0")
    assert_equal [ "app/models/current.rb", "app/models/session.rb", "app/views/auth_labs/show.html.erb", "app/views/passwords/edit.html.erb" ], feature.files_for("8.1.3")
    assert_predicate feature, :live_demo_available?
  end

  test "loads propshaft and kamal metadata from yaml" do
    propshaft = FeatureCatalog.fetch!("propshaft")
    kamal = FeatureCatalog.fetch!("kamal")

    assert_equal "Propshaft becomes the default asset story", propshaft.status_for("8.0")
    assert_equal [ "config/importmap.rb", "app/views/features/demos/_propshaft.html.erb", "app/controllers/features_controller.rb" ], propshaft.files_for("8.0")
    assert_equal [ "Propshaft enabled" ], propshaft.code_examples_for("8.0")
    assert_equal [ "Confirm asset precompilation and fingerprinted file handling still work." ], propshaft.operational_notes_for("8.0")
    assert_predicate propshaft, :live_demo_available?

    assert_equal "Kamal becomes part of the default deploy story", kamal.status_for("8.0")
    assert_equal [ "config/deploy.yml", ".kamal/secrets", "app/views/features/demos/_kamal.html.erb" ], kamal.files_for("8.0")
    assert_equal [ "config/deploy.yml" ], kamal.code_examples_for("8.0")
    assert_equal [ "Verify the deploy image host, proxy, and secret settings together." ], kamal.operational_notes_for("8.0")
    assert_equal [ "config/deploy.yml", ".kamal/secrets", "app/views/features/demos/_kamal.html.erb" ], kamal.files_for("8.1.3")
    assert_predicate kamal, :live_demo_available?
  end

  test "optional metadata falls back when omitted" do
    feature = CatalogFeature.new(
      slug: "sample",
      title: "Sample",
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

  test "raises when feature entry is missing required keys" do
    invalid_features = [
      {
        "slug" => "broken-feature",
        "category" => "Interactive Demo",
        "demo_type" => "runtime_demo",
        "title" => "Broken feature",
        "summary" => "Missing notes"
      }
    ]

    error = assert_raises(ArgumentError) do
      with_raw_features(invalid_features) do
        FeatureCatalog.all
      end
    end

    assert_match(/notes_by_version/, error.message)
  end

  test "raises when feature slugs are duplicated" do
    duplicate_features = [
      {
        "slug" => "same-slug",
        "category" => "Interactive Demo",
        "demo_type" => "runtime_demo",
        "title" => "Feature A",
        "summary" => "Summary A",
        "notes_by_version" => { "7.0" => "A", "8.0" => "A", "8.1.3" => "A" },
        "highlights_by_version" => { "7.0" => "A", "8.0" => "A", "8.1.3" => "A" },
        "source_links_by_version" => { "7.0" => "https://example.com/a", "8.0" => "https://example.com/a", "8.1.3" => "https://example.com/a" }
      },
      {
        "slug" => "same-slug",
        "category" => "Config / Platform Differences",
        "demo_type" => "comparison_card",
        "title" => "Feature B",
        "summary" => "Summary B",
        "notes_by_version" => { "7.0" => "B", "8.0" => "B", "8.1.3" => "B" },
        "highlights_by_version" => { "7.0" => "B", "8.0" => "B", "8.1.3" => "B" },
        "source_links_by_version" => { "7.0" => "https://example.com/b", "8.0" => "https://example.com/b", "8.1.3" => "https://example.com/b" }
      }
    ]

    error = assert_raises(ArgumentError) do
      with_raw_features(duplicate_features) do
        FeatureCatalog.all
      end
    end

    assert_match(/duplicate feature slugs/, error.message)
  end

  test "raises when versioned hashes include unknown version keys" do
    invalid_features = [
      valid_feature_hash.merge(
        "notes_by_version" => valid_feature_hash.fetch("notes_by_version").merge("9.0" => "future")
      )
    ]

    error = assert_raises(ArgumentError) do
      with_raw_features(invalid_features) do
        FeatureCatalog.all
      end
    end

    assert_match(/notes_by_version has unknown version keys: 9.0/, error.message)
  end

  test "raises when versioned hashes are missing configured version keys" do
    invalid_features = [
      valid_feature_hash.merge(
        "highlights_by_version" => valid_feature_hash.fetch("highlights_by_version").except("8.0")
      )
    ]

    error = assert_raises(ArgumentError) do
      with_raw_features(invalid_features) do
        FeatureCatalog.all
      end
    end

    assert_match(/highlights_by_version is missing version keys: 8.0/, error.message)
  end

  test "raises when source links are not absolute urls" do
    invalid_features = [
      valid_feature_hash.merge(
        "source_links_by_version" => valid_feature_hash.fetch("source_links_by_version").merge("8.0" => "/relative/path")
      )
    ]

    error = assert_raises(ArgumentError) do
      with_raw_features(invalid_features) do
        FeatureCatalog.all
      end
    end

    assert_match(/source_links_by_version.8.0 must be an absolute http\(s\) URL/, error.message)
  end

  test "allows optional metadata hashes to be omitted" do
    feature = nil

    with_raw_features([ valid_feature_hash ]) do
      feature = FeatureCatalog.all.first
    end

    assert_nil feature.status_for("8.0")
    assert_equal [], feature.files_for("8.0")
    assert_not_predicate feature, :live_demo_available?
  end

  test "loads optional metadata when present" do
    feature = nil

    with_raw_features([
      valid_feature_hash.merge(
        "status_by_version" => { "8.0" => "default" },
        "files_by_version" => { "8.0" => [ "config/queue.yml" ] },
        "upgrade_notes_by_version" => { "8.0" => [ "worker required" ] },
        "code_examples_by_version" => { "8.0" => [ "bin/jobs start" ] },
        "operational_notes_by_version" => { "8.0" => [ "check worker health" ] },
        "adoption_when" => [ "when durable jobs are needed" ],
        "adoption_cautions" => [ "when worker operations are not ready" ],
        "adoption_alternatives" => [ "Sidekiq" ],
        "adoption_requirements" => [ "worker process" ],
        "live_demo_available" => true
      )
    ]) do
      feature = FeatureCatalog.all.first
    end

    assert_equal "default", feature.status_for("8.0")
    assert_equal [ "config/queue.yml" ], feature.files_for("8.0")
    assert_equal [ "worker required" ], feature.upgrade_notes_for("8.0")
    assert_equal [ "bin/jobs start" ], feature.code_examples_for("8.0")
    assert_equal [ "check worker health" ], feature.operational_notes_for("8.0")
    assert_equal [ "when durable jobs are needed" ], feature.adoption_when
    assert_equal [ "when worker operations are not ready" ], feature.adoption_cautions
    assert_equal [ "Sidekiq" ], feature.adoption_alternatives
    assert_equal [ "worker process" ], feature.adoption_requirements
    assert_predicate feature, :adoption_readiness_available?
    assert_predicate feature, :live_demo_available?
  end

  test "raises when optional metadata hashes include unknown version keys" do
    invalid_features = [
      valid_feature_hash.merge(
        "status_by_version" => { "9.0" => "future" }
      )
    ]

    error = assert_raises(ArgumentError) do
      with_raw_features(invalid_features) do
        FeatureCatalog.all
      end
    end

    assert_match(/status_by_version has unknown version keys: 9.0/, error.message)
  end

  test "raises when live_demo_available is not boolean" do
    invalid_features = [
      valid_feature_hash.merge(
        "live_demo_available" => "yes"
      )
    ]

    error = assert_raises(ArgumentError) do
      with_raw_features(invalid_features) do
        FeatureCatalog.all
      end
    end

    assert_match(/live_demo_available must be a boolean/, error.message)
  end

  test "raises when adoption readiness metadata is not an array" do
    invalid_features = [
      valid_feature_hash.merge(
        "adoption_when" => { "8.0" => [ "versioned data is not supported here" ] }
      )
    ]

    error = assert_raises(ArgumentError) do
      with_raw_features(invalid_features) do
        FeatureCatalog.all
      end
    end

    assert_match(/adoption_when must be an array/, error.message)
  end

  private
    def valid_feature_hash
      {
        "slug" => "valid-feature",
        "category" => "Interactive Demo",
        "demo_type" => "runtime_demo",
        "title" => "Valid feature",
        "summary" => "Summary",
        "notes_by_version" => {
          "7.0" => "note 7",
          "8.0" => "note 8",
          "8.1.3" => "note 8.1.3"
        },
        "highlights_by_version" => {
          "7.0" => "highlight 7",
          "8.0" => "highlight 8",
          "8.1.3" => "highlight 8.1.3"
        },
        "source_links_by_version" => {
          "7.0" => "https://example.com/7",
          "8.0" => "https://example.com/8",
          "8.1.3" => "https://example.com/8-1-3"
        }
      }
    end

    def with_raw_features(raw_features)
      singleton_class = FeatureCatalog.singleton_class
      original_method = singleton_class.instance_method(:raw_features)

      singleton_class.send(:define_method, :raw_features) { raw_features }
      FeatureCatalog.send(:reset_cache!)
      yield
    ensure
      singleton_class.send(:define_method, :raw_features, original_method)
      FeatureCatalog.send(:reset_cache!)
    end
end
