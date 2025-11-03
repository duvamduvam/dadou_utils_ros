#!/usr/bin/env bash

# shellcheck disable=SC2086

set -euo pipefail

export GIT_SSH_COMMAND="${GIT_SSH_COMMAND:-ssh -o StrictHostKeyChecking=no}"

REPO_URL="${REPO_URL:-git@github.com:duvamduvam/dadou_robot_ros.git}"
REPO_BRANCH="${REPO_BRANCH:-main}"
PYTHON_REQUIREMENTS="${PYTHON_REQUIREMENTS:-requirements.txt}"
TEST_COMMAND="${TEST_COMMAND:-pytest -q}"
DOCKER_IMAGE="${DOCKER_IMAGE:-dadou_robot}"
DOCKER_TAG="${DOCKER_TAG:-${REPO_BRANCH}-$(date +%Y%m%d%H%M%S)}"
DOCKERFILE="${DOCKERFILE:-Dockerfile}"
DOCKER_CONTEXT="${DOCKER_CONTEXT:-.}"
WORKSPACE_ROOT="${WORKSPACE_ROOT:-}"

TEMP_DIR=""

cleanup() {
  if [[ -z "${KEEP_WORKDIR:-}" && -n "${TEMP_DIR}" && -d "${TEMP_DIR}" ]]; then
    rm -rf "${TEMP_DIR}"
  fi
}

trap cleanup EXIT ERR INT TERM

require_command() {
  local cmd="$1"
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    printf "Missing required command: %s\n" "${cmd}" >&2
    exit 1
  fi
}

require_tools() {
  require_command git
  require_command python3
  require_command docker
}

prepare_workspace() {
  if [[ -n "${WORKSPACE_ROOT}" ]]; then
    mkdir -p "${WORKSPACE_ROOT}"
    TEMP_DIR="${WORKSPACE_ROOT}"
    if [[ -d "${TEMP_DIR}/.git" ]]; then
      git -C "${TEMP_DIR}" fetch origin "${REPO_BRANCH}"
      git -C "${TEMP_DIR}" reset --hard "origin/${REPO_BRANCH}"
      return
    fi
  else
    TEMP_DIR="$(mktemp -d -t dadou-ci-XXXXXX)"
  fi

  if [[ -d "${TEMP_DIR}/.git" ]]; then
    git -C "${TEMP_DIR}" fetch origin "${REPO_BRANCH}"
    git -C "${TEMP_DIR}" reset --hard "origin/${REPO_BRANCH}"
  else
    git clone --depth=1 --branch "${REPO_BRANCH}" "${REPO_URL}" "${TEMP_DIR}"
  fi
}

run_tests() {
  pushd "${TEMP_DIR}" >/dev/null
  python3 -m venv venv
  source venv/bin/activate
  pip install --upgrade pip
  pip install -r "${PYTHON_REQUIREMENTS}"
  bash -lc "${TEST_COMMAND}"
  deactivate
  popd >/dev/null
}

build_docker() {
  pushd "${TEMP_DIR}" >/dev/null
  docker build \
    --file "${DOCKERFILE}" \
    --tag "${DOCKER_IMAGE}:${DOCKER_TAG}" \
    "${DOCKER_CONTEXT}"
  popd >/dev/null
}

main() {
  require_tools
  prepare_workspace
  run_tests
  build_docker
  printf "Docker image available: %s:%s\n" "${DOCKER_IMAGE}" "${DOCKER_TAG}"
}

main "$@"
