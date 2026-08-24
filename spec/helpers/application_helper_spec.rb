require "rails_helper"

RSpec.describe ApplicationHelper do
  describe "#current_runtime_label" do
    it "omits the fourth version segment" do
      allow(Rails).to receive(:gem_version).and_return(Gem::Version.new("8.1.3.1"))

      expect(helper.current_runtime_label).to eq("Rails 8.1.3")
    end
  end
end
