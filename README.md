dlflickr
========

This repository contains a set of scripts which, used together, can automatically archive a set of Flickr URLs from a Google Sheet.

* `dlflickr.rb`: takes a list of newline-separated Flickr URLs as input and calls `wget` to download them to the current working directory
* `google_spreadsheet_to_csv.rb`: downloads a Google Sheet to a local CSV for input to `dlflickr.rb`, and updates a column in the Google Sheet with the image license
* `update-cron.sh`: calls `google_spreadsheet_to_csv.rb` and `dlflickr.rb` then `rsync`s the images to a remote server

You can use the components piecemeal, or use `update-cron.sh` on an automated basis if it meets your needs. Run `bundle install` to install gems first.

`google_spreadsheet_to_csv.rb` expects configuration variables to be stored in a file named `.secrets.yml`:

    ---
    email: usename@gmail.com
    pass: googlepasswordorapppassword
    spreadsheet_key: googlespreadhseetkeystring
    spreadsheet_worksheet: 0
    spreadsheet_flickr_column: 2
    spreadsheet_license_column: 6
    flickr_key: flickrapikey
    flickr_secret: flickrapikeysecret

`update-cron.sh` expects your `rsync` destination in a file named `.rsync-dest`:

    remote-host.example.com:/srv/data/flickrbackup
