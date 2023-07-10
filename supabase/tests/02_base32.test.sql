-- Start transaction and plan the tests.
BEGIN;
SELECT plan(4);

-- Run the tests.
SELECT is(base32_encode('00000000-0000-0000-0000-000000000000'),
          '00000000000000000000000000',
          'Encode nil uuid' );
SELECT is(base32_decode('00000000000000000000000000'),
          '00000000-0000-0000-0000-000000000000',
          'Decode nil uuid' );

SELECT is(base32_encode('01890a5d-ac96-774b-bcce-b302099a8057'),
          '01h455vb4pex5vsknk084sn02q',
          'Encode valid uuidv7' );
SELECT is(base32_decode('01h455vb4pex5vsknk084sn02q'),
          '01890a5d-ac96-774b-bcce-b302099a8057',
          'Decode valid uuidv7' );
          
-- Finish the tests and clean up.
SELECT * FROM finish();
ROLLBACK;

