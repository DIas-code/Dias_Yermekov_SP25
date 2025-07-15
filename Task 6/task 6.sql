--1. PARTITIONING
--Task Results: Provide queries where needed. Describe what happened and why with screenshots where
--needed.
--1.1 TASK 1: USE INHERITANCE
--Create table:
CREATE TABLE SALES_INFO
(
id INTEGER,
category VARCHAR(1),
ischeck BOOLEAN,
eventdate DATE
);
--Apply partitioning by using inheritance:
--1. Create 4-5 child tables with partitioning by eventdate column. One partition is one year.
CREATE TABLE sales_info_2021 (
    CHECK (eventdate >= DATE '2021-01-01' AND eventdate < DATE '2022-01-01')
) INHERITS (sales_info);

CREATE TABLE sales_info_2022 (
    CHECK (eventdate >= DATE '2022-01-01' AND eventdate < DATE '2023-01-01')
) INHERITS (sales_info);

CREATE TABLE sales_info_2023 (
    CHECK (eventdate >= DATE '2023-01-01' AND eventdate < DATE '2024-01-01')
) INHERITS (sales_info);

CREATE TABLE sales_info_2024 (
    CHECK (eventdate >= DATE '2024-01-01' AND eventdate < DATE '2025-01-01')
) INHERITS (sales_info);
--2. Create partition function for your tables. Use following as a template:
CREATE OR REPLACE FUNCTION partition_sales_info() RETURNS trigger
as $$
 BEGIN
 IF (new.eventdate >= '2021-01-01'::DATE AND
 new.eventdate < '2022-01-01'::DATE) THEN
 INSERT INTO sales_info_2021 VALUES (new.*) ;
 ELSEIF (new.eventdate >= '2022-01-01'::DATE AND
 new.eventdate < '2023-01-01'::DATE) then
 INSERT INTO sales_info_2022 VALUES (new.*) ;
 ELSEIF (new.eventdate >= '2023-01-01'::DATE AND
 new.eventdate < '2024-01-01'::DATE) then
 INSERT INTO sales_info_2023 VALUES (new.*) ;
 ELSEIF (new.eventdate >= '2024-01-01'::DATE AND
 new.eventdate < '2025-01-01'::DATE) then
 INSERT INTO sales_info_2024 VALUES (new.*) ;
 ELSE
 RAISE EXCEPTION 'Out of range';
END IF;
RETURN NULL;
END;
$$ language plpgsql;
--3. Create trigger for your function and tables. Use following as a template:
CREATE TRIGGER partition_sales_info_trigger
 BEFORE INSERT ON sales_info
 FOR EACH ROW EXECUTE PROCEDURE partition_sales_info();
--4. Generate test data and insert in SALES_INFO table:
INSERT
	INTO
	sales_info(id, category, ischeck, EventDate)
SELECT
	id,
	('{"A","B","C","D","E","F","J","H","I","J","K"}'::text[])[(
(RANDOM())* 10)::INTEGER] category,
	((1 *(RANDOM())::INTEGER)<1) ischeck,
	(DATE '2021-01-01' + (random() * 1460)::int) EventDate
FROM
	generate_series(1, 10000000) id;
--5. Update some rows in SALES_INFO and set another eventdate.
SELECT count(*) FROM sales_info_2024 s ;
WITH to_move AS (
  SELECT * FROM sales_info_2024 LIMIT 1000
),
delete_old AS (
  DELETE FROM sales_info_2024
  WHERE id IN (SELECT id FROM to_move)
),
insert_new as(INSERT INTO sales_info(id, category, ischeck, eventdate)
SELECT id, category, ischeck, DATE '2021-06-01'
FROM to_move
RETURNING *
)
SELECT * FROM insert_new;

SELECT count(*) FROM sales_info_2024 s ;

SELECT count(*) FROM sales_info_2024 s ;
--6. Create table SALES_INFO_SIMPLE with the same structure as SALES_INFO but without
--partitioning. Insert test data from the 5th step. Compare plans of different queries:
--• Select all
--• Select with range of dates
--• Select exact date
--• Count of all rows
--• Count of rows with range of dates

CREATE TABLE sales_info_simple (
    id INTEGER,
    category VARCHAR(1),
    ischeck BOOLEAN,
    eventdate DATE
);

INSERT INTO sales_info_simple(id, category, ischeck, eventdate)
SELECT id, category, ischeck, DATE '2021-06-01'
FROM sales_info_2021
LIMIT 1000;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM sales_info;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM sales_info_simple;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM sales_info
WHERE eventdate BETWEEN '2021-01-01' AND '2021-12-31';

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM sales_info_simple
WHERE eventdate BETWEEN '2021-01-01' AND '2021-12-31';

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM sales_info
WHERE eventdate = '2021-06-01';

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM sales_info_simple
WHERE eventdate = '2021-06-01';

EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*) FROM sales_info;

EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*) FROM sales_info_simple;

EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*) FROM sales_info
WHERE eventdate BETWEEN '2021-01-01' AND '2021-12-31';

EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*) FROM sales_info_simple
WHERE eventdate BETWEEN '2021-01-01' AND '2021-12-31';

--7. Delete one of partition (the oldest one). Create some general table like sales_info_3000 with
--the same structure as sales_info and add it as new partition.

DROP TABLE sales_info_2021;

CREATE TABLE sales_info_3000 (
    CHECK (eventdate >= DATE '3000-01-01' AND eventdate < DATE '3001-01-01')
) INHERITS (sales_info);



--1.2 TASK2: USE DECLARATIVE PARTITIONING
--1. Create table SALES_INFO_DP with structure:
CREATE TABLE sales_info_dp (
    id INTEGER,
    category VARCHAR(1),
    ischeck BOOLEAN,
    eventdate DATE
) PARTITION BY RANGE (eventdate);
--And make it partitioned by eventdate.
--2. Create 4-5 child tables with partitioning by eventdate column. One partition is one year. Each
--child table should be partitioned by list on category column. Use 2 lists of values and one
--default partition here. As a result you should have SALES_INFO_DP table with composite
--partitioning by range and list.

CREATE TABLE sales_info_dp_2022 PARTITION OF sales_info_dp
    FOR VALUES FROM ('2022-01-01') TO ('2023-01-01')
    PARTITION BY LIST (category);

CREATE TABLE sales_info_dp_2022_abcde PARTITION OF sales_info_dp_2022
    FOR VALUES IN ('A','B','C','D','E');

CREATE TABLE sales_info_dp_2022_fgh PARTITION OF sales_info_dp_2022
    FOR VALUES IN ('F','G','H');

CREATE TABLE sales_info_dp_2022_default PARTITION OF sales_info_dp_2022
    DEFAULT;

CREATE TABLE sales_info_dp_2025 PARTITION OF sales_info_dp
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01')
    PARTITION BY LIST (category);

CREATE TABLE sales_info_dp_2025_abcde PARTITION OF sales_info_dp_2025
    FOR VALUES IN ('A','B','C','D','E');

CREATE TABLE sales_info_dp_2025_fgh PARTITION OF sales_info_dp_2025
    FOR VALUES IN ('F','G','H');

CREATE TABLE sales_info_dp_2025_default PARTITION OF sales_info_dp_2025
    DEFAULT;

--3. Add date to partitioned table:
INSERT INTO SALES_INFO_DP(id,category, ischeck, EventDate)
SELECT id
,('{"A","B","C","D","E","F","J","H","I","J","K"}'::text[])[((
RANDOM())*10)::INTEGER] category
 ,((1*(RANDOM())::INTEGER)<1) ischeck
 ,(NOW() - '10 day'::INTERVAL * (RANDOM()::int * 100))::
DATE EventDate
FROM generate_series(1,10000000) id;
--4. Update some rows in SALES_INFO_DP and set another category.

UPDATE sales_info_dp
SET category = 'Z'
WHERE category = 'A'
  AND eventdate BETWEEN '2022-01-01' AND '2023-01-01'
  AND id < 100;


--5. Compare plans of different queries for tables SALES_INFO_DP and SALES_INFO_SIMPLE:
-- 1. Select all
EXPLAIN ANALYZE SELECT * FROM sales_info_dp;
EXPLAIN ANALYZE SELECT * FROM sales_info_simple;

-- 2. Select with range of dates
EXPLAIN ANALYZE SELECT * FROM sales_info_dp WHERE eventdate BETWEEN '2022-01-01' AND '2023-01-01';
EXPLAIN ANALYZE SELECT * FROM sales_info_simple WHERE eventdate BETWEEN '2022-01-01' AND '2023-01-01';

-- 3. Select exact date
EXPLAIN ANALYZE SELECT * FROM sales_info_dp WHERE eventdate = '2022-06-01';
EXPLAIN ANALYZE SELECT * FROM sales_info_simple WHERE eventdate = '2022-06-01';

-- 4. Select exact category
EXPLAIN ANALYZE SELECT * FROM sales_info_dp WHERE category = 'A';
EXPLAIN ANALYZE SELECT * FROM sales_info_simple WHERE category = 'A';

-- 5. Select a list of categories
EXPLAIN ANALYZE SELECT * FROM sales_info_dp WHERE category IN ('A','B','C');
EXPLAIN ANALYZE SELECT * FROM sales_info_simple WHERE category IN ('A','B','C');

-- 6. Select a list of categories in exact date
EXPLAIN ANALYZE SELECT * FROM sales_info_dp WHERE category IN ('A','B','C') AND eventdate = '2022-06-01';
EXPLAIN ANALYZE SELECT * FROM sales_info_simple WHERE category IN ('A','B','C') AND eventdate = '2022-06-01';

-- 7. Count of all rows
EXPLAIN ANALYZE SELECT COUNT(*) FROM sales_info_dp;
EXPLAIN ANALYZE SELECT COUNT(*) FROM sales_info_simple;

-- 8. Count of rows with range of dates
EXPLAIN ANALYZE SELECT COUNT(*) FROM sales_info_dp WHERE eventdate BETWEEN '2022-01-01' AND '2023-01-01';
EXPLAIN ANALYZE SELECT COUNT(*) FROM sales_info_simple WHERE eventdate BETWEEN '2022-01-01' AND '2023-01-01';



--6. For one of the child tables with range partition by eventdate split one list partition for two. For
--example:
SALES_INFO_DP_2020_A PARTITION OF SALES_INFO_DP_2020 FOR VALUES IN
('A','B','C','D','E') => SALES_INFO_DP_2020_A PARTITION OF SALES_INFO_DP_2020 FOR
VALUES IN ('A','B','C') and SALES_INFO_DP_2020_A PARTITION OF SALES_INFO_DP_2020
FOR VALUES IN ('D','E')
Return partition ('A','B','C','D','E'). Drop newly created (for ('A','B','C') and ('D','E')).



--2. PARALLEL EXECUTION
--2.1 TASK 3: USE PARALLEL QUERING
--1. Add parallel workers:
set max_parallel_workers_per_gather=4;
--2. Analyze plans for tables SALES_INFO, SALES_INFO_DP and SALES_INFO_SIMPLE by querying:
--a. Select all from tables
SHOW enable_parallel_append;
SET parallel_setup_cost = 0;
SET parallel_tuple_cost = 0;
EXPLAIN ANALYZE SELECT * FROM sales_info;
EXPLAIN ANALYZE SELECT * FROM sales_info_dp;
EXPLAIN ANALYZE SELECT * FROM sales_info_simple;
--b. Add order by eventadate
EXPLAIN ANALYZE SELECT * FROM sales_info ORDER BY eventdate;
EXPLAIN ANALYZE SELECT * FROM sales_info_dp ORDER BY eventdate;
EXPLAIN ANALYZE SELECT * FROM sales_info_simple ORDER BY eventdate;

--c. Select count of all rows
EXPLAIN ANALYZE SELECT COUNT(*) FROM sales_info;
EXPLAIN ANALYZE SELECT COUNT(*) FROM sales_info_dp;
EXPLAIN ANALYZE SELECT COUNT(*) FROM sales_info_simple;

--d. Add range of dates
EXPLAIN ANALYZE
SELECT * FROM sales_info
WHERE eventdate BETWEEN '2022-01-01' AND '2023-01-01';


EXPLAIN ANALYZE
SELECT * FROM sales_info_dp
WHERE eventdate BETWEEN '2022-01-01' AND '2023-01-01';

EXPLAIN ANALYZE
SELECT * FROM sales_info_simple
WHERE eventdate BETWEEN '2022-01-01' AND '2023-01-01';

--e. Add grouping by category
EXPLAIN ANALYZE
SELECT category, COUNT(*) FROM sales_info
GROUP BY category;

EXPLAIN ANALYZE
SELECT category, COUNT(*) FROM sales_info_dp
GROUP BY category;

EXPLAIN ANALYZE
SELECT category, COUNT(*) FROM sales_info_simple
GROUP BY category;

--f. Join SALES_INFO and SALES_INFO_DP on id and count rows on exact date.
EXPLAIN ANALYZE
SELECT COUNT(*)
FROM sales_info s
JOIN sales_info_dp d ON s.id = d.id
WHERE d.eventdate = '2022-06-01';

--3. Add indexes on any of table with partitions. Check how plans are change.

CREATE INDEX idx_sales_dp_eventdate ON sales_info_dp(eventdate);
CREATE INDEX idx_sales_dp_category ON sales_info_dp(category);

--a. Select all from tables
EXPLAIN ANALYZE SELECT * FROM sales_info_dp;

--b. Add order by eventadate

EXPLAIN ANALYZE SELECT * FROM sales_info_dp ORDER BY eventdate;


--c. Select count of all rows

EXPLAIN ANALYZE SELECT COUNT(*) FROM sales_info_dp;


--d. Add range of dates



EXPLAIN ANALYZE
SELECT * FROM sales_info_dp
WHERE eventdate BETWEEN '2022-01-01' AND '2023-01-01';


--e. Add grouping by category

EXPLAIN ANALYZE
SELECT category, COUNT(*) FROM sales_info_dp
GROUP BY category;














