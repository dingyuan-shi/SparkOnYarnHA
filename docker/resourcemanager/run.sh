#!/bin/bash
set -e

echo "start yarn"
yarn --daemon start resourcemanager

# create foreground process to avoid being killed
echo "a" >> /a.log
tail -f a.log
