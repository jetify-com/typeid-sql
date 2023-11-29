-- Example of how to use text version of typeids in your own tables.
-- In this example we'll define a members table that uses typeids.

-- Define a `member_id` type, which is a typeid with type prefix "member".
-- Using `member_id` throughout our schema, gives us type safety by guaranteeing
-- that the type prefix is always "member".
create domain member_id AS text check (typeid_check_text(value, 'member'));

-- Define a `members` table that uses `member_id` as its primary key.
-- We use the `typeid_generate_text` function to randomly generate a new typeid of the
-- correct type for each member.
create table members (
    "id" member_id not null default typeid_generate_text('member'),
    "name" text,
    "email" text
);

CREATE UNIQUE INDEX members_pkey ON members USING btree (id);
alter table "members" add constraint "members_pkey" PRIMARY KEY using index "members_pkey";


-- Now we can insert new uses and have the `id` column automatically generated.
insert into members ("name", "email") values ('Alice P. Hacker', 'alice@hacker.net');

-- Or you can specify the typeid yourself:
insert into members ("id", "name", "email")
values ('member_01h455vb4pex5vsknk084sn02q', 'Ben Bitdiddle', 'ben@bitdiddle.com');
