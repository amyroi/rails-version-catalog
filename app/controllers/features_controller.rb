class FeaturesController < ApplicationController
  allow_unauthenticated_access

  def index
    @runtime_features = FeatureCatalog.runtime_demos
    @platform_features = FeatureCatalog.comparison_cards
  end

  def show
    @feature = FeatureCatalog.fetch!(params[:slug])
    prepare_feature_data
  end

  private
    def prepare_feature_data
      case @feature.slug
      when "solid-queue"
        @queue_runs = QueueRun.recent.limit(8)
        @queue_run = QueueRun.new(input: "Compare Rails 7.2 and 8.0 queue defaults")
      when "solid-cable"
        @demo_messages = DemoMessage.recent.limit(12)
        @demo_message = DemoMessage.new(author: Current.session&.user&.email_address || "Guest")
      when "solid-cache"
        @cache_snapshot = CacheDemoProbe.snapshot
      when "runtime-stack"
        @stack_facts = stack_facts
      when "docker-deploy-orientation", "propshaft", "kamal-2", "thruster"
        @repo_facts = repo_facts
      when "authentication-generator"
        @current_user = Current.session&.user
      end
    end

    def stack_facts
      {
        queue_adapter: ActiveJob::Base.queue_adapter.class.name,
        cache_store: Rails.cache.class.name,
        cable_adapter: ActionCable.server.config.cable.fetch("adapter"),
        auth_enabled: defined?(Authentication).present?,
        queue_runs: QueueRun.count,
        live_messages: DemoMessage.count
      }
    end

    def repo_facts
      {
        dockerfile: Rails.root.join("Dockerfile").exist?,
        kamal_config: Rails.root.join("config/deploy.yml").exist?,
        kamal_secrets: Rails.root.join(".kamal/secrets").exist?,
        propshaft: Gem.loaded_specs.key?("propshaft"),
        kamal: Gem.loaded_specs.key?("kamal"),
        thruster: Gem.loaded_specs.key?("thruster"),
        bin_thrust: Rails.root.join("bin/thrust").exist?,
        github_actions: Rails.root.join(".github/workflows/ci.yml").exist?
      }
    end
end
