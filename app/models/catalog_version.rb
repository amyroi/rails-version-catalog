class CatalogVersion
  attr_reader :key, :label, :release_date, :status, :release_notes_url

  def initialize(key:, label:, release_date:, status:, release_notes_url:)
    @key = key
    @label = label
    @release_date = release_date
    @status = status
    @release_notes_url = release_notes_url
  end

  def latest?
    status == :latest
  end

  def planned?
    status == :planned
  end
end
