select * from country

select table_name, constraint_schema , constraint_type
from information_schema.table_constraints tc 
where constraint_type ='PRIMARY KEY' and constraint_schema  = 'dvd-rental'