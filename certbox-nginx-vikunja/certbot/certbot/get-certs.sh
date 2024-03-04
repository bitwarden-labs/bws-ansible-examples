#!/usr/bin/env bash

set -x

certbot certonly \
    --quiet \
    --agree-tos \
    --email atjbramley@hotmail.com \
    --dns-cloudflare \
    --dns-cloudflare-credentials /root/certbot/cloudflare-credentials.ini \
    --dns-cloudflare-propagation-seconds 60 \
    --domain 'ansibledemo.atjb.link'
