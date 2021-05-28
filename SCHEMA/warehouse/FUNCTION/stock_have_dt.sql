CREATE OR REPLACE FUNCTION warehouse.stock_have_dt(_dt date) RETURNS TABLE(dt date, cnt integer)
    LANGUAGE sql
    AS $$
	SELECT ws.stock_dt            dt,
	       SUM (ws.quantity)      cnt
	FROM   warehouse.wb_stock  AS ws
	WHERE  ws.stock_dt = _dt
	GROUP BY
	       ws.stock_dt;
$$;

ALTER FUNCTION warehouse.stock_have_dt(_dt date) OWNER TO postgres;

GRANT ALL ON FUNCTION warehouse.stock_have_dt(_dt date) TO user1c;
