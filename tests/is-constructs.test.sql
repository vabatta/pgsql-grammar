-- IS NULL / IS NOT NULL (existing multi-word keywords)
SELECT x FROM t WHERE x IS NULL;
--                      ^^^^^^^ keyword
SELECT x FROM t WHERE x IS NOT NULL;
--                      ^^^^^^^^^^^ keyword

-- IS TRUE / IS NOT TRUE
SELECT x FROM t WHERE b IS TRUE;
--                      ^^ keyword
--                         ^^^^ entity.name.label
SELECT x FROM t WHERE b IS NOT TRUE;
--                      ^^ keyword
--                         ^^^ keyword
--                             ^^^^ entity.name.label

-- IS FALSE / IS NOT FALSE
SELECT x FROM t WHERE b IS FALSE;
--                      ^^ keyword
--                         ^^^^^ entity.name.label
SELECT x FROM t WHERE b IS NOT FALSE;
--                      ^^ keyword
--                         ^^^ keyword
--                             ^^^^^ entity.name.label

-- IS UNKNOWN / IS NOT UNKNOWN
SELECT x FROM t WHERE b IS UNKNOWN;
--                      ^^ keyword
--                         ^^^^^^^ entity.name.label
SELECT x FROM t WHERE b IS NOT UNKNOWN;
--                      ^^ keyword
--                         ^^^ keyword
--                             ^^^^^^^ entity.name.label

-- IS DISTINCT FROM / IS NOT DISTINCT FROM
SELECT x FROM t WHERE a IS DISTINCT FROM b;
--                      ^^^^^^^^^^^^^^^^^ keyword
SELECT x FROM t WHERE a IS NOT DISTINCT FROM b;
--                      ^^^^^^^^^^^^^^^^^^^^^ keyword

-- IS NORMALIZED / IS NOT NORMALIZED
SELECT x FROM t WHERE s IS NORMALIZED;
--                      ^^^^^^^^^^^^^ keyword
SELECT x FROM t WHERE s IS NOT NORMALIZED;
--                      ^^^^^^^^^^^^^^^^^ keyword

-- IS NFC NORMALIZED / IS NOT NFC NORMALIZED
SELECT x FROM t WHERE s IS NFC NORMALIZED;
--                      ^^^^^^^^^^^^^^^^^ keyword
SELECT x FROM t WHERE s IS NOT NFKD NORMALIZED;
--                      ^^^^^^^^^^^^^^^^^^^^^^^ keyword
