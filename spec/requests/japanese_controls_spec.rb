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
end
