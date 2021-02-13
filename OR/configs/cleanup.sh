#!/bin/sh
 
set -e
 
echo 'Cleaning up after bootstrapping...'
sudo apt-get -y autoremove
sudo apt-get -y clean
sudo rm -r /tmp/*
cat /dev/null > ~/.bash_history
#history -c
exit
