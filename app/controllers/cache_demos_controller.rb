class CacheDemosController < ApplicationController
  allow_unauthenticated_access

  def refresh
    CacheDemo::Refresh.call(force_refresh: true)
    redirect_to feature_path("solid-cache"), notice: "Cache miss triggered and payload regenerated."
  end

  def destroy
    CacheDemo::CacheAdapter.delete(CacheDemo::Refresh::KEY)
    redirect_to feature_path("solid-cache"), notice: "Cache entry cleared."
  end
end
