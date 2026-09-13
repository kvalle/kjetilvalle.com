#!/usr/bin/env bash

set -euo pipefail

readonly BUCKET="s3://kjetilvalle.com/"
readonly AWS_ACCESS_KEY_ID_REF="op://Private/aws_privat_access_key_id/credential"
readonly AWS_SECRET_ACCESS_KEY_REF="op://Private/aws_privat_secret_access_key/credential"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

for command in op aws; do
  if ! command -v "$command" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$command" >&2
    exit 1
  fi
done

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
AWS_ACCESS_KEY_ID="$(op read "$AWS_ACCESS_KEY_ID_REF")"
AWS_SECRET_ACCESS_KEY="$(op read "$AWS_SECRET_ACCESS_KEY_REF")"

printf 'Changes to %s:\n\n' "$BUCKET"
aws s3 sync "$SCRIPT_DIR/public/" "$BUCKET" \
  --delete \
  --no-follow-symlinks \
  --dryrun

printf '\nDeploy these changes? [y/N] '
read -r confirmation </dev/tty

if [[ "$confirmation" != "y" && "$confirmation" != "Y" ]]; then
  printf 'Deployment cancelled.\n'
  exit 0
fi

aws s3 sync "$SCRIPT_DIR/public/" "$BUCKET" \
  --delete \
  --no-follow-symlinks

printf 'Deployment complete.\n'
