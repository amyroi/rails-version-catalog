require "rails_helper"

RSpec.describe VersionCatalog, type: :model do
  after do
    described_class.send(:reset_cache!)
  end

  describe "catalog behavior" do
    it "loads default compare keys from yaml" do
      expect(described_class.default_compare_keys).to eq([ "7.0", "8.0", "8.1.3" ])
    end

    it "fetches a configured version" do
      version = described_class.fetch("8.0")

      expect(version.label).to eq("Rails 8.0")
      expect(version.status).to eq(:supported)
      expect(version.release_notes_url).to eq("https://guides.rubyonrails.org/8_0_release_notes.html")
    end

    it "keeps known versions in order and removes duplicates when normalized" do
      expect(described_class.normalize([ "8.0,7.0,8.0", "unknown" ])).to eq([ "8.0", "7.0" ])
    end

    it "returns the position of a configured version" do
      expect(described_class.index_for("7.0")).to eq(0)
      expect(described_class.index_for("8.1.3")).to eq(2)
      expect(described_class.index_for("9.0")).to eq(-1)
    end

    it "raises when a version entry is missing required keys" do
      invalid_versions = [
        {
          "key" => "8.2",
          "label" => "Rails 8.2",
          "release_date" => "June 2026",
          "status" => "supported"
        }
      ]

      expect do
        with_raw_versions(invalid_versions) { described_class.all }
      end.to raise_error(ArgumentError, /release_notes_url/)
    end

    it "raises when version keys are duplicated" do
      duplicate_versions = [
        {
          "key" => "8.1.3",
          "label" => "Rails 8.1.3",
          "release_date" => "March 24, 2026",
          "status" => "latest",
          "release_notes_url" => "https://guides.rubyonrails.org/8_1_release_notes.html"
        },
        {
          "key" => "8.1.3",
          "label" => "Rails 8.1.3 duplicate",
          "release_date" => "January 9, 2026",
          "status" => "supported",
          "release_notes_url" => "https://example.com/duplicate"
        }
      ]

      expect do
        with_raw_versions(duplicate_versions) { described_class.all }
      end.to raise_error(ArgumentError, /duplicate version keys/)
    end

    it "raises when release notes url is not absolute" do
      invalid_versions = [
        {
          "key" => "8.2",
          "label" => "Rails 8.2",
          "release_date" => "June 2026",
          "status" => "supported",
          "release_notes_url" => "/relative/path"
        }
      ]

      expect do
        with_raw_versions(invalid_versions) { described_class.all }
      end.to raise_error(ArgumentError, /release_notes_url must be an absolute http\(s\) URL/)
    end
  end
end
