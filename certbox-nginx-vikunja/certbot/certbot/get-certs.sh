#!/usr/bin/env bash

set -x

certbot certonly \
    --quiet \
    --agree-tos \
    --dns-cloudflare \
    --dns-cloudflare-credentials /root/certbot/cloudflare-credentials.ini \
    --dns-cloudflare-propagation-seconds 60 \
