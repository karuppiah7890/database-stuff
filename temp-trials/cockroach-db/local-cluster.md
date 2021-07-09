# Local Cluster

https://www.cockroachlabs.com/docs/v21.1/start-a-local-cluster

```bash
$ cockroach start \
--insecure \
--store=node1 \
--listen-addr=localhost:26257 \
--http-addr=localhost:8080 \
--join=localhost:26257,localhost:26258,localhost:26259 \
--background
*
* WARNING: ALL SECURITY CONTROLS HAVE BEEN DISABLED!
*
* This mode is intended for non-production testing only.
*
* In this mode:
* - Your cluster is open to any client that can access localhost.
* - Intruders with access to your machine or network can observe client-server traffic.
* - Intruders can log in without password and read or write any data in the cluster.
* - Intruders can consume all your server\'s resources and cause unavailability.
*
*
* INFO: To start a secure server without mandating TLS for clients,
* consider --accept-sql-without-tls instead. For other options, see:
*
* - https://go.crdb.dev/issue-v/53404/v21.1
* - https://www.cockroachlabs.com/docs/v21.1/secure-a-cluster.html
*
*
* INFO: initial startup completed.
* Node will now attempt to join a running cluster, or wait for `cockroach init`.
* Client connections will be accepted after this completes successfully.
* Check the log file(s) for progress.
*
```

Cool! So, it looks like I have started a background process with the `--background`, that is, a cockroach DB server instance listening at a particular port `26257` using this `--listen-addr=localhost:26257` and then I guess it will join other server instances listening at `26258` and `26259` looking at the `--join=localhost:26257,localhost:26258,localhost:26259`

Oh, it's also mentioned in the web page, and also links to flags docs

https://www.cockroachlabs.com/docs/v21.1/cockroach-start#flags

and yeah, it's insecure `--insecure` and I have to check what's available at port `8080` because of `--http-addr=localhost:8080`

and `--store=node1` mentions where to store stuff it seems - stuff like node's data and logs

Currently I don't know what endpoints are there in the `localhost:8080`, I just see 404 at the root, hmm

```bash
$ curl localhost:8080
404 page not found
```

Anyways, I'll finish off creating a cluster first

```bash
$ cockroach start \
--insecure \
--store=node2 \
--listen-addr=localhost:26258 \
--http-addr=localhost:8081 \
--join=localhost:26257,localhost:26258,localhost:26259 \
--background

*
* WARNING: ALL SECURITY CONTROLS HAVE BEEN DISABLED!
*
* This mode is intended for non-production testing only.
*
* In this mode:
* - Your cluster is open to any client that can access localhost.
* - Intruders with access to your machine or network can observe client-server traffic.
* - Intruders can log in without password and read or write any data in the cluster.
* - Intruders can consume all your server\'s resources and cause unavailability.
*
*
* INFO: To start a secure server without mandating TLS for clients,
* consider --accept-sql-without-tls instead. For other options, see:
*
* - https://go.crdb.dev/issue-v/53404/v21.1
* - https://www.cockroachlabs.com/docs/v21.1/secure-a-cluster.html
*
*
* INFO: initial startup completed.
* Node will now attempt to join a running cluster, or wait for `cockroach init`.
* Client connections will be accepted after this completes successfully.
* Check the log file(s) for progress.
*
```

```bash
$ cockroach start \
--insecure \
--store=node3 \
--listen-addr=localhost:26259 \
--http-addr=localhost:8082 \
--join=localhost:26257,localhost:26258,localhost:26259 \
--background
*
* WARNING: ALL SECURITY CONTROLS HAVE BEEN DISABLED!
*
* This mode is intended for non-production testing only.
*
* In this mode:
* - Your cluster is open to any client that can access localhost.
* - Intruders with access to your machine or network can observe client-server traffic.
* - Intruders can log in without password and read or write any data in the cluster.
* - Intruders can consume all your server\'s resources and cause unavailability.
*
*
* INFO: To start a secure server without mandating TLS for clients,
* consider --accept-sql-without-tls instead. For other options, see:
*
* - https://go.crdb.dev/issue-v/53404/v21.1
* - https://www.cockroachlabs.com/docs/v21.1/secure-a-cluster.html
*
*
* INFO: initial startup completed.
* Node will now attempt to join a running cluster, or wait for `cockroach init`.
* Client connections will be accepted after this completes successfully.
* Check the log file(s) for progress.
*
```

So, 3 instances are running now :)

Next I'm going to do an `init` I guess, which is a one time initialization thing it seems, for the cluster and it
can be done on any node in the cluster it seems by sending the request to that appropriate node

```bash
cockroach init --insecure --host=localhost:26257
```

https://www.cockroachlabs.com/docs/v21.1/cockroach-init has been linked, it has some basic info about the command

Before I do `init`, I was thinking about reflecting on what all I just did and what data / stuff can I see till now

I started off 3 instances of cockroach DB server in the background. I think they are all joined? because of the `--join`, but I'm not sure. Also, I was wondering if there's any data already being stored by the servers even before I do an `init`

I was checking what `node1`, `node2` and `node3` have assuming it's a local directory and it was

```bash
$ ls node1
000002.log			auxiliary			cockroach.listen-addr
CURRENT				cockroach-temp030044566		cockroach.sql-addr
LOCK				cockroach.advertise-addr	logs
MANIFEST-000001			cockroach.advertise-sql-addr	temp-dirs-record.txt
OPTIONS-000003			cockroach.http-addr

$ ls node2
000002.log			auxiliary			cockroach.listen-addr
CURRENT				cockroach-temp499125747		cockroach.sql-addr
LOCK				cockroach.advertise-addr	logs
MANIFEST-000001			cockroach.advertise-sql-addr	temp-dirs-record.txt
OPTIONS-000003			cockroach.http-addr

$ ls node3
000002.log			auxiliary			cockroach.listen-addr
CURRENT				cockroach-temp943422055		cockroach.sql-addr
LOCK				cockroach.advertise-addr	logs
MANIFEST-000001			cockroach.advertise-sql-addr	temp-dirs-record.txt
OPTIONS-000003			cockroach.http-addr
```

Looks like it already has lots of things in the directory. I'm going to take a look at the data stored in one of the nodes to start off with. Maybe I'll start with `node1` for now

```bash
$ cd node1

$ ls -al
total 80
drwxr-x---  16 karuppiahn  staff   512 Jul  9 08:06 .
drwxr-xr-x   9 karuppiahn  staff   288 Jul  9 08:24 ..
-rw-r-----   1 karuppiahn  staff    62 Jul  9 08:06 000002.log
-rw-r-----   1 karuppiahn  staff    16 Jul  9 08:06 CURRENT
-rw-r-----   1 karuppiahn  staff     0 Jul  9 08:06 LOCK
-rw-r-----   1 karuppiahn  staff    44 Jul  9 08:06 MANIFEST-000001
-rw-r-----   1 karuppiahn  staff  2222 Jul  9 08:06 OPTIONS-000003
drwxr-x---   2 karuppiahn  staff    64 Jul  9 08:06 auxiliary
drwxr-xr-x   9 karuppiahn  staff   288 Jul  9 08:06 cockroach-temp030044566
-rw-r-----   1 karuppiahn  staff    15 Jul  9 08:06 cockroach.advertise-addr
-rw-r-----   1 karuppiahn  staff    15 Jul  9 08:06 cockroach.advertise-sql-addr
-rw-r-----   1 karuppiahn  staff    14 Jul  9 08:06 cockroach.http-addr
-rw-r-----   1 karuppiahn  staff    15 Jul  9 08:06 cockroach.listen-addr
-rw-r-----   1 karuppiahn  staff    15 Jul  9 08:06 cockroach.sql-addr
drwxr-x---   8 karuppiahn  staff   256 Jul  9 08:06 logs
-rw-r-----   1 karuppiahn  staff    97 Jul  9 08:06 temp-dirs-record.txt
```

```bash
$ cat CURRENT
MANIFEST-000001
```

```bash
$ cat LOCK
```

```bash
$ cat MANIFEST-000001
??cockroach_comparator?@t
```


```bash
$ cat OPTIONS-000003
[Version]
  pebble_version=0.1

[Options]
  bytes_per_sync=524288
  cache_size=134217728
  cleaner=delete
  compaction_debt_concurrency=1073741824
  comparer=cockroach_comparator
  delete_range_flush_delay=10s
  disable_wal=false
  flush_split_bytes=4194304
  l0_compaction_concurrency=10
  l0_compaction_threshold=2
  l0_stop_writes_threshold=1000
  lbase_max_bytes=67108864
  max_concurrent_compactions=3
  max_manifest_file_size=134217728
  max_open_files=10000
  mem_table_size=67108864
  mem_table_stop_writes_threshold=4
  min_compaction_rate=4194304
  min_deletion_rate=134217728
  min_flush_rate=1048576
  merger=cockroach_merge_operator
  read_compaction_rate=16000
  read_sampling_multiplier=-1
  strict_wal_tail=true
  table_property_collectors=[TimeBoundTblPropCollectorFactory,DeleteRangeTblPropCollectorFactory]
  wal_dir=
  wal_bytes_per_sync=0

[Level "0"]
  block_restart_interval=16
  block_size=32768
  compression=Snappy
  filter_policy=rocksdb.BuiltinBloomFilter
  filter_type=table
  index_block_size=262144
  target_file_size=2097152

[Level "1"]
  block_restart_interval=16
  block_size=32768
  compression=Snappy
  filter_policy=rocksdb.BuiltinBloomFilter
  filter_type=table
  index_block_size=262144
  target_file_size=4194304

[Level "2"]
  block_restart_interval=16
  block_size=32768
  compression=Snappy
  filter_policy=rocksdb.BuiltinBloomFilter
  filter_type=table
  index_block_size=262144
  target_file_size=8388608

[Level "3"]
  block_restart_interval=16
  block_size=32768
  compression=Snappy
  filter_policy=rocksdb.BuiltinBloomFilter
  filter_type=table
  index_block_size=262144
  target_file_size=16777216

[Level "4"]
  block_restart_interval=16
  block_size=32768
  compression=Snappy
  filter_policy=rocksdb.BuiltinBloomFilter
  filter_type=table
  index_block_size=262144
  target_file_size=33554432

[Level "5"]
  block_restart_interval=16
  block_size=32768
  compression=Snappy
  filter_policy=rocksdb.BuiltinBloomFilter
  filter_type=table
  index_block_size=262144
  target_file_size=67108864

[Level "6"]
  block_restart_interval=16
  block_size=32768
  compression=Snappy
  filter_policy=none
  filter_type=table
  index_block_size=262144
  target_file_size=134217728
```

```bash
$ cat 000002.log
?^3scve (2?
```

```bash
$ cat cockroach.advertise-sql-addr
localhost:26257
```

```
$ cat cockroach.advertise-addr
localhost:26257
```

```
$ cat cockroach.http-addr
localhost:8080
```

```bash
$ cat cockroach.sql-addr
127.0.0.1:26257
```

Interesting! Lot of stuff in each one of them! I couldn't understand some gibberish though, like the data in `MANIFEST-000001` or the logs in `000002.log`

I can also see that some of the options I provided in the command line have been stored in files

I also see there's an `OPTIONS-000003` file with lot of options I guess? or something like config? I couldn't understand all the options though, but I can see some familiar names like `WAL` for Write Ahead Logs, which is mentioned in `disable_wal`, `strict_wal_tail`, `wal_dir`, `wal_bytes_per_sync` config

I can also see something called `Level` which I don't get and there are 7 of them, from 0 to 6. I see it mentioning some stuff about `block`s like `block_size` and then something about compression `compression=Snappy` and then a filter policy `filter_policy=rocksdb.BuiltinBloomFilter`, which refers to Rocks DB `rocksdb` - https://rocksdb.org and something about filter type and more. I'll probably have to dig into Cockroach DB internals to understand better I guess. And who knows, they might be using RocksDB internally? and hence the reference? I don't know 🤷 Or maybe it's just to denote something similar to the RocksDB thingy, but internally the implementation is different to do the same thing? I don't know, gotta check

Let's initialize the cluster now I guess? Oh wait, I forgot to check the directories in the `node1` directory. The above were all files

I see three directories - `logs` , `auxiliary`, `cockroach-temp030044566`

I was checking the `logs` directory first

```bash
$ ls logs
cockroach-pebble.karuppiahn-a01.karuppiahn.2021-07-09T02_36_56Z.004195.log
cockroach-pebble.log
cockroach-stderr.karuppiahn-a01.karuppiahn.2021-07-09T02_36_56Z.004195.log
cockroach-stderr.log
cockroach.karuppiahn-a01.karuppiahn.2021-07-09T02_36_56Z.004195.log
cockroach.log
```

I see the mention of the word `pebble` a lot. I noticed `pebble` even in the `OPTIONS-000003` file where I saw a version field which said

```
[Version]
  pebble_version=0.1
```

Hmm, interesting thing. In logs we have `cockroach-pebble.log` and even another file called `cockroach-pebble.karuppiahn-a01.karuppiahn.2021-07-09T02_36_56Z.004195.log`

Actually, looking at the file names, I had a question in my mind - are there any links among these files - symbolic etc and looks like there is

```bash
$ ls -al logs/
total 1048
drwxr-x---   8 karuppiahn  staff     256 Jul  9 08:06 .
drwxr-x---  16 karuppiahn  staff     512 Jul  9 08:06 ..
-rw-r-----   1 karuppiahn  staff    1733 Jul  9 08:06 cockroach-pebble.karuppiahn-a01.karuppiahn.2021-07-09T02_36_56Z.004195.log
lrwxr-x---   1 karuppiahn  staff      74 Jul  9 08:06 cockroach-pebble.log -> cockroach-pebble.karuppiahn-a01.karuppiahn.2021-07-09T02_36_56Z.004195.log
-rw-r-----   1 karuppiahn  staff     999 Jul  9 08:06 cockroach-stderr.karuppiahn-a01.karuppiahn.2021-07-09T02_36_56Z.004195.log
lrwxr-x---   1 karuppiahn  staff      74 Jul  9 08:06 cockroach-stderr.log -> cockroach-stderr.karuppiahn-a01.karuppiahn.2021-07-09T02_36_56Z.004195.log
-rw-r-----   1 karuppiahn  staff  521882 Jul  9 09:06 cockroach.karuppiahn-a01.karuppiahn.2021-07-09T02_36_56Z.004195.log
lrwxr-x---   1 karuppiahn  staff      67 Jul  9 08:06 cockroach.log -> cockroach.karuppiahn-a01.karuppiahn.2021-07-09T02_36_56Z.004195.log
```

So `cockroach-pebble.karuppiahn-a01.karuppiahn.2021-07-09T02_36_56Z.004195.log` is the main log file, `cockroach-pebble.log` is just a nice and fancy pointer / link to that file. Maybe it points to different log files when log rotation happens? I don't know if log rotation happens to create more log files etc when log file becomes too big. Anyways, that's interesting!

Also, I noticed only the `pebble` log file and `stderr` log file. I just noticed the probably important `cockroach.log` file

I was actually wondering how to look at the logs since the process is in the background and was wondering if there was any command but yeah, the `start` command did say `Check the log file(s) for progress.` so I guess it makes sense. I'll still look for commands that can provide this info, more like sugar coat commands that simply read from this file, which looks like the source of truth :)

Before getting into the `cockroach.log`, I had already gotten into the `pebble` one assuming that's the main thing. Let's see

```bash
$ cat logs/cockroach-pebble.log
I210709 02:36:56.398843 29 util/log/file_sync_buffer.go:238 ⋮ [config]   file created at: 2021/07/09 02:36:56
I210709 02:36:56.398872 29 util/log/file_sync_buffer.go:238 ⋮ [config]   running on machine: ‹karuppiahn-a01›
I210709 02:36:56.398908 29 util/log/file_sync_buffer.go:238 ⋮ [config]   binary: CockroachDB CCL v21.1.5 (x86_64-apple-darwin19, built 2021/07/02 04:00:15, go1.15.11)
I210709 02:36:56.398958 29 util/log/file_sync_buffer.go:238 ⋮ [config]   arguments: ‹[cockroach start --insecure --store=node1 --listen-addr=localhost:26257 --http-addr=localhost:8080 --join=localhost:26257,localhost:26258,localhost:26259]›
I210709 02:36:56.398991 29 util/log/file_sync_buffer.go:238 ⋮ [config]   log format (utf8=✓): crdb-v2
I210709 02:36:56.398996 29 util/log/file_sync_buffer.go:238 ⋮ [config]   line format: [IWEF]yymmdd hh:mm:ss.uuuuuu goid [chan@]file:line redactionmark \[tags\] [counter] msg
I210709 02:36:56.398183 29 3@vendor/github.com/cockroachdb/pebble/version_set.go:156 ⋮ [n?,pebble] 1  [JOB 1] MANIFEST created 000001
I210709 02:36:56.418658 29 3@vendor/github.com/cockroachdb/pebble/open.go:305 ⋮ [n?,pebble] 2  [JOB 1] WAL created 000002
I210709 02:36:56.455700 133 3@vendor/github.com/cockroachdb/pebble/table_stats.go:118 ⋮ [n?,pebble] 3  [JOB 2] all initial table stats loaded
I210709 02:36:56.521750 29 3@vendor/github.com/cockroachdb/pebble/version_set.go:156 ⋮ [n?,pebble] 4  [JOB 1] MANIFEST created 000001
I210709 02:36:56.543138 29 3@vendor/github.com/cockroachdb/pebble/open.go:305 ⋮ [n?,pebble] 5  [JOB 1] WAL created 000002
I210709 02:36:56.581824 84 3@vendor/github.com/cockroachdb/pebble/table_stats.go:118 ⋮ [n?,pebble] 6  [JOB 2] all initial table stats loaded
```

It says when the file was created `2021/07/09 02:36:56`. I think it makes sense and resonates with the file name of the actual file `cockroach-pebble.karuppiahn-a01.karuppiahn.2021-07-09T02_36_56Z.004195.log` where the hostname is present partially `karuppiahn-a01` and the username too `karuppiahn`, apart from creation time and timezone which I think is Z / UTC over here

It shows which machine it's running on, what binary, and the arguments used to run the start command - by showing the whole command. There's a mention of the log format and line format, and then there's mention of `MANIFEST` - `MANIFEST created 000001` and about `WAL` - `WAL created 000002`

Okay, so I guess `000002.log` is a WAL log? hmm and I think the above manifest thingy is related to the `MANIFEST-000001` file

And then there's mention of `all initial table stats loaded`

Also, I keep seeing `[n?,pebble]` and also two jobs `[JOB 1]` and `[JOB 2]`. Let's find out what's the whole thing about by checking out the log line format mentioned previously. It says

`line format: [IWEF]yymmdd hh:mm:ss.uuuuuu goid [chan@]file:line redactionmark \[tags\] [counter] msg`

`[IWEF]yymmdd hh:mm:ss.uuuuuu goid [chan@]file:line redactionmark \[tags\] [counter] msg`

Let's look at that with an example log line

`I210709 02:36:56.581824 84 3@vendor/github.com/cockroachdb/pebble/table_stats.go:118 ⋮ [n?,pebble] 6  [JOB 2] all initial table stats loaded`

So, from our example, what field is what?

IWEF=I210709 ?

Oops, no

`[IWEF]` field value = I

It's like, "one of IWEF" I think. Ah. This is like Info, Warning, Error and I don't know what F stands for. So, it's kind of like the log level, hmm

`yymmdd` field value = 210709

So, it's more of a year month date standard format thingy. For year they just use last two characters I guess

`hh:mm:ss.uuuuuu` field value = 02:36:56.581824

Another stanard thingy, hours, minutes, seconds. And I think `u` is to denote the symbol of micro, so, micro seconds? maybe

`goid` field value = 84

Hmm. Not sure what this `goid` is. Golang thingy? Golang threads stuff? Go routines stuff? Not sure

`[chan@]` field value = 3@

I think this an optional thing? I don't know why the `[]`. So, I guess `chan` = 3. Maybe some channel name? In go routines? I don't know. Or channel number? 🤷

`file:line` field value = vendor/github.com/cockroachdb/pebble/table_stats.go:118

Pretty standard thingy to probably show where the log is coming from for people to go and debug etc in case they want to. So, the file name and file path along with line number / row number. No column number I guess :P

`redactionmark` field value = ⋮

Not sure what this is. Simply a mark or what? 🤷

`\[tags\]` field value = [n?,pebble]

Not sure why it has the `\`. Oh. Maybe they were escaping the `[` to show that an actual `[` is present instead of some sort of meaning like "one of the values" kind of meaning similar to `[IWEF]`. So, it's a tag. Not sure what the `n?,pebble` refers to though

`[counter]` field value = 6

Seems like a counter or number. Looking at all the logs, looks like it's an increasing number, from 1.

`msg` field value = [JOB 2] all initial table stats loaded

Interesting that it looks like `[JOB 2]` is part of the `msg`, hmm and other parts are also a message. This is the main log line / information, or like the crux of the log line apart from the metadata we saw previously

Next, looking at stderr logs, it looks similar to pebble logs

```bash
$ cat cockroach-stderr.log
I210709 02:36:56.323015 1 util/log/file_sync_buffer.go:238 ⋮ [config]   file created at: 2021/07/09 02:36:56
I210709 02:36:56.323033 1 util/log/file_sync_buffer.go:238 ⋮ [config]   running on machine: ‹karuppiahn-a01›
I210709 02:36:56.323039 1 util/log/file_sync_buffer.go:238 ⋮ [config]   binary: CockroachDB CCL v21.1.5 (x86_64-apple-darwin19, built 2021/07/02 04:00:15, go1.15.11)
I210709 02:36:56.323044 1 util/log/file_sync_buffer.go:238 ⋮ [config]   arguments: ‹[cockroach start --insecure --store=node1 --listen-addr=localhost:26257 --http-addr=localhost:8080 --join=localhost:26257,localhost:26258,localhost:26259]›
I210709 02:36:56.323054 1 util/log/file_sync_buffer.go:238 ⋮ [config]   log format (utf8=✓): crdb-v2
I210709 02:36:56.323058 1 util/log/file_sync_buffer.go:238 ⋮ [config]   line format: [IWEF]yymmdd hh:mm:ss.uuuuuu goid [chan@]file:line redactionmark \[tags\] [counter] msg
I210709 02:36:56.322726 1 util/log/flags.go:180  [-] 1  stderr capture started
```

Similar stuff, creation time, machine info, binary info, arguments info, log and log line format. Actually, it looks exactly the same, hmm, the whole log file format, hmm. Makes sense. It mentions the same `crdb-v2` log file format, which seems to be correctly consitent across log files

There's just one log for now

`I210709 02:36:56.322726 1 util/log/flags.go:180  [-] 1  stderr capture started`

Next, I was just checking the `cockroach.log` log file and it had too much logs!! It already has 4.525 K lines! :O

It's just continuously logging and there thousands of errors - same errors. I tried to remove the duplicate lines

```bash
$ cat cockroach.log
I210709 02:36:56.323807 1 util/log/file_sync_buffer.go:238 ⋮ [config]   file created at: 2021/07/09 02:36:56
I210709 02:36:56.323816 1 util/log/file_sync_buffer.go:238 ⋮ [config]   running on machine: ‹karuppiahn-a01›
I210709 02:36:56.323821 1 util/log/file_sync_buffer.go:238 ⋮ [config]   binary: CockroachDB CCL v21.1.5 (x86_64-apple-darwin19, built 2021/07/02 04:00:15, go1.15.11)
I210709 02:36:56.323825 1 util/log/file_sync_buffer.go:238 ⋮ [config]   arguments: ‹[cockroach start --insecure --store=node1 --listen-addr=localhost:26257 --http-addr=localhost:8080 --join=localhost:26257,localhost:26258,localhost:26259]›
I210709 02:36:56.323832 1 util/log/file_sync_buffer.go:238 ⋮ [config]   log format (utf8=✓): crdb-v2
I210709 02:36:56.323835 1 util/log/file_sync_buffer.go:238 ⋮ [config]   line format: [IWEF]yymmdd hh:mm:ss.uuuuuu goid [chan@]file:line redactionmark \[tags\] [counter] msg
W210709 02:36:56.323474 1 1@cli/start.go:992 ⋮ [-] 1  ALL SECURITY CONTROLS HAVE BEEN DISABLED!
W210709 02:36:56.323474 1 1@cli/start.go:992 ⋮ [-] 1 +
W210709 02:36:56.323474 1 1@cli/start.go:992 ⋮ [-] 1 +This mode is intended for non-production testing only.
W210709 02:36:56.323474 1 1@cli/start.go:992 ⋮ [-] 1 +
W210709 02:36:56.323474 1 1@cli/start.go:992 ⋮ [-] 1 +In this mode:
W210709 02:36:56.323474 1 1@cli/start.go:992 ⋮ [-] 1 +- Your cluster is open to any client that can access ‹localhost›.
W210709 02:36:56.323474 1 1@cli/start.go:992 ⋮ [-] 1 +- Intruders with access to your machine or network can observe client-server traffic.
W210709 02:36:56.323474 1 1@cli/start.go:992 ⋮ [-] 1 +- Intruders can log in without password and read or write any data in the cluster.
W210709 02:36:56.323474 1 1@cli/start.go:992 ⋮ [-] 1 +- Intruders can consume all your server\'s resources and cause unavailability.
I210709 02:36:56.324046 1 1@cli/start.go:1002 ⋮ [-] 2  To start a secure server without mandating TLS for clients,
I210709 02:36:56.324046 1 1@cli/start.go:1002 ⋮ [-] 2 +consider --accept-sql-without-tls instead. For other options, see:
I210709 02:36:56.324046 1 1@cli/start.go:1002 ⋮ [-] 2 +
I210709 02:36:56.324046 1 1@cli/start.go:1002 ⋮ [-] 2 +- ‹https://go.crdb.dev/issue-v/53404/v21.1›
I210709 02:36:56.324046 1 1@cli/start.go:1002 ⋮ [-] 2 +- https://www.cockroachlabs.com/docs/v21.1/secure-a-cluster.html
W210709 02:36:56.324083 1 1@cli/start.go:958 ⋮ [-] 3  ‹Using the default setting for --cache (128 MiB).›
W210709 02:36:56.324083 1 1@cli/start.go:958 ⋮ [-] 3 +‹  A significantly larger value is usually needed for good performance.›
W210709 02:36:56.324083 1 1@cli/start.go:958 ⋮ [-] 3 +‹  If you have a dedicated server a reasonable setting is --cache=.25 (8.0 GiB).›
I210709 02:36:56.324104 1 1@cli/start.go:1031 ⋮ [-] 4  ‹CockroachDB CCL v21.1.5 (x86_64-apple-darwin19, built 2021/07/02 04:00:15, go1.15.11)›
I210709 02:36:56.324651 1 server/config.go:431 ⋮ [-] 5  system total memory: ‹32 GiB›
I210709 02:36:56.324663 1 server/config.go:433 ⋮ [-] 6  server configuration:
I210709 02:36:56.324663 1 server/config.go:433 ⋮ [-] 6 +‹max offset             500000000›
I210709 02:36:56.324663 1 server/config.go:433 ⋮ [-] 6 +‹cache size             128 MiB›
I210709 02:36:56.324663 1 server/config.go:433 ⋮ [-] 6 +‹SQL memory pool size   8.0 GiB›
I210709 02:36:56.324663 1 server/config.go:433 ⋮ [-] 6 +‹scan interval          10m0s›
I210709 02:36:56.324663 1 server/config.go:433 ⋮ [-] 6 +‹scan min idle time     10ms›
I210709 02:36:56.324663 1 server/config.go:433 ⋮ [-] 6 +‹scan max idle time     1s›
I210709 02:36:56.324663 1 server/config.go:433 ⋮ [-] 6 +‹event log enabled      true›
I210709 02:36:56.324724 1 1@cli/start.go:936 ⋮ [-] 7  using local environment variables: ‹COCKROACH_BACKGROUND_RESTART=1›
I210709 02:36:56.324806 1 1@cli/start.go:943 ⋮ [-] 8  process identity: ‹uid 501 euid 501 gid 20 egid 20›
I210709 02:36:56.333967 1 1@cli/start.go:1111 ⋮ [-] 9  GEOS loaded from directory ‹/usr/local/lib/cockroach›
I210709 02:36:56.333985 1 1@cli/start.go:510 ⋮ [-] 10  starting cockroach node
I210709 02:36:56.455633 29 server/config.go:568 ⋮ [n?] 11  1 storage engine‹› initialized
I210709 02:36:56.455729 29 server/config.go:571 ⋮ [n?] 12  ‹Pebble cache size: 128 MiB›
I210709 02:36:56.455882 29 server/config.go:571 ⋮ [n?] 13  ‹store 0: RocksDB, max size 0 B, max open file limit 10000›
I210709 02:36:56.595766 29 1@server/server.go:913 ⋮ [n?] 14  monitoring forward clock jumps based on server.clock.forward_jump_check_enabled
I210709 02:36:56.617898 29 1@cli/start.go:467 ⋮ [-] 15  initial startup completed.
I210709 02:36:56.617898 29 1@cli/start.go:467 ⋮ [-] 15 +Node will now attempt to join a running cluster, or wait for `cockroach init`.
I210709 02:36:56.617898 29 1@cli/start.go:467 ⋮ [-] 15 +Client connections will be accepted after this completes successfully.
I210709 02:36:56.617898 29 1@cli/start.go:467 ⋮ [-] 15 +Check the log file(s) for progress.
I210709 02:36:56.672917 29 server/init.go:196 ⋮ [n?] 16  no stores initialized
I210709 02:36:56.672964 29 server/init.go:197 ⋮ [n?] 17  awaiting `cockroach init` or join with an already initialized node
W210709 02:36:56.673877 183 server/init.go:374 ⋮ [n?] 19  outgoing join rpc to ‹localhost:26258› unsuccessful: ‹rpc error: code = Unavailable desc = connection error: desc = "transport: Error while dialing dial tcp [::1]:26258: connect: connection refused"›
W210709 02:36:57.675934 183 server/init.go:420 ⋮ [n?] 22  outgoing join rpc to ‹localhost:26258› unsuccessful: ‹rpc error: code = Unavailable desc = connection error: desc = "transport: Error while dialing dial tcp [::1]:26258: connect: connection refused"›
....
W210709 02:53:11.674923 183 server/init.go:420 ⋮ [n?] 1059  outgoing join rpc to ‹localhost:26258› unsuccessful: ‹rpc error: code = Unavailable desc = connection error: desc = "transport: Error while dialing dial tcp [::1]:26258: connect: connection refused"›
W210709 02:53:13.674489 183 server/init.go:420 ⋮ [n?] 1061  outgoing join rpc to ‹localhost:26258› unsuccessful: ‹rpc error: code = Unavailable desc = connection error: desc = "transport: Error while dialing dial tcp [::1]:26258: connect: connection refused"›
W210709 02:53:15.674295 183 server/init.go:420 ⋮ [n?] 1063  outgoing join rpc to ‹localhost:26258› unsuccessful: ‹rpc error: code = Unavailable desc = connection error: desc = "transport: Error while dialing dial tcp [::1]:26258: connect: connection refused"›

W210709 02:36:56.674505 183 server/init.go:374 ⋮ [n?] 21  outgoing join rpc to ‹localhost:26259› unsuccessful: ‹rpc error: code = Unavailable desc = connection error: desc = "transport: Error while dialing dial tcp [::1]:26259: connect: connection refused"›
W210709 02:36:58.676208 183 server/init.go:420 ⋮ [n?] 23  outgoing join rpc to ‹localhost:26259› unsuccessful: ‹rpc error: code = Unavailable desc = connection error: desc = "transport: Error while dialing dial tcp [::1]:26259: connect: connection refused"›
...
W210709 02:54:02.674679 183 server/init.go:420 ⋮ [n?] 1112  outgoing join rpc to ‹localhost:26259› unsuccessful: ‹rpc error: code = Unavailable desc = connection error: desc = "transport: Error while dialing dial tcp [::1]:26259: connect: connection refused"›
W210709 02:54:04.674893 183 server/init.go:420 ⋮ [n?] 1114  outgoing join rpc to ‹localhost:26259› unsuccessful: ‹rpc error: code = Unavailable desc = connection error: desc = "transport: Error while dialing dial tcp [::1]:26259: connect: connection refused"›

W210709 02:36:56.674460 221 vendor/google.golang.org/grpc/internal/channelz/logging.go:73 ⋮ [-] 20  ‹grpc: addrConn.createTransport failed to connect to {localhost:26259  <nil> 0 <nil>}. Err: connection error: desc = "transport: Error while dialing dial tcp [::1]:26259: connect: connection refused". Reconnecting...›
W210709 02:37:26.676046 448 vendor/google.golang.org/grpc/internal/channelz/logging.go:73 ⋮ [-] 52  ‹grpc: addrConn.createTransport failed to connect to {localhost:26259  <nil> 0 <nil>}. Err: connection error: desc = "transport: Error while dialing dial tcp [::1]:26259: connect: connection refused". Reconnecting...›
...
W210709 02:53:20.674680 8119 vendor/google.golang.org/grpc/internal/channelz/logging.go:73 ⋮ [-] 1068  ‹grpc: addrConn.createTransport failed to connect to {localhost:26259  <nil> 0 <nil>}. Err: connection error: desc = "transport: Error while dialing dial tcp [::1]:26259: connect: connection refused". Reconnecting...›
W210709 02:53:50.674884 8487 vendor/google.golang.org/grpc/internal/channelz/logging.go:73 ⋮ [-] 1099  ‹grpc: addrConn.createTransport failed to connect to {localhost:26259  <nil> 0 <nil>}. Err: connection error: desc = "transport: Error while dialing dial tcp [::1]:26259: connect: connection refused". Reconnecting...›

W210709 02:37:26.618211 451 1@cli/start.go:502 ⋮ [-] 51  The server appears to be unable to contact the other nodes in the cluster. Please try:
W210709 02:37:26.618211 451 1@cli/start.go:502 ⋮ [-] 51 +
W210709 02:37:26.618211 451 1@cli/start.go:502 ⋮ [-] 51 +- starting the other nodes, if you haven\'t already;
W210709 02:37:26.618211 451 1@cli/start.go:502 ⋮ [-] 51 +- double-checking that the '--join' and '--listen'/'--advertise' flags are set up correctly;
W210709 02:37:26.618211 451 1@cli/start.go:502 ⋮ [-] 51 +- running the 'cockroach init' command if you are trying to initialize a new cluster.
W210709 02:37:26.618211 451 1@cli/start.go:502 ⋮ [-] 51 +
W210709 02:37:26.618211 451 1@cli/start.go:502 ⋮ [-] 51 +If problems persist, please see ‹https://www.cockroachlabs.com/docs/v21.1/cluster-setup-troubleshooting.html›.

W210709 02:36:56.673801 185 vendor/google.golang.org/grpc/internal/channelz/logging.go:73 ⋮ [-] 18  ‹grpc: addrConn.createTransport failed to connect to {localhost:26258  <nil> 0 <nil>}. Err: connection error: desc = "transport: Error while dialing dial tcp [::1]:26258: connect: connection refused". Reconnecting...›
W210709 02:37:27.676207 382 vendor/google.golang.org/grpc/internal/channelz/logging.go:73 ⋮ [-] 54  ‹grpc: addrConn.createTransport failed to connect to {localhost:26258  <nil> 0 <nil>}. Err: connection error: desc = "transport: Error while dialing dial tcp [::1]:26258: connect: connection refused". Reconnecting...›
...
W210709 02:52:23.674608 7657 vendor/google.golang.org/grpc/internal/channelz/logging.go:73 ⋮ [-] 1008  ‹grpc: addrConn.createTransport failed to connect to {localhost:26258  <nil> 0 <nil>}. Err: connection error: desc = "transport: Error while dialing dial tcp [::1]:26258: connect: connection refused". Reconnecting...›
W210709 02:52:55.674399 7728 vendor/google.golang.org/grpc/internal/channelz/logging.go:73 ⋮ [-] 1042  ‹grpc: addrConn.createTransport failed to connect to {localhost:26258  <nil> 0 <nil>}. Err: connection error: desc = "transport: Error while dialing dial tcp [::1]:26258: connect: connection refused". Reconnecting...›

I210709 02:53:17.674837 183 server/init.go:418 ⋮ [n?] 1065  ‹localhost:26258› is itself waiting for init, will retry
I210709 02:53:19.674776 183 server/init.go:418 ⋮ [n?] 1067  ‹localhost:26258› is itself waiting for init, will retry
...
I210709 04:03:01.024919 183 server/init.go:418 ⋮ [n?] 4485  ‹localhost:26258› is itself waiting for init, will retry
I210709 04:03:03.025288 183 server/init.go:418 ⋮ [n?] 4487  ‹localhost:26258› is itself waiting for init, will retry

I210709 02:54:06.675294 183 server/init.go:418 ⋮ [n?] 1116  ‹localhost:26259› is itself waiting for init, will retry
I210709 02:54:08.675196 183 server/init.go:418 ⋮ [n?] 1118  ‹localhost:26259› is itself waiting for init, will retry
...
I210709 04:03:00.024914 183 server/init.go:418 ⋮ [n?] 4484  ‹localhost:26259› is itself waiting for init, will retry
I210709 04:03:02.024953 183 server/init.go:418 ⋮ [n?] 4486  ‹localhost:26259› is itself waiting for init, will retry
```

That's still like a 100 lines and with some duplicates - 3 duplicates for every error, in the format of 1st appearance, second appearance, and then second last and last appearance. I also reordered it a bit while processing. In reality it was a bit interleaved. I also added two `\` near `'` because it was rendering the bash content in markdown in a wierd way when I marked the code content as `bash` in the triple backtick block. Anyways, I didn't change too much other than that

From the log you can see how it's saying there's a lot of erros with connectivity. Looking at the start of the logs, I can see the same log format, log line format and stuff similar to other logs. I can also see the warnings that we saw while running the `start` command, warnings related to insecure node

And then it warns / talks about the cache, hmm

```bash
‹Using the default setting for --cache (128 MiB).›
W210709 02:36:56.324083 1 1@cli/start.go:958 ⋮ [-] 3 +‹  A significantly larger value is usually needed for good performance.›
W210709 02:36:56.324083 1 1@cli/start.go:958 ⋮ [-] 3 +‹  If you have a dedicated server a reasonable setting is --cache=.25 (8.0 GiB).›
```

It's using 128MB cache, lol. That's too low, hmm. And they recommend `.25` - that is `0.25` which is 1/4 of the system RAM. I have 32GB RAM, so it mentions 8GB will be taken up if the value is `.25`

It then shows my system and server information / configuration

```bash
I210709 02:36:56.324104 1 1@cli/start.go:1031 ⋮ [-] 4  ‹CockroachDB CCL v21.1.5 (x86_64-apple-darwin19, built 2021/07/02 04:00:15, go1.15.11)›
I210709 02:36:56.324651 1 server/config.go:431 ⋮ [-] 5  system total memory: ‹32 GiB›
I210709 02:36:56.324663 1 server/config.go:433 ⋮ [-] 6  server configuration:
I210709 02:36:56.324663 1 server/config.go:433 ⋮ [-] 6 +‹max offset             500000000›
I210709 02:36:56.324663 1 server/config.go:433 ⋮ [-] 6 +‹cache size             128 MiB›
I210709 02:36:56.324663 1 server/config.go:433 ⋮ [-] 6 +‹SQL memory pool size   8.0 GiB›
I210709 02:36:56.324663 1 server/config.go:433 ⋮ [-] 6 +‹scan interval          10m0s›
I210709 02:36:56.324663 1 server/config.go:433 ⋮ [-] 6 +‹scan min idle time     10ms›
I210709 02:36:56.324663 1 server/config.go:433 ⋮ [-] 6 +‹scan max idle time     1s›
I210709 02:36:56.324663 1 server/config.go:433 ⋮ [-] 6 +‹event log enabled      true›
```

And then it shows

```bash
I210709 02:36:56.324724 1 1@cli/start.go:936 ⋮ [-] 7  using local environment variables: ‹COCKROACH_BACKGROUND_RESTART=1›
I210709 02:36:56.324806 1 1@cli/start.go:943 ⋮ [-] 8  process identity: ‹uid 501 euid 501 gid 20 egid 20›
I210709 02:36:56.333967 1 1@cli/start.go:1111 ⋮ [-] 9  GEOS loaded from directory ‹/usr/local/lib/cockroach›
I210709 02:36:56.333985 1 1@cli/start.go:510 ⋮ [-] 10  starting cockroach node
I210709 02:36:56.455633 29 server/config.go:568 ⋮ [n?] 11  1 storage engine‹› initialized
I210709 02:36:56.455729 29 server/config.go:571 ⋮ [n?] 12  ‹Pebble cache size: 128 MiB›
I210709 02:36:56.455882 29 server/config.go:571 ⋮ [n?] 13  ‹store 0: RocksDB, max size 0 B, max open file limit 10000›
I210709 02:36:56.595766 29 1@server/server.go:913 ⋮ [n?] 14  monitoring forward clock jumps based on server.clock.forward_jump_check_enabled
I210709 02:36:56.617898 29 1@cli/start.go:467 ⋮ [-] 15  initial startup completed.
I210709 02:36:56.617898 29 1@cli/start.go:467 ⋮ [-] 15 +Node will now attempt to join a running cluster, or wait for `cockroach init`.
I210709 02:36:56.617898 29 1@cli/start.go:467 ⋮ [-] 15 +Client connections will be accepted after this completes successfully.
I210709 02:36:56.617898 29 1@cli/start.go:467 ⋮ [-] 15 +Check the log file(s) for progress.
I210709 02:36:56.672917 29 server/init.go:196 ⋮ [n?] 16  no stores initialized
I210709 02:36:56.672964 29 server/init.go:197 ⋮ [n?] 17  awaiting `cockroach init` or join with an already initialized node
```

Showing process identity and how it's starting a cockroach node. There's also mention of `pebble` again! It says `Pebble cache size: 128 MiB` hmm. There's also mention of RocksDB ! :D `store 0: RocksDB, max size 0 B, max open file limit 10000`

It says `store 0`. Hmm

and then says `initial startup completed` and shows some information which we already saw while running `start` command

I think the errors are because the `init` has not been run. I can see a log mentioning

```
awaiting `cockroach init` or join with an already initialized node
```

So, until I do init, it will try to reach other nodes but it will fail? As init has not been run on the other nodes too? Hmm

I'm planning to tail the node 1 logs and then see what happens when I do `init`

I ran `init`

```bash
$ cockroach init --insecure --host=localhost:26257
Cluster successfully initialized
```

and I was tailing the logs of node 1 and I saw a hell a lot of logs once I did `init`

```bash
$ tail -f cockroach.log
I210709 04:25:04.006157 183 server/init.go:418 ⋮ [n?] 5808  ‹localhost:26259› is itself waiting for init, will retry
I210709 04:25:05.006149 183 server/init.go:418 ⋮ [n?] 5809  ‹localhost:26258› is itself waiting for init, will retry
I210709 04:25:06.006252 183 server/init.go:418 ⋮ [n?] 5810  ‹localhost:26259› is itself waiting for init, will retry
I210709 04:25:07.006245 183 server/init.go:418 ⋮ [n?] 5811  ‹localhost:26258› is itself waiting for init, will retry
I210709 04:25:08.006142 183 server/init.go:418 ⋮ [n?] 5812  ‹localhost:26259› is itself waiting for init, will retry
I210709 04:25:09.006109 183 server/init.go:418 ⋮ [n?] 5813  ‹localhost:26258› is itself waiting for init, will retry
I210709 04:25:09.810319 29 server/init.go:261 ⋮ [n?] 5814  cluster ‹fed66a44-872b-4ca2-ab75-c7821390fcec› has been created
I210709 04:25:09.810371 29 server/init.go:262 ⋮ [n?] 5815  allocated node ID: n1 (for self)
I210709 04:25:09.810384 29 server/init.go:263 ⋮ [n?] 5816  active cluster version: 21.1
W210709 04:25:09.828727 29 2@gossip/gossip.go:1491 ⋮ [n?] 5818  no incoming or outgoing connections
I210709 04:25:09.828704 83832 1@server/server.go:1552 ⋮ [n?] 5817  connecting to gossip network to verify cluster ID ‹"fed66a44-872b-4ca2-ab75-c7821390fcec"›
I210709 04:25:09.828769 29 gossip/gossip.go:402 ⋮ [n1] 5819  NodeDescriptor set to ‹node_id:1 address:<network_field:"tcp" address_field:"localhost:26257" > attrs:<> locality:<> ServerVersion:<major_val:21 minor_val:1 patch:0 internal:0 > build_tag:"v21.1.5" started_at:1625804709828761000 cluster_name:"" sql_address:<network_field:"tcp" address_field:"localhost:26257" >›
I210709 04:25:09.829285 83761 kv/kvserver/closedts/provider/provider.go:135 ⋮ [ct-closer] 5820  disabling legacy closed-timestamp mechanism; the new one is enabled
I210709 04:25:09.830420 83760 gossip/client.go:124 ⋮ [n1] 5821  started gossip client to ‹localhost:26258›
I210709 04:25:09.831237 83760 gossip/client.go:131 ⋮ [n1] 5822  closing client to ‹localhost:26258›: ‹rpc error: code = Unknown desc = gossip connection refused from different cluster fed66a44-872b-4ca2-ab75-c7821390fcec›
I210709 04:25:09.833312 29 server/node.go:388 ⋮ [n1] 5823  initialized store s1
I210709 04:25:09.833350 29 kv/kvserver/stores.go:250 ⋮ [n1] 5824  read 0 node addresses from persistent storage
I210709 04:25:09.833374 83832 1@server/server.go:1555 ⋮ [n1] 5825  node connected via gossip
W210709 04:25:09.833547 83961 kv/kvserver/store.go:1690 ⋮ [n1,s1,r6/1:‹/Table/{SystemCon…-11}›] 5826  could not gossip system config: ‹[NotLeaseHolderError] lease acquisition attempt lost to another lease; r6: replica (n1,s1):1 not lease holder; lease holder unknown›
W210709 04:25:09.833547 83961 kv/kvserver/store.go:1690 ⋮ [n1,s1,r6/1:‹/Table/{SystemCon…-11}›] 5826 +(1) ‹[NotLeaseHolderError] lease acquisition attempt lost to another lease; r6: replica (n1,s1):1 not lease holder; lease holder unknown›
W210709 04:25:09.833547 83961 kv/kvserver/store.go:1690 ⋮ [n1,s1,r6/1:‹/Table/{SystemCon…-11}›] 5826 +Error types: (1) *roachpb.NotLeaseHolderError
I210709 04:25:09.852141 29 server/node.go:465 ⋮ [n1] 5827  started with engine type ‹2›
I210709 04:25:09.852187 29 server/node.go:467 ⋮ [n1] 5828  started with attributes ‹[]›
I210709 04:25:09.852472 29 server/goroutinedumper/goroutinedumper.go:120 ⋮ [n1] 5829  writing goroutine dumps to ‹/Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff/node1/logs/goroutine_dump›
I210709 04:25:09.870261 29 server/heapprofiler/heapprofiler.go:49 ⋮ [n1] 5830  writing go heap profiles to ‹/Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff/node1/logs/heap_profiler› at least every 1h0m0s
I210709 04:25:09.870312 29 server/heapprofiler/cgoprofiler.go:53 ⋮ [n1] 5831  to enable jmalloc profiling: "export MALLOC_CONF=prof:true" or "ln -s prof:true /etc/malloc.conf"
I210709 04:25:09.870332 29 server/heapprofiler/statsprofiler.go:54 ⋮ [n1] 5832  writing memory stats to ‹/Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff/node1/logs/heap_profiler› at last every 1h0m0s
I210709 04:25:09.870357 29 1@server/server.go:1682 ⋮ [n1] 5833  starting http server at ‹127.0.0.1:8080› (use: ‹localhost:8080›)
I210709 04:25:09.870382 29 1@server/server.go:1689 ⋮ [n1] 5834  starting grpc/postgres server at ‹127.0.0.1:26257›
I210709 04:25:09.870400 29 1@server/server.go:1690 ⋮ [n1] 5835  advertising CockroachDB node at ‹localhost:26257›
W210709 04:25:09.877502 83961 kv/kvserver/store.go:1690 ⋮ [n1,s1,r6/1:‹/Table/{SystemCon…-11}›] 5836  could not gossip system config: ‹[NotLeaseHolderError] lease acquisition attempt lost to another lease; r6: replica (n1,s1):1 not lease holder; lease holder unknown›
W210709 04:25:09.877502 83961 kv/kvserver/store.go:1690 ⋮ [n1,s1,r6/1:‹/Table/{SystemCon…-11}›] 5836 +(1) ‹[NotLeaseHolderError] lease acquisition attempt lost to another lease; r6: replica (n1,s1):1 not lease holder; lease holder unknown›
W210709 04:25:09.877502 83961 kv/kvserver/store.go:1690 ⋮ [n1,s1,r6/1:‹/Table/{SystemCon…-11}›] 5836 +Error types: (1) *roachpb.NotLeaseHolderError
W210709 04:25:09.964952 83961 kv/kvserver/store.go:1690 ⋮ [n1,s1,r6/1:‹/Table/{SystemCon…-11}›] 5837  could not gossip system config: ‹[NotLeaseHolderError] lease acquisition attempt lost to another lease; r6: replica (n1,s1):1 not lease holder; lease holder unknown›
W210709 04:25:09.964952 83961 kv/kvserver/store.go:1690 ⋮ [n1,s1,r6/1:‹/Table/{SystemCon…-11}›] 5837 +(1) ‹[NotLeaseHolderError] lease acquisition attempt lost to another lease; r6: replica (n1,s1):1 not lease holder; lease holder unknown›
W210709 04:25:09.964952 83961 kv/kvserver/store.go:1690 ⋮ [n1,s1,r6/1:‹/Table/{SystemCon…-11}›] 5837 +Error types: (1) *roachpb.NotLeaseHolderError
I210709 04:25:10.033546 29 1@util/log/event_log.go:32 ⋮ [n1] 5838 ={"Timestamp":1625804710033544000,"EventType":"node_join","NodeID":1,"StartedAt":1625804709828761000,"LastUp":1625804709828761000}
I210709 04:25:10.033641 29 sql/sqlliveness/slinstance/slinstance.go:252 ⋮ [n1] 5839  starting SQL liveness instance
I210709 04:25:10.033683 84020 sql/temporary_schema.go:492 ⋮ [n1] 5840  running temporary object cleanup background job
I210709 04:25:10.107688 84020 sql/temporary_schema.go:527 ⋮ [n1] 5841  found 0 temporary schemas
I210709 04:25:10.107734 84020 sql/temporary_schema.go:530 ⋮ [n1] 5842  early exiting temporary schema cleaner as no temporary schemas were found
I210709 04:25:10.107755 84020 sql/temporary_schema.go:531 ⋮ [n1] 5843  completed temporary object cleanup job
I210709 04:25:10.107773 84020 sql/temporary_schema.go:610 ⋮ [n1] 5844  temporary object cleaner next scheduled to run at 2021-07-09 04:55:10.03366 +0000 UTC
I210709 04:25:10.107801 62431 kv/kvserver/replica_rangefeed.go:619 ⋮ [n1,rangefeed=‹lease›,s1,r6/1:‹/Table/{SystemCon…-11}›] 5845  RangeFeed closed timestamp is empty
I210709 04:25:10.275359 84186 kv/kvserver/liveness/liveness.go:567 ⋮ [n1] 5846  created liveness record for n2
I210709 04:25:10.275399 84186 server/node.go:1265 ⋮ [n1] 5847  allocated IDs: n2, s2
I210709 04:25:10.293680 84031 sql/sqlliveness/slstorage/slstorage.go:352 ⋮ [n1] 5848  inserted sqlliveness session ‹7b8d5b7456fd4a10b3f0f75c04b8fb19›
I210709 04:25:10.293705 84031 sql/sqlliveness/slinstance/slinstance.go:144 ⋮ [n1] 5849  created new SQL liveness session ‹7b8d5b7456fd4a10b3f0f75c04b8fb19›
I210709 04:25:10.365240 84176 util/log/event_log.go:32 ⋮ [n1,intExec=‹optInToDiagnosticsStatReporting›] 5850 ={"Timestamp":1625804710127608000,"EventType":"set_cluster_setting","Statement":"‹SET CLUSTER SETTING \"diagnostics.reporting.enabled\" = true›","Tag":"SET CLUSTER SETTING","User":"root","ApplicationName":"$ internal-optInToDiagnosticsStatReporting","SettingName":"diagnostics.reporting.enabled","Value":"‹true›"}
I210709 04:25:10.424104 135 kv/kvserver/stores.go:269 ⋮ [n1] 5851  wrote 1 node addresses to persistent storage
I210709 04:25:10.463981 77288 migration/migrationmanager/manager.go:102 ⋮ [n1,intExec=‹set-setting›,migration-mgr] 5852  no need to migrate, cluster already at newest version
I210709 04:25:10.687356 83985 kv/kvserver/liveness/liveness.go:567 ⋮ [n1] 5853  created liveness record for n3
I210709 04:25:10.687393 83985 server/node.go:1265 ⋮ [n1] 5854  allocated IDs: n3, s3
I210709 04:25:10.706225 77288 util/log/event_log.go:32 ⋮ [n1,intExec=‹set-setting›] 5855 ={"Timestamp":1625804710462350000,"EventType":"set_cluster_setting","Statement":"‹SET CLUSTER SETTING version = $1›","Tag":"SET CLUSTER SETTING","User":"root","ApplicationName":"$ internal-set-setting","PlaceholderValues":["‹'21.1'›"],"SettingName":"version","Value":"‹21.1›"}
I210709 04:25:10.836142 135 kv/kvserver/stores.go:269 ⋮ [n1] 5856  wrote 2 node addresses to persistent storage
I210709 04:25:10.837491 84533 gossip/client.go:124 ⋮ [n1] 5857  started gossip client to ‹localhost:26259›
I210709 04:25:10.968682 84054 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r31/1:‹/Table/3{5-6}›] 5858  change replicas (add ‹[(n2,s2):2LEARNER]› remove ‹[]›): existing descriptor r31:‹/Table/3{5-6}› [(n1,s1):1, next=2, gen=0]
I210709 04:25:11.103448 84054 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r31/1:‹/Table/3{5-6}›] 5859  proposing SIMPLE(l2) ‹[(n2,s2):2LEARNER]›: after=‹[(n1,s1):1 (n2,s2):2LEARNER]› next=3
I210709 04:25:11.180442 84054 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r31/1:‹/Table/3{5-6}›] 5860  streamed INITIAL snapshot ‹3af69994› at applied index 17 to (n2,s2):2LEARNER in 0.00s @ ‹7.4 MiB›/s: ‹kv pairs: 8, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.02s
I210709 04:25:11.180552 84618 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r31/1:‹/Table/3{5-6}›] 5861  skipping snapshot; replica is likely a LEARNER in the process of being added: (n2,s2):2LEARNER
I210709 04:25:11.373562 83835 1@gossip/gossip.go:1505 ⋮ [n1] 5862  node has connected to cluster via gossip
I210709 04:25:11.407091 83835 kv/kvserver/stores.go:269 ⋮ [n1] 5863  wrote 2 node addresses to persistent storage
I210709 04:25:11.646372 84624 util/log/event_log.go:32 ⋮ [n1,intExec=‹initializeClusterSecret›] 5864 ={"Timestamp":1625804711473330000,"EventType":"set_cluster_setting","Statement":"‹SET CLUSTER SETTING \"cluster.secret\" = gen_random_uuid()::STRING›","Tag":"SET CLUSTER SETTING","User":"root","ApplicationName":"$ internal-initializeClusterSecret","SettingName":"cluster.secret","Value":"‹1a16bc91-f0fe-47b7-8e10-cb504bf02736›"}
I210709 04:25:11.838571 84054 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r31/1:‹/Table/3{5-6}›] 5865  change replicas (add ‹[(n2,s2):2]› remove ‹[]›): existing descriptor r31:‹/Table/3{5-6}› [(n1,s1):1, (n2,s2):2LEARNER, next=3, gen=1]
I210709 04:25:11.899859 84054 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r31/1:‹/Table/3{5-6}›] 5866  proposing SIMPLE(v2) ‹[(n2,s2):2]›: after=‹[(n1,s1):1 (n2,s2):2]› next=3
I210709 04:25:11.955500 84891 5@util/log/event_log.go:32 ⋮ [n1,intExec=‹create-default-DB›] 5867 ={"Timestamp":1625804711745752000,"EventType":"create_database","Statement":"‹CREATE DATABASE IF NOT EXISTS defaultdb›","Tag":"CREATE DATABASE","User":"root","DescriptorID":50,"ApplicationName":"$ internal-create-default-DB","DatabaseName":"‹defaultdb›"}
I210709 04:25:11.955628 84054 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r31/1:‹/Table/3{5-6}›] 5868  change replicas (add ‹[(n3,s3):3LEARNER]› remove ‹[]›): existing descriptor r31:‹/Table/3{5-6}› [(n1,s1):1, (n2,s2):2, next=3, gen=2]
I210709 04:25:12.067524 84054 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r31/1:‹/Table/3{5-6}›] 5869  proposing SIMPLE(l3) ‹[(n3,s3):3LEARNER]›: after=‹[(n1,s1):1 (n2,s2):2 (n3,s3):3LEARNER]› next=4
I210709 04:25:12.200484 84958 5@util/log/event_log.go:32 ⋮ [n1,intExec=‹create-default-DB›] 5870 ={"Timestamp":1625804711955798000,"EventType":"create_database","Statement":"‹CREATE DATABASE IF NOT EXISTS postgres›","Tag":"CREATE DATABASE","User":"root","DescriptorID":51,"ApplicationName":"$ internal-create-default-DB","DatabaseName":"‹postgres›"}
I210709 04:25:12.219304 84054 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r31/1:‹/Table/3{5-6}›] 5871  streamed INITIAL snapshot ‹bb41045b› at applied index 23 to (n3,s3):3LEARNER in 0.00s @ ‹24 MiB›/s: ‹kv pairs: 12, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.06s
I210709 04:25:12.257276 84704 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r31/1:‹/Table/3{5-6}›] 5872  skipping snapshot; replica is likely a LEARNER in the process of being added: (n3,s3):3LEARNER
I210709 04:25:12.818812 84054 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r31/1:‹/Table/3{5-6}›] 5873  change replicas (add ‹[(n3,s3):3]› remove ‹[]›): existing descriptor r31:‹/Table/3{5-6}› [(n1,s1):1, (n2,s2):2, (n3,s3):3LEARNER, next=4, gen=3]
I210709 04:25:12.875708 84054 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r31/1:‹/Table/3{5-6}›] 5874  proposing SIMPLE(v3) ‹[(n3,s3):3]›: after=‹[(n1,s1):1 (n2,s2):2 (n3,s3):3]› next=4
I210709 04:25:13.062372 84054 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r8/1:‹/Table/1{2-3}›] 5875  change replicas (add ‹[(n2,s2):2LEARNER]› remove ‹[]›): existing descriptor r8:‹/Table/1{2-3}› [(n1,s1):1, next=2, gen=0]
I210709 04:25:13.099199 29 server/server_sql.go:848 ⋮ [n1] 5876  done ensuring all necessary startup migrations have run
I210709 04:25:13.099317 29 1@server/server.go:2083 ⋮ [n1] 5877  serving sql connections
I210709 04:25:13.099303 84752 jobs/job_scheduler.go:360 ⋮ [n1] 5878  waiting 3m0s before scheduled jobs daemon start
I210709 04:25:13.099415 29 1@cli/start.go:676 ⋮ [config] 5879  clusterID: ‹fed66a44-872b-4ca2-ab75-c7821390fcec›
I210709 04:25:13.099430 29 1@cli/start.go:676 ⋮ [config] 5880  nodeID: n1
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881  node startup completed:
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +CockroachDB node starting at 2021-07-09 04:25:13.099347 +0000 UTC (took 6496.8s)
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +build:               CCL v21.1.5 @ 2021/07/02 04:00:15 (go1.15.11)
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +webui:               ‹http://localhost:8080›
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +sql:                 ‹postgresql://root@localhost:26257?sslmode=disable›
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +RPC client flags:    ‹cockroach <client cmd> --host=localhost:26257 --insecure›
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +logs:                ‹/Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff/node1/logs›
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +temp dir:            ‹/Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff/node1/cockroach-temp030044566›
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +external I/O path:   ‹/Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff/node1/extern›
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +store[0]:            ‹path=/Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff/node1›
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +storage engine:      pebble
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +status:              initialized new cluster
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +clusterID:           ‹fed66a44-872b-4ca2-ab75-c7821390fcec›
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +nodeID:              1
I210709 04:25:13.104992 85362 server/auto_upgrade.go:55 ⋮ [n1] 5882  no need to upgrade, cluster already at the newest version
I210709 04:25:13.137633 84054 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r8/1:‹/Table/1{2-3}›] 5883  proposing SIMPLE(l2) ‹[(n2,s2):2LEARNER]›: after=‹[(n1,s1):1 (n2,s2):2LEARNER]› next=3
I210709 04:25:13.380663 85401 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r8/1:‹/Table/1{2-3}›] 5884  skipping snapshot; replica is likely a LEARNER in the process of being added: (n2,s2):2LEARNER
I210709 04:25:13.380658 84054 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r8/1:‹/Table/1{2-3}›] 5885  streamed INITIAL snapshot ‹8eced069› at applied index 44 to (n2,s2):2LEARNER in 0.00s @ ‹42 MiB›/s: ‹kv pairs: 48, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.07s
I210709 04:25:13.584536 85355 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r8/1:‹/Table/1{2-3}›] 5886  skipping snapshot; replica is likely a LEARNER in the process of being added: (n2,s2):2LEARNER
I210709 04:25:14.047801 84054 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r8/1:‹/Table/1{2-3}›] 5887  change replicas (add ‹[(n2,s2):2]› remove ‹[]›): existing descriptor r8:‹/Table/1{2-3}› [(n1,s1):1, (n2,s2):2LEARNER, next=3, gen=1]
I210709 04:25:14.158902 84054 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r8/1:‹/Table/1{2-3}›] 5888  proposing SIMPLE(v2) ‹[(n2,s2):2]›: after=‹[(n1,s1):1 (n2,s2):2]› next=3
I210709 04:25:14.233813 84054 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r8/1:‹/Table/1{2-3}›] 5889  change replicas (add ‹[(n3,s3):3LEARNER]› remove ‹[]›): existing descriptor r8:‹/Table/1{2-3}› [(n1,s1):1, (n2,s2):2, next=3, gen=2]
I210709 04:25:14.374338 84054 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r8/1:‹/Table/1{2-3}›] 5890  proposing SIMPLE(l3) ‹[(n3,s3):3LEARNER]›: after=‹[(n1,s1):1 (n2,s2):2 (n3,s3):3LEARNER]› next=4
I210709 04:25:14.500328 84054 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r8/1:‹/Table/1{2-3}›] 5891  streamed INITIAL snapshot ‹5246f222› at applied index 48 to (n3,s3):3LEARNER in 0.00s @ ‹40 MiB›/s: ‹kv pairs: 52, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.08s
I210709 04:25:14.519276 85376 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r8/1:‹/Table/1{2-3}›] 5892  skipping snapshot; replica is likely a LEARNER in the process of being added: (n3,s3):3LEARNER
I210709 04:25:14.599512 85577 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r8/1:‹/Table/1{2-3}›] 5893  skipping snapshot; replica is likely a LEARNER in the process of being added: (n3,s3):3LEARNER
I210709 04:25:15.083760 84054 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r8/1:‹/Table/1{2-3}›] 5894  change replicas (add ‹[(n3,s3):3]› remove ‹[]›): existing descriptor r8:‹/Table/1{2-3}› [(n1,s1):1, (n2,s2):2, (n3,s3):3LEARNER, next=4, gen=3]
I210709 04:25:15.160464 84054 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r8/1:‹/Table/1{2-3}›] 5895  proposing SIMPLE(v3) ‹[(n3,s3):3]›: after=‹[(n1,s1):1 (n2,s2):2 (n3,s3):3]› next=4
I210709 04:25:15.314157 84054 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r35/1:‹/Table/{39-40}›] 5896  change replicas (add ‹[(n3,s3):2LEARNER]› remove ‹[]›): existing descriptor r35:‹/Table/{39-40}› [(n1,s1):1, next=2, gen=0]
I210709 04:25:15.529456 84054 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r35/1:‹/Table/{39-40}›] 5897  proposing SIMPLE(l2) ‹[(n3,s3):2LEARNER]›: after=‹[(n1,s1):1 (n3,s3):2LEARNER]› next=3
I210709 04:25:15.813024 85744 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r35/1:‹/Table/{39-40}›] 5898  skipping snapshot; replica is likely a LEARNER in the process of being added: (n3,s3):2LEARNER
I210709 04:25:15.813444 84054 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r35/1:‹/Table/{39-40}›] 5899  streamed INITIAL snapshot ‹c1024c9a› at applied index 35 to (n3,s3):2LEARNER in 0.00s @ ‹27 MiB›/s: ‹kv pairs: 15, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.00s
I210709 04:25:16.247314 84054 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r35/1:‹/Table/{39-40}›] 5900  change replicas (add ‹[(n3,s3):2]› remove ‹[]›): existing descriptor r35:‹/Table/{39-40}› [(n1,s1):1, (n3,s3):2LEARNER, next=3, gen=1]
I210709 04:25:16.343952 84054 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r35/1:‹/Table/{39-40}›] 5901  proposing SIMPLE(v2) ‹[(n3,s3):2]›: after=‹[(n1,s1):1 (n3,s3):2]› next=3
I210709 04:25:16.434632 84054 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r35/1:‹/Table/{39-40}›] 5902  change replicas (add ‹[(n2,s2):3LEARNER]› remove ‹[]›): existing descriptor r35:‹/Table/{39-40}› [(n1,s1):1, (n3,s3):2, next=3, gen=2]
I210709 04:25:16.712477 84054 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r35/1:‹/Table/{39-40}›] 5903  proposing SIMPLE(l3) ‹[(n2,s2):3LEARNER]›: after=‹[(n1,s1):1 (n3,s3):2 (n2,s2):3LEARNER]› next=4
I210709 04:25:16.826142 85893 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r35/1:‹/Table/{39-40}›] 5904  skipping snapshot; replica is likely a LEARNER in the process of being added: (n2,s2):3LEARNER
I210709 04:25:16.826159 84054 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r35/1:‹/Table/{39-40}›] 5905  streamed INITIAL snapshot ‹f45aa5b6› at applied index 43 to (n2,s2):3LEARNER in 0.00s @ ‹21 MiB›/s: ‹kv pairs: 18, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.04s
I210709 04:25:17.182751 84054 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r35/1:‹/Table/{39-40}›] 5906  change replicas (add ‹[(n2,s2):3]› remove ‹[]›): existing descriptor r35:‹/Table/{39-40}› [(n1,s1):1, (n3,s3):2, (n2,s2):3LEARNER, next=4, gen=3]
I210709 04:25:17.258366 84054 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r35/1:‹/Table/{39-40}›] 5907  proposing SIMPLE(v3) ‹[(n2,s2):3]›: after=‹[(n1,s1):1 (n3,s3):2 (n2,s2):3]› next=4
I210709 04:25:17.402944 84054 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r27/1:‹/{NamespaceTab…-Table/32}›] 5908  change replicas (add ‹[(n3,s3):2LEARNER]› remove ‹[]›): existing descriptor r27:‹/{NamespaceTable/Max-Table/32}› [(n1,s1):1, next=2, gen=0]
I210709 04:25:17.554389 84054 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r27/1:‹/{NamespaceTab…-Table/32}›] 5909  proposing SIMPLE(l2) ‹[(n3,s3):2LEARNER]›: after=‹[(n1,s1):1 (n3,s3):2LEARNER]› next=3
I210709 04:25:17.707121 84054 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r27/1:‹/{NamespaceTab…-Table/32}›] 5910  streamed INITIAL snapshot ‹ed66cb8c› at applied index 16 to (n3,s3):2LEARNER in 0.00s @ ‹11 MiB›/s: ‹kv pairs: 8, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.06s
I210709 04:25:17.707156 86036 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r27/1:‹/{NamespaceTab…-Table/32}›] 5911  skipping snapshot; replica is likely a LEARNER in the process of being added: (n3,s3):2LEARNER
I210709 04:25:18.241367 84054 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r27/1:‹/{NamespaceTab…-Table/32}›] 5912  change replicas (add ‹[(n3,s3):2]› remove ‹[]›): existing descriptor r27:‹/{NamespaceTable/Max-Table/32}› [(n1,s1):1, (n3,s3):2LEARNER, next=3, gen=1]
I210709 04:25:18.352290 84054 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r27/1:‹/{NamespaceTab…-Table/32}›] 5913  proposing SIMPLE(v2) ‹[(n3,s3):2]›: after=‹[(n1,s1):1 (n3,s3):2]› next=3
I210709 04:25:18.408402 84054 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r27/1:‹/{NamespaceTab…-Table/32}›] 5914  change replicas (add ‹[(n2,s2):3LEARNER]› remove ‹[]›): existing descriptor r27:‹/{NamespaceTable/Max-Table/32}› [(n1,s1):1, (n3,s3):2, next=3, gen=2]
I210709 04:25:18.540355 84054 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r27/1:‹/{NamespaceTab…-Table/32}›] 5915  proposing SIMPLE(l3) ‹[(n2,s2):3LEARNER]›: after=‹[(n1,s1):1 (n3,s3):2 (n2,s2):3LEARNER]› next=4
I210709 04:25:18.633301 84054 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r27/1:‹/{NamespaceTab…-Table/32}›] 5916  streamed INITIAL snapshot ‹eff9b502› at applied index 21 to (n2,s2):3LEARNER in 0.00s @ ‹10 MiB›/s: ‹kv pairs: 12, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.02s
I210709 04:25:18.633391 86098 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r27/1:‹/{NamespaceTab…-Table/32}›] 5917  skipping snapshot; replica is likely a LEARNER in the process of being added: (n2,s2):3LEARNER
I210709 04:25:18.941018 86013 kv/kvserver/replica_consistency.go:255 ⋮ [n1,consistencyChecker,s1,r4/1:‹/System{/tsd-tse}›] 5918  triggering stats recomputation to resolve delta of {ContainsEstimates:5160 LastUpdateNanos:1625804710896471000 IntentAge:0 GCBytesAge:0 LiveBytes:-172398 LiveCount:-2580 KeyBytes:-131118 KeyCount:-2580 ValBytes:-41280 ValCount:-2580 IntentBytes:0 IntentCount:0 SeparatedIntentCount:0 SysBytes:0 SysCount:0 AbortSpanBytes:0}
I210709 04:25:19.077167 84054 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r27/1:‹/{NamespaceTab…-Table/32}›] 5919  change replicas (add ‹[(n2,s2):3]› remove ‹[]›): existing descriptor r27:‹/{NamespaceTable/Max-Table/32}› [(n1,s1):1, (n3,s3):2, (n2,s2):3LEARNER, next=4, gen=3]
I210709 04:25:19.188821 84054 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r27/1:‹/{NamespaceTab…-Table/32}›] 5920  proposing SIMPLE(v3) ‹[(n2,s2):3]›: after=‹[(n1,s1):1 (n3,s3):2 (n2,s2):3]› next=4
I210709 04:25:19.353365 84054 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r11/1:‹/Table/1{5-6}›] 5921  change replicas (add ‹[(n3,s3):2LEARNER]› remove ‹[]›): existing descriptor r11:‹/Table/1{5-6}› [(n1,s1):1, next=2, gen=0]
I210709 04:25:19.504362 84054 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r11/1:‹/Table/1{5-6}›] 5922  proposing SIMPLE(l2) ‹[(n3,s3):2LEARNER]›: after=‹[(n1,s1):1 (n3,s3):2LEARNER]› next=3
I210709 04:25:19.633194 84054 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r11/1:‹/Table/1{5-6}›] 5923  streamed INITIAL snapshot ‹5c60a2bf› at applied index 19 to (n3,s3):2LEARNER in 0.00s @ ‹11 MiB›/s: ‹kv pairs: 9, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.04s
I210709 04:25:19.633213 86156 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r11/1:‹/Table/1{5-6}›] 5924  skipping snapshot; replica is likely a LEARNER in the process of being added: (n3,s3):2LEARNER
W210709 04:25:19.870706 83971 1@server/status/runtime.go:476 ⋮ [n1] 5925  unable to get file descriptor usage (will not try again): ‹not implemented on darwin›
I210709 04:25:19.875414 83971 2@server/status/runtime.go:569 ⋮ [n1] 5926  runtime stats: 119 MiB RSS, 347 goroutines (stacks: 5.0 MiB), 34 MiB/72 MiB Go alloc/total (heap fragmentation: 9.9 MiB, heap reserved: 12 MiB, heap released: 3.5 MiB), 5.1 MiB/10 MiB CGO alloc/total (0.0 CGO/sec), 0.0/0.0 %(u/s)time, 0.0 %gc (0x), 33 MiB/41 MiB (r/w)net
I210709 04:25:19.970509 84054 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r11/1:‹/Table/1{5-6}›] 5927  change replicas (add ‹[(n3,s3):2]› remove ‹[]›): existing descriptor r11:‹/Table/1{5-6}› [(n1,s1):1, (n3,s3):2LEARNER, next=3, gen=1]
W210709 04:25:20.043493 83993 server/node.go:768 ⋮ [n1,summaries] 5928  health alerts detected: ‹{Alerts:[{StoreID:1 Category:METRICS Description:ranges.underreplicated Value:32}]}›
I210709 04:25:20.062289 84054 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r11/1:‹/Table/1{5-6}›] 5929  proposing SIMPLE(v2) ‹[(n3,s3):2]›: after=‹[(n1,s1):1 (n3,s3):2]› next=3
I210709 04:25:20.137332 84054 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r11/1:‹/Table/1{5-6}›] 5930  change replicas (add ‹[(n2,s2):3LEARNER]› remove ‹[]›): existing descriptor r11:‹/Table/1{5-6}› [(n1,s1):1, (n3,s3):2, next=3, gen=2]
I210709 04:25:20.325100 84054 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r11/1:‹/Table/1{5-6}›] 5931  proposing SIMPLE(l3) ‹[(n2,s2):3LEARNER]›: after=‹[(n1,s1):1 (n3,s3):2 (n2,s2):3LEARNER]› next=4
I210709 04:25:20.417395 86276 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r11/1:‹/Table/1{5-6}›] 5932  skipping snapshot; replica is likely a LEARNER in the process of being added: (n2,s2):3LEARNER
I210709 04:25:20.417410 84054 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r11/1:‹/Table/1{5-6}›] 5933  streamed INITIAL snapshot ‹159a4bea› at applied index 23 to (n2,s2):3LEARNER in 0.00s @ ‹18 MiB›/s: ‹kv pairs: 13, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.04s
I210709 04:25:21.373804 84054 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r11/1:‹/Table/1{5-6}›] 5934  change replicas (add ‹[(n2,s2):3]› remove ‹[]›): existing descriptor r11:‹/Table/1{5-6}› [(n1,s1):1, (n3,s3):2, (n2,s2):3LEARNER, next=4, gen=3]
I210709 04:25:21.487392 84054 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r11/1:‹/Table/1{5-6}›] 5935  proposing SIMPLE(v3) ‹[(n2,s2):3]›: after=‹[(n1,s1):1 (n3,s3):2 (n2,s2):3]› next=4
I210709 04:25:21.615770 84054 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r16/1:‹/Table/2{0-1}›] 5936  change replicas (add ‹[(n2,s2):2LEARNER]› remove ‹[]›): existing descriptor r16:‹/Table/2{0-1}› [(n1,s1):1, next=2, gen=0]
I210709 04:25:21.690543 84054 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r16/1:‹/Table/2{0-1}›] 5937  proposing SIMPLE(l2) ‹[(n2,s2):2LEARNER]›: after=‹[(n1,s1):1 (n2,s2):2LEARNER]› next=3
I210709 04:25:21.748153 86422 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r16/1:‹/Table/2{0-1}›] 5938  skipping snapshot; replica is likely a LEARNER in the process of being added: (n2,s2):2LEARNER
I210709 04:25:21.748153 84054 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r16/1:‹/Table/2{0-1}›] 5939  streamed INITIAL snapshot ‹f0fb7eaa› at applied index 18 to (n2,s2):2LEARNER in 0.00s @ ‹10 MiB›/s: ‹kv pairs: 9, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.02s
I210709 04:25:22.176157 84054 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r16/1:‹/Table/2{0-1}›] 5940  change replicas (add ‹[(n2,s2):2]› remove ‹[]›): existing descriptor r16:‹/Table/2{0-1}› [(n1,s1):1, (n2,s2):2LEARNER, next=3, gen=1]
I210709 04:25:22.268333 84054 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r16/1:‹/Table/2{0-1}›] 5941  proposing SIMPLE(v2) ‹[(n2,s2):2]›: after=‹[(n1,s1):1 (n2,s2):2]› next=3
I210709 04:25:22.323457 84054 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r16/1:‹/Table/2{0-1}›] 5942  change replicas (add ‹[(n3,s3):3LEARNER]› remove ‹[]›): existing descriptor r16:‹/Table/2{0-1}› [(n1,s1):1, (n2,s2):2, next=3, gen=2]
I210709 04:25:22.471641 84054 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r16/1:‹/Table/2{0-1}›] 5943  proposing SIMPLE(l3) ‹[(n3,s3):3LEARNER]›: after=‹[(n1,s1):1 (n2,s2):2 (n3,s3):3LEARNER]› next=4
I210709 04:25:22.581870 84054 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r16/1:‹/Table/2{0-1}›] 5944  streamed INITIAL snapshot ‹ccfb2aa3› at applied index 22 to (n3,s3):3LEARNER in 0.00s @ ‹19 MiB›/s: ‹kv pairs: 13, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.00s
I210709 04:25:22.656213 86516 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r16/1:‹/Table/2{0-1}›] 5945  skipping snapshot; replica is likely a LEARNER in the process of being added: (n3,s3):3LEARNER
I210709 04:25:22.843065 86477 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r16/1:‹/Table/2{0-1}›] 5946  skipping snapshot; replica is likely a LEARNER in the process of being added: (n3,s3):3LEARNER
I210709 04:25:23.179589 84054 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r16/1:‹/Table/2{0-1}›] 5947  change replicas (add ‹[(n3,s3):3]› remove ‹[]›): existing descriptor r16:‹/Table/2{0-1}› [(n1,s1):1, (n2,s2):2, (n3,s3):3LEARNER, next=4, gen=3]
I210709 04:25:23.272373 84054 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r16/1:‹/Table/2{0-1}›] 5948  proposing SIMPLE(v3) ‹[(n3,s3):3]›: after=‹[(n1,s1):1 (n2,s2):2 (n3,s3):3]› next=4
I210709 04:25:23.437293 84054 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r7/1:‹/Table/1{1-2}›] 5949  change replicas (add ‹[(n3,s3):2LEARNER]› remove ‹[]›): existing descriptor r7:‹/Table/1{1-2}› [(n1,s1):1, next=2, gen=0]
I210709 04:25:23.564263 84054 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r7/1:‹/Table/1{1-2}›] 5950  proposing SIMPLE(l2) ‹[(n3,s3):2LEARNER]›: after=‹[(n1,s1):1 (n3,s3):2LEARNER]› next=3
I210709 04:25:23.686167 86496 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r7/1:‹/Table/1{1-2}›] 5952  skipping snapshot; replica is likely a LEARNER in the process of being added: (n3,s3):2LEARNER
I210709 04:25:23.686146 84054 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r7/1:‹/Table/1{1-2}›] 5951  streamed INITIAL snapshot ‹fb607bdb› at applied index 28 to (n3,s3):2LEARNER in 0.00s @ ‹7.7 MiB›/s: ‹kv pairs: 11, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.03s
I210709 04:25:24.120603 84054 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r7/1:‹/Table/1{1-2}›] 5953  change replicas (add ‹[(n3,s3):2]› remove ‹[]›): existing descriptor r7:‹/Table/1{1-2}› [(n1,s1):1, (n3,s3):2LEARNER, next=3, gen=1]
I210709 04:25:24.231128 84054 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r7/1:‹/Table/1{1-2}›] 5954  proposing SIMPLE(v2) ‹[(n3,s3):2]›: after=‹[(n1,s1):1 (n3,s3):2]› next=3
I210709 04:25:24.285409 84054 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r7/1:‹/Table/1{1-2}›] 5955  change replicas (add ‹[(n2,s2):3LEARNER]› remove ‹[]›): existing descriptor r7:‹/Table/1{1-2}› [(n1,s1):1, (n3,s3):2, next=3, gen=2]
I210709 04:25:24.489311 84054 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r7/1:‹/Table/1{1-2}›] 5956  proposing SIMPLE(l3) ‹[(n2,s2):3LEARNER]›: after=‹[(n1,s1):1 (n3,s3):2 (n2,s2):3LEARNER]› next=4

I210709 04:25:24.678121 86695 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r7/1:‹/Table/1{1-2}›] 5957  skipping snapshot; replica is likely a LEARNER in the process of being added: (n2,s2):3LEARNER
I210709 04:25:24.678132 84054 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r7/1:‹/Table/1{1-2}›] 5958  streamed INITIAL snapshot ‹7c6164eb› at applied index 33 to (n2,s2):3LEARNER in 0.00s @ ‹16 MiB›/s: ‹kv pairs: 15, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.02s
I210709 04:25:25.050211 84054 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r7/1:‹/Table/1{1-2}›] 5959  change replicas (add ‹[(n2,s2):3]› remove ‹[]›): existing descriptor r7:‹/Table/1{1-2}› [(n1,s1):1, (n3,s3):2, (n2,s2):3LEARNER, next=4, gen=3]
I210709 04:25:25.161140 84054 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r7/1:‹/Table/1{1-2}›] 5960  proposing SIMPLE(v3) ‹[(n2,s2):3]›: after=‹[(n1,s1):1 (n3,s3):2 (n2,s2):3]› next=4
I210709 04:25:25.254005 84054 kv/kvserver/queue.go:1193 ⋮ [n1,replicate] 5961  purgatory is now empty
I210709 04:25:25.254332 86733 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r9/1:‹/Table/1{3-4}›] 5962  change replicas (add ‹[(n3,s3):2LEARNER]› remove ‹[]›): existing descriptor r9:‹/Table/1{3-4}› [(n1,s1):1, next=2, gen=0]
I210709 04:25:25.310187 86733 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r9/1:‹/Table/1{3-4}›] 5963  proposing SIMPLE(l2) ‹[(n3,s3):2LEARNER]›: after=‹[(n1,s1):1 (n3,s3):2LEARNER]› next=3
I210709 04:25:25.456488 86806 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r9/1:‹/Table/1{3-4}›] 5964  skipping snapshot; replica is likely a LEARNER in the process of being added: (n3,s3):2LEARNER
I210709 04:25:25.456641 86733 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r9/1:‹/Table/1{3-4}›] 5965  streamed INITIAL snapshot ‹d37fe7ec› at applied index 102 to (n3,s3):2LEARNER in 0.00s @ ‹89 MiB›/s: ‹kv pairs: 153, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.05s
I210709 04:25:25.903324 86733 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r9/1:‹/Table/1{3-4}›] 5966  change replicas (add ‹[(n3,s3):2]› remove ‹[]›): existing descriptor r9:‹/Table/1{3-4}› [(n1,s1):1, (n3,s3):2LEARNER, next=3, gen=1]
I210709 04:25:25.997113 86733 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r9/1:‹/Table/1{3-4}›] 5967  proposing SIMPLE(v2) ‹[(n3,s3):2]›: after=‹[(n1,s1):1 (n3,s3):2]› next=3
I210709 04:25:26.096178 86733 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r9/1:‹/Table/1{3-4}›] 5968  change replicas (add ‹[(n2,s2):3LEARNER]› remove ‹[]›): existing descriptor r9:‹/Table/1{3-4}› [(n1,s1):1, (n3,s3):2, next=3, gen=2]
I210709 04:25:26.440240 86733 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r9/1:‹/Table/1{3-4}›] 5969  proposing SIMPLE(l3) ‹[(n2,s2):3LEARNER]›: after=‹[(n1,s1):1 (n3,s3):2 (n2,s2):3LEARNER]› next=4
I210709 04:25:26.570078 86899 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r9/1:‹/Table/1{3-4}›] 5970  skipping snapshot; replica is likely a LEARNER in the process of being added: (n2,s2):3LEARNER
I210709 04:25:26.570221 86733 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r9/1:‹/Table/1{3-4}›] 5971  streamed INITIAL snapshot ‹7d9309f4› at applied index 108 to (n2,s2):3LEARNER in 0.00s @ ‹68 MiB›/s: ‹kv pairs: 167, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.04s
I210709 04:25:26.950977 86733 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r9/1:‹/Table/1{3-4}›] 5972  change replicas (add ‹[(n2,s2):3]› remove ‹[]›): existing descriptor r9:‹/Table/1{3-4}› [(n1,s1):1, (n3,s3):2, (n2,s2):3LEARNER, next=4, gen=3]
I210709 04:25:27.084183 86733 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r9/1:‹/Table/1{3-4}›] 5973  proposing SIMPLE(v3) ‹[(n2,s2):3]›: after=‹[(n1,s1):1 (n3,s3):2 (n2,s2):3]› next=4
I210709 04:25:27.248158 86957 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r19/1:‹/Table/2{3-4}›] 5974  change replicas (add ‹[(n2,s2):2LEARNER]› remove ‹[]›): existing descriptor r19:‹/Table/2{3-4}› [(n1,s1):1, next=2, gen=0]
I210709 04:25:27.396550 86957 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r19/1:‹/Table/2{3-4}›] 5975  proposing SIMPLE(l2) ‹[(n2,s2):2LEARNER]›: after=‹[(n1,s1):1 (n2,s2):2LEARNER]› next=3
I210709 04:25:27.434899 86957 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r19/1:‹/Table/2{3-4}›] 5976  streamed INITIAL snapshot ‹1382c38a› at applied index 20 to (n2,s2):2LEARNER in 0.00s @ ‹14 MiB›/s: ‹kv pairs: 13, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.02s
I210709 04:25:27.434909 86997 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r19/1:‹/Table/2{3-4}›] 5977  skipping snapshot; replica is likely a LEARNER in the process of being added: (n2,s2):2LEARNER
I210709 04:25:27.940176 86957 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r19/1:‹/Table/2{3-4}›] 5978  change replicas (add ‹[(n2,s2):2]› remove ‹[]›): existing descriptor r19:‹/Table/2{3-4}› [(n1,s1):1, (n2,s2):2LEARNER, next=3, gen=1]
I210709 04:25:28.072407 86957 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r19/1:‹/Table/2{3-4}›] 5979  proposing SIMPLE(v2) ‹[(n2,s2):2]›: after=‹[(n1,s1):1 (n2,s2):2]› next=3
I210709 04:25:28.145008 86957 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r19/1:‹/Table/2{3-4}›] 5980  change replicas (add ‹[(n3,s3):3LEARNER]› remove ‹[]›): existing descriptor r19:‹/Table/2{3-4}› [(n1,s1):1, (n2,s2):2, next=3, gen=2]
I210709 04:25:28.313530 86957 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r19/1:‹/Table/2{3-4}›] 5981  proposing SIMPLE(l3) ‹[(n3,s3):3LEARNER]›: after=‹[(n1,s1):1 (n2,s2):2 (n3,s3):3LEARNER]› next=4
I210709 04:25:28.409014 86957 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r19/1:‹/Table/2{3-4}›] 5982  streamed INITIAL snapshot ‹d5bd6f0a› at applied index 24 to (n3,s3):3LEARNER in 0.00s @ ‹15 MiB›/s: ‹kv pairs: 17, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.04s
I210709 04:25:28.428460 87077 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r19/1:‹/Table/2{3-4}›] 5983  skipping snapshot; replica is likely a LEARNER in the process of being added: (n3,s3):3LEARNER
I210709 04:25:28.599547 87069 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r19/1:‹/Table/2{3-4}›] 5984  skipping snapshot; replica is likely a LEARNER in the process of being added: (n3,s3):3LEARNER
I210709 04:25:28.729007 86957 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r19/1:‹/Table/2{3-4}›] 5985  change replicas (add ‹[(n3,s3):3]› remove ‹[]›): existing descriptor r19:‹/Table/2{3-4}› [(n1,s1):1, (n2,s2):2, (n3,s3):3LEARNER, next=4, gen=3]
I210709 04:25:28.876299 86957 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r19/1:‹/Table/2{3-4}›] 5986  proposing SIMPLE(v3) ‹[(n3,s3):3]›: after=‹[(n1,s1):1 (n2,s2):2 (n3,s3):3]› next=4
I210709 04:25:29.026387 87124 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r26/1:‹/NamespaceTable/{30-Max}›] 5987  change replicas (add ‹[(n3,s3):2LEARNER]› remove ‹[]›): existing descriptor r26:‹/NamespaceTable/{30-Max}› [(n1,s1):1, next=2, gen=0]
I210709 04:25:29.144444 87124 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r26/1:‹/NamespaceTable/{30-Max}›] 5988  proposing SIMPLE(l2) ‹[(n3,s3):2LEARNER]›: after=‹[(n1,s1):1 (n3,s3):2LEARNER]› next=3
I210709 04:25:29.311837 87165 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r26/1:‹/NamespaceTable/{30-Max}›] 5989  skipping snapshot; replica is likely a LEARNER in the process of being added: (n3,s3):2LEARNER
I210709 04:25:29.311837 87124 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r26/1:‹/NamespaceTable/{30-Max}›] 5990  streamed INITIAL snapshot ‹f91a548d› at applied index 25 to (n3,s3):2LEARNER in 0.00s @ ‹29 MiB›/s: ‹kv pairs: 45, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.02s
I210709 04:25:29.628741 87124 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r26/1:‹/NamespaceTable/{30-Max}›] 5991  change replicas (add ‹[(n3,s3):2]› remove ‹[]›): existing descriptor r26:‹/NamespaceTable/{30-Max}› [(n1,s1):1, (n3,s3):2LEARNER, next=3, gen=1]
I210709 04:25:29.741686 87124 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r26/1:‹/NamespaceTable/{30-Max}›] 5992  proposing SIMPLE(v2) ‹[(n3,s3):2]›: after=‹[(n1,s1):1 (n3,s3):2]› next=3
I210709 04:25:29.832235 87124 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r26/1:‹/NamespaceTable/{30-Max}›] 5993  change replicas (add ‹[(n2,s2):3LEARNER]› remove ‹[]›): existing descriptor r26:‹/NamespaceTable/{30-Max}› [(n1,s1):1, (n3,s3):2, next=3, gen=2]
I210709 04:25:29.853552 83727 kv/kvserver/store.go:2663 ⋮ [n1,s1] 5994
I210709 04:25:29.853552 83727 kv/kvserver/store.go:2663 ⋮ [n1,s1] 5994 +__level_____count____size___score______in__ingest(sz_cnt)____move(sz_cnt)___write(sz_cnt)____read___r-amp___w-amp
I210709 04:25:29.853552 83727 kv/kvserver/store.go:2663 ⋮ [n1,s1] 5994 +    WAL         4   2.0 M       -   2.0 M       -       -       -       -   2.0 M       -       -       -     1.0
I210709 04:25:29.853552 83727 kv/kvserver/store.go:2663 ⋮ [n1,s1] 5994 +      0         0     0 B    0.00     0 B     0 B       0     0 B       0     0 B       0     0 B       0     0.0
I210709 04:25:29.853552 83727 kv/kvserver/store.go:2663 ⋮ [n1,s1] 5994 +      1         0     0 B    0.00     0 B     0 B       0     0 B       0     0 B       0     0 B       0     0.0
I210709 04:25:29.853552 83727 kv/kvserver/store.go:2663 ⋮ [n1,s1] 5994 +      2         0     0 B    0.00     0 B     0 B       0     0 B       0     0 B       0     0 B       0     0.0
I210709 04:25:29.853552 83727 kv/kvserver/store.go:2663 ⋮ [n1,s1] 5994 +      3         0     0 B    0.00     0 B     0 B       0     0 B       0     0 B       0     0 B       0     0.0
I210709 04:25:29.853552 83727 kv/kvserver/store.go:2663 ⋮ [n1,s1] 5994 +      4         0     0 B    0.00     0 B     0 B       0     0 B       0     0 B       0     0 B       0     0.0
I210709 04:25:29.853552 83727 kv/kvserver/store.go:2663 ⋮ [n1,s1] 5994 +      5         0     0 B    0.00     0 B     0 B       0     0 B       0     0 B       0     0 B       0     0.0
I210709 04:25:29.853552 83727 kv/kvserver/store.go:2663 ⋮ [n1,s1] 5994 +      6         0     0 B       -     0 B     0 B       0     0 B       0     0 B       0     0 B       0     0.0
I210709 04:25:29.853552 83727 kv/kvserver/store.go:2663 ⋮ [n1,s1] 5994 +  total         0     0 B       -   2.0 M     0 B       0     0 B       0   2.0 M       0     0 B       0     1.0
I210709 04:25:29.853552 83727 kv/kvserver/store.go:2663 ⋮ [n1,s1] 5994 +  flush         0
I210709 04:25:29.853552 83727 kv/kvserver/store.go:2663 ⋮ [n1,s1] 5994 +compact         0     0 B             0 B  (size == estimated-debt, in = in-progress-bytes)
I210709 04:25:29.853552 83727 kv/kvserver/store.go:2663 ⋮ [n1,s1] 5994 + memtbl         4   3.8 M
I210709 04:25:29.853552 83727 kv/kvserver/store.go:2663 ⋮ [n1,s1] 5994 +zmemtbl         0     0 B
I210709 04:25:29.853552 83727 kv/kvserver/store.go:2663 ⋮ [n1,s1] 5994 +   ztbl         0     0 B
I210709 04:25:29.853552 83727 kv/kvserver/store.go:2663 ⋮ [n1,s1] 5994 + bcache         0     0 B    0.0%  (score == hit-rate)
I210709 04:25:29.853552 83727 kv/kvserver/store.go:2663 ⋮ [n1,s1] 5994 + tcache         0     0 B    0.0%  (score == hit-rate)
I210709 04:25:29.853552 83727 kv/kvserver/store.go:2663 ⋮ [n1,s1] 5994 + titers         0
I210709 04:25:29.853552 83727 kv/kvserver/store.go:2663 ⋮ [n1,s1] 5994 + filter         -       -    0.0%  (score == utility)
I210709 04:25:29.875429 83971 2@server/status/runtime.go:569 ⋮ [n1] 5995  runtime stats: 125 MiB RSS, 353 goroutines (stacks: 7.1 MiB), 39 MiB/78 MiB Go alloc/total (heap fragmentation: 5.2 MiB, heap reserved: 13 MiB, heap released: 63 MiB), 6.9 MiB/12 MiB CGO alloc/total (0.7 CGO/sec), 5.2/4.4 %(u/s)time, 0.0 %gc (0x), 638 KiB/640 KiB (r/w)net
I210709 04:25:30.022351 87124 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r26/1:‹/NamespaceTable/{30-Max}›] 5996  proposing SIMPLE(l3) ‹[(n2,s2):3LEARNER]›: after=‹[(n1,s1):1 (n3,s3):2 (n2,s2):3LEARNER]› next=4
W210709 04:25:30.039883 83993 server/node.go:768 ⋮ [n1,summaries] 5997  health alerts detected: ‹{Alerts:[{StoreID:1 Category:METRICS Description:ranges.underreplicated Value:27}]}›
I210709 04:25:30.167057 87271 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r26/1:‹/NamespaceTable/{30-Max}›] 5998  skipping snapshot; replica is likely a LEARNER in the process of being added: (n2,s2):3LEARNER
I210709 04:25:30.167105 87124 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r26/1:‹/NamespaceTable/{30-Max}›] 5999  streamed INITIAL snapshot ‹4f64fa61› at applied index 29 to (n2,s2):3LEARNER in 0.00s @ ‹21 MiB›/s: ‹kv pairs: 49, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.09s
I210709 04:25:31.080435 87124 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r26/1:‹/NamespaceTable/{30-Max}›] 6000  change replicas (add ‹[(n2,s2):3]› remove ‹[]›): existing descriptor r26:‹/NamespaceTable/{30-Max}› [(n1,s1):1, (n3,s3):2, (n2,s2):3LEARNER, next=4, gen=3]
I210709 04:25:31.248370 87124 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r26/1:‹/NamespaceTable/{30-Max}›] 6001  proposing SIMPLE(v3) ‹[(n2,s2):3]›: after=‹[(n1,s1):1 (n3,s3):2 (n2,s2):3]› next=4
I210709 04:25:31.415053 87427 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r17/1:‹/Table/2{1-2}›] 6002  change replicas (add ‹[(n2,s2):2LEARNER]› remove ‹[]›): existing descriptor r17:‹/Table/2{1-2}› [(n1,s1):1, next=2, gen=0]
I210709 04:25:31.528228 87427 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r17/1:‹/Table/2{1-2}›] 6003  proposing SIMPLE(l2) ‹[(n2,s2):2LEARNER]›: after=‹[(n1,s1):1 (n2,s2):2LEARNER]› next=3
I210709 04:25:31.679505 87427 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r17/1:‹/Table/2{1-2}›] 6004  streamed INITIAL snapshot ‹5a5aff17› at applied index 21 to (n2,s2):2LEARNER in 0.00s @ ‹17 MiB›/s: ‹kv pairs: 13, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.00s
I210709 04:25:31.714864 87340 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r17/1:‹/Table/2{1-2}›] 6005  skipping snapshot; replica is likely a LEARNER in the process of being added: (n2,s2):2LEARNER
I210709 04:25:32.148789 87427 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r17/1:‹/Table/2{1-2}›] 6006  change replicas (add ‹[(n2,s2):2]› remove ‹[]›): existing descriptor r17:‹/Table/2{1-2}› [(n1,s1):1, (n2,s2):2LEARNER, next=3, gen=1]
I210709 04:25:32.277307 87427 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r17/1:‹/Table/2{1-2}›] 6007  proposing SIMPLE(v2) ‹[(n2,s2):2]›: after=‹[(n1,s1):1 (n2,s2):2]› next=3
I210709 04:25:32.349902 87427 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r17/1:‹/Table/2{1-2}›] 6008  change replicas (add ‹[(n3,s3):3LEARNER]› remove ‹[]›): existing descriptor r17:‹/Table/2{1-2}› [(n1,s1):1, (n2,s2):2, next=3, gen=2]
I210709 04:25:32.554436 87427 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r17/1:‹/Table/2{1-2}›] 6009  proposing SIMPLE(l3) ‹[(n3,s3):3LEARNER]›: after=‹[(n1,s1):1 (n2,s2):2 (n3,s3):3LEARNER]› next=4
I210709 04:25:32.722180 87514 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r17/1:‹/Table/2{1-2}›] 6010  skipping snapshot; replica is likely a LEARNER in the process of being added: (n3,s3):3LEARNER
I210709 04:25:32.722198 87427 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r17/1:‹/Table/2{1-2}›] 6011  streamed INITIAL snapshot ‹17ac1134› at applied index 26 to (n3,s3):3LEARNER in 0.00s @ ‹19 MiB›/s: ‹kv pairs: 17, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.08s
I210709 04:25:33.206813 87427 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r17/1:‹/Table/2{1-2}›] 6012  change replicas (add ‹[(n3,s3):3]› remove ‹[]›): existing descriptor r17:‹/Table/2{1-2}› [(n1,s1):1, (n2,s2):2, (n3,s3):3LEARNER, next=4, gen=3]
I210709 04:25:33.356561 87427 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r17/1:‹/Table/2{1-2}›] 6013  proposing SIMPLE(v3) ‹[(n3,s3):3]›: after=‹[(n1,s1):1 (n2,s2):2 (n3,s3):3]› next=4
I210709 04:25:33.483992 87608 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r29/1:‹/Table/3{3-4}›] 6014  change replicas (add ‹[(n3,s3):2LEARNER]› remove ‹[]›): existing descriptor r29:‹/Table/3{3-4}› [(n1,s1):1, next=2, gen=0]
I210709 04:25:33.653671 87608 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r29/1:‹/Table/3{3-4}›] 6015  proposing SIMPLE(l2) ‹[(n3,s3):2LEARNER]›: after=‹[(n1,s1):1 (n3,s3):2LEARNER]› next=3
I210709 04:25:33.838695 87642 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r29/1:‹/Table/3{3-4}›] 6016  skipping snapshot; replica is likely a LEARNER in the process of being added: (n3,s3):2LEARNER
I210709 04:25:33.838733 87608 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r29/1:‹/Table/3{3-4}›] 6017  streamed INITIAL snapshot ‹311fef5f› at applied index 19 to (n3,s3):2LEARNER in 0.00s @ ‹10 MiB›/s: ‹kv pairs: 9, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.05s
I210709 04:25:34.162572 87608 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r29/1:‹/Table/3{3-4}›] 6018  change replicas (add ‹[(n3,s3):2]› remove ‹[]›): existing descriptor r29:‹/Table/3{3-4}› [(n1,s1):1, (n3,s3):2LEARNER, next=3, gen=1]
I210709 04:25:34.290424 87608 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r29/1:‹/Table/3{3-4}›] 6019  proposing SIMPLE(v2) ‹[(n3,s3):2]›: after=‹[(n1,s1):1 (n3,s3):2]› next=3
I210709 04:25:34.361932 87608 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r29/1:‹/Table/3{3-4}›] 6020  change replicas (add ‹[(n2,s2):3LEARNER]› remove ‹[]›): existing descriptor r29:‹/Table/3{3-4}› [(n1,s1):1, (n3,s3):2, next=3, gen=2]
I210709 04:25:34.529756 87608 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r29/1:‹/Table/3{3-4}›] 6021  proposing SIMPLE(l3) ‹[(n2,s2):3LEARNER]›: after=‹[(n1,s1):1 (n3,s3):2 (n2,s2):3LEARNER]› next=4

I210709 04:25:34.662648 87693 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r29/1:‹/Table/3{3-4}›] 6022  skipping snapshot; replica is likely a LEARNER in the process of being added: (n2,s2):3LEARNER
I210709 04:25:34.662655 87608 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r29/1:‹/Table/3{3-4}›] 6023  streamed INITIAL snapshot ‹4d22d874› at applied index 24 to (n2,s2):3LEARNER in 0.00s @ ‹16 MiB›/s: ‹kv pairs: 13, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.04s
I210709 04:25:34.784405 87712 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r29/1:‹/Table/3{3-4}›] 6024  skipping snapshot; replica is likely a LEARNER in the process of being added: (n2,s2):3LEARNER
I210709 04:25:35.083051 87608 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r29/1:‹/Table/3{3-4}›] 6025  change replicas (add ‹[(n2,s2):3]› remove ‹[]›): existing descriptor r29:‹/Table/3{3-4}› [(n1,s1):1, (n3,s3):2, (n2,s2):3LEARNER, next=4, gen=3]
I210709 04:25:35.196611 87608 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r29/1:‹/Table/3{3-4}›] 6026  proposing SIMPLE(v3) ‹[(n2,s2):3]›: after=‹[(n1,s1):1 (n3,s3):2 (n2,s2):3]› next=4
I210709 04:25:35.325917 87628 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r5/1:‹/{Systemtse-Table/System…}›] 6027  change replicas (add ‹[(n2,s2):2LEARNER]› remove ‹[]›): existing descriptor r5:‹/{Systemtse-Table/SystemConfigSpan/Start}› [(n1,s1):1, next=2, gen=0]
I210709 04:25:35.455034 87628 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r5/1:‹/{Systemtse-Table/System…}›] 6028  proposing SIMPLE(l2) ‹[(n2,s2):2LEARNER]›: after=‹[(n1,s1):1 (n2,s2):2LEARNER]› next=3

I210709 04:25:35.639616 87628 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r5/1:‹/{Systemtse-Table/System…}›] 6029  streamed INITIAL snapshot ‹e81421b1› at applied index 19 to (n2,s2):2LEARNER in 0.00s @ ‹12 MiB›/s: ‹kv pairs: 10, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.05s
I210709 04:25:35.639633 87772 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r5/1:‹/{Systemtse-Table/System…}›] 6030  skipping snapshot; replica is likely a LEARNER in the process of being added: (n2,s2):2LEARNER
I210709 04:25:35.994521 87628 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r5/1:‹/{Systemtse-Table/System…}›] 6031  change replicas (add ‹[(n2,s2):2]› remove ‹[]›): existing descriptor r5:‹/{Systemtse-Table/SystemConfigSpan/Start}› [(n1,s1):1, (n2,s2):2LEARNER, next=3, gen=1]
I210709 04:25:36.131941 87628 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r5/1:‹/{Systemtse-Table/System…}›] 6032  proposing SIMPLE(v2) ‹[(n2,s2):2]›: after=‹[(n1,s1):1 (n2,s2):2]› next=3
I210709 04:25:36.204723 87628 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r5/1:‹/{Systemtse-Table/System…}›] 6033  change replicas (add ‹[(n3,s3):3LEARNER]› remove ‹[]›): existing descriptor r5:‹/{Systemtse-Table/SystemConfigSpan/Start}› [(n1,s1):1, (n2,s2):2, next=3, gen=2]
I210709 04:25:36.428050 87628 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r5/1:‹/{Systemtse-Table/System…}›] 6034  proposing SIMPLE(l3) ‹[(n3,s3):3LEARNER]›: after=‹[(n1,s1):1 (n2,s2):2 (n3,s3):3LEARNER]› next=4
I210709 04:25:36.581924 87823 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r5/1:‹/{Systemtse-Table/System…}›] 6035  skipping snapshot; replica is likely a LEARNER in the process of being added: (n3,s3):3LEARNER
I210709 04:25:36.581961 87628 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r5/1:‹/{Systemtse-Table/System…}›] 6036  streamed INITIAL snapshot ‹d4259a99› at applied index 23 to (n3,s3):3LEARNER in 0.00s @ ‹12 MiB›/s: ‹kv pairs: 14, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.05s
I210709 04:25:37.046656 87628 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r5/1:‹/{Systemtse-Table/System…}›] 6037  change replicas (add ‹[(n3,s3):3]› remove ‹[]›): existing descriptor r5:‹/{Systemtse-Table/SystemConfigSpan/Start}› [(n1,s1):1, (n2,s2):2, (n3,s3):3LEARNER, next=4, gen=3]
I210709 04:25:37.197398 87628 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r5/1:‹/{Systemtse-Table/System…}›] 6038  proposing SIMPLE(v3) ‹[(n3,s3):3]›: after=‹[(n1,s1):1 (n2,s2):2 (n3,s3):3]› next=4
I210709 04:25:37.324875 87911 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r20/1:‹/Table/2{4-5}›] 6039  change replicas (add ‹[(n2,s2):2LEARNER]› remove ‹[]›): existing descriptor r20:‹/Table/2{4-5}› [(n1,s1):1, next=2, gen=0]
I210709 04:25:37.480342 87911 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r20/1:‹/Table/2{4-5}›] 6040  proposing SIMPLE(l2) ‹[(n2,s2):2LEARNER]›: after=‹[(n1,s1):1 (n2,s2):2LEARNER]› next=3
I210709 04:25:37.690735 88005 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r20/1:‹/Table/2{4-5}›] 6042  skipping snapshot; replica is likely a LEARNER in the process of being added: (n2,s2):2LEARNER
I210709 04:25:37.690702 87911 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r20/1:‹/Table/2{4-5}›] 6041  streamed INITIAL snapshot ‹8ab5dd5f› at applied index 18 to (n2,s2):2LEARNER in 0.00s @ ‹8.0 MiB›/s: ‹kv pairs: 9, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.08s
I210709 04:25:38.121188 87911 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r20/1:‹/Table/2{4-5}›] 6043  change replicas (add ‹[(n2,s2):2]› remove ‹[]›): existing descriptor r20:‹/Table/2{4-5}› [(n1,s1):1, (n2,s2):2LEARNER, next=3, gen=1]
I210709 04:25:38.250166 87911 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r20/1:‹/Table/2{4-5}›] 6044  proposing SIMPLE(v2) ‹[(n2,s2):2]›: after=‹[(n1,s1):1 (n2,s2):2]› next=3
I210709 04:25:38.321976 87911 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r20/1:‹/Table/2{4-5}›] 6045  change replicas (add ‹[(n3,s3):3LEARNER]› remove ‹[]›): existing descriptor r20:‹/Table/2{4-5}› [(n1,s1):1, (n2,s2):2, next=3, gen=2]
I210709 04:25:38.454167 87911 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r20/1:‹/Table/2{4-5}›] 6046  proposing SIMPLE(l3) ‹[(n3,s3):3LEARNER]›: after=‹[(n1,s1):1 (n2,s2):2 (n3,s3):3LEARNER]› next=4
I210709 04:25:38.603686 88049 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r20/1:‹/Table/2{4-5}›] 6047  skipping snapshot; replica is likely a LEARNER in the process of being added: (n3,s3):3LEARNER
I210709 04:25:38.603736 87911 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r20/1:‹/Table/2{4-5}›] 6048  streamed INITIAL snapshot ‹e0b7ce15› at applied index 23 to (n3,s3):3LEARNER in 0.00s @ ‹12 MiB›/s: ‹kv pairs: 13, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.07s
I210709 04:25:38.996459 87911 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r20/1:‹/Table/2{4-5}›] 6049  change replicas (add ‹[(n3,s3):3]› remove ‹[]›): existing descriptor r20:‹/Table/2{4-5}› [(n1,s1):1, (n2,s2):2, (n3,s3):3LEARNER, next=4, gen=3]
I210709 04:25:39.146023 87911 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r20/1:‹/Table/2{4-5}›] 6050  proposing SIMPLE(v3) ‹[(n3,s3):3]›: after=‹[(n1,s1):1 (n2,s2):2 (n3,s3):3]› next=4
I210709 04:25:39.256944 88182 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r24/1:‹/Table/2{8-9}›] 6051  change replicas (add ‹[(n2,s2):2LEARNER]› remove ‹[]›): existing descriptor r24:‹/Table/2{8-9}› [(n1,s1):1, next=2, gen=0]
I210709 04:25:39.370315 88182 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r24/1:‹/Table/2{8-9}›] 6052  proposing SIMPLE(l2) ‹[(n2,s2):2LEARNER]›: after=‹[(n1,s1):1 (n2,s2):2LEARNER]› next=3
I210709 04:25:39.516677 88198 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r24/1:‹/Table/2{8-9}›] 6053  skipping snapshot; replica is likely a LEARNER in the process of being added: (n2,s2):2LEARNER
I210709 04:25:39.516710 88182 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r24/1:‹/Table/2{8-9}›] 6054  streamed INITIAL snapshot ‹8e86da72› at applied index 18 to (n2,s2):2LEARNER in 0.00s @ ‹7.8 MiB›/s: ‹kv pairs: 9, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.03s
I210709 04:25:39.860598 88182 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r24/1:‹/Table/2{8-9}›] 6055  change replicas (add ‹[(n2,s2):2]› remove ‹[]›): existing descriptor r24:‹/Table/2{8-9}› [(n1,s1):1, (n2,s2):2LEARNER, next=3, gen=1]
I210709 04:25:39.876387 83971 2@server/status/runtime.go:569 ⋮ [n1] 6056  runtime stats: 127 MiB RSS, 350 goroutines (stacks: 6.5 MiB), 46 MiB/79 MiB Go alloc/total (heap fragmentation: 5.1 MiB, heap reserved: 7.4 MiB, heap released: 63 MiB), 7.0 MiB/12 MiB CGO alloc/total (0.6 CGO/sec), 5.0/4.3 %(u/s)time, 0.0 %gc (0x), 730 KiB/732 KiB (r/w)net
I210709 04:25:39.970825 88182 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r24/1:‹/Table/2{8-9}›] 6057  proposing SIMPLE(v2) ‹[(n2,s2):2]›: after=‹[(n1,s1):1 (n2,s2):2]› next=3
I210709 04:25:40.026992 88182 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r24/1:‹/Table/2{8-9}›] 6058  change replicas (add ‹[(n3,s3):3LEARNER]› remove ‹[]›): existing descriptor r24:‹/Table/2{8-9}› [(n1,s1):1, (n2,s2):2, next=3, gen=2]
W210709 04:25:40.061444 83993 server/node.go:768 ⋮ [n1,summaries] 6059  health alerts detected: ‹{Alerts:[{StoreID:1 Category:METRICS Description:ranges.underreplicated Value:22}]}›
I210709 04:25:40.226961 88182 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r24/1:‹/Table/2{8-9}›] 6060  proposing SIMPLE(l3) ‹[(n3,s3):3LEARNER]›: after=‹[(n1,s1):1 (n2,s2):2 (n3,s3):3LEARNER]› next=4
I210709 04:25:40.353684 88182 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r24/1:‹/Table/2{8-9}›] 6061  streamed INITIAL snapshot ‹e18cc2b4› at applied index 22 to (n3,s3):3LEARNER in 0.00s @ ‹18 MiB›/s: ‹kv pairs: 13, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.04s
I210709 04:25:40.353701 88241 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r24/1:‹/Table/2{8-9}›] 6062  skipping snapshot; replica is likely a LEARNER in the process of being added: (n3,s3):3LEARNER
I210709 04:25:40.771299 88182 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r24/1:‹/Table/2{8-9}›] 6063  change replicas (add ‹[(n3,s3):3]› remove ‹[]›): existing descriptor r24:‹/Table/2{8-9}› [(n1,s1):1, (n2,s2):2, (n3,s3):3LEARNER, next=4, gen=3]
I210709 04:25:40.938464 88182 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r24/1:‹/Table/2{8-9}›] 6064  proposing SIMPLE(v3) ‹[(n3,s3):3]›: after=‹[(n1,s1):1 (n2,s2):2 (n3,s3):3]› next=4
I210709 04:25:41.091125 88419 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r15/1:‹/Table/{19-20}›] 6065  change replicas (add ‹[(n2,s2):2LEARNER]› remove ‹[]›): existing descriptor r15:‹/Table/{19-20}› [(n1,s1):1, next=2, gen=0]
I210709 04:25:41.256016 88419 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r15/1:‹/Table/{19-20}›] 6066  proposing SIMPLE(l2) ‹[(n2,s2):2LEARNER]›: after=‹[(n1,s1):1 (n2,s2):2LEARNER]› next=3
I210709 04:25:41.511566 88419 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r15/1:‹/Table/{19-20}›] 6067  streamed INITIAL snapshot ‹123f3719› at applied index 18 to (n2,s2):2LEARNER in 0.00s @ ‹8.2 MiB›/s: ‹kv pairs: 9, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.05s
I210709 04:25:41.511592 88350 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r15/1:‹/Table/{19-20}›] 6068  skipping snapshot; replica is likely a LEARNER in the process of being added: (n2,s2):2LEARNER
I210709 04:25:42.021504 88419 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r15/1:‹/Table/{19-20}›] 6069  change replicas (add ‹[(n2,s2):2]› remove ‹[]›): existing descriptor r15:‹/Table/{19-20}› [(n1,s1):1, (n2,s2):2LEARNER, next=3, gen=1]
I210709 04:25:42.114090 88419 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r15/1:‹/Table/{19-20}›] 6070  proposing SIMPLE(v2) ‹[(n2,s2):2]›: after=‹[(n1,s1):1 (n2,s2):2]› next=3
I210709 04:25:42.189116 88419 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r15/1:‹/Table/{19-20}›] 6071  change replicas (add ‹[(n3,s3):3LEARNER]› remove ‹[]›): existing descriptor r15:‹/Table/{19-20}› [(n1,s1):1, (n2,s2):2, next=3, gen=2]
I210709 04:25:42.382745 88419 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r15/1:‹/Table/{19-20}›] 6072  proposing SIMPLE(l3) ‹[(n3,s3):3LEARNER]›: after=‹[(n1,s1):1 (n2,s2):2 (n3,s3):3LEARNER]› next=4
I210709 04:25:42.528495 88504 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r15/1:‹/Table/{19-20}›] 6073  skipping snapshot; replica is likely a LEARNER in the process of being added: (n3,s3):3LEARNER
I210709 04:25:42.528507 88419 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r15/1:‹/Table/{19-20}›] 6074  streamed INITIAL snapshot ‹0cea4fab› at applied index 22 to (n3,s3):3LEARNER in 0.00s @ ‹17 MiB›/s: ‹kv pairs: 13, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.06s
I210709 04:25:43.072358 88419 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r15/1:‹/Table/{19-20}›] 6075  change replicas (add ‹[(n3,s3):3]› remove ‹[]›): existing descriptor r15:‹/Table/{19-20}› [(n1,s1):1, (n2,s2):2, (n3,s3):3LEARNER, next=4, gen=3]
I210709 04:25:43.237757 88419 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r15/1:‹/Table/{19-20}›] 6076  proposing SIMPLE(v3) ‹[(n3,s3):3]›: after=‹[(n1,s1):1 (n2,s2):2 (n3,s3):3]› next=4
I210709 04:25:43.403867 88591 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r18/1:‹/Table/2{2-3}›] 6077  change replicas (add ‹[(n2,s2):2LEARNER]› remove ‹[]›): existing descriptor r18:‹/Table/2{2-3}› [(n1,s1):1, next=2, gen=0]
I210709 04:25:43.480264 88591 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r18/1:‹/Table/2{2-3}›] 6078  proposing SIMPLE(l2) ‹[(n2,s2):2LEARNER]›: after=‹[(n1,s1):1 (n2,s2):2LEARNER]› next=3
I210709 04:25:43.577934 88591 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r18/1:‹/Table/2{2-3}›] 6079  streamed INITIAL snapshot ‹9bc92d4b› at applied index 18 to (n2,s2):2LEARNER in 0.00s @ ‹11 MiB›/s: ‹kv pairs: 9, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.00s
I210709 04:25:43.612450 88677 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r18/1:‹/Table/2{2-3}›] 6080  skipping snapshot; replica is likely a LEARNER in the process of being added: (n2,s2):2LEARNER
I210709 04:25:44.043627 88591 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r18/1:‹/Table/2{2-3}›] 6081  change replicas (add ‹[(n2,s2):2]› remove ‹[]›): existing descriptor r18:‹/Table/2{2-3}› [(n1,s1):1, (n2,s2):2LEARNER, next=3, gen=1]
I210709 04:25:44.117037 88591 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r18/1:‹/Table/2{2-3}›] 6082  proposing SIMPLE(v2) ‹[(n2,s2):2]›: after=‹[(n1,s1):1 (n2,s2):2]› next=3
I210709 04:25:44.153754 88591 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r18/1:‹/Table/2{2-3}›] 6083  change replicas (add ‹[(n3,s3):3LEARNER]› remove ‹[]›): existing descriptor r18:‹/Table/2{2-3}› [(n1,s1):1, (n2,s2):2, next=3, gen=2]
I210709 04:25:44.302072 88591 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r18/1:‹/Table/2{2-3}›] 6084  proposing SIMPLE(l3) ‹[(n3,s3):3LEARNER]›: after=‹[(n1,s1):1 (n2,s2):2 (n3,s3):3LEARNER]› next=4
I210709 04:25:44.448543 88765 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r18/1:‹/Table/2{2-3}›] 6085  skipping snapshot; replica is likely a LEARNER in the process of being added: (n3,s3):3LEARNER
I210709 04:25:44.448571 88591 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r18/1:‹/Table/2{2-3}›] 6086  streamed INITIAL snapshot ‹4a81c419› at applied index 22 to (n3,s3):3LEARNER in 0.00s @ ‹14 MiB›/s: ‹kv pairs: 13, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.05s
I210709 04:25:44.599393 88769 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r18/1:‹/Table/2{2-3}›] 6087  skipping snapshot; replica is likely a LEARNER in the process of being added: (n3,s3):3LEARNER
I210709 04:25:44.831090 88591 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r18/1:‹/Table/2{2-3}›] 6088  change replicas (add ‹[(n3,s3):3]› remove ‹[]›): existing descriptor r18:‹/Table/2{2-3}› [(n1,s1):1, (n2,s2):2, (n3,s3):3LEARNER, next=4, gen=3]
I210709 04:25:45.016204 88591 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r18/1:‹/Table/2{2-3}›] 6089  proposing SIMPLE(v3) ‹[(n3,s3):3]›: after=‹[(n1,s1):1 (n2,s2):2 (n3,s3):3]› next=4
I210709 04:25:45.149879 88797 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r4/1:‹/System{/tsd-tse}›] 6090  change replicas (add ‹[(n2,s2):2LEARNER]› remove ‹[]›): existing descriptor r4:‹/System{/tsd-tse}› [(n1,s1):1, next=2, gen=0]
I210709 04:25:45.336315 88797 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r4/1:‹/System{/tsd-tse}›] 6091  proposing SIMPLE(l2) ‹[(n2,s2):2LEARNER]›: after=‹[(n1,s1):1 (n2,s2):2LEARNER]› next=3
I210709 04:25:45.481387 88720 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r4/1:‹/System{/tsd-tse}›] 6092  skipping snapshot; replica is likely a LEARNER in the process of being added: (n2,s2):2LEARNER
I210709 04:25:45.525157 88797 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r4/1:‹/System{/tsd-tse}›] 6093  streamed INITIAL snapshot ‹0461a47a› at applied index 57 to (n2,s2):2LEARNER in 0.04s @ ‹7.6 MiB›/s: ‹kv pairs: 2611, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.07s
I210709 04:25:45.778489 88797 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r4/1:‹/System{/tsd-tse}›] 6094  change replicas (add ‹[(n2,s2):2]› remove ‹[]›): existing descriptor r4:‹/System{/tsd-tse}› [(n1,s1):1, (n2,s2):2LEARNER, next=3, gen=1]
I210709 04:25:45.908835 88797 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r4/1:‹/System{/tsd-tse}›] 6095  proposing SIMPLE(v2) ‹[(n2,s2):2]›: after=‹[(n1,s1):1 (n2,s2):2]› next=3
I210709 04:25:45.981122 88797 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r4/1:‹/System{/tsd-tse}›] 6096  change replicas (add ‹[(n3,s3):3LEARNER]› remove ‹[]›): existing descriptor r4:‹/System{/tsd-tse}› [(n1,s1):1, (n2,s2):2, next=3, gen=2]
I210709 04:25:46.129752 88797 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r4/1:‹/System{/tsd-tse}›] 6097  proposing SIMPLE(l3) ‹[(n3,s3):3LEARNER]›: after=‹[(n1,s1):1 (n2,s2):2 (n3,s3):3LEARNER]› next=4
I210709 04:25:46.256407 88931 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r4/1:‹/System{/tsd-tse}›] 6098  skipping snapshot; replica is likely a LEARNER in the process of being added: (n3,s3):3LEARNER
I210709 04:25:46.296666 88797 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r4/1:‹/System{/tsd-tse}›] 6099  streamed INITIAL snapshot ‹dcb39242› at applied index 61 to (n3,s3):3LEARNER in 0.04s @ ‹8.3 MiB›/s: ‹kv pairs: 2615, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.05s
I210709 04:25:47.052045 88797 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r4/1:‹/System{/tsd-tse}›] 6100  change replicas (add ‹[(n3,s3):3]› remove ‹[]›): existing descriptor r4:‹/System{/tsd-tse}› [(n1,s1):1, (n2,s2):2, (n3,s3):3LEARNER, next=4, gen=3]
I210709 04:25:47.219938 88797 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r4/1:‹/System{/tsd-tse}›] 6101  proposing SIMPLE(v3) ‹[(n3,s3):3]›: after=‹[(n1,s1):1 (n2,s2):2 (n3,s3):3]› next=4
I210709 04:25:47.310728 89014 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r23/1:‹/Table/2{7-8}›] 6102  change replicas (add ‹[(n3,s3):2LEARNER]› remove ‹[]›): existing descriptor r23:‹/Table/2{7-8}› [(n1,s1):1, next=2, gen=0]
I210709 04:25:47.441798 89014 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r23/1:‹/Table/2{7-8}›] 6103  proposing SIMPLE(l2) ‹[(n3,s3):2LEARNER]›: after=‹[(n1,s1):1 (n3,s3):2LEARNER]› next=3
I210709 04:25:47.631406 89030 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r23/1:‹/Table/2{7-8}›] 6104  skipping snapshot; replica is likely a LEARNER in the process of being added: (n3,s3):2LEARNER
I210709 04:25:47.631401 89014 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r23/1:‹/Table/2{7-8}›] 6105  streamed INITIAL snapshot ‹a4de25fa› at applied index 18 to (n3,s3):2LEARNER in 0.00s @ ‹9.3 MiB›/s: ‹kv pairs: 9, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.05s
I210709 04:25:47.949252 89014 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r23/1:‹/Table/2{7-8}›] 6106  change replicas (add ‹[(n3,s3):2]› remove ‹[]›): existing descriptor r23:‹/Table/2{7-8}› [(n1,s1):1, (n3,s3):2LEARNER, next=3, gen=1]
I210709 04:25:48.062525 89014 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r23/1:‹/Table/2{7-8}›] 6107  proposing SIMPLE(v2) ‹[(n3,s3):2]›: after=‹[(n1,s1):1 (n3,s3):2]› next=3
I210709 04:25:48.153538 89014 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r23/1:‹/Table/2{7-8}›] 6108  change replicas (add ‹[(n2,s2):3LEARNER]› remove ‹[]›): existing descriptor r23:‹/Table/2{7-8}› [(n1,s1):1, (n3,s3):2, next=3, gen=2]
I210709 04:25:48.342755 89014 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r23/1:‹/Table/2{7-8}›] 6109  proposing SIMPLE(l3) ‹[(n2,s2):3LEARNER]›: after=‹[(n1,s1):1 (n3,s3):2 (n2,s2):3LEARNER]› next=4
I210709 04:25:48.461374 89106 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r23/1:‹/Table/2{7-8}›] 6110  skipping snapshot; replica is likely a LEARNER in the process of being added: (n2,s2):3LEARNER
I210709 04:25:48.461390 89014 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r23/1:‹/Table/2{7-8}›] 6111  streamed INITIAL snapshot ‹5a8bc5e9› at applied index 23 to (n2,s2):3LEARNER in 0.00s @ ‹16 MiB›/s: ‹kv pairs: 13, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.08s
I210709 04:25:48.584336 89109 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r23/1:‹/Table/2{7-8}›] 6112  skipping snapshot; replica is likely a LEARNER in the process of being added: (n2,s2):3LEARNER
I210709 04:25:48.858732 89014 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r23/1:‹/Table/2{7-8}›] 6113  change replicas (add ‹[(n2,s2):3]› remove ‹[]›): existing descriptor r23:‹/Table/2{7-8}› [(n1,s1):1, (n3,s3):2, (n2,s2):3LEARNER, next=4, gen=3]
I210709 04:25:48.991390 89014 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r23/1:‹/Table/2{7-8}›] 6114  proposing SIMPLE(v3) ‹[(n2,s2):3]›: after=‹[(n1,s1):1 (n3,s3):2 (n2,s2):3]› next=4
I210709 04:25:49.157613 89172 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r30/1:‹/Table/3{4-5}›] 6115  change replicas (add ‹[(n2,s2):2LEARNER]› remove ‹[]›): existing descriptor r30:‹/Table/3{4-5}› [(n1,s1):1, next=2, gen=0]
I210709 04:25:49.290290 89172 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r30/1:‹/Table/3{4-5}›] 6116  proposing SIMPLE(l2) ‹[(n2,s2):2LEARNER]›: after=‹[(n1,s1):1 (n2,s2):2LEARNER]› next=3
I210709 04:25:49.437295 89178 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r30/1:‹/Table/3{4-5}›] 6117  skipping snapshot; replica is likely a LEARNER in the process of being added: (n2,s2):2LEARNER
I210709 04:25:49.437314 89172 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r30/1:‹/Table/3{4-5}›] 6118  streamed INITIAL snapshot ‹f4b77fe2› at applied index 18 to (n2,s2):2LEARNER in 0.00s @ ‹8.9 MiB›/s: ‹kv pairs: 9, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.05s
I210709 04:25:49.775333 89172 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r30/1:‹/Table/3{4-5}›] 6119  change replicas (add ‹[(n2,s2):2]› remove ‹[]›): existing descriptor r30:‹/Table/3{4-5}› [(n1,s1):1, (n2,s2):2LEARNER, next=3, gen=1]
I210709 04:25:49.884906 89172 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r30/1:‹/Table/3{4-5}›] 6120  proposing SIMPLE(v2) ‹[(n2,s2):2]›: after=‹[(n1,s1):1 (n2,s2):2]› next=3
I210709 04:25:49.886762 83971 2@server/status/runtime.go:569 ⋮ [n1] 6121  runtime stats: 132 MiB RSS, 349 goroutines (stacks: 6.2 MiB), 48 MiB/81 MiB Go alloc/total (heap fragmentation: 6.6 MiB, heap reserved: 6.6 MiB, heap released: 60 MiB), 11 MiB/16 MiB CGO alloc/total (0.7 CGO/sec), 5.5/4.3 %(u/s)time, 0.0 %gc (0x), 826 KiB/826 KiB (r/w)net
I210709 04:25:49.959677 89172 kv/kvserver/replica_command.go:2113 ⋮ [n1,replicate,s1,r30/1:‹/Table/3{4-5}›] 6122  change replicas (add ‹[(n3,s3):3LEARNER]› remove ‹[]›): existing descriptor r30:‹/Table/3{4-5}› [(n1,s1):1, (n2,s2):2, next=3, gen=2]
W210709 04:25:50.050577 83993 server/node.go:768 ⋮ [n1,summaries] 6123  health alerts detected: ‹{Alerts:[{StoreID:1 Category:METRICS Description:ranges.underreplicated Value:17}]}›
I210709 04:25:50.106824 89172 kv/kvserver/replica_raft.go:277 ⋮ [n1,s1,r30/1:‹/Table/3{4-5}›] 6124  proposing SIMPLE(l3) ‹[(n3,s3):3LEARNER]›: after=‹[(n1,s1):1 (n2,s2):2 (n3,s3):3LEARNER]› next=4
I210709 04:25:50.222336 89121 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r30/1:‹/Table/3{4-5}›] 6125  skipping snapshot; replica is likely a LEARNER in the process of being added: (n3,s3):3LEARNER
I210709 04:25:50.222432 89172 kv/kvserver/store_snapshot.go:1160 ⋮ [n1,replicate,s1,r30/1:‹/Table/3{4-5}›] 6126  streamed INITIAL snapshot ‹730deac9› at applied index 23 to (n3,s3):3LEARNER in 0.00s @ ‹9.0 MiB›/s: ‹kv pairs: 13, log entries: 0›, rate-limit: ‹8.0 MiB›/s, queued: 0.06s
I210709 04:25:50.299346 88992 kv/kvserver/raft_snapshot_queue.go:129 ⋮ [n1,raftsnapshot,s1,r30/1:‹/Table/3{4-5}›] 6127  skipping snapshot; replica is likely a LEARNER in the process of being added: (n3,s3):3LEARNER
^C
```

That's like around 400 lines of logs!! At some point I think it finally became a bit slower.

The next time I did after some time, it showed this

```bash
$ tail -f cockroach.log
I210709 04:27:09.851713 83728 2@gossip/gossip.go:567 ⋮ [n1] 6337  gossip status (ok, 3 node‹s›)
I210709 04:27:09.851713 83728 2@gossip/gossip.go:567 ⋮ [n1] 6337 +gossip client (1/3 cur/max conns)
I210709 04:27:09.851713 83728 2@gossip/gossip.go:567 ⋮ [n1] 6337 +  3: ‹localhost:26259› (1m59s: infos 505/147 sent/received, bytes 187391B/49036B sent/received)
I210709 04:27:09.851713 83728 2@gossip/gossip.go:567 ⋮ [n1] 6337 +gossip server (1/3 cur/max conns, infos 1050/294 sent/received, bytes 445767B/82741B sent/received)
I210709 04:27:09.851713 83728 2@gossip/gossip.go:567 ⋮ [n1] 6337 +  2: ‹localhost:26258› (1m59s)
I210709 04:27:09.875948 83971 2@server/status/runtime.go:569 ⋮ [n1] 6338  runtime stats: 144 MiB RSS, 346 goroutines (stacks: 6.3 MiB), 36 MiB/82 MiB Go alloc/total (heap fragmentation: 9.1 MiB, heap reserved: 17 MiB, heap released: 60 MiB), 20 MiB/25 MiB CGO alloc/total (0.6 CGO/sec), 3.9/4.1 %(u/s)time, 0.0 %gc (0x), 612 KiB/615 KiB (r/w)net
I210709 04:27:19.877371 83971 2@server/status/runtime.go:569 ⋮ [n1] 6339  runtime stats: 145 MiB RSS, 345 goroutines (stacks: 5.4 MiB), 30 MiB/82 MiB Go alloc/total (heap fragmentation: 12 MiB, heap reserved: 22 MiB, heap released: 60 MiB), 20 MiB/25 MiB CGO alloc/total (0.6 CGO/sec), 4.0/4.1 %(u/s)time, 0.0 %gc (0x), 694 KiB/868 KiB (r/w)net
I210709 04:27:29.951735 83971 2@server/status/runtime.go:569 ⋮ [n1] 6340  runtime stats: 146 MiB RSS, 345 goroutines (stacks: 6.3 MiB), 44 MiB/82 MiB Go alloc/total (heap fragmentation: 6.9 MiB, heap reserved: 11 MiB, heap released: 60 MiB), 20 MiB/25 MiB CGO alloc/total (0.6 CGO/sec), 3.7/4.1 %(u/s)time, 0.0 %gc (0x), 628 KiB/621 KiB (r/w)net
I210709 04:27:39.950285 83971 2@server/status/runtime.go:569 ⋮ [n1] 6341  runtime stats: 147 MiB RSS, 345 goroutines (stacks: 6.3 MiB), 37 MiB/82 MiB Go alloc/total (heap fragmentation: 8.4 MiB, heap reserved: 17 MiB, heap released: 60 MiB), 36 MiB/41 MiB CGO alloc/total (0.7 CGO/sec), 4.1/4.2 %(u/s)time, 0.0 %gc (0x), 636 KiB/637 KiB (r/w)net
I210709 04:27:49.949654 83971 2@server/status/runtime.go:569 ⋮ [n1] 6342  runtime stats: 148 MiB RSS, 346 goroutines (stacks: 7.0 MiB), 51 MiB/82 MiB Go alloc/total (heap fragmentation: 4.7 MiB, heap reserved: 5.4 MiB, heap released: 60 MiB), 36 MiB/41 MiB CGO alloc/total (0.6 CGO/sec), 3.3/3.7 %(u/s)time, 0.0 %gc (0x), 624 KiB/626 KiB (r/w)net
I210709 04:27:59.951363 83971 2@server/status/runtime.go:569 ⋮ [n1] 6343  runtime stats: 149 MiB RSS, 346 goroutines (stacks: 6.1 MiB), 44 MiB/82 MiB Go alloc/total (heap fragmentation: 8.1 MiB, heap reserved: 10 MiB, heap released: 59 MiB), 36 MiB/41 MiB CGO alloc/total (0.6 CGO/sec), 3.9/4.1 %(u/s)time, 0.0 %gc (0x), 621 KiB/624 KiB (r/w)net
```

It already has around 6.5 K log lines in total. Excluding the previous 4K of errors and what not, that's like 2K log lines in a few moments of `init`! Wow. Hmm

The guide asks me to `grep` the logs after `init`

```bash
$ grep 'node starting' node1/logs/cockroach.log -A 11
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +CockroachDB node starting at 2021-07-09 04:25:13.099347 +0000 UTC (took 6496.8s)
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +build:               CCL v21.1.5 @ 2021/07/02 04:00:15 (go1.15.11)
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +webui:               ‹http://localhost:8080›
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +sql:                 ‹postgresql://root@localhost:26257?sslmode=disable›
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +RPC client flags:    ‹cockroach <client cmd> --host=localhost:26257 --insecure›
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +logs:                ‹/Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff/node1/logs›
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +temp dir:            ‹/Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff/node1/cockroach-temp030044566›
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +external I/O path:   ‹/Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff/node1/extern›
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +store[0]:            ‹path=/Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff/node1›
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +storage engine:      pebble
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +status:              initialized new cluster
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +clusterID:           ‹fed66a44-872b-4ca2-ab75-c7821390fcec›
```

I modified that `grep` a bit to show a bit more after and before too

```bash
$ grep 'node starting' node1/logs/cockroach.log -A 13 -B 5
I210709 04:25:13.099317 29 1@server/server.go:2083 ⋮ [n1] 5877  serving sql connections
I210709 04:25:13.099303 84752 jobs/job_scheduler.go:360 ⋮ [n1] 5878  waiting 3m0s before scheduled jobs daemon start
I210709 04:25:13.099415 29 1@cli/start.go:676 ⋮ [config] 5879  clusterID: ‹fed66a44-872b-4ca2-ab75-c7821390fcec›
I210709 04:25:13.099430 29 1@cli/start.go:676 ⋮ [config] 5880  nodeID: n1
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881  node startup completed:
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +CockroachDB node starting at 2021-07-09 04:25:13.099347 +0000 UTC (took 6496.8s)
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +build:               CCL v21.1.5 @ 2021/07/02 04:00:15 (go1.15.11)
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +webui:               ‹http://localhost:8080›
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +sql:                 ‹postgresql://root@localhost:26257?sslmode=disable›
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +RPC client flags:    ‹cockroach <client cmd> --host=localhost:26257 --insecure›
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +logs:                ‹/Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff/node1/logs›
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +temp dir:            ‹/Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff/node1/cockroach-temp030044566›
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +external I/O path:   ‹/Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff/node1/extern›
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +store[0]:            ‹path=/Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff/node1›
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +storage engine:      pebble
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +status:              initialized new cluster
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +clusterID:           ‹fed66a44-872b-4ca2-ab75-c7821390fcec›
I210709 04:25:13.099452 29 1@cli/start.go:686 ⋮ [-] 5881 +nodeID:              1
I210709 04:25:13.104992 85362 server/auto_upgrade.go:55 ⋮ [n1] 5882  no need to upgrade, cluster already at the newest version
```

I think I'm going to try the built-in SQL client later

https://www.cockroachlabs.com/docs/v21.1/start-a-local-cluster#step-2-use-the-built-in-sql-client

I need to stop all the nodes though! I forgot about that! Haha

I think I can keep the node data locally though. Previously I was planning on getting rid of everything. But then I'll start from scratch later - which is okay, as there's not much steps to follow. But still, it will be interesting to see the nodes stop and then start back again and how the logs look etc ;) Unlike a brand new set of nodes and a new cluster

I was looking at how to stop the nodes. I couldn't find any commands named "stop", hmm

```bash
$ cockroach
CockroachDB command-line interface and server.

Usage:
  cockroach [command]

Available Commands:
  start             start a node in a multi-node cluster
  start-single-node start a single-node cluster
  connect           auto-build TLS certificates for use with the start command
  init              initialize a cluster
  cert              create ca, node, and client certs
  sql               open a sql shell
  statement-diag    commands for managing statement diagnostics bundles
  auth-session      log in and out of HTTP sessions
  node              list, inspect, drain or remove nodes

  nodelocal         upload and delete nodelocal files
  userfile          upload, list and delete user scoped files
  import            import a db or table from a local PGDUMP or MYSQLDUMP file
  demo              open a demo sql shell
  gen               generate auxiliary files
  version           output version information
  debug             debugging commands
  sqlfmt            format SQL statements
  workload          generators for data and query loads
  systembench       Run systembench
  load              loading commands
  help              Help about any command

Flags:
  -h, --help                     help for cockroach
      --log <string>
                                  Logging configuration, expressed using YAML syntax. For example, you can
                                  change the default logging directory with: --log='file-defaults: {dir: ...}'.
                                  See the documentation for more options and details.  To preview how the log
                                  configuration is applied, or preview the default configuration, you can use
                                  the 'cockroach debug check-log-config' sub-command.

      --log-config-file <file>
                                  File name to read the logging configuration from. This has the same effect as
                                  passing the content of the file via the --log flag.
                                  (default <unset>)
      --vmodule moduleSpec       comma-separated list of pattern=N settings for file-filtered logging (significantly hurts performance)

Use "cockroach [command] --help" for more information about a command.
```

There was some `node` command, so I thought I could do some node stuff there

```bash
$ cockroach node
Usage:
  cockroach node [command] [flags]
  cockroach node [command]

Available Commands:
  ls           lists the IDs of all nodes in the cluster
  status       shows the status of a node or all nodes
  decommission decommissions the node(s)
  recommission recommissions the node(s)
  drain        drain a node without shutting it down

Flags:
  -h, --help   help for node

Global Flags:
      --log <string>
                                  Logging configuration, expressed using YAML syntax. For example, you can
                                  change the default logging directory with: --log='file-defaults: {dir: ...}'.
                                  See the documentation for more options and details.  To preview how the log
                                  configuration is applied, or preview the default configuration, you can use
                                  the 'cockroach debug check-log-config' sub-command.

      --log-config-file <file>
                                  File name to read the logging configuration from. This has the same effect as
                                  passing the content of the file via the --log flag.
                                  (default <unset>)
      --vmodule moduleSpec       comma-separated list of pattern=N settings for file-filtered logging (significantly hurts performance)

Use "cockroach node [command] --help" for more information about a command.
ERROR: unknown sub-command: ""
Failed running "node"
```

I mean, I guess I could just go and kill the processes using `ps aux | grep cockroach` or something like that. I was wondering if it will be graceful etc. Also, sometimes I kill processes forcefully with `kill -9` if I can't kill them just with `kill` and it can get very messy apparently, since it's abrupt. So, just checking out what's the general way

I noticed the `decommission` command under `node`. That looked nice, so I tried that out

```bash
$ cockroach node decommission
ERROR: no node ID specified; use --self to target the node specified with --host
Failed running "node decommission"

$ cockroach node decommission -h

Marks the nodes with the supplied IDs as decommissioning.
This will cause leases and replicas to be removed from these nodes.

Usage:
  cockroach node decommission { --self | <node id 1> [<node id 2> ...] } [flags]

Flags:
      --cert-principal-map strings
                                             A comma separated list of <cert-principal>:<db-principal> mappings. This
                                             allows mapping the principal in a cert to a DB principal such as "node" or
                                             "root" or any SQL user. This is intended for use in situations where the
                                             certificate management system places restrictions on the Subject.CommonName or
                                             SubjectAlternateName fields in the certificate (e.g. disallowing a CommonName
                                             such as "node" or "root"). If multiple mappings are provided for the same
                                             <cert-principal>, the last one specified in the list takes precedence. A
                                             principal not specified in the map is passed through as-is via the identity
                                             function. A cert is allowed to authenticate a DB principal if the DB principal
                                             name is contained in the mapped CommonName or DNS-type SubjectAlternateName
                                             fields.

      --certs-dir string
                                             Path to the directory containing SSL certificates and keys.
                                             Environment variable: COCKROACH_CERTS_DIR
                                             (default "${HOME}/.cockroach-certs")
      --cluster-name <identifier>
                                             Sets a name to verify the identity of a remote node or cluster. The value must
                                             match between this node and the remote node(s) specified via --join.

                                             This can be used as an additional verification when either the node or
                                             cluster, or both, have not yet been initialized and do not yet know their
                                             cluster ID.

                                             To introduce a cluster name into an already-initialized cluster, pair this
                                             flag with --disable-cluster-name-verification.

      --disable-cluster-name-verification
                                             Tell the server to ignore cluster name mismatches. This is meant for use when
                                             opting an existing cluster into starting to use cluster name verification, or
                                             when changing the cluster name.

                                             The cluster should be restarted once with --cluster-name and
                                             --disable-cluster-name-verification combined, and once all nodes have been
                                             updated to know the new cluster name, the cluster can be restarted again with
                                             this flag removed.

      --format string
                                             Selects how to display table rows in results. Possible values: tsv, csv,
                                             table, records, sql, raw, html. If left unspecified, defaults to tsv for
                                             non-interactive sessions and table for interactive sessions.
                                             (default "table")
  -h, --help                                help for decommission
      --host <addr/host>[:<port>]
                                             CockroachDB node to connect to. This can be specified either as an
                                             address/hostname, or together with a port number as in -s myhost:26257. If
                                             the port number is left unspecified, it defaults to 26257. An IPv6 address
                                             can also be specified with the notation [...], for example [::1]:26257 or
                                             [fe80::f6f2:::]:26257.
                                             Environment variable: COCKROACH_HOST
                                             (default :26257)
      --insecure
                                             Connect to a cluster without using TLS nor authentication. This makes the
                                             client-server connection vulnerable to MITM attacks. Use with care.
                                             Environment variable: COCKROACH_INSECURE

      --self
                                             Use the node ID of the node connected to via --host as target of the
                                             decommissioning or recommissioning command.

      --url <postgres://...>
                                             Connection URL, of the form:
                                                postgresql://[user[:passwd]@]host[:port]/[db][?parameters...]
                                             For example, postgresql://myuser@localhost:26257/mydb.

                                             If left empty, the discrete connection flags are used: host, port, user,
                                             database, insecure, certs-dir.
                                             Environment variable: COCKROACH_URL

      --wait string
                                             Specifies when to return during the decommissioning process. Takes any of the
                                             following values:

                                               - all   waits until all target nodes\' replica counts have dropped to zero and
                                                       marks the nodes as fully decommissioned. This is the default.
                                               - none  marks the targets as decommissioning, but does not wait for the
                                                       replica counts to drop to zero before returning. If the replica counts
                                                       are found to be zero, nodes are marked as fully decommissioned. Use
                                                       when polling manually from an external system.

                                             (default "all")

Global Flags:
      --log <string>
                                  Logging configuration, expressed using YAML syntax. For example, you can
                                  change the default logging directory with: --log='file-defaults: {dir: ...}'.
                                  See the documentation for more options and details.  To preview how the log
                                  configuration is applied, or preview the default configuration, you can use
                                  the 'cockroach debug check-log-config' sub-command.

      --log-config-file <file>
                                  File name to read the logging configuration from. This has the same effect as
                                  passing the content of the file via the --log flag.
                                  (default <unset>)
      --vmodule moduleSpec       comma-separated list of pattern=N settings for file-filtered logging (significantly hurts performance)
```

Damn, I just found out from the guide on how to stop the cluster

https://www.cockroachlabs.com/docs/v21.1/start-a-local-cluster#step-7-stop-the-cluster

I was looking for `stop` or something but I guess I could have read all the sub commands, lol. Impatiently
searching for `stop` didn't help :P

Wierdly, `quit` doesn't show up in the `cockroach` help

```bash
$ cockroach | rg quit
```

Hmm, interesting

```bash
$ cockroach quit
Command "quit" is deprecated, see 'cockroach node drain' instead to drain a
server without terminating the server process (which can in turn be done using
an orchestration layer or a process manager, or by sending a termination signal
directly).
ERROR: cannot load certificates.
Check your certificate settings, set --certs-dir, or use --insecure for insecure clusters.

failed to connect to the node: problem using security settings: no certificates found; does certs dir exist?
Failed running "quit"
```

Ah, it's deprecated, okay

So, they ask us to drain the server. Hmm. Drain still sounds like - drain out the data to other servers / move out the data to other servers, so that this server can be killed, or upgraded or do some similar maintenance stuff. Hmm

I'm just going to quit it I guess, let's see how it works

```bash
$ cockroach quit -h
Command "quit" is deprecated, see 'cockroach node drain' instead to drain a
server without terminating the server process (which can in turn be done using
an orchestration layer or a process manager, or by sending a termination signal
directly).

Shut down the server. The first stage is drain, where the server stops accepting
client connections, then stops extant connections, and finally pushes range
leases onto other nodes, subject to various timeout parameters configurable via
cluster settings. After the first stage completes, the server process is shut
down.

Usage:
  cockroach quit [flags]

Flags:
      --cert-principal-map strings
                                             A comma separated list of <cert-principal>:<db-principal> mappings. This
                                             allows mapping the principal in a cert to a DB principal such as "node" or
                                             "root" or any SQL user. This is intended for use in situations where the
                                             certificate management system places restrictions on the Subject.CommonName or
                                             SubjectAlternateName fields in the certificate (e.g. disallowing a CommonName
                                             such as "node" or "root"). If multiple mappings are provided for the same
                                             <cert-principal>, the last one specified in the list takes precedence. A
                                             principal not specified in the map is passed through as-is via the identity
                                             function. A cert is allowed to authenticate a DB principal if the DB principal
                                             name is contained in the mapped CommonName or DNS-type SubjectAlternateName
                                             fields.

      --certs-dir string
                                             Path to the directory containing SSL certificates and keys.
                                             Environment variable: COCKROACH_CERTS_DIR
                                             (default "${HOME}/.cockroach-certs")
      --cluster-name <identifier>
                                             Sets a name to verify the identity of a remote node or cluster. The value must
                                             match between this node and the remote node(s) specified via --join.

                                             This can be used as an additional verification when either the node or
                                             cluster, or both, have not yet been initialized and do not yet know their
                                             cluster ID.

                                             To introduce a cluster name into an already-initialized cluster, pair this
                                             flag with --disable-cluster-name-verification.

      --disable-cluster-name-verification
                                             Tell the server to ignore cluster name mismatches. This is meant for use when
                                             opting an existing cluster into starting to use cluster name verification, or
                                             when changing the cluster name.

                                             The cluster should be restarted once with --cluster-name and
                                             --disable-cluster-name-verification combined, and once all nodes have been
                                             updated to know the new cluster name, the cluster can be restarted again with
                                             this flag removed.

      --drain-wait duration
                                             When non-zero, wait for at most the specified amount of time for the node to
                                             drain all active client connections and migrate away range leases. If zero,
                                             the command waits until the last client has disconnected and all range leases
                                             have been migrated away.
                                             (default 10m0s)
  -h, --help                                help for quit
      --host <addr/host>[:<port>]
                                             CockroachDB node to connect to. This can be specified either as an
                                             address/hostname, or together with a port number as in -s myhost:26257. If
                                             the port number is left unspecified, it defaults to 26257. An IPv6 address
                                             can also be specified with the notation [...], for example [::1]:26257 or
                                             [fe80::f6f2:::]:26257.
                                             Environment variable: COCKROACH_HOST
                                             (default :26257)
      --insecure
                                             Connect to a cluster without using TLS nor authentication. This makes the
                                             client-server connection vulnerable to MITM attacks. Use with care.
                                             Environment variable: COCKROACH_INSECURE

      --url <postgres://...>
                                             Connection URL, of the form:
                                                postgresql://[user[:passwd]@]host[:port]/[db][?parameters...]
                                             For example, postgresql://myuser@localhost:26257/mydb.

                                             If left empty, the discrete connection flags are used: host, port, user,
                                             database, insecure, certs-dir.
                                             Environment variable: COCKROACH_URL

Global Flags:
      --log <string>
                                  Logging configuration, expressed using YAML syntax. For example, you can
                                  change the default logging directory with: --log='file-defaults: {dir: ...}'.
                                  See the documentation for more options and details.  To preview how the log
                                  configuration is applied, or preview the default configuration, you can use
                                  the 'cockroach debug check-log-config' sub-command.

      --log-config-file <file>
                                  File name to read the logging configuration from. This has the same effect as
                                  passing the content of the file via the --log flag.
                                  (default <unset>)
      --vmodule moduleSpec       comma-separated list of pattern=N settings for file-filtered logging (significantly hurts performance)
```

The guide says I can gracefully shut down the node with `quit`

```
When you're done with your test cluster, use the cockroach quit command to gracefully shut down each node.
```

Looks like there's a note about the process of quitting

```
Note:

For the last 2 nodes, the shutdown process will take longer (about a minute each) and will eventually force the nodes to stop. This is because, with only 2 of 5 nodes left, a majority of replicas are not available, and so the cluster is no longer operational.
```

I think there's a step to scale the nodes from 3 to 5 nodes. I still have only 3. But looks like when the majority goes down, the cluster is not operational, hmm, makes sense if it's quorum and stuff I guess? Not sure. In my case, out of 3, majority is (3/2) + 1 = 1 + 1 = 2. So, my third node is taking a lot of time to shutdown but apparently it will be shutdown just a bit later

```bash
$ cockroach quit --insecure --host=localhost:26257
Command "quit" is deprecated, see 'cockroach node drain' instead to drain a
server without terminating the server process (which can in turn be done using
an orchestration layer or a process manager, or by sending a termination signal
directly).
node is draining... remaining: 21
node is draining... remaining: 0 (complete)
ok

$ cockroach quit --insecure --host=localhost:26258
Command "quit" is deprecated, see 'cockroach node drain' instead to drain a
server without terminating the server process (which can in turn be done using
an orchestration layer or a process manager, or by sending a termination signal
directly).
node is draining... remaining: 14
node is draining... remaining: 0 (complete)
ok

$ cockroach quit --insecure --host=localhost:26259
Command "quit" is deprecated, see 'cockroach node drain' instead to drain a
server without terminating the server process (which can in turn be done using
an orchestration layer or a process manager, or by sending a termination signal
directly).
node is draining...
```

Currently it's stuck trying to drain the last node

Let's see if it stops at all, hmm

Also, I can start the nodes later it seems. The guide says

```
To restart the cluster at a later time, run the same cockroach start commands as earlier from the directory containing the nodes' data stores.

If you do not plan to restart the cluster, you may want to remove the nodes' data stores
```

So I just need to run `start` command. Makes sense! :)

The node3 didn't shutdown at all actually. It was just stuck. I tried to use `kill`

```bash
$ ps aux | rg cockroach
karuppiahn        7656   8.4  0.5  5538868 173436 s000  S     8:24AM   7:36.97 cockroach start --insecure --store=node3 --listen-addr=localhost:26259 --http-addr=localhost:8082 --join=localhost:26257,localhost:26258,localhost:26259
karuppiahn       30433   0.0  0.0  4265112    300 s000  R+   11:35AM   0:00.00 rg cockroach
$ kill 7656
$ initiating graceful shutdown of server
```

Note how it says "initiating graceful shutdown of server"

Even the guide mentioned that the server is not fully detached from the terminal / shell, so I guess the log makes sense

But then the process still exits, even though the log contains the shutdown message and there are lots of messages after that too, haha

```bash
$ rg shutdown node3/logs/cockroach.log
5209:I210709 04:47:41.690426 167982 1@server/drain.go:57 ⋮ [n3] 5034  drain request received with doDrain = true, shutdown = false
7351:I210709 05:20:31.827262 187510 1@server/drain.go:57 ⋮ [n3] 5896  drain request received with doDrain = true, shutdown = false
8113:I210709 06:05:10.230388 194232 1@server/drain.go:57 ⋮ [n3] 6247  drain request received with doDrain = true, shutdown = false
8246:I210709 06:05:47.583957 1 1@cli/start.go:821 ⋮ [-] 6297  initiating graceful shutdown of server
8458:I210709 06:06:44.436890 1 1@cli/start.go:859 ⋮ [-] 6399  received additional signal 'terminated'; continuing graceful shutdown
8511:I210709 06:06:57.805543 1 1@cli/start.go:859 ⋮ [-] 6425  received additional signal 'terminated'; continuing graceful shutdown
```

I finally killed it with `SIGKILL` signal instead of the default `SIGTERM`

```bash
$ kill -9 7656
$ ps aux | rg cockroach
karuppiahn       32151   0.0  0.0  4265112    212 s000  R+   11:40AM   0:00.00 rg cockroach
```
