#!/bin/bash

# Usage:
# ./dns-override.sh --servers 1.2.3.4,5.6.7.8
# ./dns-soverride.sh 

set -euo pipefail  # Strict bash

readonly SEPARATOR=','
SERVERS=''

show_help() {
  cat >&2 <<EOF
$0: Run a file with modified DNS server list
Usage:
    $0 -s SERVERLIST [-s SERVERLIST] BINARY
    $0 -h (shows help)
SERVERLIST:
    List of servers, separated by $SEPARATOR
    Argument can be repeated
BINARY:
    Executable to run
EOF
exit 1
}

# Parse args
while getopts 's:h' opt; do
  case $opt in
    s) SERVERS="${SERVERS}${SEPARATOR}${OPTARG}" ;;
    h|?|:) show_help ;;
  esac
done

shift $(( $OPTIND  -1 ))

# Remove starting seperator
SERVERS="$(echo "$SERVERS" | sed -e "s/^$SEPARATOR//")"
if [[ ( ! "$SERVERS" ) || ( ! "$@" ) ]]; then
  echo "Missing servers or binary" >&2
  show_help
fi

# generate new resolv.conf
RESOLV_CONF="$(grep -Pv '^\s*nameserver ' /etc/resolv.conf)"
RESOLV_CONF="${RESOLV_CONF}$(echo ; echo "$SERVERS" | tr "$SEPARATOR" "\n" | sed 's/^/nameserver /')"
export RESOLV_CONF

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export LD_PRELOAD=$DIR/dns-override.so:${LD_PRELOAD-}

exec $@
