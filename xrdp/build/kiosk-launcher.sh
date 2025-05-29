#!/bin/bash

source /tmp/envfile

if [[ -z "${KIOSK_URL}" ]]; then
  echo "Error: KIOSK_URL environment variable is not set."
  exit 1
fi

# Set DISPLAY for X apps like xbindkeys and firefox
export DISPLAY=:10

# Fontconfig fix: ensure writable cache directory
export FONTCONFIG_PATH=/etc/fonts
export FONTCONFIG_FILE=/etc/fonts/fonts.conf
export XDG_CACHE_HOME="/tmp/.fontcache"
mkdir -p "$XDG_CACHE_HOME"

PROFILE_PATH="/tmp/firefox-profile"
MOZILLA_DIR="/home/${USERNAME}/.mozilla/firefox"

# Create minimal Firefox profile if it doesn't exist
if [[ ! -d "${PROFILE_PATH}" ]]; then
  echo "Creating minimal Firefox profile at ${PROFILE_PATH}..."
  mkdir -p "${PROFILE_PATH}"

  # Create a minimal prefs.js file
  cat <<EOF > "${PROFILE_PATH}/prefs.js"
user_pref("browser.shell.checkDefaultBrowser", false);
EOF

  # Add first-run disabling config
  cat <<EOF > "${PROFILE_PATH}/user.js"
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.startup.homepage_override.mstone", "ignore");
user_pref("startup.homepage_welcome_url", "");
user_pref("startup.homepage_welcome_url.additional", "");
user_pref("browser.aboutwelcome.enabled", false);
user_pref("browser.aboutwelcome.showOnFirstRun", false);
user_pref("browser.aboutwelcome.override.tour", false);
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);
user_pref("browser.newtabpage.activity-stream.feeds.snippets", false);
user_pref("browser.newtabpage.enabled", false);
user_pref("toolkit.telemetry.reportingpolicy.firstRun", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("security.enterprise_roots.enabled", true);
user_pref("browser.ssl_override_behavior", 2);
user_pref("network.stricttransportsecurity.preloadlist", false);
EOF
fi

# Create minimal profiles.ini if not present
if [[ ! -f "${MOZILLA_DIR}/profiles.ini" ]]; then
  echo "Creating minimal profiles.ini at ${MOZILLA_DIR}..."
  mkdir -p "${MOZILLA_DIR}"
  cat <<EOF > "${MOZILLA_DIR}/profiles.ini"
[General]
StartWithLastProfile=1

[Profile0]
Name=default
IsRelative=0
Path=${PROFILE_PATH}
Default=1
EOF

  # Ensure correct permissions
  chown -R kiosk:kiosk "${MOZILLA_DIR}"
fi

# Import custom self-signed cert if it exists
if [[ -f /tmp/cert.pem ]]; then
  echo "Importing self-signed certificate into Firefox profile..."
  certutil -A -n "CustomCert" -t "C,," -i /tmp/cert.pem -d sql:"${PROFILE_PATH}"
else
  echo "No certificate found at /tmp/cert.pem, skipping import."
fi

# Start xbindkeys and save its PID
xbindkeys -v > /tmp/xbindkeys.log 2>&1 &
XBINDS_PID=$!

# Trap signals to clean up xbindkeys properly on exit
trap "echo 'Received shutdown signal'; kill $XBINDS_PID; wait $XBINDS_PID; exit 0" SIGINT SIGTERM

# Wait a moment and check if xbindkeys is still running
sleep 1
if ! kill -0 $XBINDS_PID 2>/dev/null; then
  echo "xbindkeys failed to start or exited early. Check /tmp/xbindkeys.log for details."
  exit 1
fi

# Start kiosk loop
while true; do
  rm -f "${PROFILE_PATH}/.parentlock" "${PROFILE_PATH}/lock"
  /usr/bin/firefox --kiosk --no-remote --profile "${PROFILE_PATH}" "${KIOSK_URL}" || true
  sleep 1
done