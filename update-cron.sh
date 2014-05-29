#!/bin/bash

# needed for ssh-agent auth under cron on OS X
declare -x SSH_AUTH_SOCK=$( find /tmp/launch-*/Listeners -user $(whoami) -type s | head -1 )

./google_spreadsheet_to_csv.rb > squeezes.csv
pushd squeezes
../dlflickr.rb < ../squeezes.csv
popd
rsync -avz -e ssh squeezes/ libdc3-dev-02.oit.duke.edu:/srv/data/IDEs/flickr