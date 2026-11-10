require "rails_helper"

RSpec.describe "Attribute translation usage", type: :request do
  fixtures :users

  around do |example|
    original_backend = I18n.backend
    I18n.backend = I18n::Backend::Simple.new
    I18n.backend.eager_load!
    I18n.backend.store_translations(:ja, activerecord: { attributes: {
      user: { email_address: "検証用メール", password: "検証用パスワード", password_confirmation: "検証用確認欄" },
      queue_run: { input: "検証用ジョブ入力" },
      demo_message: { author: "検証用投稿者", body: "検証用本文" }
    } })
    example.run
  ensure
    I18n.backend = original_backend
  end

  it "uses the same User attribute definitions on the home page and authentication forms" do
    get root_path
    page = Capybara.string(response.body)
    expect(page).to have_css("p", text: "検証用メール: demo@example.com")
    expect(page).to have_css("p", text: "検証用パスワード: password123")

    [ new_user_path, new_session_path, new_password_path ].each do |path|
      get path
      page = Capybara.string(response.body)
      expect(page).to have_field("検証用メール"), path
      expect(page).not_to have_field("メールアドレス"), path
    end

    [ new_user_path, new_session_path, edit_password_path(token: users(:one).password_reset_token) ].each do |path|
      get path
      page = Capybara.string(response.body)
      expect(page).to have_field("検証用パスワード", exact: true), path
      expect(page).not_to have_field("パスワード", exact: true), path
    end

    [ new_user_path, edit_password_path(token: users(:one).password_reset_token) ].each do |path|
      get path
      expect(Capybara.string(response.body)).to have_field("検証用確認欄"), path
    end
  end

  it "uses the catalog demo models' attribute definitions for their form labels" do
    get feature_path("solid-queue")
    expect(Capybara.string(response.body)).to have_field("検証用ジョブ入力")

    get feature_path("solid-cable")
    page = Capybara.string(response.body)
    expect(page).to have_field("検証用投稿者")
    expect(page).to have_field("検証用本文")
  end

  it "keeps validation errors and form labels consistent when translations change" do
    post users_path, params: { user: { email_address: "", password: "password", password_confirmation: "password" } }
    expect(response).to have_http_status(:unprocessable_content)
    page = Capybara.string(response.body)
    expect(page).to have_field("検証用メール")
    expect(page).to have_text("検証用メールを入力してください")

    post queue_runs_path, params: { queue_run: { input: "" } }
    follow_redirect!
    page = Capybara.string(response.body)
    expect(page).to have_field("検証用ジョブ入力")
    expect(page).to have_text("検証用ジョブ入力を入力してください")
  end
end
