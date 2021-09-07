
When learning about indices, I was thinking about how to store the data in the disk etc and how one needs to create a data structure to work with the data, for example a structure for the record and some sort of B Tree or B+ Tree or similar Tree structures, let's say for relational databases

Come to think of it, this is something that happens only in schema based databases I guess, where one needs to define the schema before doing anything. "Data Definition Language (DDL)" or more like language to define the data - the schema of the data and more, like primary key, indices etc

I was wondering how when we write code, the data structure is defined and static, like some `map` or `struct` in Golang. But, in schema based databases like Postgres, users create the table, their own custom table, define it with columns and what not, with each column with a data type and then use the table to store the data. So I was wondering how I can code the database with a predefined data structure, say a B Tree with keys and children and records, where record data is not known before hand and is something defined by the user at runtime

I was wondering if we need to do some meta programming or something, or do some crazy stuff for creating data structures at runtime and working with them. Pretty crazy thing!
