SELECT slope, y_max - x_max * slope as intercept
FROM (
         SELECT
             SUM((x - x_bar) * (y - y_bar)) / SUM((x - x_bar) * (x - x_bar)) as slope,
             MAX(x_bar) as x_max,
             MAX(y_bar) as y_max
         FROM (
                  SELECT
                      x, AVG(x) OVER() as x_bar,
                          y, AVG(y) OVER() as y_bar
                  FROM  tb1
              )
     )

