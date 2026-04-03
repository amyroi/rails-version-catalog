module EnvFileLoader
  module_function

  def load(path, env: ENV, override: false)
    return env unless File.file?(path)

    File.foreach(path) do |line|
      key, value = parse_assignment(line)
      next unless key
      next if env.key?(key) && !override

      env[key] = value
    end

    env
  end

  def parse_assignment(line)
    stripped = line.strip
    return if stripped.empty?
    return if stripped.start_with?("#")

    assignment = stripped.delete_prefix("export ").strip
    key, raw_value = assignment.split("=", 2)
    return if key.nil? || key.strip.empty? || raw_value.nil?

    [key.strip, normalize_value(raw_value)]
  end

  def normalize_value(raw_value)
    value = raw_value.strip

    if (match = value.match(/\A"(.*)"(?:\s+#.*)?\z/m))
      match[1]
    elsif (match = value.match(/\A'(.*)'(?:\s+#.*)?\z/m))
      match[1]
    else
      value.sub(/\s+#.*\z/, "").strip
    end
  end
end
