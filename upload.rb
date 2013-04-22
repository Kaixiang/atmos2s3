require "aws"
require "yaml"
require "multi_json"
require "uri"
require "base64"


s3_blob_option = {
  :aws_options => {
    :access_key_id     => ENV['BOSH_AWS_ACCESS_KEY_ID'],
    :secret_access_key => ENV['BOSH_AWS_SECRET_ACCESS_KEY'],
    :use_ssl           => true,
    :port              => 443
  },
  :bucket => ENV['BLOB_S3_BUCKET']
}

base_dir = File.join(ENV['BOSH_REPOSITORY'],"tmp", "cf-release")
blobs_dir = File.join(base_dir, "blobs")

def upload_to_s3(s3_object, file_path)
  File.open(file_path, "r") do |temp_file|
    s3_object.write(temp_file)
  end
end

def decode_object_id(object_id)
  begin
    object_info = MultiJson.decode(Base64.decode64(URI::unescape(object_id)))
  rescue MultiJson::DecodeError => e
    raise 'Failed to parse object_id. Please try updating the release'
  end

  if !object_info.kind_of?(Hash) || object_info["oid"].nil? ||
    object_info["sig"].nil?
    raise "Invalid object_id (#{object_id})"
  end
  object_info
end

blob_yml = YAML.load_file(File.join(base_dir, "config", "blobs.yml"))
aws_s3 = AWS::S3.new(s3_blob_option[:aws_options])

blob_yml.each do |k, v|
  blob_file = File.join(blobs_dir, k)
  object_id = decode_object_id(v['object_id'])
  oid = object_id["oid"]
  puts "uploading #{blob_file} as #{oid}.."
  s3_object = aws_s3.buckets[s3_blob_option[:bucket]].objects[oid]
  upload_to_s3(s3_object, blob_file)
  s3_object.acl = :public_read
end

