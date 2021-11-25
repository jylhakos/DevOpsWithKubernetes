#!/usr/bin/env sh
set -e

echo URL

npm install curl

ls -l /usr/bin/curl

TODO_URL=$(sh -c echo -n ; /usr/bin/curl -sI https://en.wikipedia.org/wiki/Special:Random | grep 'location:' | awk '{print $2}')

echo $TODO_URL
