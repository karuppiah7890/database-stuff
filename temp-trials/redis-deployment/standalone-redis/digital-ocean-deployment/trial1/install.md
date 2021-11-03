
```bash
doctl compute droplet create --image ubuntu-20-04-x64 --size s-1vcpu-1gb --region blr1 redis-server --ssh-keys 32221856 --wait

doctl compute droplet list
```

```bash
ssh -i ~/.ssh/digital_ocean root@142.93.221.126
```

```bash
{
    sudo add-apt-repository ppa:redislabs/redis --yes;
    apt install redis-server --yes;
    systemctl status redis-server;
    redis-cli PING;
    redis-cli MEMORY MALLOC-STATS;
    redis-cli ACL GENPASS;
}
```

```bash
{
    vi /etc/redis/redis.conf;
}
```

- Comment out the `bind` config where it binds to loop back interfaces. It looks like this -    

```
bind 127.0.0.1 -::1
```

- Change `port 6379` to `port 56679`
- Add `requirepass <password>`. Search for `requirepass foobared` which is commented out

```bash
{
    systemctl restart redis-server;
    systemctl status redis-server;
    redis-cli -p 56679 PING;
    echo -e "AUTH add913f939e06dd90128d40c86c5d2522bec26a822bf73eccffd3d3182e34dea\nPING\n" | redis-cli -p 56679;
    export REDISCLI_AUTH="add913f939e06dd90128d40c86c5d2522bec26a822bf73eccffd3d3182e34dea"
    redis-cli -p 56679 PING;
}
```

```bash
doctl compute droplet delete redis-server --force
```
