# Getting started with Cockroach DB

https://www.cockroachlabs.com/

https://www.cockroachlabs.com/get-started-cockroachdb/

https://www.cockroachlabs.com/docs/stable/install-cockroachdb.html

https://www.cockroachlabs.com/docs/stable/install-cockroachdb-mac.html

https://www.cockroachlabs.com/docs/stable/install-cockroachdb-mac.html#use-homebrew-1

```bash
$ brew install cockroachdb/tap/cockroach
Updating Homebrew...
==> Auto-updated Homebrew!
Updated 2 taps (homebrew/core and homebrew/cask).
==> New Formulae
clarinet                               graphqurl                              ncc
==> Updated Formulae
Updated 352 formulae.
==> New Casks
pulse                                                      sleek
==> Updated Casks
Updated 39 casks.

==> Tapping cockroachdb/tap
Cloning into '/usr/local/Homebrew/Library/Taps/cockroachdb/homebrew-tap'...
remote: Enumerating objects: 338, done.
remote: Counting objects: 100% (85/85), done.
remote: Compressing objects: 100% (51/51), done.
remote: Total 338 (delta 33), reused 51 (delta 17), pack-reused 253
Receiving objects: 100% (338/338), 76.96 KiB | 1.33 MiB/s, done.
Resolving deltas: 100% (118/118), done.
Tapped 1 formula (15 files, 108.0KB).
==> Installing cockroach from cockroachdb/tap
==> Downloading https://binaries.cockroachdb.com/cockroach-v21.1.5.darwin-10.9-amd64.tgz
######################################################################## 100.0%
==> install_name_tool -id /usr/local/Cellar/cockroach/21.1.5/lib/cockroach/libgeos.dylib /usr/local/Cellar/cockroach/
==> install_name_tool -id /usr/local/Cellar/cockroach/21.1.5/lib/cockroach/libgeos_c.1.dylib /usr/local/Cellar/cockro
==> install_name_tool -change @rpath/libgeos.3.8.1.dylib /usr/local/Cellar/cockroach/21.1.5/lib/cockroach/libgeos.dyl
==> /usr/local/Cellar/cockroach/21.1.5/bin/cockroach gen man --path=/usr/local/Cellar/cockroach/21.1.5/share/man/man1
==> /usr/local/Cellar/cockroach/21.1.5/bin/cockroach gen autocomplete bash --out=/usr/local/Cellar/cockroach/21.1.5/e
==> /usr/local/Cellar/cockroach/21.1.5/bin/cockroach gen autocomplete zsh --out=/usr/local/Cellar/cockroach/21.1.5/sh
==> Caveats
For local development only, this formula ships a launchd configuration to
start a single-node cluster that stores its data under:
  /usr/local/var/cockroach/
Instead of the default port of 8080, the node serves its admin UI at:
  http://localhost:26256

Do NOT use this cluster to store data you care about; it runs in insecure
mode and may expose data publicly in e.g. a DNS rebinding attack. To run
CockroachDB securely, please see:
  https://www.cockroachlabs.com/docs/stable/secure-a-cluster.html

Bash completion has been installed to:
  /usr/local/etc/bash_completion.d

To have launchd start cockroachdb/tap/cockroach now and restart at login:
  brew services start cockroachdb/tap/cockroach
Or, if you dont want/need a background service you can just run:
  cockroach start-single-node --insecure --http-port=26256 --host=localhost
==> Summary
🍺  /usr/local/Cellar/cockroach/21.1.5: 146 files, 167.4MB, built in 6 seconds
```

Looks like there are other ways to install too, like with binary

https://www.cockroachlabs.com/docs/stable/install-cockroachdb-mac.html#download-the-binary-1

Cockroach commands are here, hmm -

https://www.cockroachlabs.com/docs/v21.1/cockroach-commands

And it seems Cockroach DB supports storing and querying spatial data - geo data - latitudes and longitudes
and stuff

https://www.cockroachlabs.com/docs/v21.1/spatial-features

It uses GEOS library it seems, which is also used by PostGIS Postgres extension

https://www.cockroachlabs.com/docs/v21.1/spatial-glossary#geos

https://trac.osgeo.org/geos/ GEOS - Geometry Engine Open Source. Nice!

There's a demo command

https://www.cockroachlabs.com/docs/v21.1/cockroach-demo

It says

```
Warning:

cockroach demo is designed for testing purposes only. It is not suitable for production deployments. To see a list of recommendations for production deployments, see the Production Checklist. 
```

production checklist - https://www.cockroachlabs.com/docs/v21.1/recommended-production-settings

So, with cockroach demo -

```bash
karuppiahn-a01:database-stuff karuppiahn$ cockroach demo
#
# Welcome to the CockroachDB demo database!
#
# You are connected to a temporary, in-memory CockroachDB cluster of 1 node.
#
# This demo session will attempt to enable enterprise features
# by acquiring a temporary license from Cockroach Labs in the background.
# To disable this behavior, set the environment variable
# COCKROACH_SKIP_ENABLING_DIAGNOSTIC_REPORTING=true.
#
# Beginning initialization of the movr dataset, please wait...
#
# The cluster has been preloaded with the "movr" dataset
# (MovR is a fictional vehicle sharing company).
#
# Reminder: your changes to data stored in the demo session will not be saved!
#
# If you wish to access this demo cluster using another tool, you will need
# the following details:
#
#   - Connection parameters:
#     (webui)    http://127.0.0.1:8080/demologin?password=demo82954&username=demo
#     (sql)      postgres://demo:demo82954@127.0.0.1:26257?sslmode=require
#     (sql/unix) postgres://demo:demo82954@?host=%2Fvar%2Ffolders%2F4z%2F09jpfvfj6c19lxl7ch78pzvc0000gn%2FT%2Fdemo670084497&port=26257
#   
#   - Username: "demo", password: "demo82954"
#   - Directory with certificate files (for certain SQL drivers/tools): /var/folders/4z/09jpfvfj6c19lxl7ch78pzvc0000gn/T/demo670084497
#
# Server version: CockroachDB CCL v21.1.5 (x86_64-apple-darwin19, built 2021/07/02 04:00:15, go1.15.11) (same version as client)
# Cluster ID: fad0f8bc-80d8-4e7b-a299-ee6cf92edbf1
#
# Enter \? for a brief introduction.
#
demo@127.0.0.1:26257/movr> \?
You are using 'cockroach sql', CockroachDB\'s lightweight SQL client.
General
  \q, quit, exit    exit the shell (Ctrl+C/Ctrl+D also supported).

Help
  \? or "help"      print this help.
  \h [NAME]         help on syntax of SQL commands.
  \hf [NAME]        help on SQL built-in functions.

Query Buffer
  \p                during a multi-line statement, show the SQL entered so far.
  \r                during a multi-line statement, erase all the SQL entered so far.
  \| CMD            run an external command and run its output as SQL statements.

Connection
  \c, \connect [DB] connect to a new database

Input/Output
  \echo [STRING]    write the provided string to standard output.
  \i                execute commands from the specified file.
  \ir               as \i, but relative to the location of the current script.

Informational
  \l                list all databases in the CockroachDB cluster.
  \dt               show the tables of the current schema in the current database.
  \dT               show the user defined types of the current database.
  \du               list the users for all databases.
  \d [TABLE]        show details about columns in the specified table, or alias for '\dt' if no table is specified.

Formatting
  \x [on|off]       toggle records display format.

Operating System
  \! CMD            run an external command and print its results on standard output.

Configuration
  \set [NAME]       set a client-side flag or (without argument) print the current settings.
  \unset NAME       unset a flag.


Commands specific to the demo shell (EXPERIMENTAL):
  \demo ls                     list the demo nodes and their connection URLs.
  \demo shutdown <nodeid>      stop a demo node.
  \demo restart <nodeid>       restart a stopped demo node.
  \demo decommission <nodeid>  decommission a node.
  \demo recommission <nodeid>  recommission a node.
  \demo add <locality>         add a node (locality specified as "region=<region>,zone=<zone>").

More documentation about our SQL dialect and the CLI shell is available online:
https://www.cockroachlabs.com/docs/v21.1/sql-statements.html
https://www.cockroachlabs.com/docs/v21.1/use-the-built-in-sql-client.html
demo@127.0.0.1:26257/movr> 
demo@127.0.0.1:26257/movr> \dt
  schema_name |         table_name         | type  | owner | estimated_row_count | locality
--------------+----------------------------+-------+-------+---------------------+-----------
  public      | promo_codes                | table | demo  |                1000 | NULL
  public      | rides                      | table | demo  |                 500 | NULL
  public      | user_promo_codes           | table | demo  |                   0 | NULL
  public      | users                      | table | demo  |                  50 | NULL
  public      | vehicle_location_histories | table | demo  |                1000 | NULL
  public      | vehicles                   | table | demo  |                  15 | NULL
(6 rows)

Time: 14ms total (execution 14ms / network 0ms)

demo@127.0.0.1:26257/movr> SELECT ST_IsValid(ST_MakePoint(1,2));
  st_isvalid
--------------
     true
(1 row)

Time: 1ms total (execution 1ms / network 0ms)

demo@127.0.0.1:26257/movr> 
```

That was interesting :D There was a temporary Enterprise license in the demo cluster! It works for an hour it
seems. And it's all demo it seems - goes away (poof!) once the shell exits. Also, interface similar to `psql` CLI for
Postgres!! :D

There's also instructions on how to make it work in Kubernetes

https://www.cockroachlabs.com/docs/stable/install-cockroachdb-mac.html#use-kubernetes-1

Docker -

https://www.cockroachlabs.com/docs/stable/install-cockroachdb-mac.html#use-docker-1

And also from source :D

https://www.cockroachlabs.com/docs/stable/install-cockroachdb-mac.html#build-from-source-1

They say we need 2-4 GB of RAM for build and running test suite. Interesting! :D Not so high. Hmm

There's a what's next, hmm

https://www.cockroachlabs.com/docs/stable/install-cockroachdb-mac.html#whats-next

I was simply checking out the dummy data loaded into the demo DB in the SQL CLI client

```bash
demo@127.0.0.1:26257/movr> \dt
  schema_name |         table_name         | type  | owner | estimated_row_count | locality
--------------+----------------------------+-------+-------+---------------------+-----------
  public      | promo_codes                | table | demo  |                1000 | NULL
  public      | rides                      | table | demo  |                 500 | NULL
  public      | user_promo_codes           | table | demo  |                   0 | NULL
  public      | users                      | table | demo  |                  50 | NULL
  public      | vehicle_location_histories | table | demo  |                1000 | NULL
  public      | vehicles                   | table | demo  |                  15 | NULL
(6 rows)

Time: 11ms total (execution 10ms / network 0ms)

demo@127.0.0.1:26257/movr> 
demo@127.0.0.1:26257/movr> select count(*)
                        -> from promo_codes;
  count
---------
   1000
(1 row)

Time: 1ms total (execution 1ms / network 0ms)

demo@127.0.0.1:26257/movr> select count(*) from rides;
  count
---------
    500
(1 row)

Time: 1ms total (execution 1ms / network 0ms)

demo@127.0.0.1:26257/movr> select count(*) from user_promo_codes;
  count
---------
      0
(1 row)

Time: 1ms total (execution 1ms / network 0ms)

demo@127.0.0.1:26257/movr> select count(*) from users;
  count
---------
     50
(1 row)

Time: 1ms total (execution 1ms / network 0ms)

demo@127.0.0.1:26257/movr> select count(*) from vehicle_location_histories;
  count
---------
   1000
(1 row)

Time: 1ms total (execution 1ms / network 0ms)

demo@127.0.0.1:26257/movr> select count(*) from vehicles;
  count
---------
     15
(1 row)

Time: 1ms total (execution 1ms / network 0ms)

demo@127.0.0.1:26257/movr> 
```

I'll probably try more SQL commands with more data later. I'm going to continue with the

https://www.cockroachlabs.com/docs/stable/install-cockroachdb-mac.html#whats-next

And checkout running a [local cluster](./local-cluster.md) - https://www.cockroachlabs.com/docs/v21.1/start-a-local-cluster
