#!/usr/bin/env bash

set -eo pipefail

cd /tmp
wget https://github.com/htacg/tidy-html5/archive/5.2.0.zip
unzip 5.2.0.zip
cd tidy-html5-5.2.0/build/cmake
cmake ../..
make
mkdir ~/bin
mv tidy ~/bin/tidy
