class DemoMessage < ApplicationRecord
  validates :author, presence: true
  validates :body, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
