require "test_helper"

class FeatureCatalogFlowTest < ActionDispatch::IntegrationTest
  test "home page renders" do
    get root_path

    assert_response :success
    assert_includes response.body, "Rails Multi-Version UI Diff Catalog"
    assert_includes response.body, "Rails 7.0 / 8.0 / 8.1.2 を UI で比較するカタログ"
    assert_includes response.body, "Interactive demos"
    assert_includes response.body, "Config / platform differences"
  end

  test "feature detail renders" do
    get feature_path("solid-queue")

    assert_response :success
    assert_includes response.body, "Queue with Solid Queue"
    assert_includes response.body, "Recent jobs"
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

  test "comparison feature renders multi-version matrix" do
    get feature_path("active-job-continuations"), params: { compare: "7.0,8.0,8.1.2" }

    assert_response :success
    assert_includes response.body, "Version comparison matrix"
    assert_includes response.body, "Rails 8.1.2"
    assert_includes response.body, "ActiveJob::Continuable"
    assert_includes response.body, "Live demo (current runtime: Rails 8.1.2)"
  end
end
