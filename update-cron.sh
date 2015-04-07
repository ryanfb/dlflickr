#!/bin/bash

# needed for ssh-agent auth under cron on OS X
declare -x SSH_AUTH_SOCK=$( find /tmp/com.apple.launchd.*/Listeners -user $(whoami) -type s | head -1 )

bundle install
bundle exec ./google_spreadsheet_to_csv.rb > images.csv
mkdir -p images
pushd images
bundle exec ../dlflickr.rb < ../images.csv
popd
rsync -avz -e ssh images/ $(cat .rsync-dest)
