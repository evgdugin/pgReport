CREATE OR REPLACE FUNCTION warehouse.stock_get() RETURNS TABLE(pants_id integer, sa_name character varying, ts_name character varying, brand_name character varying, art_name character varying, subject_name character varying, nm_id integer, whprice numeric, qty smallint, wb_stock bigint, sale_qty_week bigint, sale_amount_week numeric, sale_qty_moth bigint, sale_amount_month numeric, sale_qty_quarter bigint, sale_amount_quarter numeric, quarter_margin numeric, in_way_to_client smallint, in_way_from_client smallint, days_on_site smallint, order_qty_week bigint)
    LANGUAGE sql
    AS $$
	SELECT s.pants_id,
	       sa.sa_name,
	       ts.ts_name,
	       b.brand_name,
	       sc.art_name,
	       sj.subject_name,
	       bc.nm_id,
	       s.whprice,
	       s.qty,
	       wbs.wb_stock,
	       wbsw.sale_qty                    sale_qty_week,
	       wbsw.sale_amount                 sale_amount_week,
	       wbsm.sale_qty                    sale_qty_moth,
	       wbsm.sale_amount                 sale_amount_month,
	       wbs4m.sale_qty                   sale_qty_quarter,
	       wbs4m.sale_amount                sale_amount_quarter,
	       CASE 
	       	WHEN wbs4m.sale_qty = 0 OR wbs4m.sale_qty IS NULL THEN 0
	       	ELSE ((wbs4m.sale_amount / wbs4m.sale_qty) - s.whprice) / (wbs4m.sale_amount / wbs4m.sale_qty) * 100
	       END                              quarter_margin,
	       wbw.in_way_to_client,
	       wbw.in_way_from_client,
	       wbs.days_on_site,
	       wbow.order_qty                   order_qty_week
	FROM   warehouse.stock s
	       INNER JOIN products.barcodes  AS bc
	            ON  bc.barcode_id = s.barcode_id
	       INNER JOIN products.supplier_article sa
	            ON  sa.sa_id = bc.sa_id
	       INNER JOIN products.tech_size ts
	            ON  ts.ts_id = bc.ts_id
	       LEFT JOIN products.barcodes_info AS bi
	            ON  bi.barcode_id = s.barcode_id
	       LEFT JOIN products.brands     AS b
	            ON  b.brand_id = bi.brand_id
	       LEFT JOIN products.subjects   AS sj
	            ON  sj.subject_id = bi.subject_id
	       LEFT JOIN products.sa_cost    AS sc
	            ON  sc.sa_id = sa.sa_id
	       LEFT JOIN (
	            	SELECT ws.barcode_id,
	            	       SUM (ws.quantity_not_in_orders) wb_stock,
	            	       MIN (ws.days_on_site) days_on_site
	            	FROM   warehouse.wb_stock AS ws
	            	WHERE  ws.stock_dt = now()::DATE
	            	GROUP BY
	            	       ws.barcode_id
	            ) wbs
	            ON  wbs.barcode_id = s.barcode_id
	       LEFT JOIN (
	            	SELECT drd.barcode_id,
	            	       SUM (drd.quantity) sale_qty,
	            	       SUM (drd.finished_price) sale_amount
	            	FROM   sale.day_report_detail AS drd
	            	WHERE  drd.sale_dt > now()::DATE - INTERVAL'14 day'
	            	GROUP BY
	            	       drd.barcode_id
	            ) wbsw
	            ON  wbsw.barcode_id = s.barcode_id
	       LEFT JOIN (
	            	SELECT drd2.barcode_id,
	            	       SUM (drd2.quantity) sale_qty,
	            	       SUM (drd2.finished_price) sale_amount
	            	FROM   sale.day_report_detail AS drd2
	            	WHERE  drd2.sale_dt > now()::DATE - INTERVAL'30 day'
	            	GROUP BY
	            	       drd2.barcode_id
	            ) wbsm
	            ON  wbsm.barcode_id = s.barcode_id
	       LEFT JOIN (
	            	SELECT drd.barcode_id,
	            	       SUM (drd.quantity) sale_qty,
	            	       SUM (drd.finished_price) sale_amount
	            	FROM   sale.day_report_detail AS drd
	            	WHERE  drd.sale_dt > now()::DATE - INTERVAL'120 day'
	            	GROUP BY
	            	       drd.barcode_id
	            ) wbs4m
	            ON  wbs4m.barcode_id = s.barcode_id
	       LEFT JOIN (
	            	SELECT ws.barcode_id,
	            	       MAX (ws.in_way_to_client) in_way_to_client,
	            	       MAX (ws.in_way_from_client) in_way_from_client
	            	FROM   warehouse.wb_stock AS ws
	            	WHERE  ws.stock_dt >= now()::DATE - INTERVAL'7 day'
	            	GROUP BY
	            	       ws.barcode_id
	            ) wbw
	            ON  wbw.barcode_id = s.barcode_id
	       LEFT JOIN (
	            	SELECT ord.barcode_id,
	            	       SUM (ord.quantity) order_qty
	            	FROM   sale.order_report_detail AS ord
	            	WHERE  ord.order_dt >= now()::DATE - INTERVAL'14 day'
	            	GROUP BY
	            	       ord.barcode_id
	            ) wbow
	            ON  wbow.barcode_id = s.barcode_id
	ORDER BY
	       sa.sa_name,
	       ts.ts_name ;
$$;

ALTER FUNCTION warehouse.stock_get() OWNER TO postgres;
