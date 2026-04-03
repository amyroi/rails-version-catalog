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
    assert_equal "https://guides.rubyonrails.org/8_1_release_notes.html", feature.source_for("8.1.2")
  end

  test "raises when feature entry is missing required keys" do
    invalid_features = [
      {
        "slug" => "broken-feature",
        "category" => "Runtime Demo",
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
        "category" => "Runtime Demo",
        "demo_type" => "runtime_demo",
        "title" => "Feature A",
        "summary" => "Summary A",
        "notes_by_version" => { "7.0" => "A" },
        "highlights_by_version" => { "7.0" => "A" },
        "source_links_by_version" => { "7.0" => "https://example.com/a" }
      },
      {
        "slug" => "same-slug",
        "category" => "Platform / Defaults",
        "demo_type" => "comparison_card",
        "title" => "Feature B",
        "summary" => "Summary B",
        "notes_by_version" => { "7.0" => "B" },
        "highlights_by_version" => { "7.0" => "B" },
        "source_links_by_version" => { "7.0" => "https://example.com/b" }
      }
    ]

    error = assert_raises(ArgumentError) do
      with_raw_features(duplicate_features) do
        FeatureCatalog.all
      end
    end

    assert_match(/duplicate feature slugs/, error.message)
  end

  private
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
