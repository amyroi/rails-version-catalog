require "rails_helper"

RSpec.describe CatalogFeature, type: :model do
  describe "optional metadata" do
    it "returns optional metadata through public api" do
      feature = described_class.new(
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

      expect(feature.status_for("8.0")).to eq("default")
      expect(feature.files_for("8.0")).to eq([ "config/queue.yml" ])
      expect(feature.upgrade_notes_for("8.0")).to eq([ "start worker" ])
      expect(feature.code_examples_for("8.0")).to eq([ "bin/jobs start" ])
      expect(feature.operational_notes_for("8.0")).to eq([ "check queue worker" ])
      expect(feature.adoption_when).to eq([ "when durable jobs are needed" ])
      expect(feature.adoption_cautions).to eq([ "when worker operations are not ready" ])
      expect(feature.adoption_alternatives).to eq([ "Sidekiq" ])
      expect(feature.adoption_requirements).to eq([ "worker process" ])
      expect(feature).to be_adoption_readiness_available
      expect(feature).to be_live_demo_available
    end

    it "returns fallback values for missing optional metadata" do
      feature = described_class.new(
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

      expect(feature.status_for("8.0")).to be_nil
      expect(feature.files_for("8.0")).to eq([])
      expect(feature.upgrade_notes_for("8.0")).to eq([])
      expect(feature.code_examples_for("8.0")).to eq([])
      expect(feature.operational_notes_for("8.0")).to eq([])
      expect(feature.adoption_when).to eq([])
      expect(feature.adoption_cautions).to eq([])
      expect(feature.adoption_alternatives).to eq([])
      expect(feature.adoption_requirements).to eq([])
      expect(feature).not_to be_adoption_readiness_available
      expect(feature).not_to be_live_demo_available
    end
  end
end
