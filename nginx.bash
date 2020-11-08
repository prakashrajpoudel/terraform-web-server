#!/bin/bash
exec 1>log.out 2>&1

sudo apt-get update
sudo apt-get install nginx -y