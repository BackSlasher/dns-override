# DNS Override
Used to override DNS settings for a single process (and its decendants) using the glibc resolv

## How it works
the function reads from the environment variable `DNS_SERVERS` and constructs a modified `/etc/resolv.conf` file, based on the original one but with our new servers.  
By using `LD_PRELOAD` we'll be monkeypatching `fopen` to open our own version of `/etc/resolv.conf` instaed of the real one.  
Since `LD_PRELOAD` is an environment variable, the same will be inherited for all subprocesses.

## Common Usgae
1. Build dns-override.so if needed (`make dns-override.so`)
2. determine replacement DNS servers
3. run desired file like so: `./dns-override.sh -s SERVER BINARY`)  
    Multiple servers can be specified, see script

## Advanced usage
Run `LD_PRELOAD=./dns-override.so:$LD_PRELOAD RESOLV_CONF=<new resolv conf contents> <binary>`.  
Do note that I'm only covering `fopen` which isn't used by all programs. For instance, `python` will be fooled but `perl` will not.

## Testing
`bats` and `perl` are required.  
