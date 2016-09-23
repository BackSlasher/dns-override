# DNS Override
Used to override DNS settings for a single process (and its decendants) using the glibc resolv

## How it works
the function reads from the environment variable `DNS_SERVERS` and constructs a modified `/etc/resolv.conf` file, based on the original one but with our new servers.  
By using `LD_PRELOAD` we'll be monkeypatching `fopen` to open our own version of `/etc/resolv.conf` instaed of the real one.  
Since `LD_PRELOAD` is an environment variable, the same will be inherited for all subprocesses.

## Usgae
1. Build dns-override.so if needed
2. determine replacement DNS servers
3. run desired binary `bin` like so: `LD_PRELOAD=$PWD/dns-override.so:$LD_PRELOAD DNS_SERVERS=192.168.0.1,192.168.0.2 bin`  
    Alternatively, one can use the wrapper script: `dns-override.sh --servers 192.168.0.1,192.168.0.2 bin`
