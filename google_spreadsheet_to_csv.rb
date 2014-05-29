#!/usr/bin/env ruby

require 'rubygems'
require 'google_drive'
require 'yaml'
require 'flickr'

config = YAML.load_file('.secrets.yml')
session = GoogleDrive.login(config["email"], config["pass"])

licenses = {
  0 => "All Rights Reserved",
  1 => "Attribution-NonCommercial-ShareAlike License",
  2 => "Attribution-NonCommercial License",
  3 => "Attribution-NonCommercial-NoDerivs License",
  4 => "Attribution License",
  5 => "Attribution-ShareAlike License",
  6 => "Attribution-NoDerivs License",
  7 => "No known copyright restrictions",
  8 => "United States Government Work"
}

ws = session.spreadsheet_by_key(config["spreadsheet_key"]).worksheets[0]

for row in 2..ws.num_rows
  flickr_url = ws[row,2]

  flickr_url.chomp!
  flickr_url.sub!(/^http\:/,'https:')
  flickr_url.sub!(/\/in\/.*/,'') # strip off /in/photostream/, /in/pool-* etc.
  flickr_url.sub!(/\/$/,'') # strip trailing slash

  photo_id = flickr_url.split('/').last.to_s
  begin
    flickr_photo = Flickr::Photo.new(photo_id, config["flickr_key"])
    license = licenses[flickr_photo.license.to_i]
    ws[row,6] = license
  rescue RuntimeError => e
    $stderr.puts e.inspect
  end

  puts flickr_url
end

ws.save()