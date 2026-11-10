require "rails_helper"

RSpec.describe "Queue run localization", type: :job do
  it "renders a broadcast serialized before the default-locale change without missing translations" do
    record = QueueRun.create!(input: "test", status: :completed)
    payload = I18n.with_locale(:en) do
      Turbo::Streams::ActionBroadcastJob.new(
        "solid_queue_runs", action: :replace, target: "queue_run_#{record.id}",
        partial: "queue_runs/queue_run", locals: { queue_run: record }
      ).serialize
    end
    restored = ActiveJob::Base.deserialize(payload)
    expect(restored.locale).to eq("en")
    expect(Turbo::StreamsChannel).to receive(:broadcast_stream_to) do |*, content:|
      expect(content).to include("完了")
      expect(content).not_to include("Translation missing", "translation_missing")
    end
    restored.perform_now
  end

  it "processes an old English-locale job with Japanese output and Japanese broadcast labels" do
    record = QueueRun.create!(input: "test")
    payload = I18n.with_locale(:en) { QueueRunJob.new(record.id).serialize }
    ActiveJob::Base.deserialize(payload).perform_now
    expect(record.reload.status).to eq("completed")
    expect(record.output).to include("で処理しました。")
    expect(record.output).not_to include("Translation missing")
  end
end
