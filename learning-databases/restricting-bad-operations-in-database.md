Restricting bad operations in Database

For example, in Redis - `DELETE` and `KEYS` are bad commands. Instead the `UNLINK` and `SCAN` alternatives are recommended for production usage. It's best to restrict such command usage from server side. There are some clients which help with this too but best to restrict at server side for once and for all

Another example is in classic databases - DROP database, DROP table, TRUNCATE table etc. Ideally such commands have to be restricted at server side even if clients - programs / human users run such commands by mistake, for example, by assuming they are running against staging database but in fact are running it against production database
