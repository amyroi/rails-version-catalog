class QueueRun < ApplicationRecord
  enum :status, {
    queued: "queued",
    working: "working",
    completed: "completed",
    failed: "failed"
  }, default: :queued, validate: true

  validates :input, presence: true

  scope :recent, -> { order(created_at: :desc) }

  after_create_commit -> { broadcast_prepend_later_to "solid_queue_runs", target: "solid_queue_runs", partial: "queue_runs/queue_run", locals: { queue_run: self } }
  after_update_commit -> { broadcast_replace_later_to "solid_queue_runs", partial: "queue_runs/queue_run", locals: { queue_run: self } }
end
