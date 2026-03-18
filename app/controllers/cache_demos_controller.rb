class CacheDemosController < ApplicationController
  allow_unauthenticated_access

  def refresh
    CacheDemoProbe.snapshot(force_refresh: true)
    redirect_to feature_path("solid-cache"), notice: "Cache miss triggered and payload regenerated."
  end

  def destroy
    CacheDemoProbe.clear!
    redirect_to feature_path("solid-cache"), notice: "Cache entry cleared."
  end
end
