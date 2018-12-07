#!/bin/bash

cd `dirname $0`
set -x

git pull
git status
git add --all .
git status
git commit -m "update"
git push
