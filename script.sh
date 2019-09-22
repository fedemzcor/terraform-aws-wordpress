#!/bin/bash
yes | sudo /opt/bitnami/letsencrypt/scripts/generate-certificate.sh -m $1 -d $2