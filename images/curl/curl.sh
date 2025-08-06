#! /usr/bin/env sh
echo $WEBSERVER_HOSTNAME
echo $WEBSERVER_PORT
export DEFAULT_URL="${WEBSERVER_HOSTNAME:-$1}:${WEBSERVER_PORT:-$2}"
if [ ! -z "${WEBSERVER_PORT}" ]; then
    export DEFAULT_URL="${WEBSERVER_HOSTNAME:-$1}:${WEBSERVER_PORT:-$2}/${WEBSERVER_PATH}"
fi
echo $DEFAULT_URL
export URL="${URL:-$DEFAULT_URL}"
echo $URL

while true; do
    echo "Polling $URL at $(date)"
    curl -skL --connect-timeout $TIMEOUT "$URL" --output /dev/null
    echo ""
    sleep "$INTERVAL"
done
