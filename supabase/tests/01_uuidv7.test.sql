-- Start transaction and plan the tests.
BEGIN;
SELECT plan(1);

-- Run the tests.
SELECT isa_ok(uuid_generate_v7(), 'uuid', 'uuid_generate_v7()');

-- Finish the tests and clean up.
SELECT * FROM finish();
ROLLBACK;

