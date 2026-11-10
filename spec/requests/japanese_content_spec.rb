require "rails_helper"

RSpec.describe "Japanese content", type: :request do
  fixtures :users

  it "renders every feature with Japanese navigation, headings and source labels" do
    FeatureCatalog.all.each do |feature|
      get feature_path(feature.slug), params: { compare: "7.0,8.0,8.1.4" }
      expect(response).to have_http_status(:ok), feature.slug
      page = Capybara.string(response.body)
      expect(page.find("html")[:lang]).to eq("ja")
      expect(page.find("h1").text).to eq(feature.title)
      expect(page).to have_link("機能一覧")
      expect(page).to have_link("公式資料（英語）↗", href: feature.source_url)
      expect(page).to have_css("h2", text: "バージョン比較")
      expect(page).to have_css("h2", text: "移行前に確認すること")
      expect(response.body).not_to include("Translation missing", "translation_missing")
    end
  end

  it "renders Japanese labels and empty states for a comparison without examples" do
    get feature_path("markdown-rendering"), params: { compare: "8.0" }
    expect(response.body).to include("コード例はまだ登録されていません。", "このバージョンの関連ファイルはまだ登録されていません。", "移行時の注意はまだ登録されていません。")
  end

  it "preserves a multiple-version selection" do
    get feature_path("solid-queue"), params: { compare: "7.0,8.1.4" }
    expect(response.body).to include("2 バージョンを選択中")
    expect(response.body).to include('value="7.0,8.1.4"')
  end

  it "shows Japanese sign-in errors" do
    post session_path, params: { email_address: "missing@example.invalid", password: "wrong" }
    follow_redirect!
    expect(response.body).to include("メールアドレスまたはパスワードを確認してください。")
    expect(Capybara.string(response.body)).to have_field("メールアドレス")
    expect(Capybara.string(response.body)).to have_field("パスワード")
  end

  it "shows Japanese duplicate and password confirmation errors" do
    post users_path, params: { user: { email_address: users(:one).email_address, password: "password", password_confirmation: "different" } }
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("メールアドレスはすでに使用されています", "パスワード（確認）がパスワードと一致しません")
    expect(response.body).not_to include("Translation missing")
  end

  it "shows Japanese queue and message validation without changing data" do
    expect do
      post queue_runs_path, params: { compare: "8.0", queue_run: { input: "" } }
    end.not_to change(QueueRun, :count)
    expect(response).to redirect_to(feature_path("solid-queue", compare: "8.0"))
    follow_redirect!
    expect(response.body).to include("ジョブの入力を入力してください")

    expect do
      post demo_messages_path, params: { compare: "8.0", demo_message: { author: "", body: "" } }
    end.not_to change(DemoMessage, :count)
    follow_redirect!
    expect(response.body).to include("投稿者を入力してください", "本文を入力してください")
  end

  it "keeps account existence private in Japanese reset instructions" do
    [ users(:one).email_address, "missing@example.invalid" ].each do |email|
      post passwords_path, params: { email_address: email }
      expect(response).to redirect_to(new_session_path)
      follow_redirect!
      expect(response.body).to include("該当するアカウントが存在する場合、パスワード再設定の案内を送信しました。")
    end
  end

  it "renders a Japanese reset mail and preserves the token link" do
    mail = PasswordsMailer.reset(users(:one))
    expect(mail.subject).to eq("パスワードの再設定")
    expect(mail.text_part.body.decoded).to include("15分以内", "/passwords/")
    expect(mail.html_part.body.decoded).to include('lang="ja"', "パスワード再設定ページ", "/passwords/")
  end

  it "resets a password with Japanese failure and success messages" do
    user = users(:one)
    token = user.password_reset_token
    get edit_password_path(token: token)
    expect(response).to have_http_status(:ok)
    expect(Capybara.string(response.body)).to have_field("パスワード（確認）")
    put password_path(token: token), params: { password: "new-password", password_confirmation: "wrong" }
    follow_redirect!
    expect(response.body).to include("パスワードを更新できませんでした。入力内容を確認してください。")
    put password_path(token: token), params: { password: "new-password", password_confirmation: "new-password" }
    follow_redirect!
    expect(response.body).to include("パスワードを再設定しました。")
    expect(user.reload.authenticate("new-password")).to eq(user)
  end

  it "renders all four job statuses as Japanese text" do
    QueueRun.statuses.keys.each { |status| QueueRun.create!(input: "日本語の確認", status: status) }
    get feature_path("solid-queue")
    expect(response.body).to include("待機中", "処理中", "完了", "失敗")
  end
end

RSpec.describe "Static error page language" do
  %w[400 404 406-unsupported-browser 422 500].each do |page|
    it "keeps #{page} readable in Japanese without Rails rendering" do
      html = Capybara.string(Rails.root.join("public/#{page}.html").read)
      expect(html.find("html")[:lang]).to eq("ja")
      expect(html.find("title", visible: :all).text(:all)).to match(/[\p{Hiragana}\p{Katakana}\p{Han}]/)
      expect(html.find("strong").text).to match(/[\p{Hiragana}\p{Katakana}\p{Han}]/)
    end
  end
end
