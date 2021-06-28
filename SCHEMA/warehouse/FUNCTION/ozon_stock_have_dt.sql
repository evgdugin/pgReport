CREATE OR REPLACE FUNCTION warehouse.ozon_stock_have_dt(_dt date) RETURNS TABLE(dt date, cnt integer)
    LANGUAGE sql
    AS $$
	SELECT ws.stock_dt            dt,
	       SUM (ws.present)      cnt
	FROM   warehouse.ozon_stock  AS ws
	WHERE  ws.stock_dt = _dt
	GROUP BY
	       ws.stock_dt;
$$;

ALTER FUNCTION warehouse.ozon_stock_have_dt(_dt date) OWNER TO postgres;
