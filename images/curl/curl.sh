#! /usr/bin/env sh
echo $WEBSERVER_HOSTNAME
echo $WEBSERVER_PORT
export DEFUALT_URL="${WEBSERVER_HOSTNAME:-$1}:${WEBSERVER_PORT:-$2}"
if [ ! -z "${WEBSERVER_PORT}" ]; then
    export DEFUALT_URL="${WEBSERVER_HOSTNAME:-$1}:${WEBSERVER_PORT:-$2}/${WEBSERVER_PATH}"
fi
echo $DEFUALT_URL
export URL="${URL:-$DEFUALT_URL}"
echo $URL

while true; do
    echo "Polling $URL at $(date)"
    curl -skL --connect-timeout $TIMEOUT "$URL" --output /dev/null
    echo ""
    sleep "$INTERVAL"
done
