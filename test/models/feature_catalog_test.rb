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
    assert_equal "Continuations-ready durable queue", feature.highlight_for("8.1.2")
    assert_equal "Production default durable queue", feature.status_for("8.0")
    assert_equal [ "config/queue.yml", "db/queue_schema.rb", "bin/jobs" ], feature.files_for("8.0")
    assert_equal [ "config.active_job.queue_adapter = :solid_queue" ], feature.code_examples_for("8.0")
    assert_equal [ "Keep `bin/jobs start` or an equivalent worker command running." ], feature.operational_notes_for("8.0")
    assert_equal "https://guides.rubyonrails.org/8_1_release_notes.html", feature.source_for("8.1.2")
    assert_equal "Durable queue with continuations baseline", feature.status_for("8.1.2")
    assert_equal [ "app/views/features/demos/_solid_queue.html.erb", "app/models/queue_run.rb", "app/jobs/queue_run_job.rb" ], feature.files_for("8.1.2")
    assert_predicate feature, :live_demo_available?
  end

  test "loads authentication generator metadata from yaml" do
    feature = FeatureCatalog.fetch!("authentication-generator")

    assert_equal "First-party authentication generator", feature.highlight_for("8.0")
    assert_equal "First-party generator baseline", feature.status_for("8.0")
    assert_equal [ "app/models/user.rb", "app/models/session.rb", "app/controllers/sessions_controller.rb", "app/controllers/passwords_controller.rb" ], feature.files_for("8.0")
    assert_equal [ "bin/rails generate authentication" ], feature.code_examples_for("7.0")
    assert_equal [ "Confirm password reset mail delivery and signed session cookies." ], feature.operational_notes_for("8.0")
    assert_equal [ "app/models/current.rb", "app/models/session.rb", "app/views/auth_labs/show.html.erb", "app/views/passwords/edit.html.erb" ], feature.files_for("8.1.2")
    assert_predicate feature, :live_demo_available?
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
        "notes_by_version" => { "7.0" => "A", "8.0" => "A", "8.1.2" => "A" },
        "highlights_by_version" => { "7.0" => "A", "8.0" => "A", "8.1.2" => "A" },
        "source_links_by_version" => { "7.0" => "https://example.com/a", "8.0" => "https://example.com/a", "8.1.2" => "https://example.com/a" }
      },
      {
        "slug" => "same-slug",
        "category" => "Config / Platform Differences",
        "demo_type" => "comparison_card",
        "title" => "Feature B",
        "summary" => "Summary B",
        "notes_by_version" => { "7.0" => "B", "8.0" => "B", "8.1.2" => "B" },
        "highlights_by_version" => { "7.0" => "B", "8.0" => "B", "8.1.2" => "B" },
        "source_links_by_version" => { "7.0" => "https://example.com/b", "8.0" => "https://example.com/b", "8.1.2" => "https://example.com/b" }
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
          "8.1.2" => "note 8.1.2"
        },
        "highlights_by_version" => {
          "7.0" => "highlight 7",
          "8.0" => "highlight 8",
          "8.1.2" => "highlight 8.1.2"
        },
        "source_links_by_version" => {
          "7.0" => "https://example.com/7",
          "8.0" => "https://example.com/8",
          "8.1.2" => "https://example.com/8-1-2"
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
