-- Sample:
-- https://www.enterprisedb.com/docs/pgd/latest/durability/group-commit/

\pset footer off

select 'Preparing commit scope config....';

-- Revome commit scope
SELECT bdr.remove_commit_scope(
    commit_scope_name := 'example_scope',
    origin_node_group := 'dc1_subgroup');

SELECT bdr.add_commit_scope(
    commit_scope_name := 'example_scope',
    origin_node_group := 'dc1_subgroup',
    rule := 'ANY 2 (dc1_subgroup) SYNCHRONOUS_COMMIT',
    wait_for_ready := true
);

select 'Waiting for 15 seconds....';
select pg_sleep(15);
select 'Starting test...';

DROP TABLE test;
CREATE TABLE test (id int, description varchar(100));

TRUNCATE TABLE test;

BEGIN;
  SET LOCAL bdr.commit_scope = 'example_scope';
  INSERT INTO test (description) SELECT 'test' FROM generate_series(1, 100000);
COMMIT;
select 'Test finished.';

-- Check that insert take more time to commit because commit almost in one different node
