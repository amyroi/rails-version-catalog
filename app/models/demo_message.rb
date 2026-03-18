class DemoMessage < ApplicationRecord
  validates :author, presence: true
  validates :body, presence: true

  scope :recent, -> { order(created_at: :desc) }

  after_create_commit -> { broadcast_prepend_later_to "solid_cable_messages", target: "solid_cable_messages", partial: "demo_messages/demo_message", locals: { demo_message: self } }
end
