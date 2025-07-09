CREATE TABLE IF NOT EXISTS public.employee(
id SERIAL,
"name" VARCHAR(20),
status VARCHAR(30)
);



SHOW TRANSACTION ISOLATION LEVEL;

-- first transaction
begin;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SHOW TRANSACTION ISOLATION LEVEL;
select txid_current();

INSERT INTO public.employee ("name", status)
VALUES 
    ('Alice', 'Not fired'),
    ('Alice2', 'Not fired'),
    ('Alice3', 'Not fired');


select *, xmin, xmax, cmin, cmax
from public.employee e;

commit;



-- second transaction
begin;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SHOW TRANSACTION ISOLATION LEVEL;
select *, xmin, xmax, cmin, cmax
from public.employee e;

select *, xmin, xmax, cmin, cmax
from public.employee e;

commit;
/*
 2.5
With REPEATABLE READ we don't see before commit in Session A  deleted  in SesB datas
after commit of 2nd transaction in SesB 
 */




--
insert into public.employee ("name", status)
values ('Alice', 'Not fired');
--

-- third transaction
begin;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SHOW TRANSACTION ISOLATION LEVEL;
select *, xmin, xmax, cmin, cmax
from public.employee e;

select *, xmin, xmax, cmin, cmax
from public.employee e;

commit;

/*
In REPEATABLE READ, Session B doesn’t see changes made by Session A 
until Session B commits and starts a new transaction.

And vice versa:
Session A also doesn’t see changes made by Session B 
until it commits and starts a new transaction.
*/

/*
 This is because REPEATABLE READ provides a consistent snapshot at the start of the transaction,
ignoring any changes committed by other sessions afterward.
 */

