class Api::V1::Catalog::VersionResource
  include Alba::Resource

  attributes :key, :label

  attribute :releaseDate do |version|
    version.release_date
  end

  attribute :releaseNotesUrl do |version|
    version.release_notes_url
  end

  attribute :status do |version|
    version.status.to_s
  end
end
