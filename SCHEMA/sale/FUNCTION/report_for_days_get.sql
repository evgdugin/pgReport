CREATE OR REPLACE FUNCTION sale.report_for_days_get(_date date, _sa_name character varying, _ts_name character varying) RETURNS TABLE(dt date, sale_qty bigint, return_qty bigint, margin numeric, qty_for_sale bigint, order_qty bigint)
    LANGUAGE plpgsql
    AS $$
	DECLARE
		_sa_id       INT;
		_whprice     NUMERIC (15, 2);
		_ts_id       INT;
	BEGIN
		_sa_id := (
			SELECT sa.sa_id
			FROM   products.supplier_article AS sa
			WHERE  sa.sa_name = _sa_name
		);
		
		_whprice := (
			SELECT sc.whprice
			FROM   products.sa_cost AS sc
			WHERE  sc.sa_id = _sa_id
		);
		
		_ts_id := (
			SELECT ts.ts_id
			FROM   products.tech_size AS ts
			WHERE  ts.ts_name = _ts_name
			       AND ts.ts_name != ''
		);
		
		RETURN query(
			SELECT d.dt,
			       vs.sale_qty,
			       vs.return_qty,
			       CASE 
			       	WHEN vs.sale_amount = 0
		       	     	OR vs.sale_qty = 0 THEN 0
			          	ELSE ((vs.sale_amount / vs.sale_qty) - _whprice) * 100 / (vs.sale_amount / vs.sale_qty)
			          END              margin,
			          wbs.qty_for_sale,
			          wbo.order_qty
			   FROM   refbook.days  AS d
			          LEFT JOIN (
			               	SELECT drd.sale_dt,
			               	       SUM (CASE WHEN drd.quantity > 0 THEN drd.quantity ELSE 0 END) sale_qty,
			               	       SUM (drd.total_price) sale_amount,
			               	       SUM (CASE WHEN drd.quantity < 0 THEN -drd.quantity ELSE 0 END) return_qty
			               	FROM   sale.day_report_detail AS drd
			               	       INNER JOIN products.barcodes AS b
			               	            ON  b.barcode_id = drd.barcode_id
			               	WHERE  b.sa_id = _sa_id
			               	       AND (_ts_id IS NULL OR b.ts_id = _ts_id)
			               	       AND drd.sale_dt >= _date
			               	GROUP BY
			               	       drd.sale_dt
			               ) vs
			               ON  d.dt = vs.sale_dt
			          LEFT JOIN (
			               	SELECT ws.stock_dt,
			               	       SUM (ws.quantity) qty_for_sale
			               	FROM   warehouse.wb_stock AS ws
			               	       INNER JOIN products.barcodes AS b
			               	            ON  b.barcode_id = ws.barcode_id
			               	WHERE  ws.stock_dt >= _date
			               	       AND b.sa_id = _sa_id
			               	       AND (_ts_id IS NULL OR b.ts_id = _ts_id)
			               	GROUP BY
			               	       ws.stock_dt
			               ) wbs
			               ON  d.dt = wbs.stock_dt
			          LEFT JOIN (
			               	SELECT ord.order_dt,
			               	       SUM (ord.quantity) order_qty
			               	FROM   sale.order_report_detail AS ord
			               	       INNER JOIN products.barcodes AS b
			               	            ON  b.barcode_id = ord.barcode_id
			               	WHERE  ord.order_dt >= _date
			               	       AND b.sa_id = _sa_id
			               	       AND (_ts_id IS NULL OR b.ts_id = _ts_id)
			               	GROUP BY
			               	       ord.order_dt
			               )wbo
			               ON  wbo.order_dt = d.dt
			   WHERE  d.dt >= _date
			          AND d.dt <= now()::DATE
			   ORDER BY
			          d.dt
		);
	END;
$$;

ALTER FUNCTION sale.report_for_days_get(_date date, _sa_name character varying, _ts_name character varying) OWNER TO postgres;
