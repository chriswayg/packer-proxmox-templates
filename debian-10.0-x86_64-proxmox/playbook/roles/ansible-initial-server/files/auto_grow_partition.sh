#!/bin/bash
growpart -N /dev/sda 1
if [ $? -eq 0 ]; then
    echo "* auto-growing and resizing /dev/sda1"
    growpart /dev/sda 1
    resize2fs /dev/sda1
fi
