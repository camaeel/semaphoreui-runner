#!/usr/bin/env bash

docker build --build-arg BASE_VERSION=v2.14.10 -t semaphore-runner:local .
