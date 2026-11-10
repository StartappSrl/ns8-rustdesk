#!/bin/bash

#
# Copyright (C) 2026 ns8-rustdesk contributors
# SPDX-License-Identifier: GPL-3.0-or-later
#

# Terminate on error
set -e

# Prepare variables for later use
images=()
# The image will be pushed to GitHub container registry.
# In GitHub Actions REPOBASE is set to ghcr.io/<repository owner>
repobase="${REPOBASE:-ghcr.io/startappsrl}"
# Configure the image name
reponame="rustdesk"
# Node.js 25+ no longer ships Corepack, install it from npm
# renovate: datasource=npm packageName=corepack
corepack_version=0.36.0

# Upstream container images. Pin exact versions: every module release
# must be reproducible. Renovate opens PRs when new versions come out.
rustdesk_server_image="docker.io/rustdesk/rustdesk-server:1.1.16"
rustdesk_api_image="docker.io/lejianwen/rustdesk-api:v2.7"

# Create a new empty container image
container=$(buildah from scratch)

# Reuse existing nodebuilder-rustdesk container, to speed up builds
if ! buildah containers --format "{{.ContainerName}}" | grep -q nodebuilder-rustdesk; then
    echo "Pulling NodeJS runtime..."
    buildah from --name nodebuilder-rustdesk -v "${PWD}:/usr/src:Z" docker.io/library/node:26.13.0-slim
    buildah run nodebuilder-rustdesk sh -c "npm install -g corepack@${corepack_version} && corepack enable"
fi

echo "Build static UI files with node..."
buildah run \
    --workingdir=/usr/src/ui \
    --env="NODE_OPTIONS=--openssl-legacy-provider" \
    nodebuilder-rustdesk \
    sh -c "yarn install && yarn build"

# Add imageroot directory to the container image
buildah add "${container}" imageroot /imageroot
buildah add "${container}" ui/dist /ui
# Labels:
# - traefik@node:routeadm  -> publish the web console through Traefik
# - node:fwadm             -> open the RustDesk ports in the node firewall
# - tcp-ports-demand=1     -> one local port for the web console (TCP_PORT)
# - max-per-node=1         -> RustDesk uses fixed ports: one instance per node
buildah config --entrypoint=/ \
    --label="org.nethserver.authorizations=traefik@node:routeadm node:fwadm" \
    --label="org.nethserver.tcp-ports-demand=1" \
    --label="org.nethserver.max-per-node=1" \
    --label="org.nethserver.rootfull=0" \
    --label="org.nethserver.min-core=3.20.1" \
    --label="org.nethserver.images=${rustdesk_server_image} ${rustdesk_api_image}" \
    "${container}"
# Commit the image
buildah commit "${container}" "${repobase}/${reponame}"

# Append the image URL to the images array
images+=("${repobase}/${reponame}")

#
# Setup CI when pushing to Github.
# Warning! docker::// protocol expects lowercase letters (,,)
if [[ -n "${CI}" ]]; then
    # Set output value for Github Actions
    printf "images=%s\n" "${images[*],,}" >> "${GITHUB_OUTPUT}"
else
    # Just print info for manual push
    printf "Publish the images with:\n\n"
    for image in "${images[@],,}"; do printf "  buildah push %s docker://%s:%s\n" "${image}" "${image}" "${IMAGETAG:-latest}" ; done
    printf "\n"
fi
