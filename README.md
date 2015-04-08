dlflickr
========

This repository contains scripts for automatically archiving Flickr URLs.

* `dlflickr.rb`: takes a list of newline-separated Flickr URLs as input and calls `wget` to download them to the current working directory, optionally archiving Flickr metadata
* `google_spreadsheet_to_csv.rb`: outputs Flickr URL's in a Google Sheet for input to `dlflickr.rb`, and updates a column in the Google Sheet with the image license
* `update-cron.sh`: calls `google_spreadsheet_to_csv.rb` and `dlflickr.rb` then `rsync`s the images to a remote server

You can use the components piecemeal, or use `update-cron.sh` on an automated basis if it meets your needs. Run `bundle install` to install gems first.

### `dlflickr.rb`

The core `dlflickr.rb` script tries to be as straightforward as possible. For each line of input, it tries to download the maximum resolution Flickr image at that URL using `wget`. If you want to get fancy, it also supports a `-a` flag for archiving Flickr metadata for each URL to a separate XML file [like this](https://gist.github.com/853a6e047aaa0063c8a9). This requires a [Flickr API key](https://www.flickr.com/services/api/keys/), which you can pass in with the `-f` flag or the `.secrets.yml` config file described below.

`dlflickr.rb` currently *does not* fetch or overwrite existing files on subsequent invocations. Files are saved to `username-or-nsid_photo-id.ext` in the current working directory.

### `google_spreadsheet_to_csv.rb`

`google_spreadsheet_to_csv.rb` expects configuration variables to be stored in a file named `.secrets.yml`:

    ---
    email: username@gmail.com
    pass: googlepasswordorapppassword
    spreadsheet_key: googlespreadhseetkeystring
    spreadsheet_worksheet: 0
    spreadsheet_flickr_column: 2
    spreadsheet_license_column: 6
    flickr_key: flickrapikey
    flickr_secret: flickrapikeysecret

### `update-cron.sh`

`update-cron.sh` expects your `rsync` destination in a file named `.rsync-dest`:

    remote-host.example.com:/srv/data/flickrbackup

### Related Tools

Based on the [Archive Team Wiki Flickr page](http://archiveteam.org/index.php?title=Flickr), here are some other Flickr backup tools that didn't quite meet my needs (still, they might meet yours):

* [photobackup](https://hsivonen.fi/photobackup/) - designed to back up all photos and metadata for a single Flickr user
* [flickrbackup](https://github.com/tiagovaz/flickrbackup) - backs up photos and metadata for a single Flickr user, but only supports writing Flickr metadata back into the original image EXIF
* [parallel-flickr](https://github.com/straup/parallel-flickr) - backs up photos and metadata for a single Flickr user, and generates a database-backed website for re-hosting them
* [FlickrFckr](https://github.com/ab2525/FlickrFckr) - brutally simple photo & metadata download, but busted for me

