-- https://github.com/citusdata/citus/issues/7029

SET
citus.next_shard_id TO 19980000;

CREATE TABLE index_use_test
(
    test_key date
);
SELECT create_distributed_table('index_use_test', 'key');

CREATE
INDEX date_index ON index_use_test (test_key);

INSERT INTO index_use_test
SELECT x.ts
FROM generate_series(date '2000-01-01', date '2023-01-01', interval '1 year') x(ts);

EXPLAIN
ANALYZE
SELECT count(*)
FROM index_use_test
WHERE test_key >= '2014-02-02'::date AND test_key < '2017-02-02'::date;

EXPLAIN
ANALYZE
SELECT count(*)
FROM index_use_test
WHERE test_key >= TO_DATE('2014-02-02 00:00:00.000000', 'YYYY-MM-DD HH24:MI:SS.US')
  AND test_key < TO_DATE('2017-02-02 00:00:00.000000', 'YYYY-MM-DD HH24:MI:SS.US');

DROP TABLE index_use_test;
