class QueueRunJob < ApplicationJob
  queue_as :default

  def perform(queue_run_id)
    queue_run = QueueRun.find(queue_run_id)
    queue_run.update!(status: :working, started_at: Time.current)

    sleep 1 if Rails.env.development?

    queue_run.update!(
      status: :completed,
      finished_at: Time.current,
      output: "Processed at #{Time.current.strftime("%Y-%m-%d %H:%M:%S")} via #{ActiveJob::Base.queue_adapter.class.name.demodulize}."
    )
  rescue StandardError => error
    queue_run&.update!(
      status: :failed,
      finished_at: Time.current,
      output: "#{error.class}: #{error.message}"
    )
    raise
  end
end
