#!/bin/bash

set -eo pipefail

[[ "$TRACE" ]] && set -x

build_viewer_static() {
  bundle exec ruby app.rb &
  while ! nc -z localhost 4567; do sleep 1; done
  cd /tmp
  wget -nv -m localhost:4567/status/all_countries.html || (echo "wget exited with non-zero exit code: $?" >&2 && exit 1)
}

deploy_viewer_static() {
  git clone https://github.com/everypolitician/viewer-static.git
  cd viewer-static
  git checkout gh-pages
  cp -R ../localhost:4567/* .
  git add .
  git -c "user.name=everypoliticianbot" -c "user.email=everypoliticianbot@users.noreply.github.com" commit -m "Automated commit" || true
  git push origin gh-pages
}

main() {
  build_viewer_static
  if [[ "$TRAVIS_PULL_REQUEST" == "false" ]]; then
    if [[ "$TRAVIS_BRANCH" == "master" ]]; then
      deploy_viewer_static
    fi
  fi
}

main
