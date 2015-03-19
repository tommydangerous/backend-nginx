require "getoptlong"
require "httparty"
require "json"
require "open4"

options = {}
raw_options = GetoptLong.new(
  ["--json", "-j", GetoptLong::OPTIONAL_ARGUMENT],
  ["--project", "-p", GetoptLong::OPTIONAL_ARGUMENT]
)
raw_options.each do |opt, arg|
  key = opt.gsub("--", "").to_sym
  options[key] = arg
end

if options[:json].nil? || options[:project].nil?
  if options[:json].nil?
    puts "--json, -j cannot be blank"
  elsif options[:project].nil?
    puts "--project, -p cannot be blank"
  end
  exit 1
end

response = HTTParty.get options[:json]
json = JSON.parse response.body, symbolize_names: true

File.open("config/nginx.conf", "w") do |file|
  text = "http {\n"
  json.each do |key, value|
    text +=
      "  upstream #{key} {\n" +
      "    server #{value[:ip]};\n" +
      "  }\n"
  end
  text += "\n" +
    "  server {\n" +
    "    listen 80;\n" +
    "\n" +
    "    location / {\n" +
    "      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n" +
    "      proxy_set_header Host $http_host;\n" +
    "      proxy_redirect off;\n" +
    "    }\n"
  json.each do |key, value|
    text +=
      "\n" +
      "    location /#{value[:uri]} {\n" +
      "      proxy_pass http://#{key};\n" +
      "    }\n"
  end
  text += "  }\n" +
    "}\n" +
    "\n" +
    "events {\n" +
    "  worker_connections 1024;\n" +
    "}"
  file.write(text)
end

status = Open4::popen4("sh") do |pid, stdin, stdout, stderr|
  tag = "dangerous/nginx:#{options[:project]}"
  stdin.puts "docker build -t #{tag} ."
  stdin.puts "docker push #{tag}"
  stdin.close

  puts "pid        : #{ pid }"
  puts "stdout     : #{ stdout.read.strip }"
  puts "stderr     : #{ stderr.read.strip }"
end

puts "status     : #{ status.inspect }"
puts "exitstatus : #{ status.exitstatus }"
