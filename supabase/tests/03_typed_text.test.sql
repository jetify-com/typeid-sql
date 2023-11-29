-- Start transaction and plan the tests.
BEGIN;
SELECT plan(7);

create table tests (
    "tid" text CHECK(typeid_check_text(tid, 'generated'))
);
-- -- Run tests for typeid_generate_text and typeid_check_text on tests table.

-- - name: generate-text
--   typeid: "generated_00000000000000000000000000"
--   description: "Generate a typeid with a specific prefix using typeid_generate_text"
INSERT INTO tests (tid) VALUES (typeid_generate_text('generated'));
SELECT is(
  typeid_check_text((SELECT tid FROM tests), 'generated'),
  true,
  'Generate typeid text with a specific prefix using typeid_generate_text'
);

-- - name: generate-text-invalid-prefix
--   typeid: "12345_00000000000000000000000000"
--   description: "Attempt to generate a typeid with an invalid prefix"
SELECT throws_ok(
  $$ INSERT INTO tests (tid) VALUES (typeid_generate_text('12345')); $$,
  'typeid prefix must match the regular expression [a-z]{0,63}',
  'Generate typeid text with an invalid prefix should throw an error'
);

-- - name: check-text-valid
--   typeid: "generated_00000000000000000000000000"
--   description: "Check if a generated typeid text is valid"
INSERT INTO tests (tid) VALUES (typeid_generate_text('generated'));
SELECT is(
  typeid_check_text((SELECT tid FROM tests limit
          1), 'generated'),
  true,
  'Check if a generated typeid text is valid using typeid_check_text'
);

-- - name: check-text-invalid-prefix
--   typeid: "12345_00000000000000000000000000"
--   description: "Check if a typeid text with an invalid prefix is invalid"
-- INSERT INTO tests (tid) VALUES ('12345_00000000000000000000000000');
SELECT throws_ok(
  $$ INSERT into tests (tid) VALUES (typeid_parse('12345_00000000000000000000000000')); $$,
  'typeid prefix must match the regular expression [a-z]{0,63}',
  'Parse invalid: prefix-underscore'
);

-- - name: generate-text
--   typeid: "generated_00000000000000000000000000"
--   description: "Generate a typeid with a specific prefix using typeid_generate_text"
INSERT INTO tests (tid) VALUES (typeid_generate_text('generated'));
SELECT is(
  typeid_check_text((SELECT tid FROM tests limit 1), 'generated'),
  true,
  'Generate typeid text with a specific prefix using typeid_generate_text'
);

-- - name: generate-text-invalid-prefix
--   typeid: "12345_00000000000000000000000000"
--   description: "Attempt to generate a typeid with an invalid prefix"
SELECT throws_ok(
  $$ INSERT INTO tests (tid) VALUES (typeid_generate_text('12345')); $$,
  'typeid prefix must match the regular expression [a-z]{0,63}',
  'Generate typeid text with an invalid prefix should throw an error'
);

-- - name: check-text-valid
--   typeid: "generated_00000000000000000000000000"
--   description: "Check if a generated typeid text is valid"
INSERT INTO tests (tid) VALUES (typeid_generate_text('generated'));
SELECT is(
  typeid_check_text((SELECT tid FROM tests limit 1), 'generated'),
  true,
  'Check if a generated typeid text is valid using typeid_check_text'
);


-- Finish the tests and clean up.
SELECT * FROM finish();
ROLLBACK;
