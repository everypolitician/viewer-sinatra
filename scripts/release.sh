#!/bin/bash
#
# This script has been copied over to everypolitician-data and modified
# slightly as `scripts/deploy.sh`. Any changes to this script might also need
# to be made in that script.
#
# @see https://git.io/viSn6

set -eo pipefail

[[ "$TRACE" ]] && set -x

build_viewer_static() {
  bundle exec ruby app.rb &
  while ! nc -z localhost 4567; do sleep 1; done
  cd /tmp
  wget -nv -m localhost:4567/status/all_countries.html || (echo "wget exited with non-zero exit code: $?" >&2 && exit 1)
}

deploy_viewer_static() {
  git clone --depth=1 https://github.com/everypolitician/viewer-static.git
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
