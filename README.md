# DNS Override
Used to override DNS settings for a single process (and its decendants) using the glibc resolv

See my post about it:  
<http://blog.backslasher.net/dns-override.html>

## How it works
The library monkeypatches `fopen` and looks for calls for `/etc/resolv.conf`, and returns a file pointer to a memory stream containing a customized version of `resolv.conf`.  
The new `resolv.conf` is built by the script based on the current `resolv.conf` and passed as the `RESOLV_CONF` environment variable.  
We then use `LD_PRELOAD` to insert our library (and version of `fopen`) before the "real" one.  
It then `exec`s the wanted binary.  
Since both `LD_PRELOAD` and `RESOLV_CONF` are environment variables, they'll pass on to subprocesses too.

## Common Usgae
1. Build `dns-override.so` if needed (`make dns-override.so`)
2. determine replacement DNS servers
3. run desired file like so: `./dns-override.sh -s SERVER BINARY`)  
    Multiple servers can be specified, see script

## Advanced usage
Run `LD_PRELOAD=./dns-override.so:$LD_PRELOAD RESOLV_CONF=<new resolv conf contents> <binary>`.  
Do note that I'm only covering `fopen` which isn't used by all programs. For instance, `python` will be fooled but `perl` will not.

## Testing
`bats`, `perl` and `python` are required.  

1. Run `make test`

## Sourced projects

* `fmemopen` for Mac OS:  
    https://github.com/materialsvirtuallab/pyhull/tree/master/src/fmemopen
    License Apache 2.0
    commit `939954d`

