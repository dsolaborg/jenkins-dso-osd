#!/bin/bash

# AWS Cli
BIN_PATH="/home/jenkins/.local/bin" 
curl -O https://bootstrap.pypa.io/get-pip.py
python get-pip.py --user
export PATH=$BIN_PATH:$PATH:/sbin
pip install --user awscli
