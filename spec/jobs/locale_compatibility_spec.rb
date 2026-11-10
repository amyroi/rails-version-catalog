require "rails_helper"

RSpec.describe "Persisted job locale compatibility", type: :job do
  include ActiveJob::TestHelper
  fixtures :users

  around do |example|
    previous_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :test
    example.run
  ensure
    clear_enqueued_jobs
    clear_performed_jobs
    ActiveJob::Base.queue_adapter = previous_adapter
  end

  it "uses Japanese while accepting previously persisted English payloads" do
    expect(I18n.default_locale).to eq(:ja)
    expect(I18n.available_locales).to include(:en, :ja)
  end

  %i[en ja].each do |locale|
    context "with a persisted #{locale} locale" do
      it "completes a queue run and broadcasts its actual status" do
        run = QueueRun.create!(input: "locale compatibility")
        payload = I18n.with_locale(locale) { QueueRunJob.new(run.id).serialize }
        job = ActiveJob::Base.deserialize(payload)
        expect(job.locale).to eq(locale.to_s)
        streams = []
        allow(Turbo::StreamsChannel).to receive(:broadcast_stream_to) do |*, content:|
          streams << content
        end

        perform_enqueued_jobs { job.perform_now }

        expect(run.reload.status).to eq("completed")
        expect(run.output).to start_with("Processed at ")
        expect(streams.join).to include("working", "completed")
        expect(I18n.locale).to eq(:ja)
      end

      it "renders a Cable broadcast serialized before the worker changed" do
        message = DemoMessage.create!(author: "System", body: "locale compatibility")
        payload = I18n.with_locale(locale) do
          Turbo::Streams::ActionBroadcastJob.new(
            "solid_cable_messages",
            action: :prepend, target: "solid_cable_messages",
            partial: "demo_messages/demo_message", locals: { demo_message: message }
          ).serialize
        end
        expect(Turbo::StreamsChannel).to receive(:broadcast_stream_to) do |*, content:|
          expect(content).to include("locale compatibility", "solid_cable_messages")
        end

        ActiveJob::Base.deserialize(payload).perform_now
      end

      it "delivers a serialized password reset mail using the test transport" do
        user = users(:one)
        payload = I18n.with_locale(locale) do
          ActionMailer::MailDeliveryJob.new(
            "PasswordsMailer", "reset", "deliver_now", args: [ user ]
          ).serialize
        end
        expect {
          ActiveJob::Base.deserialize(payload).perform_now
        }.to change { ActionMailer::Base.deliveries.size }.by(1)

        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq([ user.email_address ])
        expect(mail.subject).to eq("パスワードの再設定")
        expect(mail.html_part.body.decoded).to include("/passwords/")
        expect(mail.text_part.body.decoded).to include("/passwords/")
      end
    end
  end
end
