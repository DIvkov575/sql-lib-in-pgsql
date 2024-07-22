

create or replace function lin_reg (in tbl regclass)
    returns table(slope float, intercept float)
    language plpgsql
as $$
    SELECT slope, y_max - x_max * slope as intercept
    FROM (
             SELECT
                 SUM((x - x_bar) * (y - y_bar)) / SUM((x - x_bar) * (x - x_bar)) as slope,
                 MAX(x_bar) as x_max,
                 MAX(y_bar) as y_max
             FROM (
                      EXECUTE format("SELECT x, AVG(x)OVER() as x_bar, y, AVG(y)OVER() as y_bar FROM %s", tbl)
                  )
         );

$$;


select * from lin_reg('linear_tb');