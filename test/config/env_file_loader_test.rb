require "test_helper"
require_relative "../../config/env_file_loader"
require "tempfile"

class EnvFileLoaderTest < ActiveSupport::TestCase
  test "loads assignments from env file" do
    env = {}

    with_env_file(<<~ENV_FILE) do |path|
      # comment
      export POSTGRES_HOST=127.0.0.1
      POSTGRES_PORT="55432"
      POSTGRES_PASSWORD='secret'
      APP_NAME=feature catalog # inline comment
    ENV_FILE
      EnvFileLoader.load(path, env: env)
    end

    assert_equal "127.0.0.1", env["POSTGRES_HOST"]
    assert_equal "55432", env["POSTGRES_PORT"]
    assert_equal "secret", env["POSTGRES_PASSWORD"]
    assert_equal "feature catalog", env["APP_NAME"]
  end

  test "does not override existing values by default" do
    env = { "POSTGRES_PORT" => "6000" }

    with_env_file("POSTGRES_PORT=55432\n") do |path|
      EnvFileLoader.load(path, env: env)
    end

    assert_equal "6000", env["POSTGRES_PORT"]
  end

  test "can override existing values when requested" do
    env = { "POSTGRES_PORT" => "6000" }

    with_env_file("POSTGRES_PORT=55432\n") do |path|
      EnvFileLoader.load(path, env: env, override: true)
    end

    assert_equal "55432", env["POSTGRES_PORT"]
  end

  private
    def with_env_file(contents)
      file = Tempfile.new(".env")
      file.write(contents)
      file.flush
      yield file.path
    ensure
      file.close!
    end
end
