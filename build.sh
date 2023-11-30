#!/usr/bin/bash
set -e

export BUILD_DATE="$(date +'%Y-%m-%d')"
export VERSION="0.0.1"

function help() {
	cat <<HERE
usage: build.sh [engine|desktop]
  build a dev image of the alexandria api by detecting whether the host is using docker engine or docker desktop
     engine: if passed, forces the build to use the docker engine Dockerfile
    desktop: if passed, forces the build to use the docker desktop Dockerfile
  -h|--help: print this help message
HERE
}

if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
	help
	exit 0
fi

if [[ -n "$2" ]]; then
	help
	exit 1
fi

type=""
if [[ -n "$1" ]]; then
	case "$1" in
		engine) type="engine" ;;
		desktop) type="desktop" ;;
		*)
			help
			echo "unknown docker variant: $1"
			exit 1
			;;
	esac
else
	if docker version | grep -i 'docker desktop' >/dev/null; then
		type="desktop"
	else
		type="engine"
	fi
fi

if [[ ! -d ./hermes/ ]]; then
	git clone https://github.com/FanFicDev/hermes.git hermes
fi

cd ./hermes/
if ! ./bin/check_setup.sh; then
	exit $?
fi
cd ..

function build_engine() {
	echo "building docker engine image"
	export USER_UID="${UID}"
	export USER_GID="$(id -g)"

	echo "using USER_UID=${USER_UID} USER_GID=${USER_GID}"

	docker build \
		--build-arg "BUILD_DATE=${BUILD_DATE}" \
		--build-arg "VERSION=${VERSION}" \
		--build-arg "USER_UID=${USER_UID}" \
		--build-arg "USER_GID=${USER_GID}" \
		-t fanficdev/alexandria:${VERSION} \
		.
}

function build_desktop() {
	echo "building docker desktop image"

	docker build -f desktop.Dockerfile \
		--build-arg "BUILD_DATE=${BUILD_DATE}" \
		--build-arg "VERSION=${VERSION}" \
		-t fanficdev/alexandria:${VERSION} \
		.
}

case "$type" in
	engine) build_engine ;;
	desktop) build_desktop ;;
	*)
		help
		echo "unknown docker variant: $1"
		exit 1
esac

