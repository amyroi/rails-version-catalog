require "test_helper"

class FeatureCatalogFlowTest < ActionDispatch::IntegrationTest
  test "home page renders" do
    get root_path

    assert_response :success
    assert_includes response.body, "Rails Multi-Version UI Diff Catalog"
    assert_includes response.body, "Rails 7.0 / Rails 8.0 / Rails 8.1.2 を UI で比較するカタログ"
    assert_includes response.body, "Interactive demos"
    assert_includes response.body, "Config / platform differences"
  end

  test "feature detail renders" do
    get feature_path("solid-queue")

    assert_response :success
    assert_includes response.body, "Queue with Solid Queue"
    assert_includes response.body, "Version comparison matrix"
    assert_includes response.body, "Live demo (current runtime: Rails 8.1.2)"
    assert_includes response.body, "Recent jobs"
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
    get feature_path("active-job-continuations"), params: { compare: "7.0,8.0,8.1.2" }

    assert_response :success
    assert_includes response.body, "Version comparison matrix"
    assert_includes response.body, "Live demo (current runtime: Rails 8.1.2)"
    assert_includes response.body, "Rails 8.1.2"
    assert_includes response.body, "ActiveJob::Continuable"
  end
end
