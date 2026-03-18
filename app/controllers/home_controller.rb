class HomeController < ApplicationController
  allow_unauthenticated_access

  def show
    @runtime_features = FeatureCatalog.runtime_demos
    @platform_features = FeatureCatalog.comparison_cards
    @queue_runs_count = QueueRun.count
    @demo_messages_count = DemoMessage.count
  end
end
