#!/bin/bash

dot -T png -o code.png template.dot
cp code.png ../../png/
#cp code.png /usr/share/nginx/html/
#shotwell out.png
#eog out.png

#dot -T ps -o out.ps template.dot
#evince out.ps
