-- Implementation of typeids in SQL (Postgres).
-- This file:
-- + Defines a `typeid` type: a composite type consisting of a type prefix,
--   and a UUID
-- + Defines functions to generate and validate typeids in SQL.

-- Create a `typeid` type.
-- Note that the "uuid" field should be a UUID v7.
create type "typeid" as ("type" varchar(63), "uuid" uuid);

-- Function that generates a random typeid of the given type.
-- This depends on the `uuid_generate_v7` function defined in `uuid_v7.sql`.
create or replace function typeid_generate(prefix text)
returns typeid
as $$
begin
  if (prefix is null) or not (prefix ~ '^[a-z]{0,63}$') then
    raise exception 'typeid prefix must match the regular expression [a-z]{0,63}';
  end if;
  return (prefix, uuid_generate_v7())::typeid;
end
$$
language plpgsql
volatile;

-- Function that checks if a typeid is valid, for the given type prefix.
-- It also enforces that the UUID is a v7 UUID.
-- NOTE: we might want to make the version check optional.
create or replace function typeid_check(tid typeid, expected_type text)
returns boolean
as $$
declare
  prefix text;
  bytes bytea;
  ver int;
begin
  prefix = (tid).type;
  bytes = uuid_send((tid).uuid);
  ver = (get_byte(bytes, 6) >> 4)::bit(4)::int;
  -- Check that:
  -- + The prefix matches the expected type
  -- + The UUID version is 7 OR it's the special "nil" UUID
  return prefix = expected_type AND (ver = 7 OR (tid).uuid = '00000000-0000-0000-0000-000000000000');
end
$$
language plpgsql
immutable;


-- Function that parses a string into a typeid.
create or replace function typeid_parse(typeid_str text)
returns typeid
as $$
declare
  prefix text;
  suffix text;
begin
  if position('_' in typeid_str) = 0 then
    return ('', base32_decode(typeid_str))::typeid;
  end if;
  prefix = split_part(typeid_str, '_', 1);
  suffix = split_part(typeid_str, '_', 2);
  if prefix is null or prefix = '' then
    raise exception 'typeid prefix cannot be empty with a delimiter';
  end if;
  -- prefix must match the regular expression [a-z]{0,63}
  if not prefix ~ '^[a-z]{0,63}$' then
    raise exception 'typeid prefix must match the regular expression [a-z]{0,63}';
  end if;

  return (prefix, base32_decode(suffix))::typeid;
end
$$
language plpgsql
immutable;

-- Function that serializes a typeid into a string.
create or replace function typeid_print(tid typeid)
returns text
as $$
declare
  prefix text;
  suffix text;
begin
  prefix = (tid).type;
  suffix = base32_encode((tid).uuid);
  if (prefix is null) or not (prefix ~ '^[a-z]{0,63}$') then
    raise exception 'typeid prefix must match the regular expression [a-z]{0,63}';
  end if;
  if prefix = '' then
    return suffix;
  end if;
  return (prefix || '_' || suffix);
end
$$
language plpgsql
immutable;