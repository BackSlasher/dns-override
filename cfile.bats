#!/usr/bin/env bats

@test "running without environment variable" {
  ERR="$(LD_PRELOAD=./dns-override.so nslookup google.com 2>&1 >/dev/null )"
  [ -n "$ERR" ]
}

@test "modifying server" {
  SERVER='8.8.8.8'
  RES="$(LD_PRELOAD=./dns-override.so RESOLV_CONF="nameserver $SERVER" timeout 1s nslookup google.com | perl -ne 'print $1,$/ if /^Server:\s+(.+)$/')"
  [[ "$RES" == "$SERVER" ]]
}

@test "not modifying server" {
  SERVER='8.8.8.8'
  RES="$(LD_PRELOAD=./dns-override.so timeout 1s nslookup google.com | perl -ne 'print $1,$/ if /^Server:\s+(.+)$/')"
  [[ "$RES" != "$SERVER" ]]
}
