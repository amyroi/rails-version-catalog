demo_user = User.find_or_initialize_by(email_address: "demo@example.com")
demo_user.password = "password123"
demo_user.password_confirmation = "password123"
demo_user.save!

DemoMessage.find_or_create_by!(author: "System", body: "Solid Cable demo ready. Open two tabs to compare live updates.")

QueueRun.find_or_create_by!(input: "Seeded queue demo example") do |run|
  run.status = :completed
  run.output = "Seed data created this record to show the queue UI before your first enqueue."
  run.started_at = Time.current
  run.finished_at = Time.current
end
#   end
