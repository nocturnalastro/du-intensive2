#!/bin/bash
export FEDORA_STRESSNG_TEST_IMAGE=ghcr.io/abraham2512/fedora-stress-ng:master
export CURL_TEST_IMAGE=quay.io/cloud-bulldozer/curl:latest
export NGINX_TEST_IMAGE=quay.io/cloud-bulldozer/sampleapp:latest
export KUBECTL_TEST_IMAGE=bitnami/kubectl:latest
kube-burner init --config du-intensive.yml