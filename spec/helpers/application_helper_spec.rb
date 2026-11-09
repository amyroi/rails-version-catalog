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
