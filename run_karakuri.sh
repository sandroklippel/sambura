#!/bin/bash
# Filename: run_karakuri.sh
#
# Description:
#   This script is intended to be run karakuri automata in a cron job, e.g.:
#   */30 * * * * /sambura/run_karakuri.sh &>> /sambura/run_karakuri_$(date +\%Y\%m\%dT\%H\%M).log
#
# Depends:
#   podman
#   docker.io/selenium/standalone-chrome:119.0
#   ghcr.io/sandroklippel/karakuri:latest

podman run --rm --pod sambura -v /sambura/downloads:/sambura/downloads:z,rw -v /sambura/var:/sambura/var:z,ro --name karakuri ghcr.io/sandroklippel/karakuri:latest