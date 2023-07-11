#!/bin/bash

set -eu

IMAGE="debian:bookworm-slim"
TARGET="$(dirname "$0" | xargs realpath)"
ALACRITTY_PROJECT_URL="https://github.com/alacritty/alacritty"
#VERSION="v0.12.2"
VERSION=$(wget --quiet "${ALACRITTY_PROJECT_URL}/tags.atom" --output-document=- | awk --assign pattern="${ALACRITTY_PROJECT_URL}/releases/tag/" --field-separator "/" '$0~pattern { print $9; exit }' | sed 's/\(.*\)"/\1/')

while getopts "v:i:h" opt
do
    case "$opt" in
        v)
            VERSION="$OPTARG"
            ;;
        i)
            IMAGE="$OPTARG"
            ;;
        h)
            echo "Usage: $0 [-i image] [-v version]"
            exit 0
            ;;
        *)
            exit 1
            ;;
    esac
done

main() {
    docker run --rm --name alacritty-build-$$ \
                    --volume "$TARGET:/target" \
                    --workdir /target \
                    --env "VERSION=$VERSION" \
                    --user root "$IMAGE" \
                    sh entrypoint.sh
}

main
