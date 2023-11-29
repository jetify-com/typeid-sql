-- Example of how to use the compound version of typeids in your own tables.
-- The compound version is a tuple of type (string, uuid)

-- In this example we'll define a users table that uses typeids to identify users.

-- Define a `user_id` type, which is a typeid with type prefix "user".
-- Using `user_id` throughout our schema, gives us type safety by guaranteeing
-- that the type prefix is always "user".
create domain user_id AS typeid check (typeid_check(value, 'user'));

-- Define a `users` table that uses `user_id` as its primary key.
-- We use the `typeid_generate` function to randomly generate a new typeid of the
-- correct type for each user.
create table users (
    "id" user_id not null default typeid_generate('user'),
    "name" text,
    "email" text
);

-- Now we can insert new uses and have the `id` column automatically generated.
insert into users ("name", "email") values ('Alice P. Hacker', 'alice@hacker.net');

-- Or you can specify the typeid yourself:
insert into users ("id", "name", "email")
values (typeid_parse('user_01h455vb4pex5vsknk084sn02q'), 'Ben Bitdiddle', 'ben@bitdiddle.com');

-- To retrieve the ids as encoded strings, use the `typeid_print` function:
select typeid_print(id) AS id, "name", "email" from users;