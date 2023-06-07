-- Implementation of typeids in SQL (Postgres).
-- This file:
-- + Defines a `typeid` type: a composite type consisting of a type prefix,
--   and a UUID
-- + Defines functions to generate and validate typeids in SQL.

-- Create a `typeid` type.
-- Note that the "uuid" field should be a UUID v7.
create type "typeid" as ("type" text, "uuid" uuid);

-- Function that generates a random typeid of the given type.
-- This depends on the `uuid_generate_v7` function defined in `uuid_v7.sql`.
create or replace function typeid_generate(kind text)
returns typeid
as $$
begin
  return (uuid_generate_v7(), kind);
end
$$
language plpgsql
volatile;

-- Function that checks if a typeid is valid, for the given type.
create or replace function typeid_check(typeid typeid, expected_type text)
returns boolean
as $$
declare
  kind text;
  bytes bytea;
  ver int;
begin
  kind = (typeid).type;
  bytes = uuid_send((typeid).uuid);
  ver = (get_byte(bytes, 6) >> 4)::bit(4)::int;
  -- Use bytes to check that the UUID version is 7
  return kind = expected_type AND ver = 7;
end
$$
language plpgsql
immutable;
