#!/usr/bin/env bash

GIT_BASE_PATH="$(git rev-parse --show-toplevel)"
DESTINATION_PATH="${GIT_BASE_PATH}/apps/tektron/hack"
fetch --repo https://github.com/tektoncd/plumbing --branch main --source-path=/hack  "${DESTINATION_PATH}"