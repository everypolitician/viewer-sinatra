#!/bin/bash

set -eo pipefail

[[ "$TRACE" ]] && set -x

add_ssh_key() {
  openssl aes-256-cbc -K $encrypted_ab0690a1b9d7_key -iv $encrypted_ab0690a1b9d7_iv -in deploy_key.pem.enc -out deploy_key.pem -d
  chmod 600 deploy_key.pem
  eval "$(ssh-agent)"
  ssh-add deploy_key.pem
}

update_viewer_static() {
  bundle exec ruby app.rb &
  while ! nc -z localhost 4567; do sleep 1; done
  cd /tmp
  wget -nv -m localhost:4567/status/all_countries.html || (echo "wget exited with non-zero exit code: $?" >&2 && exit 1)
  git clone "git@github.com:everypolitician/viewer-static.git"
  cd viewer-static
  git checkout gh-pages
  cp -R ../localhost:4567/* .
  git add .
  git -c "user.name=everypoliticianbot" -c "user.email=everypoliticianbot@users.noreply.github.com" commit -m "Automated commit" || true
  git push origin gh-pages
}

update_politician_image_proxy() {
  cd /tmp
  git clone "git@github.com:mysociety/politician-image-proxy.git"
  cd politician-image-proxy
  bundle install --gemfile=Gemfile
  echo "Updating politician-image-proxy"
  QUIET=1 ruby scraper.rb
  git add .
  git -c "user.name=everypoliticianbot" -c "user.email=everypoliticianbot@users.noreply.github.com" commit -m "Update images" || true
  git push origin gh-pages
}

main() {
  if [[ "$TRAVIS_PULL_REQUEST" == "false" ]]; then
    add_ssh_key
    if [[ "$TRAVIS_BRANCH" == "master" ]]; then
      update_viewer_static
    fi
    # update_politician_image_proxy
  fi
}

main
