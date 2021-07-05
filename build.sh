#!/usr/bin/bash
set -e

export BUILD_DATE="$(date +'%Y-%m-%d')"
export VERSION="0.0.1"

if [[ ! -d ./hermes/ ]]; then
	git clone https://github.com/FanFicDev/hermes.git hermes
fi

cd ./hermes/
if ! ./bin/check_setup.sh; then
	exit $?
fi
cd ..

docker build \
	--build-arg "BUILD_DATE=${BUILD_DATE}" \
	--build-arg "VERSION=${VERSION}" \
	-t fanficdev/alexandria:${VERSION} \
	.

