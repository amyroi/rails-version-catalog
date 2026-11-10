require "rails_helper"

RSpec.describe ApplicationHelper do
  describe "#current_runtime_label" do
    it "shows the current supported patch version" do
      allow(Rails).to receive(:gem_version).and_return(Gem::Version.new("8.1.4"))

      expect(helper.current_runtime_label).to eq("Rails 8.1.4")
    end

    it "omits the fourth version segment" do
      allow(Rails).to receive(:gem_version).and_return(Gem::Version.new("8.1.4.1"))

      expect(helper.current_runtime_label).to eq("Rails 8.1.4")
    end
  end
end

RSpec.describe ApplicationHelper, type: :helper do
  describe "queue status labels" do
    { queued: "待機中", working: "処理中", completed: "完了", failed: "失敗" }.each do |status, label|
      it "labels #{status} in Japanese without changing the stored status" do
        queue_run = QueueRun.new(status: status)
        expect(helper.queue_status_label(queue_run)).to eq(label)
        expect(queue_run.status).to eq(status.to_s)
      end
    end
  end
end
