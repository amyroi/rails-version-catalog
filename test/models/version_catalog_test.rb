require "test_helper"

class VersionCatalogTest < ActiveSupport::TestCase
  teardown do
    VersionCatalog.send(:reset_cache!)
  end

  private
    def with_raw_versions(raw_versions)
      singleton_class = VersionCatalog.singleton_class
      original_method = singleton_class.instance_method(:raw_versions)

      singleton_class.send(:define_method, :raw_versions) { raw_versions }
      VersionCatalog.send(:reset_cache!)
      yield
    ensure
      singleton_class.send(:define_method, :raw_versions, original_method)
      VersionCatalog.send(:reset_cache!)
    end

  test "default compare keys are loaded from yaml" do
    assert_equal [ "7.0", "8.0", "8.1.2" ], VersionCatalog.default_compare_keys
  end

  test "fetch returns configured version" do
    version = VersionCatalog.fetch("8.0")

    assert_equal "Rails 8.0", version.label
    assert_equal :supported, version.status
    assert_equal "https://guides.rubyonrails.org/8_0_release_notes.html", version.release_notes_url
  end

  test "normalize keeps known versions in order and removes duplicates" do
    assert_equal [ "8.0", "7.0" ], VersionCatalog.normalize([ "8.0,7.0,8.0", "unknown" ])
  end

  test "index_for returns position of configured version" do
    assert_equal 0, VersionCatalog.index_for("7.0")
    assert_equal 2, VersionCatalog.index_for("8.1.2")
    assert_equal(-1, VersionCatalog.index_for("9.0"))
  end

  test "raises when version entry is missing required keys" do
    invalid_versions = [
      {
        "key" => "8.2",
        "label" => "Rails 8.2",
        "release_date" => "June 2026",
        "status" => "supported"
      }
    ]

    error = assert_raises(ArgumentError) do
      with_raw_versions(invalid_versions) do
        VersionCatalog.all
      end
    end

    assert_match(/release_notes_url/, error.message)
  end

  test "raises when version keys are duplicated" do
    duplicate_versions = [
      {
        "key" => "8.1.2",
        "label" => "Rails 8.1.2",
        "release_date" => "January 8, 2026",
        "status" => "latest",
        "release_notes_url" => "https://guides.rubyonrails.org/8_1_release_notes.html"
      },
      {
        "key" => "8.1.2",
        "label" => "Rails 8.1.2 duplicate",
        "release_date" => "January 9, 2026",
        "status" => "supported",
        "release_notes_url" => "https://example.com/duplicate"
      }
    ]

    error = assert_raises(ArgumentError) do
      with_raw_versions(duplicate_versions) do
        VersionCatalog.all
      end
    end

    assert_match(/duplicate version keys/, error.message)
  end
end
