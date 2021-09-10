
Implement an existing database or parts of an existing database from scratch or from other projects. Some examples for existing databases that I can try to implement -
- Redis
- Splinter DB. This is pretty new, it's a research paper and there seems to one implementation for now
- Bolt DB
- PostgreSQL
- MySQL
- MongoDB

This will help learn database topics behind the features of the database

Implementation language could be: Golang / C / C++ / Rust language

Things I can learn by practicing
- Tables and Indexes - data structures that one can use to store them on memory and disk
- Storage - disk access - reading and writing to the disk
- Networking for a database with client-server architecture

---

# Simple relational database

With following features
- Ability to store a table with only one primary key column and a few other columns like name, interests. Column types can be integer and string. No defined constraints on the size as of now, whatever works and is easy
- Ability to retrieve the table - complete and parts of the table using a simple query. Parts / single records using primary key

Things I'll learn from this
- How to create a simple query language, parse it, process it
- How to store data in the disk
- How to use indexes to search the disk fast
- I can try to do benchmark testing to see how the database performs in terms of data insertion, deletion and data search when there's a LOT of data

---

# Simple B Tree implementation

Extension
- Store the tree on disk. User configurable option

---

# Simple B+ Tree implementation

Extension
- Store the tree on disk. User configurable option.

---

# Simple in-memory key value store

- With keys and values as strings

---

# Simple key value store

- With keys and values as strings
- In-memory store or persisted on disk - user can choose

---

# Implement WiscKey

WiscKey is a research paper - https://www.usenix.org/system/files/conference/fast16/fast16-papers-lu.pdf

---

# Host and run a database meetup

- To learn database concepts in a deep dive, with hands on practical stuff and workshops too
- Pros and Cons kind of talks
- Discussing research papers and blog posts by companies
- Discussing and implementing a database from scratch over a few weeks!

Why? To learn databases for free and for fun

What platform to host it on? meetup.com ? Twitter? No need for registrations etc though, because in online there's usually not much operations to take care of, except in workshops maybe in case we need more folks to help people during the workshop or hands on sessions, then number of helpers would depend on the size of the audience

A simple google calendar? But we need a forum for questions etc. Discord? Discourse? Slack? Hmm. Also, Instagram? Facebook? TikTok? :P We will see, in case I host it! Not to mention, YouTube, Twitch, Zoom? Microsoft Teams, Google Meet etc? To help with the virtual sessions. I can't think of any physical sessions for now. Also, virtual means, we can go global easily, but yeah, timezones are still a problem

---

# Implement a LSM Tree

Log Structured Merge Tree

---

# Implement a QUIC client and server

Use existing QUIC libraries for creating the client and server 

---

# Implement a gRPC client and server with HTTP v3

HTTP v3 or HTTP/3 uses QUIC protocol

---

# Visualizations for different concepts and algorithms

- B Trees
- B+ Trees
- QUIC
- LSM Trees
