-- Start transaction and plan the tests.
BEGIN;
SELECT plan(44);

create table tests (
    "tid" typeid
);

-- Run the 'valid' tests.

-- - name: nil
--   typeid: "00000000000000000000000000"
--   prefix: ""
--   uuid: "00000000-0000-0000-0000-000000000000"
SELECT is(
  typeid_parse('00000000000000000000000000'),
  ('', '00000000-0000-0000-0000-000000000000')::typeid,
  'Parse valid: nil'
);
SELECT is(
  typeid_print(('', '00000000-0000-0000-0000-000000000000')),
  '00000000000000000000000000',
  'Print valid: nil'
);

-- - name: one
--   typeid: "00000000000000000000000001"
--   prefix: ""
--   uuid: "00000000-0000-0000-0000-000000000001"
SELECT is(
  typeid_parse('00000000000000000000000001'),
  ('', '00000000-0000-0000-0000-000000000001')::typeid,
  'Parse valid: one'
);
SELECT is(
  typeid_print(('', '00000000-0000-0000-0000-000000000001')),
  '00000000000000000000000001',
  'Print valid: one'
);

-- - name: ten
--   typeid: "0000000000000000000000000a"
--   prefix: ""
--   uuid: "00000000-0000-0000-0000-00000000000a"
SELECT is(
  typeid_parse('0000000000000000000000000a'),
  ('', '00000000-0000-0000-0000-00000000000a')::typeid,
  'Parse valid: ten'
);
SELECT is(
  typeid_print(('', '00000000-0000-0000-0000-00000000000a')),
  '0000000000000000000000000a',
  'Print valid: ten'
);

-- - name: sixteen
--   typeid: "0000000000000000000000000g"
--   prefix: ""
--   uuid: "00000000-0000-0000-0000-000000000010"
SELECT is(
  typeid_parse('0000000000000000000000000g'),
  ('', '00000000-0000-0000-0000-000000000010')::typeid,
  'Parse valid: sixteen'
);
SELECT is(
  typeid_print(('', '00000000-0000-0000-0000-000000000010')),
  '0000000000000000000000000g',
  'Print valid: sixteen'
);

-- - name: thirty-two
--   typeid: "00000000000000000000000010"
--   prefix: ""
--   uuid: "00000000-0000-0000-0000-000000000020"
SELECT is(
  typeid_parse('00000000000000000000000010'),
  ('', '00000000-0000-0000-0000-000000000020')::typeid,
  'Parse valid: thirty-two'
);
SELECT is(
  typeid_print(('', '00000000-0000-0000-0000-000000000020')),
  '00000000000000000000000010',
  'Print valid: thirty-two'
);

-- - name: max-valid
--   typeid: "7zzzzzzzzzzzzzzzzzzzzzzzzz"
--   prefix: ""
--   uuid: "ffffffff-ffff-ffff-ffff-ffffffffffff"
SELECT is(
  typeid_parse('7zzzzzzzzzzzzzzzzzzzzzzzzz'),
  ('', 'ffffffff-ffff-ffff-ffff-ffffffffffff')::typeid,
  'Parse valid: max-valid'
);
SELECT is(
  typeid_print(('', 'ffffffff-ffff-ffff-ffff-ffffffffffff')),
  '7zzzzzzzzzzzzzzzzzzzzzzzzz',
  'Print valid: max-valid'
);

-- - name: valid-alphabet
--   typeid: "prefix_0123456789abcdefghjkmnpqrs"
--   prefix: "prefix"
--   uuid: "0110c853-1d09-52d8-d73e-1194e95b5f19"
SELECT is(
  typeid_parse('prefix_0123456789abcdefghjkmnpqrs'),
  ('prefix', '0110c853-1d09-52d8-d73e-1194e95b5f19')::typeid,
  'Parse valid: valid-alphabet'
);
SELECT is(
  typeid_print(('prefix', '0110c853-1d09-52d8-d73e-1194e95b5f19')),
  'prefix_0123456789abcdefghjkmnpqrs',
  'Print valid: valid-alphabet'
);

-- - name: valid-prefix-underscores
--   typeid: "pre_fix_0123456789abcdefghjkmnpqrs"
--   prefix: "pre_fix"
--   uuid: "0110c853-1d09-52d8-d73e-1194e95b5f19"
SELECT is(
  typeid_parse('pre_fix_0123456789abcdefghjkmnpqrs'),
  ('pre_fix', '0110c853-1d09-52d8-d73e-1194e95b5f19')::typeid,
  'Parse valid: valid-prefix-underscores'
);
SELECT is(
  typeid_print(('pre_fix', '0110c853-1d09-52d8-d73e-1194e95b5f19')),
  'pre_fix_0123456789abcdefghjkmnpqrs',
  'Print valid: valid-alphabet-underscores'
);
SELECT is(
  typeid_print(('pre_____fix', '0110c853-1d09-52d8-d73e-1194e95b5f19')),
  'pre_____fix_0123456789abcdefghjkmnpqrs',
  'Print valid: valid-alphabet-underscores'
);

-- - name: valid-uuidv7
--   typeid: "prefix_01h455vb4pex5vsknk084sn02q"
--   prefix: "prefix"
--   uuid: "01890a5d-ac96-774b-bcce-b302099a8057"
SELECT is(
  typeid_parse('prefix_01h455vb4pex5vsknk084sn02q'),
  ('prefix', '01890a5d-ac96-774b-bcce-b302099a8057')::typeid,
  'Parse valid: valid-uuidv7'
);
SELECT is(
  typeid_print(('prefix', '01890a5d-ac96-774b-bcce-b302099a8057')),
  'prefix_01h455vb4pex5vsknk084sn02q',
  'Print valid: valid-uuidv7'
);

-- Run the 'invalid' tests.

-- - name: prefix-uppercase
--   typeid: "PREFIX_00000000000000000000000000"
--   description: "The prefix should be lowercase with no uppercase letters"
SELECT throws_ok(
  $$ INSERT into tests (tid) VALUES (typeid_parse('PREFIX_00000000000000000000000000')); $$,
  'typeid prefix must match the regular expression ^([a-z]([a-z_]{0,61}[a-z])?)?$',
  'Parse invalid: prefix-uppercase'
);

SELECT throws_ok(
  $$ INSERT into tests (tid) VALUES (typeid_generate('PREFIX')); $$,
  'typeid prefix must match the regular expression ^([a-z]([a-z_]{0,61}[a-z])?)?$',
  'Parse invalid: prefix-uppercase'
);

-- - name: prefix-numeric
--   typeid: "12345_00000000000000000000000000"
--   description: "The prefix can't have numbers, it needs to be alphabetic"
SELECT throws_ok(
  $$ INSERT into tests (tid) VALUES (typeid_parse('12345_00000000000000000000000000')); $$,
  'typeid prefix must match the regular expression ^([a-z]([a-z_]{0,61}[a-z])?)?$',
  'Parse invalid: prefix-numeric'
);

SELECT throws_ok(
  $$ INSERT into tests (tid) VALUES (typeid_generate('12345')); $$,
  'typeid prefix must match the regular expression ^([a-z]([a-z_]{0,61}[a-z])?)?$',
  'Parse invalid: prefix-numeric'
);

-- - name: prefix-period
--   typeid: "pre.fix_00000000000000000000000000"
--   description: "The prefix can't have symbols, it needs to be alphabetic"
SELECT throws_ok(
  $$ INSERT into tests (tid) VALUES (typeid_parse('pre.fix_00000000000000000000000000')); $$,
  'typeid prefix must match the regular expression ^([a-z]([a-z_]{0,61}[a-z])?)?$',
  'Parse invalid: prefix-period'
);

SELECT throws_ok(
  $$ INSERT into tests (tid) VALUES (typeid_generate('pre.fix')); $$,
  'typeid prefix must match the regular expression ^([a-z]([a-z_]{0,61}[a-z])?)?$',
  'Parse invalid: prefix-period'
);

-- - name: prefix-underscore
--   typeid: "pre_fix_00000000000000000000000000"
--   description: "The prefix can't have leading or trailing underscores"
SELECT throws_ok(
  $$ INSERT into tests (tid) VALUES (typeid_generate('_prefix')); $$,
  'typeid prefix must match the regular expression ^([a-z]([a-z_]{0,61}[a-z])?)?$',
  'Parse invalid: prefix-underscore'
);

SELECT throws_ok(
  $$ INSERT into tests (tid) VALUES (typeid_generate('prefix_')); $$,
  'typeid prefix must match the regular expression ^([a-z]([a-z_]{0,61}[a-z])?)?$',
  'Parse invalid: prefix-underscore'
);

-- - name: prefix-non-ascii
--   typeid: "préfix_00000000000000000000000000"
--   description: "The prefix can only have ascii letters"
SELECT throws_ok(
  $$ INSERT into tests (tid) VALUES (typeid_parse('préfix_00000000000000000000000000')); $$,
  'typeid prefix must match the regular expression ^([a-z]([a-z_]{0,61}[a-z])?)?$',
  'Parse invalid: prefix-non-ascii'
);

SELECT throws_ok(
  $$ INSERT into tests (tid) VALUES (typeid_generate('préfix')); $$,
  'typeid prefix must match the regular expression ^([a-z]([a-z_]{0,61}[a-z])?)?$',
  'Parse invalid: prefix-non-ascii'
);

-- - name: prefix-spaces
--   typeid: "  prefix_00000000000000000000000000"
--   description: "The prefix can't have any spaces"
SELECT throws_ok(
  $$ INSERT into tests (tid) VALUES (typeid_parse('  prefix_00000000000000000000000000')); $$,
  'typeid prefix must match the regular expression ^([a-z]([a-z_]{0,61}[a-z])?)?$',
  'Parse invalid: prefix-spaces'
);

SELECT throws_ok(
  $$ INSERT into tests (tid) VALUES (typeid_generate('  prefix')); $$,
  'typeid prefix must match the regular expression ^([a-z]([a-z_]{0,61}[a-z])?)?$',
  'Parse invalid: prefix-spaces'
);

-- - name: prefix-64-chars
--   #        123456789 123456789 123456789 123456789 123456789 123456789 1234
--   typeid: "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl_00000000000000000000000000"
--   description: "The prefix can't be 64 characters, it needs to be 63 characters or less"
SELECT throws_ok(
  $$ INSERT into tests (tid) VALUES (typeid_parse('abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl_00000000000000000000000000')); $$,
  'typeid prefix must match the regular expression ^([a-z]([a-z_]{0,61}[a-z])?)?$',
  'Parse invalid: prefix-64-chars'
);

SELECT throws_ok(
  $$ INSERT into tests (tid) VALUES (typeid_generate('abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl')); $$,
  'typeid prefix must match the regular expression ^([a-z]([a-z_]{0,61}[a-z])?)?$',
  'Parse invalid: prefix-64-chars'
);

-- - name: separator-empty-prefix
--   typeid: "_00000000000000000000000000"
--   description: "If the prefix is empty, the separator should not be there"
SELECT throws_ok(
  $$ INSERT into tests (tid) VALUES (typeid_parse('_00000000000000000000000000')); $$,
  'typeid prefix cannot be empty with a delimiter',
  'Parse invalid: separator-empty-prefix'
);

-- - name: separator-empty
--   typeid: "_"
--   description: "A separator by itself should not be treated as the empty string"
SELECT throws_ok(
  $$ INSERT into tests (tid) VALUES (typeid_parse('_')); $$,
  'typeid prefix cannot be empty with a delimiter',
  'Parse invalid: separator-empty'
);

-- - name: suffix-short
--   typeid: "prefix_1234567890123456789012345"
--   description: "The suffix can't be 25 characters, it needs to be exactly 26 characters"
SELECT throws_ok(
  $$ INSERT into tests (tid) VALUES (typeid_parse('prefix_1234567890123456789012345')); $$,
  'typeid suffix must be 26 characters',
  'Parse invalid: suffix-short'
);

-- - name: suffix-long
--   typeid: "prefix_123456789012345678901234567"
--   description: "The suffix can't be 27 characters, it needs to be exactly 26 characters"
SELECT throws_ok(
  $$ INSERT into tests (tid) VALUES (typeid_parse('prefix_123456789012345678901234567')); $$,
  'typeid suffix must be 26 characters',
  'Parse invalid: suffix-long'
);

-- - name: suffix-spaces
--   # This example has the right length, so that the failure is caused by the space
--   # and not the suffix length
--   typeid: "prefix_1234567890123456789012345 "
--   description: "The suffix can't have any spaces"
SELECT throws_ok(
  $$ INSERT into tests (tid) VALUES (typeid_parse('prefix_1234567890123456789012345 ')); $$,
  'typeid suffix must only use characters from the base32 alphabet',
  'Parse invalid: suffix-spaces'
);

-- - name: suffix-uppercase
--   # This example is picked because it would be valid in lowercase
--   typeid: "prefix_0123456789ABCDEFGHJKMNPQRS"
--   description: "The suffix should be lowercase with no uppercase letters"
SELECT throws_ok(
  $$ INSERT into tests (tid) VALUES (typeid_parse('prefix_0123456789ABCDEFGHJKMNPQRS')); $$,
  'typeid suffix must only use characters from the base32 alphabet',
  'Parse invalid: suffix-uppercase'
);

-- - name: suffix-hyphens
--   # This example has the right length, so that the failure is caused by the hyphens
--   # and not the suffix length
--   typeid: "prefix_123456789-123456789-123456"
--   description: "The suffix should be lowercase with no uppercase letters"
SELECT throws_ok(
  $$ INSERT into tests (tid) VALUES (typeid_parse('prefix_123456789-123456789-123456')); $$,
  'typeid suffix must only use characters from the base32 alphabet',
  'Parse invalid: suffix-hyphens'
);

-- - name: suffix-wrong-alphabet
--   typeid: "prefix_ooooooiiiiiiuuuuuuulllllll"
--   description: "The suffix should only have letters from the spec's alphabet"
SELECT throws_ok(
  $$ INSERT into tests (tid) VALUES (typeid_parse('prefix_ooooooiiiiiiuuuuuuulllllll')); $$,
  'typeid suffix must only use characters from the base32 alphabet',
  'Parse invalid: suffix-wrong-alphabet'
);

-- - name: suffix-ambiguous-crockford
--   # This example would be valid if we were using the crockford disambiguation rules
--   typeid: "prefix_i23456789ol23456789oi23456"
--   description: "The suffix should not have any ambiguous characters from the crockford encoding"
SELECT throws_ok(
  $$ INSERT into tests (tid) VALUES (typeid_parse('prefix_i23456789ol23456789oi23456')); $$,
  'typeid suffix must only use characters from the base32 alphabet',
  'Parse invalid: suffix-ambiguous-crockford'
);

-- - name: suffix-hyphens-crockford
--   # This example would be valid if we were using the crockford hyphenation rules
--   typeid: "prefix_123456789-0123456789-0123456"
--   description: "The suffix can't ignore hyphens as in the crockford encoding"
SELECT throws_ok(
  $$ INSERT into tests (tid) VALUES (typeid_parse('prefix_123456789-0123456789-0123456')); $$,
  'typeid suffix must be 26 characters',
  'Parse invalid: suffix-hyphens-crockford'
);

-- - name: suffix-overflow
--   # This is the first suffix that overflows into 129 bits
--   typeid: "prefix_8zzzzzzzzzzzzzzzzzzzzzzzzz"
--   description: "The suffix should encode at most 128-bits"
SELECT throws_ok(
  $$ INSERT into tests (tid) VALUES (typeid_parse('prefix_8zzzzzzzzzzzzzzzzzzzzzzzzz')); $$,
  'typeid suffix must start with 0-7',
  'Parse invalid: suffix-overflow'
);

-- Finish the tests and clean up.
SELECT * FROM finish();
ROLLBACK;

