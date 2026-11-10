demo_user = User.find_or_initialize_by(email_address: "demo@example.com")
if demo_user.new_record?
  demo_user.password = "password123"
  demo_user.password_confirmation = "password123"
  demo_user.save!
end

DemoMessage.create!(author: "System", body: I18n.t("seeds.message")) if DemoMessage.none?

if QueueRun.none?
  run = QueueRun.new(input: I18n.t("seeds.input"))
  run.status = :completed
  run.output = "Seed data created this record to show the queue UI before your first enqueue."
  run.started_at = Time.current
  run.finished_at = Time.current
  run.save!
end
