#!/bin/bash -ex

# Grab configuration from the environment, or use defaults
SAVENAME="${FACTORIO_SAVENAME:-headless}"
LATENCY="${FACTORIO_LATENCY_MS:-50}"
AUTOSAVE_INTERVAL="${FACTORIO_AUTOSAVE_INTERVAL:-5}"
AUTOSAVE_SLOTS="${FACTORIO_AUTOSAVE_SLOTS:-3}"
# If you want to pass any other args to the server command
EXTRA_OPTS="${FACTORIO_EXTRA_OPTS:-}"


SAVEDIR="/opt/factorio/saves"
SAVEPATH="$SAVEDIR/$SAVENAME.zip"

if [ ! -f "$SAVEPATH" ]; then
  /opt/factorio/bin/x64/factorio --create "$SAVENAME"
else
  # Check if there's a more recent autosave (e.g. server crashed)
  LATEST_SAVEFILE="$(ls -t "$SAVEDIR" 2>/dev/null | head -1)"
  if [ -z "$LATEST_SAVEFILE" ]; then
    echo "Couldn't identify latest save game in $SAVEDIR, aborting."
    exit 1
  fi

  # If the more recent save isn't the main save, replace the main save
  if [ "$LATEST_SAVEFILE" == "$SAVENAME.zip" ]; then
    echo "Save is up to date - using $SAVEPATH."
  else
    if echo "$LATEST_SAVEFILE" | grep -qF "_autosave"; then
      echo "Found more recent save $LATEST_SAVEFILE (server crashed?) - transferring to $SAVEPATH."
      cp "$SAVEDIR/$LATEST_SAVEFILE" "$SAVEPATH"
    else
      echo "Found a more recent save $LATEST_SAVEFILE, but it doesn't appear to be an autosave. Ignoring."
    fi
  fi
fi

# Run the server
/opt/factorio/bin/x64/factorio \
  --start-server "$SAVENAME" \
  --latency-ms "$LATENCY" \
  --autosave-interval "$AUTOSAVE_INTERVAL" \
  --autosave-slots "$AUTOSAVE_SLOTS" \
  $EXTRA_OPTS
