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
DOCKER_BUILD_CONTEXT="${DOCKER_BUILD_CONTEXT:-${DOCKER_CONTEXT:-.}}"

# Optional secondary repository containing shared utilities required by the build.
DADOU_UTILS_REPO_URL="${DADOU_UTILS_REPO_URL:-https://github.com/duvamduvam/dadou_utils_ros.git}"
DADOU_UTILS_REPO_BRANCH="${DADOU_UTILS_REPO_BRANCH:-main}"

# Allow overriding the Docker command (e.g. "sudo docker").
if [[ -n "${DOCKER_CMD:-}" ]]; then
  # shellcheck disable=SC2206 # Word splitting is intentional to support arguments like "sudo -H docker".
  DOCKER_CLI=( ${DOCKER_CMD} )
else
  DOCKER_CLI=(docker)
fi

# Treat values that look like filesystem paths as build contexts rather than Docker CLI contexts.
if [[ -n "${DOCKER_CONTEXT:-}" ]]; then
  case "${DOCKER_CONTEXT}" in
    .|./*|../*|/*)
      DOCKER_BUILD_CONTEXT="${DOCKER_CONTEXT}"
      unset DOCKER_CONTEXT
      ;;
  esac
fi

# Optional shared workspace on the remote host (allows cache reuse between builds).
WORKSPACE_ROOT="${WORKSPACE_ROOT:-}"

# Will point to the active working directory during the run.
TEMP_DIR=""
PRIMARY_WORKSPACE_DIR=""
LOCAL_MIRROR_DIR=""

##########################################################
# Stage 2 – Define lifecycle helpers and shell safeguards #
##########################################################

# Remove every entry in the given directory while keeping the directory itself.
purge_directory_contents() {
  local dir="$1"
  if [[ -d "${dir}" && "${dir}" != "/" ]]; then
    find "${dir}" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
  fi
}

# Reset a Git workspace to a pristine state without deleting the clone.
reset_git_workspace() {
  local dir="$1"
  if [[ ! -d "${dir}/.git" ]]; then
    return 1
  fi

  if git -C "${dir}" reset --hard HEAD >/dev/null 2>&1 \
      && git -C "${dir}" clean -fdx >/dev/null 2>&1; then
    return 0
  fi

  return 1
}

# Remove the working directory when the script ends, unless KEEP_WORKDIR is set.
cleanup() {
  if [[ -n "${LOCAL_MIRROR_DIR}" && -d "${LOCAL_MIRROR_DIR}" ]]; then
    rm -rf "${LOCAL_MIRROR_DIR}"
  fi

  local target="${PRIMARY_WORKSPACE_DIR:-${TEMP_DIR}}"
  if [[ -z "${target}" || ! -d "${target}" ]]; then
    return
  fi

  if [[ -n "${WORKSPACE_ROOT}" && "${target}" == "${WORKSPACE_ROOT}" ]]; then
    if [[ -n "${KEEP_WORKDIR:-}" ]]; then
      if ! reset_git_workspace "${target}"; then
        purge_directory_contents "${target}" || true
      fi
      return
    fi
  fi

  rm -rf "${target}"
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
  require_command "${DOCKER_CLI[0]}"
}

# Ensure the script can reach the Docker daemon, falling back to sudo when available.
ensure_docker_access() {
  if docker_has_access; then
    return
  fi

  if command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
    local sudo_cli=(sudo "${DOCKER_CLI[@]}")
    if docker_has_access "${sudo_cli[@]}"; then
      DOCKER_CLI=("${sudo_cli[@]}")
      echo "[CI][0/3] Docker daemon reachable via sudo." >&2
      return
    fi
  fi

  printf "Unable to reach the Docker daemon with current permissions.\n" >&2
  printf "Verify that the user belongs to the docker group or provide DOCKER_CMD='sudo docker'.\n" >&2
  exit 1
}

# Check whether the current (or provided) Docker command can query the daemon.
docker_has_access() {
  local cli=("${DOCKER_CLI[@]}")
  if [[ "$#" -gt 0 ]]; then
    cli=("$@")
  fi

  "${cli[@]}" info >/dev/null 2>&1
}

# Convenience wrapper to execute Docker commands via the resolved CLI.
docker_exec() {
  "${DOCKER_CLI[@]}" "$@"
}

# Ensure Dockerfile path and build context refer to actual repository files.
resolve_docker_build_inputs() {
  local repo_root="${TEMP_DIR}"

  if [[ -z "${repo_root}" ]]; then
    printf "Workspace directory is not set before resolving Docker build inputs.\n" >&2
    exit 1
  fi

  local requested_dockerfile="${DOCKERFILE}"
  local requested_context="${DOCKER_BUILD_CONTEXT}"
  local original_context="${DOCKER_BUILD_CONTEXT}"
  local resolved_relative=""
  local resolved_absolute=""
  local context_trim=""

  if [[ "${requested_dockerfile}" == ./* ]]; then
    requested_dockerfile="${requested_dockerfile#./}"
  fi

  if [[ -n "${requested_dockerfile}" ]]; then
    if [[ "${requested_dockerfile}" == /* ]]; then
      if [[ -f "${requested_dockerfile}" ]]; then
        resolved_absolute="${requested_dockerfile}"
      elif [[ -f "${repo_root}${requested_dockerfile}" ]]; then
        resolved_relative="${requested_dockerfile#/}"
      fi
    elif [[ -f "${repo_root}/${requested_dockerfile}" ]]; then
      resolved_relative="${requested_dockerfile}"
    fi
  fi

  if [[ -z "${resolved_relative}" && -z "${resolved_absolute}" && -n "${requested_context}" && "${requested_context}" != "." ]]; then
    context_trim="${requested_context%/}"
    if [[ -f "${repo_root}/${context_trim}/${requested_dockerfile}" ]]; then
      resolved_relative="${context_trim}/${requested_dockerfile}"
      echo "[CI][2/3] Dockerfile not found at repository root, using ${resolved_relative}." >&2
    fi
  fi

  if [[ -z "${resolved_relative}" && -z "${resolved_absolute}" ]]; then
    local inferred=""
    case "$(uname -m)" in
      arm*|aarch64)
        inferred="conf/docker/arm/Dockerfile-arm"
        ;;
      x86_64|amd64)
        inferred="conf/docker/x8664/Dockerfile-x86"
        ;;
    esac

    if [[ -z "${inferred}" || ! -f "${repo_root}/${inferred}" ]]; then
      if [[ -f "${repo_root}/conf/docker/Dockerfile" ]]; then
        inferred="conf/docker/Dockerfile"
      elif [[ -f "${repo_root}/conf/docker/Dockerfile-bak" ]]; then
        inferred="conf/docker/Dockerfile-bak"
      else
        inferred=""
      fi
    fi

    if [[ -n "${inferred}" ]]; then
      resolved_relative="${inferred}"
      echo "[CI][2/3] Dockerfile not found at requested path, using ${resolved_relative}." >&2
    fi
  fi

  if [[ -n "${resolved_relative}" ]]; then
    DOCKERFILE="${resolved_relative}"
  elif [[ -n "${resolved_absolute}" ]]; then
    DOCKERFILE="${resolved_absolute}"
  else
    printf "Dockerfile '%s' introuvable dans le workspace (contexte: '%s').\n" "${requested_dockerfile}" "${original_context}" >&2
    printf "Ajustez DOCKERFILE/DOCKER_CONTEXT ou ajoutez le Dockerfile attendu.\n" >&2
    exit 1
  fi

  local context_final="${original_context}"
  if [[ -z "${KEEP_DOCKER_CONTEXT:-}" ]]; then
    if [[ -n "${resolved_relative}" ]]; then
      if [[ "${resolved_relative}" == */* ]]; then
        context_final="${resolved_relative%/*}"
      else
        context_final="."
      fi
    fi

    if [[ -z "${context_final}" || "${context_final}" == "." || "${context_final}" == "./" ]]; then
      DOCKER_BUILD_CONTEXT="."
    elif [[ "${context_final}" != /* ]]; then
      DOCKER_BUILD_CONTEXT="."
      if [[ "${original_context}" != "." && -n "${original_context}" ]]; then
        echo "[CI][2/3] Ajustement du contexte Docker à la racine du dépôt pour exposer tous les fichiers." >&2
        echo "[CI][2/3] Définissez KEEP_DOCKER_CONTEXT=1 pour conserver le contexte initial (${original_context})." >&2
      fi
    else
      DOCKER_BUILD_CONTEXT="${context_final}"
    fi
  elif [[ -n "${original_context}" ]]; then
    DOCKER_BUILD_CONTEXT="${original_context}"
  fi

  if [[ "${DOCKER_BUILD_CONTEXT}" == "." && "${DOCKERFILE}" == /* ]]; then
    local relative_from_root="${DOCKERFILE#${repo_root}/}"
    if [[ -n "${relative_from_root}" && -f "${repo_root}/${relative_from_root}" ]]; then
      DOCKERFILE="${relative_from_root}"
    fi
  fi
}

sync_dadou_utils_repository() {
  if [[ -z "${DADOU_UTILS_REPO_URL}" ]]; then
    echo "[CI][1/3] DADOU_UTILS_REPO_URL is empty, skipping shared utilities checkout."
    return
  fi

  local target_path="${TEMP_DIR}/dadou_utils_ros"
  echo "[CI][1/3] Fetching dadou_utils_ros from ${DADOU_UTILS_REPO_URL} (branch ${DADOU_UTILS_REPO_BRANCH})..."

  if [[ -e "${target_path}" || -L "${target_path}" ]]; then
    rm -rf "${target_path}"
  fi

  if ! git clone --depth=1 --branch "${DADOU_UTILS_REPO_BRANCH}" "${DADOU_UTILS_REPO_URL}" "${target_path}"; then
    echo "[CI][1/3] Failed to clone ${DADOU_UTILS_REPO_URL}" >&2
    exit 1
  fi
  echo "[CI][1/3] dadou_utils_ros workspace ready in ${target_path}"
}

####################################################
# Stage 3 – Prepare or refresh the source workspace #
####################################################

prepare_workspace() {
  echo "[CI][1/3] Preparing workspace at ${WORKSPACE_ROOT:-temporary directory}..."
  local workspace_path=""
  if [[ -n "${WORKSPACE_ROOT}" ]]; then
    # Use the provided persistent directory and refresh it if already cloned.
    mkdir -p "${WORKSPACE_ROOT}"
    workspace_path="${WORKSPACE_ROOT}"
  else
    # Otherwise create a brand-new temporary directory for this build.
    workspace_path="$(mktemp -d -t dadou-ci-XXXXXX)"
  fi

  if [[ -n "${workspace_path}" && -e "${workspace_path}" ]]; then
    rm -rf "${workspace_path}"
  fi
  git clone --depth=1 --branch "${REPO_BRANCH}" "${REPO_URL}" "${workspace_path}"
  PRIMARY_WORKSPACE_DIR="${workspace_path}"
  TEMP_DIR="${workspace_path}"
  echo "[CI][1/3] Workspace ready in ${TEMP_DIR}"
  sync_dadou_utils_repository
  stage_local_workspace_if_needed
}

stage_local_workspace_if_needed() {
  if [[ -z "${WORKSPACE_ROOT}" ]]; then
    return
  fi

  local staging_pref="${LOCAL_WORKSPACE_STAGING:-auto}"
  case "${staging_pref,,}" in
    0|false|off|no)
      return
      ;;
  esac

  LOCAL_MIRROR_DIR="$(mktemp -d -t dadou-ci-local-XXXXXX)"
  echo "[CI][1/3] Mirroring workspace to ${LOCAL_MIRROR_DIR} for local Docker build context..."
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete "${PRIMARY_WORKSPACE_DIR}/" "${LOCAL_MIRROR_DIR}/"
  else
    cp -a "${PRIMARY_WORKSPACE_DIR}/." "${LOCAL_MIRROR_DIR}/"
  fi
  TEMP_DIR="${LOCAL_MIRROR_DIR}"
}

# Stage 4 – Build the Docker image output #
###########################################

build_docker() {
  echo "[CI][2/3] Building Docker image ${DOCKER_IMAGE}:${DOCKER_TAG}..."
  pushd "${TEMP_DIR}" >/dev/null
  local dockerfile_path="${DOCKERFILE}"
  if [[ "${dockerfile_path}" != /* ]]; then
    local context_prefix="${DOCKER_BUILD_CONTEXT%/}"
    [[ -z "${context_prefix}" ]] && context_prefix="."
    dockerfile_path="${context_prefix}/${dockerfile_path}"
  fi
  docker_exec build \
    --file "${dockerfile_path}" \
    --tag "${DOCKER_IMAGE}:${DOCKER_TAG}" \
    "${DOCKER_BUILD_CONTEXT}"
  popd >/dev/null
  echo "[CI][2/3] Docker build finished"
}

###########################################################
# Stage 5 – Run integration tests inside the Docker image #
###########################################################

test_docker_image() {
  echo "[CI][3/3] Running tests inside Docker image ${DOCKER_IMAGE}:${DOCKER_TAG}..."
  local default_cmd="pytest -q /home/ros2_ws/src/robot/robot/tests --ignore=/home/ros2_ws/src/robot/robot/tests/sandbox"
  local resolved_cmd="${TEST_COMMAND:-${default_cmd}}"

  docker_exec run --rm \
    --entrypoint robot-tests-entrypoint \
    --env TEST_COMMAND="${resolved_cmd}" \
    "${DOCKER_IMAGE}:${DOCKER_TAG}" \
    bash -lc "${resolved_cmd}"
  echo "[CI][3/3] Dockerized test stage completed successfully"
}

##########################################
# Stage 6 – Orchestrate the full process #
##########################################

main() {
  echo "[CI][0/3] Validating build prerequisites..."
  require_tools           # 1. Sanity-check required binaries.
  ensure_docker_access    # 2. Confirm Docker daemon accessibility (uses sudo fallback when possible).
  echo "[CI][0/3] Prerequisites validated"
  prepare_workspace       # 3. Fetch or update the project sources.
  resolve_docker_build_inputs
  build_docker            # 4. Build the Docker image from the tested sources.
  test_docker_image       # 5. Execute tests inside the built image.
  printf "[CI] Docker image available: %s:%s\n" "${DOCKER_IMAGE}" "${DOCKER_TAG}"
}

main "$@"
