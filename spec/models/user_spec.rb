require "rails_helper"

RSpec.describe User, type: :model do
  it "normalizes email before uniqueness validation" do
    user = described_class.new(
      email_address: " One@Example.com ",
      password: "password123",
      password_confirmation: "password123"
    )

    expect(user).not_to be_valid
    expect(user.errors[:email_address]).to include("has already been taken")
  end
end
