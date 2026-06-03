require "test_helper"

class Api::V1::Catalog::VersionsControllerTest < ActionDispatch::IntegrationTest
  test "index returns catalog versions as camelCase JSON" do
    get api_v1_catalog_versions_url

    assert_response :success

    versions = JSON.parse(response.body)
    assert_equal VersionCatalog.all.size, versions.size

    version = versions.first
    assert_equal %w[key label releaseDate releaseNotesUrl status].sort, version.keys.sort
    assert_equal "7.0", version.fetch("key")
    assert_kind_of String, version.fetch("status")
  end

  test "index does not include runtime demo data" do
    get api_v1_catalog_versions_url

    assert_response :success
    refute_includes response.body, "QueueRun"
    refute_includes response.body, "DemoMessage"
  end
end
