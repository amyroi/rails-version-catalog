class Api::V1::Catalog::VersionsController < Api::V1::BaseController
  def index
    render json: Api::V1::Catalog::VersionResource.new(VersionCatalog.all).as_json
  end
end
