#!/usr/bin/env bats

@test "modifying server" {
  SERVER='8.8.8.8'
  RES="$(./dns-override.sh -s 8.8.8.8 timeout 1s nslookup google.com | perl -ne 'print $1,$/ if /^Server:\s+(.+)$/')"
  [[ "$RES" == "$SERVER" ]]
}

@test "not modifying server" {
  SERVER='8.8.8.8'
  RES="$(timeout 1s nslookup google.com | perl -ne 'print $1,$/ if /^Server:\s+(.+)$/')"
  [[ "$RES" != "$SERVER" ]]
}

@test "not providing anything" {
  run ./dns-override.sh
  [[ "$status" == 1 ]]
}

@test "providing only servers" {
  run ./dns-override.sh -s 1.2.3.4 -s 5.6.7.8
  [[ "$status" == 1 ]]
}

@test "providing only binary" {
  run ./dns-override.sh binny
  [[ "$status" == 1 ]]
}

@test "providing bad arg" {
  run ./dns-override.sh -s 1.2.3.4 -f -s 5.6.7.8
  [[ "$status" == 1 ]]
}

@test 'validating nameserver' {
  RES=$(./dns-override.sh -s 1.2.3.4 python -c 'print open("/etc/resolv.conf").read()')
  RES=$(echo "$RES" | perl -ne 'print $1,$/ if /^nameserver\s+(.*)$/')
  [[ "$RES" == '1.2.3.4' ]]
}

@test 'validating multiple nameservers' {
  RES=$(./dns-override.sh -s 1.2.3.4 -s 5.6.7.8 python -c 'print open("/etc/resolv.conf").read()')
  RES=$(echo "$RES" | perl -ne 'print $1,$/ if /^nameserver\s+(.*)$/')
  [[ "$RES" == $'1.2.3.4\n5.6.7.8' ]]
}

@test 'validating multiple nameservers 2' {
  RES=$(./dns-override.sh -s 1.2.3.4 -s 5.6.7.8,9.10.11.12 python -c 'print open("/etc/resolv.conf").read()')
  RES=$(echo "$RES" | perl -ne 'print $1,$/ if /^nameserver\s+(.*)$/')
  [[ "$RES" == $'1.2.3.4\n5.6.7.8\n9.10.11.12' ]]
}

@test 'subprocesses' {
  SERVER='8.8.8.8'
  RES="$(./dns-override.sh -s $SERVER bash -c nslookup\ google.com | perl -ne 'print $1,$/ if /^Server:\s+(.+)$/')"
  [[ "$RES" == "$SERVER" ]]
}
