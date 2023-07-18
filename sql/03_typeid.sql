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

-- Enables direct textual equality checks. This enables direct querying in pSQL without
-- having to have clients know about db column internals- e.g. using the users table
-- example in example.sql:
--
-- Query:
-- SELECT * FROM users u WHERE u.id = 'user_01h455vb4pex5vsknk084sn02q'
--
-- Result:
-- "(user,018962e7-3a6d-7290-b088-5c4e3bdf918c)",Ben Bitdiddle,ben@bitdiddle.com
--
-- Note: This also has the nice benefit of playing very well with generators
-- such as Hibernate/JPA/JDBC/r2dbc, as you'll be able to do direct equality checks
-- in repositories, such as for r2dbc:
--
-- @Query(value = "SELECT u.id, u.name, u.email FROM users u WHERE u.id = :id")
-- Mono<UserEntity> findByPassedInTypeId(@Param("id") Mono<String> typeId); // user_01h455vb4pex5vsknk084sn02q
--
-- Note: This function only has to ever be declared once, and will work for any domains that use
-- the original typeid type (e.g. this function gets called when querying for a user_id even though
-- we never explicitly override the quality operator for a user_id.
CREATE OR REPLACE FUNCTION compare_type_id_equality(lhs_id typeid, rhs_id VARCHAR)
    RETURNS BOOLEAN AS $$
SELECT lhs_id = typeid_parse(rhs_id);
$$ LANGUAGE SQL IMMUTABLE;

CREATE OPERATOR = (
    LEFTARG = typeid,
    RIGHTARG = VARCHAR,
    PROCEDURE = compare_type_id_equality,
    COMMUTATOR = =,
    NEGATOR = !=,
    HASHES,
    MERGES
    );

