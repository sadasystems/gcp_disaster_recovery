#!/usr/bin/env bash
set -e

curl -o jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
chmod 0755 jq

eval "$(jq -r '@sh "SOURCE_VM=\(.source_vm) PROJECT=\(.project) ZONE=\(.zone)"')"

#CMD="gcloud compute instances describe $SOURCE_VM --project $PROJECT --zone $ZONE --format=json | jq ."
CMD="curl -H 'Authorization: Bearer 2a3xrm1eg3t811zv1nt22qj1fr125q2brd13feedaqkzczsq5y2wz' -H 'Content-Type: application/json' 'https://compute.googleapis.com/compute/v1/projects/$PROJECT/zones/$ZONE/instances/$SOURCE_VM' | jq ."


jq -n --arg vm "$(eval $CMD)" '{"source_vm":$vm}'
