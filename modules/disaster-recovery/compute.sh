#!/usr/bin/env bash
set -e

eval "$(jq -r '@sh "SOURCE_VM=\(.source_vm) PROJECT=\(.project) ZONE=\(.zone)"')"

CMD="gcloud compute instances describe $SOURCE_VM --project $PROJECT --zone $ZONE --format=json | jq ."

jq -n --arg vm "$(eval $CMD)" '{"source_vm":$vm}'