#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'optparse'
require 'yaml'
require 'rest-client'
require 'json'

FLICKR_API_ENDPOINT = 'https://api.flickr.com/services/rest/'

@rest_responses = {}

def append_flickr_response(xml, params)
  @rest_responses[params.hash] ||= RestClient.get FLICKR_API_ENDPOINT, {:params => params}
  rest_response = @rest_responses[params.hash]
  flickr_response_node = Nokogiri::XML "<flickrResponse method=\"#{params['method']}\"/>"
  flickr_response_node.root.add_child Nokogiri::XML(rest_response.body.to_s).root
  if ((flickr_response_node.xpath('/flickrResponse/rsp/@stat').first.value != 'ok') || rest_response.code != 200)
    $stderr.puts "Error with Flickr request #{params.inspect}"
    $stderr.puts rest_response.inspect
  end
  xml.root.add_child flickr_response_node.root

  return xml
end

config = {}

config_yaml = File.join(File.dirname(File.expand_path(__FILE__)),'.secrets.yml')
if File.exist?(config_yaml)
  config = config.merge(YAML.load_file(config_yaml))
end

OptionParser.new do |opts|
  opts.banner = "Usage: dlflickr.rb [options]"
  opts.on('-a','--[no-]archive','Archive Flickr metadata') {|a| config[:archive] = a}
  opts.on('-fKEY','--flickr-api-key=KEY','Flickr API key') {|f| config['flickr_key'] = f}
end.parse!

ARGF.each_line do |line|
  line.chomp!
  line.sub!(/^http\:/,'https:')
  line.sub!(/\/in\/.*/,'') # strip off /in/photostream/, /in/pool-* etc.
  save_file_basename = line.split('/')[-2..-1].join('_')
  save_file_image = save_file_basename + '.jpg'
  save_file_metadata = save_file_basename + '.xml'
  photo_id = line.split('/')[-1]
  # download Flickr image
  begin
    unless File.exist?(save_file_image)
      doc = Nokogiri::HTML(open(line + "/sizes/o/"))

      doc.xpath('//div[@id="allsizes-photo"]/img/@src').each do |link|
        $stderr.puts "#{save_file_image}: #{line} => #{link}"
        `wget -O #{save_file_image} -c #{link}`
      end
    end
  rescue OpenURI::HTTPError => e
    $stderr.puts line
    $stderr.puts e.inspect
  end
  # download Flickr metadata
  if (config[:archive] && !File.exist?(save_file_metadata))
    xml = Nokogiri::XML '<flickrMetadata/>'
    # flickr.photos.getInfo
    xml = append_flickr_response(xml, {'api_key' => config['flickr_key'], 'method' => 'flickr.photos.getInfo', 'photo_id' => photo_id})
    # flickr.photos.licenses.getInfo
    xml = append_flickr_response(xml, {'api_key' => config['flickr_key'], 'method' => 'flickr.photos.licenses.getInfo'})
    # flickr.photos.comments.getList
    xml = append_flickr_response(xml, {'api_key' => config['flickr_key'], 'method' => 'flickr.photos.comments.getList', 'photo_id' => photo_id})
    # flickr.photos.getFavorites
    xml = append_flickr_response(xml, {'api_key' => config['flickr_key'], 'method' => 'flickr.photos.getFavorites', 'photo_id' => photo_id, 'per_page' => 50})
    # flickr.photos.getAllContexts
    xml = append_flickr_response(xml, {'api_key' => config['flickr_key'], 'method' => 'flickr.photos.getAllContexts', 'photo_id' => photo_id})
    # flickr.people.getInfo
    owner_nsid = xml.xpath('//photo/owner/@nsid').first ? xml.xpath('//photo/owner/@nsid').first.value : line.split('/')[-2]
    xml = append_flickr_response(xml, {'api_key' => config['flickr_key'], 'method' => 'flickr.people.getInfo', 'user_id' => owner_nsid})
    $stderr.puts "#{save_file_metadata}: #{File.write(save_file_metadata, xml.to_s)} bytes written"
  end

end
