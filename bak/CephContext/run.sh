#!/bin/bash

dot -T png -o CephContext.png template.dot
cp CephContext.png /usr/share/nginx/html/
#shotwell out.png
#eog out.png

#dot -T ps -o out.ps template.dot
#evince out.ps
