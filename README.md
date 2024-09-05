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
you can use it as follows.

To define a new type of typeid with a specific prefix use the `typeid\_

```sql
-- Define a `users` table that uses `user_id` as its primary key.
-- We use the `typeid_generate` function to randomly generate a new typeid of the
-- correct type for each user.
CREATE TABLE users (
    "id" user_id not null default typeid_generate('user'),
    "name" text,
    "email" text
);

-- Now we can insert new uses and have the `id` column automatically generated.
INSERT INTO users ("name", "email") VALUES ('Alice P. Hacker', 'alice@hacker.net');
```

Or

You can use the typeid_generate_text function to generate a new typeid as a string, and not use the typeid type

```sql
-- Define a `users` table that uses `user_id` as its primary key.
-- We use the `typeid_generate_text` function to randomly generate a new typeid of the
-- correct type for each user.
-- You will need to manually add the check constraint to the column
CREATE TABLE users (
    "id" text not null default typeid_generate_text('user') CHECK (typeid_check_text(id, 'user')),
    "name" text,
    "email" text
);

-- Now we can insert new uses and have the `id` column automatically generated.
INSERT INTO users ("name", "email") VALUES ('Alice P. Hacker', 'alice@hacker.net');
SELECT id FROM users;
-- Result:
-- "user_01hfs6amkdfem8sb6b1xmg7tq7"
```

Note that the database internally encodes typeids as a `(prefix, uuid)` tuple. Because
this is different than the standard string representation of typeids in other libraries,
we provide a `typeid_parse` and a `typeid_print` function that can be used to write
queries with the standard string representation of typeids:

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

or for the text variant

```sql
-- Insert a user with a specific typeid that might have been generated elsewhere:
INSERT INTO users ("id", "name", "email")
VALUES ('user_01h455vb4pex5vsknk084sn02q', 'Ben Bitdiddle', 'ben@bitdiddle.com');

-- To retrieve the ids as encoded strings, just use the column:
SELECT id AS id, "name", "email" FROM users;

-- You can also use filter in a WHERE clause to filter by typeid:
SELECT typeid_print(id) AS id, "name", "email" FROM users
WHERE id = 'user_01h455vb4pex5vsknk084sn02q';
```

## (Optional) Operator overload

If you'd like to be able to do the following:

```sql
-- Query directly from the DB with a serialized typeid
SELECT * FROM users u WHERE u.id = 'user_01h455vb4pex5vsknk084sn02q';

-- Result:
-- "(user,018962e7-3a6d-7290-b088-5c4e3bdf918c)",Ben Bitdiddle,ben@bitdiddle.com
```

Then you can add in [the operator overload function for typeids](https://github.com/search?q=repo%3Ajetify-com%2Ftypeid-sql%20compare_type_id_equality&type=code):

## Future work (contributions welcome)

-   Include examples not just for Postgres, but for other databases like MySQL as well.
-   Consider rewriting this library as a postgres extension. It would make it possible to
    use the standard typeid string representation without the need of extra functions.
