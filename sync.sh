#!/bin/bash

set -x

git status
git add --all .
git status
git commit -m "update"
git push
