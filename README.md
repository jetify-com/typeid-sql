# TypeID SQL
### A SQL implementation of [TypeID](https://github.com/jetpack-io/typeid) using PostgresSQL.
![License: Apache 2.0](https://img.shields.io/github/license/jetpack-io/typeid-sql)

TypeIDs are a modern, **type-safe**, globally unique identifier based on the upcoming
UUIDv7 standard. They provide a ton of nice properties that make them a great choice
as the primary identifiers for your data in a database, APIs, and distributed systems.
Read more about TypeIDs in their [spec](https://github.com/jetpack-io/typeid).

This particular implementation demonstrates how to use TypeIDs in a postgres database.

## Installation
To use typeids in your Postgres instance, you'll need define all the
appropriate types and functions by running the SQL scripts in this repo.

We recommend copying the SQL scripts into your migrations directory and using the
migration tool of your choice. For example, [Flyway](https://flywaydb.org/), or
[Liquibase](https://www.liquibase.org/).

Noe that this repo is using Supabase as a way to easily start a Postgres instance
for development and testing, but you do **not** need to use Supabase for this
implementation to work – simply use the Postgres instance of your choice.

## Future work (contributions welcome)
- Include examples not just for Postgres, but for other databases like MySQL as well.
- Consider packaging this library as a postgres extension that can be easily installed
  and used in a database.