class QueueRunJob < ApplicationJob
  queue_as :default

  def perform(queue_run_id)
    queue_run = QueueRun.find(queue_run_id)
    queue_run.update!(status: :working, started_at: Time.current)
    broadcast_queue_run(queue_run)

    sleep 1 if Rails.env.development?

    queue_run.update!(
      status: :completed,
      finished_at: Time.current,
      output: I18n.t("jobs.queue_run.completed", time: I18n.l(Time.current, format: :catalog), adapter: ActiveJob::Base.queue_adapter.class.name.demodulize)
    )
    broadcast_queue_run(queue_run)
  rescue StandardError => error
    if queue_run&.persisted?
      queue_run.update_columns(
        status: QueueRun.statuses.fetch(:failed),
        finished_at: Time.current,
        output: I18n.t("jobs.queue_run.failed", error_class: error.class.name, message: error.message),
        updated_at: Time.current
      )
      broadcast_queue_run(queue_run)
    end

    raise
  end

  private
    def broadcast_queue_run(queue_run)
      queue_run.broadcast_replace_later_to(
        "solid_queue_runs",
        partial: "queue_runs/queue_run",
        locals: { queue_run: queue_run }
      )
    end
end
