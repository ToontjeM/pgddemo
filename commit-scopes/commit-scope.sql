-- Sample:
-- https://www.enterprisedb.com/docs/pgd/latest/durability/group-commit/

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

-- Problem with group commit
-- https://edb.slack.com/archives/C03UY95D2TA/p1703094099805349?thread_ts=1691405149.506519&cid=C03UY95D2TA

DROP TABLE test;
CREATE TABLE test (id int, description varchar(100));

SELECT count(*) from test;

TRUNCATE TABLE test;

BEGIN;
  SET LOCAL bdr.commit_scope = 'example_scope';
  INSERT INTO test (description) SELECT 'test' FROM generate_series(1, 100000);
COMMIT;

SELECT bdr.remove_commit_scope(
    commit_scope_name := 'example_scope',
    origin_node_group := 'dc1_subgroup');

SELECT bdr.add_commit_scope(
    commit_scope_name := 'example_scope',
    origin_node_group := 'dc1_subgroup',
    rule := 'ANY 2 (dc1_subgroup) SYNCHRONOUS_COMMIT',
    wait_for_ready := false
);


SELECT bdr.alter_commit_scope(
    commit_scope_name := 'example_scope',
    origin_node_group := 'dc1_subgroup',
    rule := 'ANY 2 (dc1_subgroup) SYNCHRONOUS_COMMIT',
    wait_for_ready := false
);

-- Check with pgAdmin psql transactions or in pg_stat_activity
\x
select *
from pg_stat_activity
where application_name='psql.bin';
\x

SELECT bdr.remove_commit_scope(
    commit_scope_name := 'example_scope',
    origin_node_group := 'dc1_subgroup');

-- test end


SELECT bdr.alter_node_group_option(
  node_group_name := 'example_bdr_group',
  config_key := 'default_commit_scope',
  config_value := 'example_scope'
);

--pgd set-group-options us_east_2_subgroup --option default_commit_scope=example_scope

-- create sub-groups
SELECT bdr.create_node_group(
    node_group_name := 'left_dc',
    parent_group_name := 'top_group',
    join_node_group := false
);
SELECT bdr.create_node_group(
    node_group_name := 'right_dc',
    parent_group_name := 'top_group',
    join_node_group := false
);

-- create a commit scope with individual rules
-- for each sub-group
SELECT bdr.add_commit_scope(
    commit_scope_name := 'example_scope',
    origin_node_group := 'left_dc',
    rule := 'ALL (left_dc) GROUP COMMIT AND ANY 1 (right_dc) GROUP COMMIT',
    wait_for_ready := true
);
SELECT bdr.add_commit_scope(
    commit_scope_name := 'example_scope',
    origin_node_group := 'right_dc',
    rule := 'ANY 1 (left_dc) GROUP COMMIT AND ALL (right_dc) GROUP COMMIT',
    wait_for_ready := true
);