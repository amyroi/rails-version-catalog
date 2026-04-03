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
      output: "Processed at #{Time.current.strftime("%Y-%m-%d %H:%M:%S")} via #{ActiveJob::Base.queue_adapter.class.name.demodulize}."
    )
    broadcast_queue_run(queue_run)
  rescue StandardError => error
    if queue_run&.persisted?
      queue_run.update_columns(
        status: QueueRun.statuses.fetch(:failed),
        finished_at: Time.current,
        output: "#{error.class}: #{error.message}",
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
