require "rails_helper"

RSpec.describe "Api::V1::Catalog::Versions", type: :request do
  describe "GET /api/v1/catalog/versions" do
    it "returns catalog versions as camelCase JSON" do
      get api_v1_catalog_versions_path

      expect(response).to have_http_status(:ok)

      versions = JSON.parse(response.body)
      expect(versions.size).to eq(VersionCatalog.all.size)

      version = versions.first
      expect(version.keys.sort).to eq(%w[key label releaseDate releaseNotesUrl status].sort)
      expect(version.fetch("key")).to eq("7.0")
      expect(version.fetch("status")).to be_a(String)
    end

    it "does not include runtime demo data" do
      get api_v1_catalog_versions_path

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include("QueueRun")
      expect(response.body).not_to include("DemoMessage")
    end
  end
end
