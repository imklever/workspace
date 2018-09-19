#!/bin/bash

set -x

git pull
git status
git add --all .
git status
git commit -m "update"
git push
