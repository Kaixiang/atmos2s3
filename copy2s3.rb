require "aws"
require "atmos"
require "tempfile"

ATOMS_PREFIX = 'rest/objects/'

atmos_blob_option = {
  :atmos_options => {
    :url => 'http://blob.cfblob.com',
    :uid => ENV['BLOB_ATMOS_UID'],
    :secret => ENV['BLOB_ATMOS_SECRET']
  },
  :tag => ENV['BLOB_ATMOS_TAG']
}

s3_blob_option = {
  :aws_options => {
    :access_key_id     => ENV['BLOB_AWS_ACCESS_KEY_ID'],
    :secret_access_key => ENV['BLOB_AWS_SECRET_ACCESS_KEY'],
    :use_ssl           => true,
    :port              => 443
  },
  :bucket => ENV['BLOB_S3_BUCKET']
}

def download_from_atmos(atmos_object, file_path)
  File.open(file_path, "w") do |temp_file|
    atmos_object.data_as_stream do |chunk|
      temp_file.write(chunk)
    end
  end
end

def upload_to_s3(s3_object, file_path)
  File.open(file_path, "r") do |temp_file|
    s3_object.write(temp_file)
  end
end

Atmos::Parser::parser = Atmos::Parser::REXML
store = Atmos::Store.new(atmos_blob_option[:atmos_options])
aws_s3 = AWS::S3.new(s3_blob_option[:aws_options])

store.each_object_with_listable_tag(atmos_blob_option[:tag]) do |ob|
  begin
    tmp_file = Tempfile.open('download_object_file')
    puts "Downloading #{ob.aoid} from Atmos..."
    download_from_atmos(ob, tmp_file.path)
    raise "Downloaded File #{ob.aoid} Broken" unless tmp_file.size.eql?ob.system_metadata['size'].to_i
    oid = ATOMS_PREFIX + ob.aoid
    s3_object = aws_s3.buckets[s3_blob_option[:bucket]].objects[oid]
    puts "Uploading #{ob.aoid} to S3..."
    upload_to_s3(s3_object, tmp_file)
    s3_object.acl = :public_read
  ensure
    tmp_file.close
    tmp_file.unlink
  end
end

