#!/bin/bash

set -x

git status
git add --all .
git commit -m "update"
git push
