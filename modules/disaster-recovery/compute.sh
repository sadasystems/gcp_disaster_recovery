#!/usr/bin/env bash
set -e

curl -o jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
chmod 0755 jq

eval "$(jq -r '@sh "SOURCE_VM=\(.source_vm) PROJECT=\(.project) ZONE=\(.zone)"')"

#CMD="gcloud compute instances describe $SOURCE_VM --project $PROJECT --zone $ZONE --format=json | jq ."
CMD="curl -H 'Authorization: Bearer ya29.a0ARrdaM9JsUUgaqwo-kTQQmJoFIAMNjG7oNXK9szfrq4RLuqCvY_qtH7KeHwQZcnmrrQYPBfigFHGC8tCIpxEdC12kdLWag3GJ5hAqkWBQE_5UvVraWRcSCkTdJwikrODwa0pFTZ-RWiC5K6Vp3P_qswf46rX' -H 'Content-Type: application/json' 'https://compute.googleapis.com/compute/v1/projects/$PROJECT/zones/$ZONE/instances/$SOURCE_VM' | jq ."


jq -n --arg vm "$(eval $CMD)" '{"source_vm":$vm}'