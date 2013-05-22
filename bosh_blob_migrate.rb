require "aws"

s3_blob_option = {
  :aws_options => {
    :access_key_id     => ENV['BLOB_AWS_ACCESS_KEY_ID'],
    :secret_access_key => ENV['BLOB_AWS_SECRET_ACCESS_KEY'],
    :use_ssl           => true,
    :port              => 443
  },
  :bucket => ENV['BLOB_S3_BUCKET']
}

def upload_to_s3(s3_object, file_path)
  File.open(file_path, "r") do |temp_file|
    s3_object.write(temp_file)
  end
end

BLOB_STORE_DIR = "/var/vcap/store/blobstore/store/"
aws_s3 = AWS::S3.new(s3_blob_option[:aws_options])

# Simple blobs to S3
blob_files = File.join(BLOB_STORE_DIR, "?*", "*")
Dir.glob(blob_files).each do |file|
  ofile = File.open(file, "r")
  oid = File.basename(file)
  s3_object = aws_s3.buckets[s3_blob_option[:bucket]].objects[oid]
  puts "Uploading #{oid} to S3..."
  upload_to_s3(s3_object, ofile)
end
