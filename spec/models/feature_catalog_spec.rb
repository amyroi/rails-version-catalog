require "rails_helper"

RSpec.describe FeatureCatalog, type: :model do
  it "keeps all feature version maps aligned with the catalog" do
    features = YAML.safe_load_file(FeatureCatalog::DATA_PATH, aliases: false).fetch("features")
    expected_keys = VersionCatalog.default_compare_keys

    features.each do |feature|
      FeatureCatalog::VERSIONED_KEYS.each do |key|
        expect(feature.fetch(key).keys).to match_array(expected_keys), "#{feature.fetch('slug')}: #{key}"
      end
      FeatureCatalog::OPTIONAL_VERSIONED_KEYS.each do |key|
        expect(feature.fetch(key, {}).keys - expected_keys).to be_empty, "#{feature.fetch('slug')}: #{key}"
      end
    end
  end
  after do
    described_class.send(:reset_cache!)
  end

  describe ".all" do
    it "loads all features from yaml" do
      expect(described_class.all.size).to eq(14)
    end
  end

  describe "catalog accessors" do
    it "returns runtime demos and comparison cards" do
      expect(described_class.runtime_demos.size).to eq(5)
      expect(described_class.comparison_cards.size).to eq(9)
    end

    it "fetches a configured feature" do
      feature = described_class.fetch!("solid-queue")

      expect(feature.title).to eq("Solid Queue")
      expect(feature.demo_type).to eq(:runtime_demo)
      expect(feature.highlight_for("8.1.4")).to eq("ジョブの継続処理と組み合わせ")
      expect(feature.status_for("8.0")).to eq("本番環境の標準は永続キュー")
      expect(feature.files_for("8.0")).to eq([ "config/queue.yml", "db/queue_schema.rb", "bin/jobs" ])
      expect(feature.code_examples_for("8.0")).to eq([ "config.active_job.queue_adapter = :solid_queue" ])
      expect(feature.operational_notes_for("8.0")).to eq([ "bin/jobs start または同等のコマンドでワーカーを常時稼働させます。" ])
      expect(feature.source_for("8.1.4")).to eq("https://guides.rubyonrails.org/8_1_release_notes.html")
      expect(feature.status_for("8.1.4")).to eq("永続キューと継続処理の基盤を利用")
      expect(feature.files_for("8.1.4")).to eq([ "app/views/features/demos/_solid_queue.html.erb", "app/models/queue_run.rb", "app/jobs/queue_run_job.rb" ])
      expect(feature.adoption_when).to include("Redis ベースのジョブ基盤を先に追加せず、Rails の Active Job でジョブを永続化したい場合。")
      expect(feature.adoption_cautions).to include("ワーカーの起動、キューのスキーマ、再試行、運用責任を確認するまでは、そのまま置き換えられると考えないでください。")
      expect(feature.adoption_alternatives).to include("Redis を使ったジョブ運用が定着している場合は、Sidekiq も有力な選択肢です。")
      expect(feature.adoption_requirements).to include("bin/jobs または同等のワーカー起動コマンドを、開発・デプロイのプロセス管理に組み込みます。")
      expect(feature).to be_adoption_readiness_available
      expect(feature).to be_live_demo_available
    end

    it "loads solid cache and solid cable metadata from yaml" do
      solid_cache = described_class.fetch!("solid-cache")
      solid_cable = described_class.fetch!("solid-cable")

      expect(solid_cache.status_for("8.0")).to eq("データベースを使うキャッシュを標準構成に追加")
      expect(solid_cache.files_for("8.0")).to eq([ "config/cache.yml", "app/views/features/demos/_solid_cache.html.erb", "app/controllers/features_controller.rb" ])
      expect(solid_cache.code_examples_for("8.0")).to eq([ "cache do" ])
      expect(solid_cache.operational_notes_for("8.0")).to eq([ "キャッシュ用データベースと保持期間を、実際の負荷に合わせます。" ])
      expect(solid_cache.adoption_when).to include("キャッシュの保存だけを目的に Redis を追加せず、Rails の構成でキャッシュを永続化したい場合。")
      expect(solid_cache.adoption_cautions).to include("データベースの容量、保持期間、削除処理を把握するまでは、キャッシュのアクセスをデータベースに移さないでください。")
      expect(solid_cache.adoption_alternatives).to include("Redis を運用していて、そのメモリ管理や監視の仕組みに依存する場合は Redis も適しています。")
      expect(solid_cache.adoption_requirements).to include("本番利用前に、キャッシュ用テーブルの容量、有効期限、削除処理を監視できるようにします。")
      expect(solid_cache).to be_adoption_readiness_available
      expect(solid_cache).to be_live_demo_available

      expect(solid_cable.status_for("8.0")).to eq("データベースによる配信が標準構成に追加")
      expect(solid_cable.files_for("8.0")).to eq([ "config/cable.yml", "app/views/features/demos/_solid_cable.html.erb", "app/controllers/features_controller.rb" ])
      expect(solid_cable.code_examples_for("8.0")).to eq([ "adapter: solid_cable" ])
      expect(solid_cable.operational_notes_for("8.0")).to eq([ "開発・本番の両方で、配信用データベースのスキーマと接続を維持します。" ])
      expect(solid_cable).to be_live_demo_available
    end

    it "loads authentication generator metadata from yaml" do
      feature = described_class.fetch!("authentication-generator")

      expect(feature.highlight_for("8.0")).to eq("標準の認証ジェネレータを追加")
      expect(feature.status_for("8.0")).to eq("標準ジェネレータを利用可能")
      expect(feature.files_for("8.0")).to eq([ "app/models/user.rb", "app/models/session.rb", "app/controllers/sessions_controller.rb", "app/controllers/passwords_controller.rb" ])
      expect(feature.code_examples_for("7.0")).to eq([ "bin/rails generate authentication" ])
      expect(feature.operational_notes_for("8.0")).to eq([ "再設定メールの配送と、署名付きセッション Cookie を確認します。" ])
      expect(feature.files_for("8.1.4")).to eq([ "app/models/current.rb", "app/models/session.rb", "app/views/auth_labs/show.html.erb", "app/views/passwords/edit.html.erb" ])
      expect(feature).to be_live_demo_available
    end

    it "loads propshaft and kamal metadata from yaml" do
      propshaft = described_class.fetch!("propshaft")
      kamal = described_class.fetch!("kamal")

      expect(propshaft.status_for("8.0")).to eq("アセットパイプラインの標準は Propshaft")
      expect(propshaft.files_for("8.0")).to eq([ "config/importmap.rb", "app/views/features/demos/_propshaft.html.erb", "app/controllers/features_controller.rb" ])
      expect(propshaft.code_examples_for("8.0")).to eq([ "Propshaft enabled" ])
      expect(propshaft.operational_notes_for("8.0")).to eq([ "アセットの事前コンパイルと、フィンガープリント付きファイルの処理を確認します。" ])
      expect(propshaft).to be_live_demo_available

      expect(kamal.status_for("8.0")).to eq("Kamal が標準のデプロイ構成に追加")
      expect(kamal.files_for("8.0")).to eq([ "config/deploy.yml", ".kamal/secrets", "app/views/features/demos/_kamal.html.erb" ])
      expect(kamal.code_examples_for("8.0")).to eq([ "config/deploy.yml" ])
      expect(kamal.operational_notes_for("8.0")).to eq([ "イメージの保存先、プロキシ、シークレットの設定をまとめて確認します。" ])
      expect(kamal.files_for("8.1.4")).to eq([ "config/deploy.yml", ".kamal/secrets", "app/views/features/demos/_kamal.html.erb" ])
      expect(kamal.adoption_when).to include("コンテナイメージ、サーバー一覧、プロキシ、シークレットを Rails のリポジトリから確認できるデプロイを求める場合。")
      expect(kamal.adoption_cautions).to include("生成した設定ファイルだけで運用できるとは考えないでください。サーバー接続、レジストリの認証、プロキシ、切り戻しにも運用責任が必要です。")
      expect(kamal.adoption_alternatives).to include("Kamal のコンテナ構成を採用せず SSH でデプロイしたい場合は、Capistrano も選択肢です。")
      expect(kamal.adoption_requirements).to include("本番利用前に、config/deploy.yml に実際のサーバー・イメージ・プロキシ・環境設定を指定します。")
      expect(kamal).to be_adoption_readiness_available
      expect(kamal).to be_live_demo_available
    end
  end

  describe "validation and fallback behavior" do
    it "falls back when optional metadata is omitted" do
      feature = CatalogFeature.new(
        slug: "sample",
        title: "Sample",
        category: "Interactive Demo",
        summary: "summary",
        supported_versions: %w[7.0 8.0 8.1.4],
        notes_by_version: { "7.0" => "note 7", "8.0" => "note 8", "8.1.4" => "note 8.1.4" },
        highlights_by_version: { "7.0" => "h7", "8.0" => "h8", "8.1.4" => "h813" },
        demo_type: :runtime_demo,
        source_links_by_version: {
          "7.0" => "https://example.com/7",
          "8.0" => "https://example.com/8",
          "8.1.4" => "https://example.com/813"
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

    it "raises when a feature entry is missing required keys" do
      invalid_features = [
        {
          "slug" => "broken-feature",
          "category" => "Interactive Demo",
          "demo_type" => "runtime_demo",
          "title" => "Broken feature",
          "summary" => "Missing notes"
        }
      ]

      expect do
        with_raw_features(invalid_features) { described_class.all }
      end.to raise_error(ArgumentError, /notes_by_version/)
    end

    it "raises when feature slugs are duplicated" do
      duplicate_features = [
        {
          "slug" => "same-slug",
          "category" => "Interactive Demo",
          "demo_type" => "runtime_demo",
          "title" => "Feature A",
          "summary" => "Summary A",
          "notes_by_version" => { "7.0" => "A", "8.0" => "A", "8.1.4" => "A" },
          "highlights_by_version" => { "7.0" => "A", "8.0" => "A", "8.1.4" => "A" },
          "source_links_by_version" => { "7.0" => "https://example.com/a", "8.0" => "https://example.com/a", "8.1.4" => "https://example.com/a" }
        },
        {
          "slug" => "same-slug",
          "category" => "Config / Platform Differences",
          "demo_type" => "comparison_card",
          "title" => "Feature B",
          "summary" => "Summary B",
          "notes_by_version" => { "7.0" => "B", "8.0" => "B", "8.1.4" => "B" },
          "highlights_by_version" => { "7.0" => "B", "8.0" => "B", "8.1.4" => "B" },
          "source_links_by_version" => { "7.0" => "https://example.com/b", "8.0" => "https://example.com/b", "8.1.4" => "https://example.com/b" }
        }
      ]

      expect do
        with_raw_features(duplicate_features) { described_class.all }
      end.to raise_error(ArgumentError, /duplicate feature slugs/)
    end

    it "raises when versioned hashes include unknown version keys" do
      invalid_features = [
        valid_feature_hash.merge(
          "notes_by_version" => valid_feature_hash.fetch("notes_by_version").merge("9.0" => "future")
        )
      ]

      expect do
        with_raw_features(invalid_features) { described_class.all }
      end.to raise_error(ArgumentError, /notes_by_version has unknown version keys: 9.0/)
    end

    it "raises when versioned hashes are missing configured version keys" do
      invalid_features = [
        valid_feature_hash.merge(
          "highlights_by_version" => valid_feature_hash.fetch("highlights_by_version").except("8.0")
        )
      ]

      expect do
        with_raw_features(invalid_features) { described_class.all }
      end.to raise_error(ArgumentError, /highlights_by_version is missing version keys: 8.0/)
    end

    it "raises when source links are not absolute urls" do
      invalid_features = [
        valid_feature_hash.merge(
          "source_links_by_version" => valid_feature_hash.fetch("source_links_by_version").merge("8.0" => "/relative/path")
        )
      ]

      expect do
        with_raw_features(invalid_features) { described_class.all }
      end.to raise_error(ArgumentError, /source_links_by_version.8.0 must be an absolute http\(s\) URL/)
    end

    it "allows optional metadata hashes to be omitted" do
      feature = nil

      with_raw_features([ valid_feature_hash ]) do
        feature = described_class.all.first
      end

      expect(feature.status_for("8.0")).to be_nil
      expect(feature.files_for("8.0")).to eq([])
      expect(feature).not_to be_live_demo_available
    end

    it "loads optional metadata when present" do
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
        feature = described_class.all.first
      end

      expect(feature.status_for("8.0")).to eq("default")
      expect(feature.files_for("8.0")).to eq([ "config/queue.yml" ])
      expect(feature.upgrade_notes_for("8.0")).to eq([ "worker required" ])
      expect(feature.code_examples_for("8.0")).to eq([ "bin/jobs start" ])
      expect(feature.operational_notes_for("8.0")).to eq([ "check worker health" ])
      expect(feature.adoption_when).to eq([ "when durable jobs are needed" ])
      expect(feature.adoption_cautions).to eq([ "when worker operations are not ready" ])
      expect(feature.adoption_alternatives).to eq([ "Sidekiq" ])
      expect(feature.adoption_requirements).to eq([ "worker process" ])
      expect(feature).to be_adoption_readiness_available
      expect(feature).to be_live_demo_available
    end

    it "raises when optional metadata hashes include unknown version keys" do
      invalid_features = [
        valid_feature_hash.merge(
          "status_by_version" => { "9.0" => "future" }
        )
      ]

      expect do
        with_raw_features(invalid_features) { described_class.all }
      end.to raise_error(ArgumentError, /status_by_version has unknown version keys: 9.0/)
    end

    it "raises when live_demo_available is not boolean" do
      invalid_features = [
        valid_feature_hash.merge(
          "live_demo_available" => "yes"
        )
      ]

      expect do
        with_raw_features(invalid_features) { described_class.all }
      end.to raise_error(ArgumentError, /live_demo_available must be a boolean/)
    end

    it "raises when adoption readiness metadata is not an array" do
      invalid_features = [
        valid_feature_hash.merge(
          "adoption_when" => { "8.0" => [ "versioned data is not supported here" ] }
        )
      ]

      expect do
        with_raw_features(invalid_features) { described_class.all }
      end.to raise_error(ArgumentError, /adoption_when must be an array/)
    end
  end

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
        "8.1.4" => "note 8.1.4"
      },
      "highlights_by_version" => {
        "7.0" => "highlight 7",
        "8.0" => "highlight 8",
        "8.1.4" => "highlight 8.1.4"
      },
      "source_links_by_version" => {
        "7.0" => "https://example.com/7",
        "8.0" => "https://example.com/8",
        "8.1.4" => "https://example.com/8-1-4"
      }
    }
  end
end
