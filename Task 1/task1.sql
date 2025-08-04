--2. UNDERSTANDING DATABASE AND TABLESPACES
-- 2.1 TASK 1 CREATE NEW DATABASE
-- 1 Connect to the postgres Database and create new one named “test_db”.
CREATE DATABASE test_db;

-- 2 Run query, investigate result:
select d.oid, d.datname, d.datistemplate, d.datallowconn, t.spcname
from pg_database d
join pg_tablespace t on t.oid = d.dattablespace;


-- 2.2 TASK 2 CREATE NEW TABLESPACE
-- 1 Create new tablespace “mytablespace” with location “C:/Program Files/PostgreSQL/17/data/tblspc_test/”.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_tablespace WHERE spcname = 'mytablespace'
    ) THEN
        EXECUTE 'CREATE TABLESPACE mytablespace LOCATION ''C:/Program Files/PostgreSQL/17/data/tblspc_test/''';
    END IF;
END$$;


-- 2 Check your tablespace exists in pg_tablespace table:
select *
from pg_tablespace;

-- 3. Move test_db into new tablespace:
--SELECT pg_terminate_backend(pid)
--FROM pg_stat_activity
--WHERE datname = 'test_db';

ALTER DATABASE test_db SET TABLESPACE mytablespace;

select d.oid, d.datname, d.datistemplate, d.datallowconn, t.spcname
from pg_database d
join pg_tablespace t on t.oid = d.dattablespace;

--2.3 TASK 3 CREATE NEW SCHEMA
-- 1. Connect to test_db and create new schema named “labs”.
CREATE SCHEMA IF NOT EXISTS labs;
--2. In new schema create table named “person”:
CREATE TABLE IF NOT EXISTS labs.person (
id integer NOT NULL,
name varchar(15)
);
--Check the table:
SELECT schemaname, tablename FROM pg_tables
WHERE tablename = 'person';
--3. Insert into person table values (correct queries if needed):
INSERT INTO person VALUES(1, 'Bob');
INSERT INTO person VALUES(2, 'Alice');
INSERT INTO person VALUES(3, 'Robert');
--4. Use SHOW search_path and SET search_path to perform INSERTS from previous task without any correction.
SHOW search_path;
SET search_path TO labs;


--3. TRANSACTION AND VACUUMING

--3.1 TASK 4 INVESTIGATE MVCC*
--*you need to install extension before: 

CREATE EXTENSION IF NOT EXISTS pageinspect;

--Use queries:
select p.id, p.name, p.ctid, p.xmin, p.xmax from person p;

SELECT t_xmin, t_xmax, t_ctid,
tuple_data_split('labs.person'::regclass, t_data, t_infomask,
t_infomask2, t_bits)
FROM heap_page_items(get_raw_page('labs.person', 0));


--And investigate what is happening with xmin and xmax while performing following in different transactions:
INSERT INTO person VALUES(4, 'John');
UPDATE person set name = 'Alex' where id = 4;
DELETE FROM person WHERE id = 3;
INSERT INTO person VALUES(999, 'Test');
DELETE FROM person WHERE id = 999;


--3.2 TASK 5 INVESTIGATE VACUUM
--To Check what happened use:
SELECT t_xmin, t_xmax, t_ctid,
tuple_data_split('labs.person'::regclass, t_data, t_infomask,
t_infomask2, t_bits)
FROM heap_page_items(get_raw_page('labs.person', 0));
--1. Run:
vacuum labs.person;
--Check results.

--2. Run:
INSERT INTO person VALUES(5, 'Sarah');
--Check results.

--3. Run:
vacuum full labs.person;
--Check results.

