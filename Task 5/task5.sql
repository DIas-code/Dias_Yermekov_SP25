--1. JOIN METHODS
--Read about PostgreSQL parameters enable_nestloop, enable_hashjoin, enable_mergejoin and how they can be used to instruct the planner to choose a join method.
--Task Results: Provide queries where needed. Read the plan and describe what happened and why with screenshots where needed.
--Performing tasks below you can modify not only queries but tables whatever you want: add, delete rows, indexes and etc.
--1.1. TASK 1: NESTED LOOP JOIN
--1. Create test tables and populate them with test data:
CREATE TABLE test_joins_a
(
id1 int,
id2 int
);

CREATE TABLE test_joins_b
(
id1 int,
id2 int
);

INSERT INTO test_joins_a values(generate_series(1,1000000),3);

INSERT INTO test_joins_b values(generate_series(1,1000000),3);

ANALYZE; -- analyze of all tables

--2. Check how NESTED LOOP JOIN method is used in below queries. Why?
--You can only see a MERGE JOIN and HASH JOIN when joining in an equality condition, not an inequality or a range.
SELECT * FROM test_joins_a a, test_joins_b b
WHERE a.id1 > b.id1;

-- a NESTED LOOP is the only way to execute a CROSS JOIN
SELECT *
FROM test_joins_a a
CROSS JOIN test_joins_b b;

--1.2 TASK 2: HASH JOIN
--1. Rewrite SELECT to instruct the planner to use HASH JOIN method:
EXPLAIN ANALYZE SELECT * FROM test_joins_a a, test_joins_b b
WHERE a.id1 = b.id1;
--2. Create query with SEMI JOIN between tables to get HASH SEMI JOIN in the plan.
EXPLAIN ANALYZE SELECT * FROM test_joins_a a
WHERE EXISTS(SELECT 1 FROM test_joins_b b WHERE a.id1 = b.id1);
--3. Set enable_hashjoin to off and recheck plan. Switch on enable_hashjoin.
SET enable_hashjoin = OFF;
SET enable_hashjoin = ON;
--1.3 TASK 3: MERGE JOIN
--1. Using tables test_joins_a and test_joins_b create a query which is use MERGE JOIN as a join
--method.
TRUNCATE test_joins_a;

INSERT INTO test_joins_a (id1, id2)
SELECT
    (i * 2) + (CASE WHEN random() < 0.05 THEN 1 ELSE 0 END),
    (random() * 10)::int
FROM generate_series(1, 500000) AS s(i);

TRUNCATE test_joins_b;

INSERT INTO test_joins_b (id1, id2)
SELECT
    (i * 2 - 1) + (CASE WHEN random() < 0.03 THEN 1 ELSE 0 END),
    (random() * 10)::int
FROM generate_series(1, 600000) AS s(i);

CREATE INDEX idx_a_id1 ON test_joins_a(id1);
CREATE INDEX idx_b_id1 ON test_joins_b(id1);
ANALYZE;
EXPLAIN ANALYZE SELECT * FROM test_joins_a a, test_joins_b b
WHERE a.id1 = b.id1;
--2. Set enable_mergejoin to off and recheck plan. Switch on enable_mergejoin.
SET enable_mergejoin = OFF;
EXPLAIN ANALYZE SELECT * FROM test_joins_a a, test_joins_b b
WHERE a.id1 = b.id1;

SET enable_mergejoin = ON;



--2. JOIN ORDER AND LATERAL JOIN
--2.1 TASK 4: CHANGING JOIN ORDER
--1. Create a table and populate it with sample data:
CREATE TABLE test_joins_c
(
id1 int,
id2 int
);
INSERT INTO test_joins_c
values(generate_series(1,1000000),(random()*10)::int);
--2. Check the plan. Describe the order of tables joining:
ANALYZE;
EXPLAIN ANALYZE
SELECT c.id2
FROM test_joins_b b
JOIN test_joins_a a on (b.id1 = a.id1)
LEFT JOIN test_joins_c c on (c.id1 = b.id1);
--3. Set join_collapse_limit = 1 and recreate plan for query above. Describe changes if any. Return
--join_collapse_limit = 8.

SET join_collapse_limit = 1;

EXPLAIN ANALYZE
SELECT c.id2
FROM test_joins_b b
JOIN test_joins_c c on (b.id1 = c.id1)
LEFT JOIN test_joins_a a on (a.id1 = b.id1);

--2.2 TASK 5: LATERAL JOIN
--1. Create tables and populate them by data:
CREATE TABLE orders AS
SELECT id AS order_id,
 (id * 10 * random()*10)::int AS order_cost,
 'order number ' || id AS order_num
FROM generate_series(1, 1000) AS id;

CREATE TABLE stores (
store_id int,
store_name text,
max_order_cost int
);

INSERT INTO stores VALUES
 (1, 'grossery shop', '800'),
 (2, 'bakery', '100'),
 (3, 'manufactured goods', '3000')
;

--2. Create a query to find TOP 10 of orders by it cost for each store. So, on the output you should
--have 10 orders for each store (or less, depends on sample random data) with cost less than
--max_order_cost. Use LATERAL join.

SELECT
    s.store_id,
    s.store_name,
    o.order_id,
    o.order_cost,
    o.order_num
FROM
    stores s
LEFT JOIN LATERAL (
    SELECT *
    FROM orders o
    WHERE o.order_cost < s.max_order_cost
    ORDER BY o.order_cost DESC
    LIMIT 10
) o ON true;


--3. CTES
--3.1 TASK 6: RECURSIVE CTE
--1. Use emp table you created before. Select all employee and his manager name and level of
--management start from president of the company

WITH RECURSIVE emp_hierarchy AS (
	SELECT empno, ename, job, mgr, NULL::TEXT AS mgr_name, 1 AS hierarchy_level FROM emp
	WHERE mgr IS NULL
	UNION ALL 
	SELECT e.empno, e.ename, e.job, e.mgr, h.ename AS mgr_name, h.hierarchy_level + 1 AS hierarchy_level
	FROM emp e
	JOIN emp_hierarchy h ON e.mgr = h.empno
)
SELECT * FROM emp_hierarchy ;

--3.2 TASK 7: CHANGING DATA CTE
--1. Create log table for emp table:
CREATE TABLE order_log
(
log_id integer primary key generated always as identity,
order_id integer,
order_cost integer,
order_num text,
 action_type varchar(1) CHECK (action_type IN ('U','D')),
 log_date TIMESTAMPTZ DEFAULT Now()
);
--2. Update all rows for ORDER table:
--a. set new ORDER_COST = (old ORDER_COST / 2) where old ORDER_COST between 100 and 1000
--b. delete all rows where ORDER_COST < 50
--c. save all updated and deleted rows into log table with action type ‘U’ and ‘D’ relatively.
--Perform all in one SQL CTE query.
WITH orders_to_update AS (
	SELECT * FROM orders
	WHERE order_cost BETWEEN 100 AND 1000
),
insert_log_update AS(
	INSERT INTO order_log (order_id, order_cost, order_num, action_type)
	SELECT order_id, order_cost, order_num, 'U'
    FROM orders_to_update
    RETURNING *
),
update_orders AS(
	UPDATE orders 
	SET order_cost = order_cost/2
	WHERE order_id IN (SELECT order_id FROM orders_to_update)
	RETURNING *
),
orders_to_delete AS (
	SELECT * FROM orders
	WHERE order_cost < 50
),
insert_log_delete AS(
	INSERT INTO order_log (order_id, order_cost, order_num, action_type)
	SELECT order_id, order_cost, order_num, 'D'
    FROM orders_to_delete
    RETURNING *
),
delete_orders AS(
	DELETE FROM orders
	WHERE order_id IN (SELECT order_id FROM orders_to_delete)
	RETURNING *
)
SELECT * FROM insert_log_update
UNION ALL
SELECT * FROM insert_log_delete
ORDER BY log_date DESC;

SELECT * FROM order_log;







