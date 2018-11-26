#!/bin/bash

genisoimage -v -cache-inodes -joliet-long -R -J -T -V leo_Centos7 -o /home/leo.iso -c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table .
