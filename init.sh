#!/bin/bash
set -e

# INGRESS_SUBNETS are subnets allowed to push stream
sed -i "s|INGRESS_SUBNETS|$INGRESS_SUBNETS|g" /etc/nginx/conf.d/rtmp.conf

# INGRESS_STREAM_KEY is a local stream key (long, random, unguessable alphanumeric-only value) to
# identify who can send stream into this relay
sed -i "s|INGRESS_STREAM_KEY|$INGRESS_STREAM_KEY|g" /etc/nginx/conf.d/rtmp.conf

# PUSH_RTMP_URL defines where should the inbound stream be relate to a third-party ingestion
# endpoint, such as Twitch.
sed -i "s|PUSH_RTMP_URL|$PUSH_RTMP_URL|g" /etc/nginx/conf.d/rtmp.conf

# Now start nginx for receiving streams
nginx