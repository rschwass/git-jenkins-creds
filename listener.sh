while true; do
  echo "Waiting for connection..."

  # Start netcat and read full HTTP request
  REQ=$(nc -l -p 8080)

  # Try to extract and decode Basic Auth header
  if echo "$REQ" | grep -qi "^Authorization: Basic"; then
    AUTH_LINE=$(echo "$REQ" | grep -i "^Authorization: Basic")
    CREDS_BASE64=$(echo "$AUTH_LINE" | cut -d' ' -f3)
    CREDS_DECODED=$(echo "$CREDS_BASE64" | base64 -d 2>/dev/null)

    echo "[+] Got credentials: $CREDS_DECODED"

    # Respond with success
    echo -e "HTTP/1.1 200 OK\r\nContent-Length: 20\r\n\r\nWelcome, $CREDS_DECODED"
  else
    echo "[!] No Authorization header found."

    # Respond with 401
    echo -e "HTTP/1.1 401 Unauthorized\r\nWWW-Authenticate: Basic realm=\"Secure\"\r\nContent-Length: 0\r\n\r\n"
  fi
done | nc -l -p 8080