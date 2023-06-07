# TypeID SQL
### A SQL implementation of [TypeID](https://github.com/jetpack-io/typeid) using PostgresSQL.
![License: Apache 2.0](https://img.shields.io/github/license/jetpack-io/typeid-sql)

TypeIDs are a modern, **type-safe**, globally unique identifier based on the upcoming
UUIDv7 standard. They provide a ton of nice properties that make them a great choice
as the primary identifiers for your data in a database, APIs, and distributed systems.
Read more about TypeIDs in their [spec](https://github.com/jetpack-io/typeid).

This particular implementation demonstrates how to use TypeIDs in a postgres database.

## Future work (contributions welcome)
- Include examples not just for Postgres, but for other databases like MySQL as well.
- Consider packaging this library as a postgres extension that can be easily installed
  and used in a database.