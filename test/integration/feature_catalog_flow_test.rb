require "test_helper"

class FeatureCatalogFlowTest < ActionDispatch::IntegrationTest
  test "home page renders" do
    get root_path

    assert_response :success
    assert_includes response.body, "Rails Version Catalog"
    assert_includes response.body, "Rails 7.0 / Rails 8.0 / Rails 8.1.3 を UI で比較するカタログ"
    assert_includes response.body, "Interactive demos"
    assert_includes response.body, "Config / platform differences"
  end

  test "feature detail renders" do
    get feature_path("solid-queue")

    assert_response :success
    assert_includes response.body, "Queue with Solid Queue"
    assert_includes response.body, "Overview"
    assert_includes response.body, "Version comparison matrix"
    assert_includes response.body, "Code / config diff"
    assert_includes response.body, "Live demo (current runtime: Rails 8.1.3)"
    assert_includes response.body, "Upgrade notes"
    assert_includes response.body, "Recent jobs"
    assert_includes response.body, "Adoption readiness"
    assert_includes response.body, "You want Rails-native durable Active Job processing"
    assert_includes response.body, "Sidekiq remains a strong option"
  end

  test "authentication generator detail renders" do
    get feature_path("authentication-generator")

    assert_response :success
    assert_includes response.body, "Authentication flow"
    assert_includes response.body, "Quick try"
    assert_includes response.body, "Current status"
  end

  test "auth lab redirects when unauthenticated" do
    get auth_lab_path

    assert_redirected_to new_session_path
  end

  test "auth lab renders when authenticated" do
    post session_path, params: { email_address: users(:one).email_address, password: "password" }
    follow_redirect!

    get auth_lab_path
    assert_response :success
    assert_includes response.body, users(:one).email_address
  end

  test "queue run can be created" do
    assert_difference("QueueRun.count", 1) do
      post queue_runs_path, params: { queue_run: { input: "Test enqueue" } }
    end

    assert_redirected_to feature_path("solid-queue")
  end

  test "queue run preserves compare query on redirect" do
    assert_difference("QueueRun.count", 1) do
      post queue_runs_path, params: { compare: "7.0", queue_run: { input: "Test enqueue" } }
    end

    assert_redirected_to feature_path("solid-queue", compare: "7.0")
  end

  test "demo message preserves compare query on redirect" do
    assert_difference("DemoMessage.count", 1) do
      post demo_messages_path, params: { compare: "7.0", demo_message: { author: "Guest", body: "Hello" } }
    end

    assert_redirected_to feature_path("solid-cable", compare: "7.0")
  end

  test "cache demo actions preserve compare query on redirect" do
    post refresh_cache_demo_path, params: { compare: "7.0" }
    assert_redirected_to feature_path("solid-cache", compare: "7.0")

    delete cache_demo_path, params: { compare: "7.0" }
    assert_redirected_to feature_path("solid-cache", compare: "7.0")
  end

  test "signup failure re-renders with validation message" do
    post users_path, params: {
      user: {
        email_address: "",
        password: "password123",
        password_confirmation: "password123"
      }
    }

    assert_response :unprocessable_entity
    assert_includes response.body, "Email address can&#39;t be blank"
  end

  test "invalid password reset token redirects to request form" do
    get edit_password_path(token: "invalid-token")

    assert_redirected_to new_password_path
    follow_redirect!
    assert_includes response.body, "Password reset link is invalid or has expired."
  end

  test "comparison feature renders multi-version matrix" do
    get feature_path("active-job-continuations"), params: { compare: "7.0,8.0,8.1.3" }

    assert_response :success
    assert_includes response.body, "Version comparison matrix"
    assert_includes response.body, "Summary"
    assert_includes response.body, "Key changes"
    assert_includes response.body, "Code / config diff"
    assert_includes response.body, "Live demo (current runtime: Rails 8.1.3)"
    assert_includes response.body, "Upgrade notes"
    assert_includes response.body, "Rails 8.1.3"
    assert_includes response.body, "ActiveJob::Continuable"
  end

  test "feature detail renders compare controls with preserved compare query" do
    get feature_path("solid-cache"), params: { compare: "7.0" }

    assert_response :success
    assert_includes response.body, 'action="/cache_demo/refresh?compare=7.0"'
    assert_includes response.body, 'action="/cache_demo?compare=7.0"'
    assert_includes response.body, 'href="/features/solid-cache?compare=7.0"'
    assert_includes response.body, "Adoption readiness"
    assert_includes response.body, "You want a Rails-native durable cache option"
    assert_includes response.body, "Redis remains a good fit"
  end

  test "kamal detail renders adoption readiness" do
    get feature_path("kamal")

    assert_response :success
    assert_includes response.body, "Adoption readiness"
    assert_includes response.body, "You want an app-centric deploy flow"
    assert_includes response.body, "Capistrano remains a familiar option"
    assert_includes response.body, "RAILS_MASTER_KEY=$(cat config/master.key)"
  end

  test "feature detail renders adoption readiness when metadata is configured" do
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

    assert_response :success
    assert_includes response.body, "Adoption readiness"
    assert_includes response.body, "When to consider"
    assert_includes response.body, "Cautions"
    assert_includes response.body, "Alternatives"
    assert_includes response.body, "Runtime requirements"
    assert_includes response.body, "When durable jobs should be kept in the Rails app boundary."
  end

  test "feature detail hides adoption readiness when metadata is omitted" do
    with_raw_features([ valid_feature_hash ]) do
      get feature_path("solid-queue")
    end

    assert_response :success
    assert_not_includes response.body, "Adoption readiness"
  end

  private
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
