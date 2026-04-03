require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "normalizes email before uniqueness validation" do
    user = User.new(
      email_address: " One@Example.com ",
      password: "password123",
      password_confirmation: "password123"
    )

    assert_not user.valid?
    assert_includes user.errors[:email_address], "has already been taken"
  end
end
