#!/bin/bash

set -e

# Add Brightbox Ruby PPA
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common
sudo apt-add-repository ppa:brightbox/ruby-ng
sudo apt-get update

# Install required packages
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  ruby2.0 ruby2.0-dev git build-essential libxslt1-dev zlib1g-dev

# Add cd /vagrant to ~/.bashrc
grep -qG "cd /vagrant" "$HOME/.bashrc" || echo "cd /vagrant" >> "$HOME/.bashrc"
cd /vagrant

# Install application gems
sudo gem install bundler foreman --no-rdoc --no-ri
bundle install

# Set shell login message
echo "-------------------------------------------------------
Welcome to the popolo-viewer-sinatra vagrant machine

Run the web server with:
  foreman start

Then visit http://localhost:5000/

Note that changes to app.rb will only be picked up
after restarting the server. Template changes will be
picked up on every page load without needing to
restart.

Run the tests with:
  bundle exec rake test

-------------------------------------------------------
" | sudo tee /etc/motd > /dev/null
