-- Example of how to use typeids in your own tables.
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