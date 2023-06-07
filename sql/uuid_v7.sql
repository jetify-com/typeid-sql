-- Function to generate new v7 UUIDs.
-- In the future we might want use an extension: https://github.com/fboulnois/pg_uuidv7
-- Or, once the UUIDv7 spec is finalized, it will probably make it into the 'uuid-ossp' extension
-- and a custom function will no longer be necessary.
create or replace function uuid_generate_v7()
returns uuid
as $$
declare
  unix_ts_ms bytea;
  uuid_bytes bytea;
begin
  unix_ts_ms = substring(int8send(floor(extract(epoch from clock_timestamp()) * 1000)::bigint) from 3);
  uuid_bytes = uuid_send(gen_random_uuid());
  uuid_bytes = overlay(uuid_bytes placing unix_ts_ms from 1 for 6);
  uuid_bytes = set_byte(uuid_bytes, 6, (b'0111' || get_byte(uuid_bytes, 6)::bit(4))::bit(8)::int);
  return encode(uuid_bytes, 'hex')::uuid;
end
$$
language plpgsql
volatile;