
-- Implementation of an equality operator that makes it easy to compare typeids stored
-- as a compound tuple (prefix, uuid) against a typeid in text form.
--
-- This is useful so that clients can query using a textual representation of typeid.
-- For example, using the users table in example.sql, you could write:
--
-- Query:
-- SELECT * FROM users u WHERE u.id === 'user_01h455vb4pex5vsknk084sn02q'
--
-- Result:
-- "(user,018962e7-3a6d-7290-b088-5c4e3bdf918c)",Ben Bitdiddle,ben@bitdiddle.com
--
-- Note: This also has the nice benefit of playing very well with generators
-- such as Hibernate/JPA/JDBC/r2dbc, as you'll be able to do direct equality checks
-- in repositories, such as for r2dbc:
--
-- @Query(value = "SELECT u.id, u.name, u.email FROM users u WHERE u.id === :id")
-- Mono<UserEntity> findByPassedInTypeId(@Param("id") Mono<String> typeId); // user_01h455vb4pex5vsknk084sn02q
--
-- Note: This function only has to ever be declared once, and will work for any domains that use
-- the original typeid type (e.g. this function gets called when querying for a user_id even though
-- we never explicitly override the quality operator for a user_id.
CREATE OR REPLACE FUNCTION typeid_eq_operator(lhs_id typeid, rhs_id VARCHAR)
    RETURNS BOOLEAN AS $$
SELECT lhs_id = typeid_parse(rhs_id);
$$ LANGUAGE SQL IMMUTABLE;

CREATE OPERATOR === (
    LEFTARG = typeid,
    RIGHTARG = VARCHAR,
    FUNCTION = typeid_eq_operator,
    COMMUTATOR = ===,
    NEGATOR = !==,
    HASHES,
    MERGES
    );

