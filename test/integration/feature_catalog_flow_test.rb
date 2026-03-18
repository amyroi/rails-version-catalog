require "test_helper"

class FeatureCatalogFlowTest < ActionDispatch::IntegrationTest
  test "home page renders" do
    get root_path

    assert_response :success
    assert_includes response.body, "Rails 8.0 UI Diff Catalog"
    assert_includes response.body, "Solid Queue demo"
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
end
