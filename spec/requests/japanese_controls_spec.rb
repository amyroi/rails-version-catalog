require "rails_helper"

RSpec.describe "Japanese controls", type: :request do
  around do |example|
    I18n.with_locale(:ja) { example.run }
  end

  it "renders every feature with Japanese comparison controls" do
    FeatureCatalog.all.each do |feature|
      get feature_path(feature.slug)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("バージョン別の比較", "すべて表示", "操作デモ")
      expect(response.body).not_to include("translation_missing", "Translation missing")
    end
  end

  it "uses model attribute names in unbound login and reset forms" do
    [ new_session_path, new_password_path ].each do |path|
      get path
      expect(Capybara.string(response.body)).to have_css("label", text: "メールアドレス")
      expect(Capybara.string(response.body)).to have_css('input[name="email_address"]')
    end
  end

  it "uses the same attribute names in signup errors" do
    post users_path, params: { user: { email_address: "", password: "password123", password_confirmation: "password123" } }
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("メールアドレスを入力してください")
  end

  it "explains duplicate addresses and password failures in Japanese" do
    User.create!(email_address: "duplicate@example.com", password: "valid-password")
    [
      [ { email_address: "duplicate@example.com", password: "valid-password", password_confirmation: "valid-password" }, "メールアドレスはすでに使用されています" ],
      [ { email_address: "mismatch@example.com", password: "valid-password", password_confirmation: "different" }, "一致しません" ],
      [ { email_address: "bytes@example.com", password: "あ" * 25, password_confirmation: "あ" * 25 }, "72バイト以内" ]
    ].each do |attributes, message|
      post users_path, params: { user: attributes }
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(message)
    end
  end

  it "uses the QueueRun attribute translation in validation feedback" do
    post queue_runs_path, params: { compare: "7.0", queue_run: { input: "" } }

    expect(response).to redirect_to(feature_path("solid-queue", compare: "7.0"))
    follow_redirect!
    expect(response.body).to include("ジョブの入力内容を入力してください")
  end

  it "joins DemoMessage validation errors with Japanese attribute names" do
    post demo_messages_path, params: { compare: "8.0", demo_message: { author: "", body: "" } }

    expect(response).to redirect_to(feature_path("solid-cable", compare: "8.0"))
    follow_redirect!
    expect(response.body).to include("投稿者を入力してください、本文を入力してください")
  end

  it "keeps runtime status and output in their original English" do
    QueueRun.create!(input: "Status display check", status: :completed, output: "Processed via SolidQueueAdapter.")

    get feature_path("solid-queue")

    row = Capybara.string(response.body).find("article", text: "Status display check")
    expect(row).to have_css("span", text: "completed", exact_text: true)
    expect(row).to have_text("Processed via SolidQueueAdapter.")
  end

  it "renders changed catalog summaries and escapes embedded markup" do
    features = YAML.safe_load_file(FeatureCatalog::DATA_PATH).fetch("features")
    feature = features.find { |item| item.fetch("slug") == "local-ci" }
    feature["summary"] = 'カタログからの説明 <img src=x onerror="alert(1)">'

    with_raw_features(features) do
      get feature_path("local-ci")
    end

    page = Capybara.string(response.body)
    expect(response).to have_http_status(:ok)
    expect(page).to have_text("カタログからの説明")
    expect(page).not_to have_css("img[onerror]", visible: :all)
    expect(response.body).to include("&lt;img")
  end

  it "escapes user input in the message timeline" do
    DemoMessage.create!(author: '<img src=x onerror="alert(1)">', body: '<script>alert("message")</script>')

    get feature_path("solid-cable")

    page = Capybara.string(response.body)
    expect(response).to have_http_status(:ok)
    expect(page).not_to have_css("img[onerror]", visible: :all)
    expect(page).not_to have_css("script", text: 'alert("message")', visible: :all)
    expect(response.body).to include("&lt;img", "&lt;script&gt;")
  end
end
