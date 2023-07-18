-- Start transaction and plan the tests.
BEGIN;
SELECT plan(2);  -- number of tests to run

create domain test_id AS typeid check (typeid_check(value, 'test'));

create table tests (
  "tid" test_id not null default typeid_generate('test'),
  "name" text
);

-- Run the tests.
SELECT results_eq(
  $$ INSERT into tests (tid) VALUES (typeid_parse('test_01h455vb4pex5vsknk084sn02q')) RETURNING tid; $$,
  ARRAY[('test', '01890a5d-ac96-774b-bcce-b302099a8057')::test_id],
  'Can insert using the typeid_parse function'
);

SELECT results_eq(
  $$ SELECT typeid_print(tid) FROM tests where tid = 'test_01h455vb4pex5vsknk084sn02q' $$,
  ARRAY['test_01h455vb4pex5vsknk084sn02q'],
  'Can select without needing to call typeid_parse() thanks to operator overload'
);

-- Finish the tests and clean up.
SELECT * FROM finish();
ROLLBACK;
