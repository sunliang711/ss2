#!/bin/bash
fullpath="$(pwd)/$0"
cd $(dirname $fullpath)
./stop.sh
./start.sh
