

-- first transaction
begin;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SHOW TRANSACTION ISOLATION LEVEL;
select *, xmin, xmax, cmin, cmax from public.employee e;

commit;
/*
2.5
With REPEATABLE READ we don't see before commit in Session B iserted in SesA datas
after commit of 1st transaction in SesA 

*/


-- second transaction
begin;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SHOW TRANSACTION ISOLATION LEVEL;
select txid_current();

delete from public.employee
where id = 1;

select *, xmin, xmax, cmin, cmax
from public.employee e;

commit;


-- third transaction
begin;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SHOW TRANSACTION ISOLATION LEVEL;
select txid_current();

update public.employee
set status = '2Yes2 Fired'
where id = 2;

select *, xmin, xmax, cmin, cmax
from public.employee e;

COMMIT;

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


