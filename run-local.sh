#!/usr/bin/env bash
cd app
bundle install
bundle exec rackup -o 127.0.0.1 -p 8080