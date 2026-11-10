demo_user = User.find_or_initialize_by(email_address: "demo@example.com")
demo_user.password = "password123"
demo_user.password_confirmation = "password123"
demo_user.save!

DemoMessage.find_or_create_by!(author: "System", body: I18n.t("seeds.message"))

QueueRun.find_or_create_by!(input: I18n.t("seeds.job_input")) do |run|
  run.status = :completed
  run.output = I18n.t("seeds.job_output")
  run.started_at = Time.current
  run.finished_at = Time.current
end
#   end
