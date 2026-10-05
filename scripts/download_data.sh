#!/usr/bin/env bash

set -eu

DATA_DIR="$(dirname "$0")/../data"
BASE_URL="https://pub-e682421888d945d684bcae889b0ec20.r2.dev/data"

mkdir -p "$DATA_DIR"

download_if_missing() {
    filename="$1"
    url="$BASE_URL/$filename"
    destination="$DATA_DIR/$filename"

    if [ -f "$destination" ]; then
        echo "Already exists: $destination"
    else
        echo "Downloading $filename..."
        curl --fail --location --retry 3 --output "$destination" "$url"
    fi
}

download_if_missing "players.csv.gz"
download_if_missing "appearances.csv.gz"
download_if_missing "player_valuations.csv.gz"

echo "Dataset setup complete."
