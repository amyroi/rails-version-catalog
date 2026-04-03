class QueueRun < ApplicationRecord
  enum :status, {
    queued: "queued",
    working: "working",
    completed: "completed",
    failed: "failed"
  }, default: :queued, validate: true

  validates :input, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
