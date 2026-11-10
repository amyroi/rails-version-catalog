require "rails_helper"

RSpec.describe "FeatureCatalogFlow", type: :request do
  fixtures :users

  describe "catalog pages and demos" do
    {
      "7.0,8.0,8.1.3" => [ "7.0", "8.0" ],
      "8.1.3" => [ "7.0", "8.0", "8.1.4" ],
      "8.1.2" => [ "7.0", "8.0", "8.1.4" ],
      "8.1.4" => [ "8.1.4" ],
      "" => [ "7.0", "8.0", "8.1.4" ],
      "unknown" => [ "7.0", "8.0", "8.1.4" ]
    }.each do |compare, expected_keys|
      it "normalizes compare=#{compare.inspect} safely" do
        get features_path, params: { compare: compare }
        expect(response).to have_http_status(:ok)
        heading = Capybara.string(response.body).find("h1").text
        expect(heading).to include(expected_keys.map { |key| "Rails #{key}" }.join(" / "))
        expect(heading).not_to include("Rails 8.1.3", "Rails 8.1.2")
      end
    end

    it "renders the home page" do
      get root_path

      expect(response).to have_http_status(:ok)
      expect(Capybara.string(response.body).find("title", visible: :all).text(:all)).to eq("Rails Version Catalog")
      expect(response.body).to include("Rails 7.0 / Rails 8.0 / Rails 8.1.4 を UI で比較するカタログ")
      expect(response.body).to include("体験デモ")
      expect(response.body).to include("設定・基盤の違い")
    end

    it "renders the feature detail page" do
      get feature_path("solid-queue")

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Solid Queue に投入")
      expect(response.body).to include("概要")
      expect(response.body).to include("バージョン比較")
      expect(response.body).to include("コード・設定の違い")
      expect(response.body).to include("体験デモ（現在の実行環境: Rails 8.1.4）")
      expect(response.body).to include("移行時の注意")
      expect(response.body).to include("最近のジョブ")
      expect(response.body).to include("採用判断")
      expect(response.body).to include("Rails 標準に沿った永続的な Active Job 処理")
      expect(response.body).to include("Sidekiq も有力な選択肢")
    end

    it "renders the authentication generator detail page" do
      get feature_path("authentication-generator")

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("認証の流れ")
      expect(response.body).to include("試してみる")
      expect(response.body).to include("現在の状態")
    end

    it "redirects auth lab when unauthenticated" do
      get auth_lab_path

      expect(response).to redirect_to(new_session_path)
    end

    it "renders auth lab when authenticated" do
      post session_path, params: { email_address: users(:one).email_address, password: "password" }
      follow_redirect!

      get auth_lab_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(users(:one).email_address)
    end

    it "creates a queue run" do
      expect do
        post queue_runs_path, params: { queue_run: { input: "Test enqueue" } }
      end.to change(QueueRun, :count).by(1)

      expect(response).to redirect_to(feature_path("solid-queue"))
    end

    it "preserves compare query on queue run redirect" do
      expect do
        post queue_runs_path, params: { compare: "7.0", queue_run: { input: "Test enqueue" } }
      end.to change(QueueRun, :count).by(1)

      expect(response).to redirect_to(feature_path("solid-queue", compare: "7.0"))
    end

    it "preserves compare query on demo message redirect" do
      expect do
        post demo_messages_path, params: { compare: "7.0", demo_message: { author: "ゲスト", body: "Hello" } }
      end.to change(DemoMessage, :count).by(1)

      expect(response).to redirect_to(feature_path("solid-cable", compare: "7.0"))
    end

    it "preserves compare query on cache demo redirects" do
      post refresh_cache_demo_path, params: { compare: "7.0" }
      expect(response).to redirect_to(feature_path("solid-cache", compare: "7.0"))

      delete cache_demo_path, params: { compare: "7.0" }
      expect(response).to redirect_to(feature_path("solid-cache", compare: "7.0"))
    end

    it "re-renders signup failure with a validation message" do
      post users_path, params: {
        user: {
          email_address: "",
          password: "password123",
          password_confirmation: "password123"
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("メールアドレスを入力してください")
    end

    it "redirects invalid password reset token to the request form" do
      get edit_password_path(token: "invalid-token")

      expect(response).to redirect_to(new_password_path)
      follow_redirect!
      expect(response.body).to include("パスワード再設定リンクが無効か、有効期限が切れています。")
    end

    it "renders comparison feature with a multi-version matrix" do
      get feature_path("active-job-continuations"), params: { compare: "7.0,8.0,8.1.4" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("バージョン比較")
      expect(response.body).to include("説明")
      expect(response.body).to include("主な変更点")
      expect(response.body).to include("コード・設定の違い")
      expect(response.body).to include("体験デモ（現在の実行環境: Rails 8.1.4）")
      expect(response.body).to include("移行時の注意")
      expect(response.body).to include("Rails 8.1.4")
      expect(response.body).to include("ActiveJob::Continuable")
    end

    it "renders compare controls with the compare query preserved" do
      get feature_path("solid-cache"), params: { compare: "7.0" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('action="/cache_demo/refresh?compare=7.0"')
      expect(response.body).to include('action="/cache_demo?compare=7.0"')
      expect(response.body).to include('href="/features/solid-cache?compare=7.0"')
      expect(response.body).to include("採用判断")
      expect(response.body).to include("Rails 標準に沿った永続キャッシュ")
      expect(response.body).to include("Redis も適しています")
    end

    it "renders adoption readiness for kamal detail" do
      get feature_path("kamal")

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("採用判断")
      expect(response.body).to include("アプリ中心のデプロイ手順")
      expect(response.body).to include("Capistrano も馴染みのある選択肢")
      expect(response.body).to include("ローカルファイルではなく")
    end

    it "renders demo explanations from catalog data, escaping prose and inline code" do
      with_raw_features([ valid_feature_hash.merge("demo_notes" => { "description" => "Catalog <b>note</b>: `<unsafe>`" }) ]) do
        get feature_path("solid-queue")
      end

      page = Capybara.string(response.body)
      expect(page).to have_css("p", text: "Catalog <b>note</b>: <unsafe>")
      expect(page).to have_css("p code", text: "<unsafe>")
      expect(page).not_to have_css("p b", text: "note")
    end

    it "renders adoption readiness when metadata is configured" do
      with_raw_features([
        valid_feature_hash.merge(
          "adoption_when" => [ "When durable jobs should be kept in the Rails app boundary." ],
          "adoption_cautions" => [ "When worker process operations are not owned yet." ],
          "adoption_alternatives" => [ "Sidekiq for existing Redis-backed job operations." ],
          "adoption_requirements" => [ "A running worker process and queue database schema." ]
        )
      ]) do
        get feature_path("solid-queue")
      end

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("採用判断")
      expect(response.body).to include("採用を検討する条件")
      expect(response.body).to include("注意点")
      expect(response.body).to include("代替案")
      expect(response.body).to include("実行環境の必要条件")
      expect(response.body).to include("When durable jobs should be kept in the Rails app boundary.")
    end

    it "hides adoption readiness when metadata is omitted" do
      with_raw_features([ valid_feature_hash ]) do
        get feature_path("solid-queue")
      end

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include("採用判断")
    end
  end

  def valid_feature_hash
    {
      "slug" => "solid-queue",
      "category" => "Interactive Demo",
      "demo_type" => "runtime_demo",
      "title" => "Solid Queue",
      "demo_notes" => { "description" => "Queue demo instructions" },
      "summary" => "A feature used to exercise adoption readiness rendering.",
      "notes_by_version" => {
        "7.0" => "Rails 7 note",
        "8.0" => "Rails 8 note",
        "8.1.4" => "Rails 8.1 の補足"
      },
      "highlights_by_version" => {
        "7.0" => "Rails 7 highlight",
        "8.0" => "Rails 8 highlight",
        "8.1.4" => "Rails 8.1 highlight"
      },
      "source_links_by_version" => {
        "7.0" => "https://example.com/rails-7",
        "8.0" => "https://example.com/rails-8",
        "8.1.4" => "https://example.com/rails-8-1"
      }
    }
  end
end
