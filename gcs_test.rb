require "google/cloud/storage"

project = ARGV[0]
keyfile = ARGV[1]

puts "Getting bar.txt from bucket in project #{ project } with keyfile #{ keyfile }"

storage = Google::Cloud::Storage.new(
  project_id: ARGV[0],
  credentials: ARGV[1]
)

begin
	bucket = storage.bucket "role-bug-demo"
	file = bucket.file "bar.txt"
rescue Google::Cloud::PermissionDeniedError => e
	puts "FAILURE: the service account cannot access the bucket = #{ e.message }"
else
	puts "SUCCESS: the service account can access the bucket."
end

