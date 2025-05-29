#!/bin/bash

start_xrdp_services() {
    # Preventing xrdp startup failure
    rm -rf /var/run/xrdp-sesman.pid
    rm -rf /var/run/xrdp.pid
    rm -rf /var/run/xrdp/xrdp-sesman.pid
    rm -rf /var/run/xrdp/xrdp.pid

    # Use exec ... to forward SIGNAL to child processes
    xrdp-sesman && exec xrdp -n
}

stop_xrdp_services() {
    xrdp --kill
    xrdp-sesman --kill
    exit 0
}

echo "export KIOSK_URL=\"$KIOSK_URL\"" > /tmp/envfile

echo "========================================"
echo "         XRDP Service Started"
echo "========================================"
echo
echo "You can now connect using any Remote Desktop (RDP) client."
echo "Note: This session supports only a SINGLE user login."
echo
echo "Kiosk will automatically load the following URL:"
echo "  $KIOSK_URL"
echo
echo "Connection Details:"
echo "  Protocol : MS RDP"
echo "  Port     : 3389"
echo
echo "Login Credentials:"
echo "  Username : $USERNAME"
echo "  Password : $PASSWORD"
echo

# Check for custom certificate
CERT_PATH="/tmp/cert.pem"
if [[ -f "$CERT_PATH" ]]; then
  echo "Custom CA certificate detected:"
  echo "  Path: $CERT_PATH"
else
  echo "No custom CA\self signed certificate has been uploaded (this is ok if you aren't using a self signed cert)."
  echo "To provide a custom CA\self signed, mount the certificate to:"
  echo "  $CERT_PATH"
fi

trap "stop_xrdp_services" SIGKILL SIGTERM SIGHUP SIGINT EXIT
start_xrdp_services