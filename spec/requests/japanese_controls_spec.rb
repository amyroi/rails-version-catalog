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

  it "renders changed catalog demo prose and escapes embedded markup" do
    features = YAML.safe_load_file(FeatureCatalog::DATA_PATH).fetch("features")
    feature = features.find { |item| item.fetch("slug") == "local-ci" }
    feature.fetch("demo_notes")["description"] = 'カタログからの説明 <img src=x onerror="alert(1)">'

    with_raw_features(features) do
      get feature_path("local-ci")
    end

    page = Capybara.string(response.body)
    expect(response).to have_http_status(:ok)
    expect(page).to have_text("カタログからの説明")
    expect(page).not_to have_css("img[onerror]", visible: :all)
    expect(response.body).to include("&lt;img")
  end

  it "rejects invalid demo prose before rendering" do
    features = YAML.safe_load_file(FeatureCatalog::DATA_PATH).fetch("features")
    features.first["demo_notes"] = { "description" => [] }

    with_raw_features(features) do
      expect { FeatureCatalog.all }.to raise_error(ArgumentError, /demo_notes/)
    end
  end
end
