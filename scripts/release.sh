#!/bin/bash

set -eo pipefail

[[ "$TRACE" ]] && set -x

add_ssh_key() {
  openssl aes-256-cbc -K $encrypted_ab0690a1b9d7_key -iv $encrypted_ab0690a1b9d7_iv -in deploy_key.pem.enc -out deploy_key.pem -d
  chmod 600 deploy_key.pem
  eval "$(ssh-agent)"
  ssh-add deploy_key.pem
}

build_viewer_static() {
  bundle exec ruby app.rb &
  while ! nc -z localhost 4567; do sleep 1; done
  cd /tmp
  wget -nv -m localhost:4567/status/all_countries.html || (echo "wget exited with non-zero exit code: $?" >&2 && exit 1)
}

deploy_viewer_static() {
  git clone "git@github.com:everypolitician/viewer-static.git"
  cd viewer-static
  git checkout gh-pages
  cp -R ../localhost:4567/* .
  git add .
  git -c "user.name=everypoliticianbot" -c "user.email=everypoliticianbot@users.noreply.github.com" commit -m "Automated commit" || true
  git push origin gh-pages
}

main() {
  add_ssh_key
  build_viewer_static
  if [[ "$TRAVIS_PULL_REQUEST" == "false" ]]; then
    if [[ "$TRAVIS_BRANCH" == "master" ]]; then
      deploy_viewer_static
    fi
  fi
}

main
