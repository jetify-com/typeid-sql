-- Start transaction and plan the tests.
BEGIN;
SELECT plan(5);

create domain test_id AS typeid check (typeid_check(value, 'test'));

create table tests (
    "tid" test_id not null default typeid_generate('test'),
    "name" text
);

-- Run the tests.
SELECT isnt_empty(
  $$ INSERT into tests (name) VALUES ('random id') RETURNING tid; $$,
  'Can insert with a default generated id'
);

SELECT isnt_empty(
  $$ INSERT into tests (tid) VALUES (('test', '00000000-0000-0000-0000-000000000000')) RETURNING tid; $$,
  'Can insert with an id of the correct type'
);

SELECT results_eq(
  $$ INSERT into tests (tid) VALUES (typeid_parse('test_01h455vb4pex5vsknk084sn02q')) RETURNING tid; $$,
  ARRAY[('test', '01890a5d-ac96-774b-bcce-b302099a8057')::test_id],
  'Can insert using the typeid_parse function'
);

SELECT results_eq(
  $$ SELECT typeid_print(tid) FROM tests where tid = typeid_parse('test_01h455vb4pex5vsknk084sn02q') $$,
  ARRAY['test_01h455vb4pex5vsknk084sn02q'],
  'Can select using typeid_parse and typeid_print'
);

SELECT throws_ok(
  $$ INSERT into tests (tid) VALUES (('user', '00000000-0000-0000-0000-000000000000')); $$,
  'value for domain test_id violates check constraint "test_id_check"',
  'Cannot insert typeid of wrong type'
);

-- Finish the tests and clean up.
SELECT * FROM finish();
ROLLBACK;

