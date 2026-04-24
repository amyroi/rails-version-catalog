class QueueRunsController < ApplicationController
  allow_unauthenticated_access

  def create
    queue_run = QueueRun.create!(queue_run_params)
    queue_run.broadcast_prepend_later_to(
      "solid_queue_runs",
      target: "solid_queue_runs",
      partial: "queue_runs/queue_run",
      locals: { queue_run: queue_run }
    )
    QueueRunJob.perform_later(queue_run.id)

    redirect_to feature_path("solid-queue", compare: params[:compare]), notice: "Queued a Solid Queue demo job."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to feature_path("solid-queue", compare: params[:compare]), alert: error.record.errors.full_messages.to_sentence
  end

  private
    def queue_run_params
      params.expect(queue_run: [ :input ])
    end
end
