#!/usr/bin/env bash

REGISTRY_NAME=isi006
IMAGE_NAME=docker-k8s-training

docker push \
    ${REGISTRY_NAME}/${IMAGE_NAME}:latest
