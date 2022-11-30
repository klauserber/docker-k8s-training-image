#!/usr/bin/env sh

REGISTRY_NAME=isi006
IMAGE_NAME=docker-k8s-training

docker run -it --rm \
  ${REGISTRY_NAME}/${IMAGE_NAME}:latest