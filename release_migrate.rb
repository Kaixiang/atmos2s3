require "yaml"
require "uri"
require "multi_json"
require "base64"


ATOMS_PREFIX = 'rest/objects/'

release_dir = ARGV[0]

final_builds = File.join(release_dir, ".final_builds")
blob_file = File.join(release_dir, "config/blobs.yml")

def translate_object_id(object_id)
  begin
    object_info = MultiJson.decode(Base64.decode64(URI::unescape(object_id)))
  rescue MultiJson::DecodeError => e
    raise 'Failed to parse object_id. Please try updating the release'
  end

  if !object_info.kind_of?(Hash) || object_info["oid"].nil? ||
    object_info["sig"].nil?
    raise "Invalid object_id (#{object_id})"
  end
  ATOMS_PREFIX + object_info["oid"]
end


# BLOB Translate
blob_yaml = YAML.load_file(blob_file)
blob_yaml.each do |k,v|
  v['object_id'] = translate_object_id (v['object_id'])
end
File.open(blob_file, 'w+') {|f| f.write(blob_yaml.to_yaml) }

# Final release Translate
final_builds_file = File.join(final_builds, "**", "**", "index.yml")
Dir.glob(final_builds_file).each do |file|
  final_yaml = YAML.load_file(file)
  final_yaml["builds"].each do |k,v|
    v['blobstore_id'] = translate_object_id (v['blobstore_id'])
  end
  File.open(file, 'w+') {|f| f.write(final_yaml.to_yaml) }
end

