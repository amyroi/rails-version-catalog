require "rails_helper"

RSpec.describe "I18n rendering", type: :request do
  it "renders all feature branches with strict missing-translation detection" do
    previous = I18n.exception_handler
    I18n.exception_handler = ->(exception, *) { raise exception.to_exception }

    FeatureCatalog.all.each do |feature|
      [ "7.0,8.0,8.1.4", "8.1.4" ].each do |compare|
        get feature_path(feature.slug), params: { compare: compare }
        expect(response).to have_http_status(:ok), feature.slug
      end
    end
    get root_path
    expect(response).to have_http_status(:ok)
    get features_path
    expect(response).to have_http_status(:ok)
  ensure
    I18n.exception_handler = previous
  end

  it "escapes user-controlled values while preserving trusted translation markup" do
    feature = FeatureCatalog.fetch!("solid-queue").dup
    allow(feature).to receive(:highlight_for).and_return('<img src=x onerror="alert(1)">')
    allow(FeatureCatalog).to receive(:runtime_demos).and_return([ feature ])

    get features_path
    page = Capybara.string(response.body)
    expect(page).to have_css("strong", text: "最新の比較対象の注目点:")
    expect(page).not_to have_css("img[onerror]", visible: :all)
    expect(response.body).to include("&lt;img")
  end

  it "has no leftover English word in the stack message-count label" do
    get feature_path("runtime-stack")
    expect(response.body).to include("メッセージの記録数")
    expect(response.body).not_to include("recorded")
  end

  it "keeps Japanese application copy in locale files rather than executable templates" do
    paths = Rails.root.glob("app/**/*.{rb,erb}")
    paths.each do |path|
      source = path.read.gsub(/<%#.*?%>/m, "").lines.reject { |line| path.extname == ".rb" && line.lstrip.start_with?("#") }.join
      expect(source).not_to match(/[\p{Hiragana}\p{Katakana}\p{Han}]/), path.to_s
    end
  end
end
