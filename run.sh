#!/bin/bash

# Exit on error, undefined var, and fail pipes
set -euo pipefail

# Check that Docker is installed and the daemon is responsive.
# You can skip this check by setting the SKIP_DOCKER_CHECK env var or
# by passing --skip-docker-check (or -s) to this script.
check_docker() {
	if ! command -v docker >/dev/null 2>&1; then
		echo "ERROR: Docker is not installed. Install Docker Desktop or Docker Engine." >&2
		return 1
	fi

	# Print client version (informational)
	docker --version 2>/dev/null || true

	# Verify the daemon responds
	if ! docker info >/dev/null 2>&1; then
		echo "ERROR: Docker is installed but the daemon is not responding. Make sure Docker is running." >&2
		echo "On Windows: open Docker Desktop and wait until it reports 'Docker is running'." >&2
		return 2
	fi

	return 0
}

# Parse simple CLI flags: allow --skip-docker-check or -s to skip the check
for _arg in "$@"; do
	case "${_arg}" in
		--skip-docker-check|-s)
			SKIP_DOCKER_CHECK=1
			;;
	esac
done

# Run verification unless SKIP_DOCKER_CHECK is set
if [ -z "${SKIP_DOCKER_CHECK:-}" ]; then
	check_docker || exit 1
fi

docker build -f Dockerfile_rocm64_base . -t 'rocm6_gfx803_base:6.4'

# docker compose -f docker-compose.yml up -d