class CacheDemosController < ApplicationController
  allow_unauthenticated_access

  def refresh
    CacheDemo::Refresh.call(force_refresh: true)
    redirect_to feature_path("solid-cache", compare: params[:compare]), notice: "キャッシュを無効化し、データを再生成しました。"
  end

  def destroy
    CacheDemo::CacheAdapter.delete(CacheDemo::Refresh::KEY)
    redirect_to feature_path("solid-cache", compare: params[:compare]), notice: "キャッシュを削除しました。"
  end
end
