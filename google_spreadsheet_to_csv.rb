#!/usr/bin/env ruby

require 'rubygems'
require 'google_drive'
require 'yaml'

config = YAML.load_file('.secrets.yml')
session = GoogleDrive.login(config["email"], config["pass"])

ws = session.spreadsheet_by_key(config["spreadsheet_key"]).worksheets[0]

for row in 2..ws.num_rows
  puts ws[row,2]
end
