#!/usr/bin/env bash
set -e

curl -o jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
chmod 0755 jq

eval "$(jq -r '@sh "SOURCE_VM=\(.source_vm) PROJECT=\(.project) ZONE=\(.zone)"')"

CMD="gcloud compute instances describe $SOURCE_VM --project $PROJECT --zone $ZONE --format=json | jq ."

jq -n --arg vm "$(eval $CMD)" '{"source_vm":$vm}'