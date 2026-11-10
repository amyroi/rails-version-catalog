require "rails_helper"

RSpec.describe "Japanese initial demo records", type: :model do
  it "creates one Japanese sample per empty table and does not duplicate them" do
    QueueRun.delete_all
    DemoMessage.delete_all
    Rails.application.load_seed
    expect(QueueRun.count).to eq(1)
    expect(DemoMessage.count).to eq(1)
    expect(QueueRun.first.input).to eq(I18n.t("seeds.input"))
    expect(DemoMessage.first.body).to eq(I18n.t("seeds.message"))

    expect { Rails.application.load_seed }.not_to change { [ QueueRun.count, DemoMessage.count ] }
  end

  it "does not update existing English records or reset an existing account password" do
    user = User.create!(email_address: "demo@example.com", password: "existing-password")
    QueueRun.create!(input: "Existing queue sample", status: :completed, output: "Existing output")
    DemoMessage.create!(author: "Existing author", body: "Existing message")
    before = [ QueueRun.order(:id).map(&:attributes), DemoMessage.order(:id).map(&:attributes), user.attributes ]

    Rails.application.load_seed

    expect([ QueueRun.order(:id).map(&:attributes), DemoMessage.order(:id).map(&:attributes), user.reload.attributes ]).to eq(before)
  end
end
