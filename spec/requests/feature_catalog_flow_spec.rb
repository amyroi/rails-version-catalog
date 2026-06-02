require "rails_helper"

RSpec.describe "FeatureCatalogFlow", type: :request do
  describe "catalog pages and demos" do
    it "renders the home page" do
      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Rails Version Catalog")
      expect(response.body).to include("Rails 7.0 / Rails 8.0 / Rails 8.1.3 を UI で比較するカタログ")
      expect(response.body).to include("Interactive demos")
      expect(response.body).to include("Config / platform differences")
    end

    it "renders the feature detail page" do
      get feature_path("solid-queue")

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Queue with Solid Queue")
      expect(response.body).to include("Overview")
      expect(response.body).to include("Version comparison matrix")
      expect(response.body).to include("Code / config diff")
      expect(response.body).to include("Live demo (current runtime: Rails 8.1.3)")
      expect(response.body).to include("Upgrade notes")
      expect(response.body).to include("Recent jobs")
      expect(response.body).to include("Adoption readiness")
      expect(response.body).to include("You want Rails-native durable Active Job processing")
      expect(response.body).to include("Sidekiq remains a strong option")
    end

    it "renders the authentication generator detail page" do
      get feature_path("authentication-generator")

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Authentication flow")
      expect(response.body).to include("Quick try")
      expect(response.body).to include("Current status")
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
        post demo_messages_path, params: { compare: "7.0", demo_message: { author: "Guest", body: "Hello" } }
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

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Email address can&#39;t be blank")
    end

    it "redirects invalid password reset token to the request form" do
      get edit_password_path(token: "invalid-token")

      expect(response).to redirect_to(new_password_path)
      follow_redirect!
      expect(response.body).to include("Password reset link is invalid or has expired.")
    end

    it "renders comparison feature with a multi-version matrix" do
      get feature_path("active-job-continuations"), params: { compare: "7.0,8.0,8.1.3" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Version comparison matrix")
      expect(response.body).to include("Summary")
      expect(response.body).to include("Key changes")
      expect(response.body).to include("Code / config diff")
      expect(response.body).to include("Live demo (current runtime: Rails 8.1.3)")
      expect(response.body).to include("Upgrade notes")
      expect(response.body).to include("Rails 8.1.3")
      expect(response.body).to include("ActiveJob::Continuable")
    end

    it "renders compare controls with the compare query preserved" do
      get feature_path("solid-cache"), params: { compare: "7.0" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('action="/cache_demo/refresh?compare=7.0"')
      expect(response.body).to include('action="/cache_demo?compare=7.0"')
      expect(response.body).to include('href="/features/solid-cache?compare=7.0"')
      expect(response.body).to include("Adoption readiness")
      expect(response.body).to include("You want a Rails-native durable cache option")
      expect(response.body).to include("Redis remains a good fit")
    end

    it "renders adoption readiness for kamal detail" do
      get feature_path("kamal")

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Adoption readiness")
      expect(response.body).to include("You want an app-centric deploy flow")
      expect(response.body).to include("Capistrano remains a familiar option")
      expect(response.body).to include("instead of local files such as")
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
      expect(response.body).to include("Adoption readiness")
      expect(response.body).to include("When to consider")
      expect(response.body).to include("Cautions")
      expect(response.body).to include("Alternatives")
      expect(response.body).to include("Runtime requirements")
      expect(response.body).to include("When durable jobs should be kept in the Rails app boundary.")
    end

    it "hides adoption readiness when metadata is omitted" do
      with_raw_features([ valid_feature_hash ]) do
        get feature_path("solid-queue")
      end

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include("Adoption readiness")
    end
  end

  def valid_feature_hash
    {
      "slug" => "solid-queue",
      "category" => "Interactive Demo",
      "demo_type" => "runtime_demo",
      "title" => "Solid Queue",
      "summary" => "A feature used to exercise adoption readiness rendering.",
      "notes_by_version" => {
        "7.0" => "Rails 7 note",
        "8.0" => "Rails 8 note",
        "8.1.3" => "Rails 8.1 note"
      },
      "highlights_by_version" => {
        "7.0" => "Rails 7 highlight",
        "8.0" => "Rails 8 highlight",
        "8.1.3" => "Rails 8.1 highlight"
      },
      "source_links_by_version" => {
        "7.0" => "https://example.com/rails-7",
        "8.0" => "https://example.com/rails-8",
        "8.1.3" => "https://example.com/rails-8-1"
      }
    }
  end
end
