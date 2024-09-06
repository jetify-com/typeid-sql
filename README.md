# TypeID SQL

### A SQL implementation of [TypeID](https://github.com/jetify-com/typeid) using PostgreSQL.

![License: Apache 2.0](https://img.shields.io/github/license/jetify-com/typeid-sql)

TypeIDs are a modern, **type-safe**, globally unique identifier based on the upcoming
UUIDv7 standard. They provide a ton of nice properties that make them a great choice
as the primary identifiers for your data in a database, APIs, and distributed systems.
Read more about TypeIDs in their [spec](https://github.com/jetify-com/typeid).

This particular implementation demonstrates how to use TypeIDs in a postgres database.

## Installation

To use typeids in your Postgres instance, you'll need define all the
appropriate types and functions by running the SQL scripts in this repo.

We recommend copying the SQL scripts into your migrations directory and using the
migration tool of your choice. For example, [Flyway](https://flywaydb.org/), or
[Liquibase](https://www.liquibase.org/).

Note that this repo is using Supabase as a way to easily start a Postgres instance
for development and testing, but you do **not** need to use Supabase for this
implementation to work – simply use the Postgres instance of your choice.

## Usage
Once you've installed the TypeID types and functions in your Postgres instance,
you have two options on how to encode TypeIDs in your database.

### 1. Text-based encoding
This encoding is more inefficient than the alternative, but it's very straight-forward
to understand, it's easy to debug by simply inspecting the contents of your tables, and
it works well with other tools you might be using to inspect your database.

To use it:
+ Declare your `id` column using the `text` type.
+ Use the `typeid_generate_text` function to generate new default values.
+ Use the `typeid_check_text` to enforce all strings in the column are valid typeids.

Example:

```sql
-- Define a `users` table that uses `user_id` as its primary key.
-- We use the `typeid_generate_text` function to randomly generate a new typeid of the
-- correct type for each user.
-- We also recommend adding the check constraint to the column
CREATE TABLE users (
    "id" text not null default typeid_generate_text('user') CHECK (typeid_check_text(id, 'user')),
    "name" text,
    "email" text
);

-- Now we can insert new users and have the `id` column automatically generated.
INSERT INTO users ("name", "email") VALUES ('Alice P. Hacker', 'alice@hacker.net');
SELECT id FROM users;
-- Result:
-- "user_01hfs6amkdfem8sb6b1xmg7tq7"

-- Insert a user with a specific typeid that might have been generated elsewhere:
INSERT INTO users ("id", "name", "email")
VALUES ('user_01h455vb4pex5vsknk084sn02q', 'Ben Bitdiddle', 'ben@bitdiddle.com');

-- To retrieve the ids as encoded strings, just use the column:
SELECT id AS id, "name", "email" FROM users;

-- You can also use filter in a WHERE clause to filter by typeid:
SELECT typeid_print(id) AS id, "name", "email" FROM users
WHERE id = 'user_01h455vb4pex5vsknk084sn02q';
```

### 2. UUID-based encoding using compound types
In this approach, we internally encode typeids as a `(prefix, uuid)` tuple. The
sql files in this library provide a predefined `typeid` type to represent
said tuples.

The advantage of this approach is that it is a more efficient encoding because we
store the uuid portion of the typeid using the native `uuid` type.

The disadvanage is that it is harder to work with and debug.

If performance is a primary concern of yours, also consider using the native
[postgres extension](https://github.com/blitss/typeid-postgres) for typeid,
which exposes typeids as a "built-in" type.

To define a new typeid using this encoding, you can use the `typeid_check` function:
```sql
-- Define a `user_id` type, which is a typeid with type prefix "user".
-- Using `user_id` throughout our schema, gives us type safety by guaranteeing
-- that the type prefix is always "user".
CREATE DOMAIN user_id AS typeid CHECK (typeid_check(value, 'user'));
```

You can now use the newly defined type in your tables. The `typeid_generate` function
makes it possible to automatically a new random typeid for each row:

```sql
-- Define a `users` table that uses `user_id` as its primary key.
-- We use the `typeid_generate` function to randomly generate a new typeid of the
-- correct type for each user.
CREATE TABLE users (
    "id" user_id not null default typeid_generate('user'),
    "name" text,
    "email" text
);

-- Now we can insert new users and have the `id` column automatically generated.
INSERT INTO users ("name", "email") VALUES ('Alice P. Hacker', 'alice@hacker.net');
```
#### Querying
To make it easy to query typeid tuples using the standard string representation, we
provide two convenience functions: `typeid_parse` and `typeid_print`, which convert
to and from the standard string representation.

Example:

```sql
-- Insert a user with a specific typeid that might have been generated elsewhere:
INSERT INTO users ("id", "name", "email")
VALUES (typeid_parse('user_01h455vb4pex5vsknk084sn02q'), 'Ben Bitdiddle', 'ben@bitdiddle.com');

-- To retrieve the ids as encoded strings, use the `typeid_print` function:
SELECT typeid_print(id) AS id, "name", "email" FROM users;

-- You can also use `typeid_parse` in a WHERE clause to filter by typeid:
SELECT typeid_print(id) AS id, "name", "email" FROM users
WHERE id = typeid_parse('user_01h455vb4pex5vsknk084sn02q');
```

#### (Optional) Operator overload

If you'd like to be able to do the following:

```sql
-- Query directly from the DB with a serialized typeid
SELECT * FROM users u WHERE u.id = 'user_01h455vb4pex5vsknk084sn02q';

-- Result:
-- "(user,018962e7-3a6d-7290-b088-5c4e3bdf918c)",Ben Bitdiddle,ben@bitdiddle.com
```

Then you can add in [the operator overload functions for typeid](https://github.com/jetify-com/typeid-sql/blob/main/sql/04_operator.sql).

Some users have reported issues with the above operator when using Rails and ActiveRecord – we
recommend removing `COMMUTATOR` from the operator definition if you encounter issues.

## Future work (contributions welcome)

-   Include examples not just for Postgres, but for other databases like MySQL as well.
-   Consider rewriting this library as a postgres extension. It would make it possible to
    use the standard typeid string representation without the need of extra functions.
