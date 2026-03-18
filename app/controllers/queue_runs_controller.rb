class QueueRunsController < ApplicationController
  allow_unauthenticated_access

  def create
    queue_run = QueueRun.create!(queue_run_params)
    QueueRunJob.perform_later(queue_run.id)

    redirect_to feature_path("solid-queue"), notice: "Queued a Solid Queue demo job."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to feature_path("solid-queue"), alert: error.record.errors.full_messages.to_sentence
  end

  private
    def queue_run_params
      params.expect(queue_run: [ :input ])
    end
end
