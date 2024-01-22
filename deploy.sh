#!/bin/bash

# create conatiners
podman pod create --shm-size="2g" sambura
podman run -d --pod sambura -v /sambura/downloads:/home/seluser/Downloads:z,rw --name selenium-chrome selenium/standalone-chrome:119.0
podman pull ghcr.io/sandroklippel/karakuri:latest

# systemd config
sudo loginctl enable-linger $USER
podman generate systemd --name sambura > ~/.config/systemd/user/pod-sambura.service
podman generate systemd --name selenium-chrome > ~/.config/systemd/user/container-selenium-chrome.service
systemctl --user daemon-reload
systemctl --user enable --now pod-sambura.service
systemctl --user enable --now container-selenium-chrome.service