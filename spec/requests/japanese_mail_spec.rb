require "rails_helper"

RSpec.describe "Japanese password reset mail", type: :request do
  include ActiveJob::TestHelper
  fixtures :users

  it "renders both reset formats with a usable signed link" do
    mail = PasswordsMailer.reset(users(:one)).message
    expect(mail.subject).to eq("パスワードの再設定")
    page = Capybara.string(mail.html_part.body.decoded)
    expect(page).to have_css('html[lang="ja"]', visible: :all)
    link = page.find("a")[:href]
    expect(mail.text_part.body.decoded).to include(link)
    expect(mail.text_part.body.decoded).to include("15分以内")

    get URI(link).request_uri
    expect(response).to have_http_status(:ok)
    expect(Capybara.string(response.body)).to have_css("label", text: "パスワード（確認）")
    expect(Capybara.string(response.body)).to have_css('input[name="password_confirmation"]')
  end

  it "keeps static errors Japanese without requiring Rails translations" do
    %w[400 404 406-unsupported-browser 422 500].each do |name|
      page = Capybara.string(Rails.root.join("public", "#{name}.html").read)
      expect(page).to have_css('html[lang="ja"]', visible: :all)
      expect(page.find("p").text).to match(/[ぁ-んァ-ヶ一-龯]/)
    end
  end
end
