class CatalogFeature
  attr_reader :slug, :title, :category, :summary, :rails_72, :rails_80, :highlight, :demo_type, :source_url

  def initialize(slug:, title:, category:, summary:, rails_72:, rails_80:, highlight:, demo_type:, source_url:)
    @slug = slug
    @title = title
    @category = category
    @summary = summary
    @rails_72 = rails_72
    @rails_80 = rails_80
    @highlight = highlight
    @demo_type = demo_type
    @source_url = source_url
  end

  def runtime_demo?
    demo_type == :runtime_demo
  end

  def comparison_card?
    demo_type == :comparison_card
  end

  def partial_name
    slug.tr("-", "_")
  end

  def category_label
    runtime_demo? ? "Runtime Demo" : "Platform / Defaults"
  end
end
