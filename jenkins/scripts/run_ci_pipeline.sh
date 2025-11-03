#!/usr/bin/env bash

# Abort on first error, treat unset variables as errors, and fail pipelines early.
set -euo pipefail

############################################
# Stage 1 – Read configuration parameters. #
############################################

# Git repository to fetch; Jenkins overrides these via environment variables.
REPO_URL="${REPO_URL:-https://github.com/duvamduvam/dadou_robot_ros.git}"
REPO_BRANCH="${REPO_BRANCH:-main}"

# Docker build settings used for the final image.
DOCKER_IMAGE="${DOCKER_IMAGE:-dadou_robot}"
DOCKER_TAG="${DOCKER_TAG:-${REPO_BRANCH}-$(date +%Y%m%d%H%M%S)}"
DOCKERFILE="${DOCKERFILE:-Dockerfile}"
DOCKER_CONTEXT="${DOCKER_CONTEXT:-.}"

# Optional shared workspace on the remote host (allows cache reuse between builds).
WORKSPACE_ROOT="${WORKSPACE_ROOT:-}"

# Will point to the active working directory during the run.
TEMP_DIR=""

##########################################################
# Stage 2 – Define lifecycle helpers and shell safeguards #
##########################################################

# Remove the working directory when the script ends, unless KEEP_WORKDIR is set.
cleanup() {
  if [[ -z "${KEEP_WORKDIR:-}" && -n "${TEMP_DIR}" && -d "${TEMP_DIR}" ]]; then
    rm -rf "${TEMP_DIR}"
  fi
}

# Ensure the cleanup is executed on success, error, or interruption.
trap cleanup EXIT ERR INT TERM

# Guard that verifies the presence of required commands.
require_command() {
  local cmd="$1"
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    printf "Missing required command: %s\n" "${cmd}" >&2
    exit 1
  fi
}

# Validate the toolchain (git / docker) before doing any work.
require_tools() {
  require_command git
  require_command docker
}

####################################################
# Stage 3 – Prepare or refresh the source workspace #
####################################################

prepare_workspace() {
  echo "[CI][1/3] Preparing workspace at ${WORKSPACE_ROOT:-temporary directory}..."
  if [[ -n "${WORKSPACE_ROOT}" ]]; then
    # Use the provided persistent directory and refresh it if already cloned.
    mkdir -p "${WORKSPACE_ROOT}"
    TEMP_DIR="${WORKSPACE_ROOT}"
    if [[ -d "${TEMP_DIR}/.git" ]]; then
      git -C "${TEMP_DIR}" fetch origin "${REPO_BRANCH}"
      git -C "${TEMP_DIR}" reset --hard "origin/${REPO_BRANCH}"
      return
    fi
  else
    # Otherwise create a brand-new temporary directory for this build.
    TEMP_DIR="$(mktemp -d -t dadou-ci-XXXXXX)"
  fi

  if [[ -d "${TEMP_DIR}/.git" ]]; then
    git -C "${TEMP_DIR}" fetch origin "${REPO_BRANCH}"
    git -C "${TEMP_DIR}" reset --hard "origin/${REPO_BRANCH}"
  else
    git clone --depth=1 --branch "${REPO_BRANCH}" "${REPO_URL}" "${TEMP_DIR}"
  fi
  echo "[CI][1/3] Workspace ready in ${TEMP_DIR}"
}

# Stage 4 – Build the Docker image output #
###########################################

build_docker() {
  echo "[CI][2/3] Building Docker image ${DOCKER_IMAGE}:${DOCKER_TAG}..."
  pushd "${TEMP_DIR}" >/dev/null
  docker build \
    --file "${DOCKERFILE}" \
    --tag "${DOCKER_IMAGE}:${DOCKER_TAG}" \
    "${DOCKER_CONTEXT}"
  popd >/dev/null
  echo "[CI][2/3] Docker build finished"
}

###########################################################
# Stage 5 – Run integration tests inside the Docker image #
###########################################################

test_docker_image() {
  echo "[CI][3/3] Running tests inside Docker image ${DOCKER_IMAGE}:${DOCKER_TAG}..."
  docker run --rm \
    --env TEST_COMMAND="${TEST_COMMAND:-pytest -q}" \
    "${DOCKER_IMAGE}:${DOCKER_TAG}" \
    bash -lc "${TEST_COMMAND:-pytest -q}"
  echo "[CI][3/3] Dockerized test stage completed successfully"
}

##########################################
# Stage 6 – Orchestrate the full process #
##########################################

main() {
  echo "[CI][0/3] Validating build prerequisites..."
  require_tools           # 1. Sanity-check required binaries.
  echo "[CI][0/3] Prerequisites validated"
  prepare_workspace       # 2. Fetch or update the project sources.
  build_docker            # 3. Build the Docker image from the tested sources.
  test_docker_image       # 4. Execute tests inside the built image.
  printf "[CI] Docker image available: %s:%s\n" "${DOCKER_IMAGE}" "${DOCKER_TAG}"
}

main "$@"
