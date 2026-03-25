class FeaturesController < ApplicationController
  allow_unauthenticated_access
  before_action :set_selected_version_keys

  def index
    @versions = VersionCatalog.all
    @comparison_versions = @selected_version_keys.map { |key| VersionCatalog.fetch(key) }
    @runtime_features = FeatureCatalog.runtime_demos
    @platform_features = FeatureCatalog.comparison_cards
  end

  def show
    @versions = VersionCatalog.all
    @feature = FeatureCatalog.fetch!(params[:slug])
    @comparison_versions = @feature.comparison_versions(@selected_version_keys)
    prepare_feature_data
  end

  private
    def set_selected_version_keys
      @selected_version_keys = VersionCatalog.normalize(params[:compare])
      @selected_version_keys = VersionCatalog.default_compare_keys if @selected_version_keys.empty?
    end

    def prepare_feature_data
      case @feature.slug
      when "solid-queue"
        @queue_runs = QueueRun.recent.limit(8)
        @queue_run = QueueRun.new(input: "Compare Rails 7.0, 8.0, and 8.1.2 queue defaults")
      when "solid-cable"
        @demo_messages = DemoMessage.recent.limit(12)
        @demo_message = DemoMessage.new(author: Current.session&.user&.email_address || "Guest")
      when "solid-cache"
        @cache_snapshot = CacheDemo::Snapshot.call
      when "runtime-stack"
        @stack_facts = stack_facts
      when "propshaft", "kamal", "thruster", "local-ci", "credentials-fetching"
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
