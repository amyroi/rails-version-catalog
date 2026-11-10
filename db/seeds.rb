demo_user = User.find_or_initialize_by(email_address: "demo@example.com")
if demo_user.new_record?
  demo_user.password = "password123"
  demo_user.password_confirmation = "password123"
  demo_user.save!
end

DemoMessage.create!(author: "System", body: "Solid Cable の配信デモです。2つのタブを開いて画面の更新を確認してください。") if DemoMessage.none?

if QueueRun.none?
  run = QueueRun.new(input: "キューの処理結果を確認するサンプル")
  run.status = :completed
  run.output = "Seed data created this record to show the queue UI before your first enqueue."
  run.started_at = Time.current
  run.finished_at = Time.current
  run.save!
end
