#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'

ARGF.each_line do |line|
  line.chomp!
  save_file = line.split('/')[-2..-1].join('_') + '.jpg'
  begin
    unless File.exist?(save_file)
      doc = Nokogiri::HTML(open(line + "/sizes/o/"))

      doc.xpath('//div[@id="allsizes-photo"]/img/@src').each do |link|
        $stderr.puts "#{save_file}: #{line} => #{link}"
        `wget -O #{save_file} -c #{link}`
      end
    end
  rescue OpenURI::HTTPError => e
    $stderr.puts line
    $stderr.puts e.inspect
  end
end