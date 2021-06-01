CREATE OR REPLACE FUNCTION warehouse.wb_stock_get() RETURNS TABLE(subject_name character varying, brand_name character varying, art_name character varying, nm_id integer, sa_name character varying, ts_name character varying, days_on_site smallint, whprice numeric, wb_stock bigint, wb_stock_quantity_full bigint, wb_stock_quantity_not_in_orders bigint, wb_stock_in_way_to_client bigint, wb_stock_in_way_from_client bigint, stock smallint, sale_qty_week bigint, sale_amount_week numeric, sale_qty_moth bigint, sale_amount_month numeric, sale_qty_quarter bigint, sale_amount_quarter numeric, quarter_margin numeric, order_qty_week bigint)
    LANGUAGE sql
    AS $$
	SELECT sj.subject_name,
	       b.brand_name,
	       sc.art_name,
	       sa.nm_id,
	       sa.sa_name,
	       ts.ts_name,
	       wbs.days_on_site,
	       sc.whprice,
	       wbs.wb_stock,
	       wbs.wb_stock_quantity_full,
	       wbs.wb_stock_quantity_not_in_orders,
	       wbs.wb_stock_in_way_to_client,
	       wbs.wb_stock_in_way_from_client,
	       s.qty                           stock,
	       wbsw.sale_qty                   sale_qty_week,
	       wbsw.sale_amount                sale_amount_week,
	       wbsm.sale_qty                   sale_qty_moth,
	       wbsm.sale_amount                sale_amount_month,
	       wbs4m.sale_qty                  sale_qty_quarter,
	       wbs4m.sale_amount               sale_amount_quarter,
	       CASE 
	       	WHEN wbs4m.sale_qty = 0 OR wbs4m.sale_amount = 0 OR wbs4m.sale_qty IS NULL THEN 0
	       	ELSE ((wbs4m.sale_amount / wbs4m.sale_qty) - s.whprice) / (wbs4m.sale_amount / wbs4m.sale_qty) * 100
	       END                             quarter_margin,
	       wbow.order_qty                  order_qty_week
	FROM   (
	       	SELECT ws.stock_dt,
	       	       ws.sats_id,
	       	       SUM (ws.quantity)         wb_stock,
	       	       SUM (ws.quantity_full) wb_stock_quantity_full,
	       	       SUM (ws.quantity_not_in_orders) wb_stock_quantity_not_in_orders,
	       	       SUM (ws.in_way_to_client) wb_stock_in_way_to_client,
	       	       SUM (ws.in_way_from_client) wb_stock_in_way_from_client,
	       	       MAX (ws.days_on_site)     days_on_site
	       	FROM   warehouse.wb_stock     AS ws
	       	WHERE  ws.stock_dt = now()::DATE
	       	GROUP BY
	       	       ws.stock_dt,
	       	       ws.sats_id
	       ) wbs
	       INNER JOIN products.sats     AS st
	            ON  st.sats_id = wbs.sats_id
	       INNER JOIN products.supplier_article sa
	            ON  sa.sa_id = st.sa_id
	       INNER JOIN products.tech_size ts
	            ON  ts.ts_id = st.ts_id
	       LEFT JOIN products.supplier_article_info sai
	            ON  sai.sa_id = sa.sa_id
	       LEFT JOIN products.brands    AS b
	            ON  b.brand_id = sai.brand_id
	       LEFT JOIN products.subjects  AS sj
	            ON  sj.subject_id = sai.subject_id
	       LEFT JOIN products.sa_cost   AS sc
	            ON  sc.sa_id = sa.sa_id
	       LEFT JOIN (
	            	SELECT ns.sats_id,
	            	       ns.pants_id,
	            	       MAX (ns.whprice) whprice,
	            	       MAX (ns.price) price,
	            	       SUM (ns.qty) qty
	            	FROM   warehouse.stock ns
	            	GROUP BY
	            	       ns.sats_id,
	            	       ns.pants_id
	            ) s
	            ON  wbs.sats_id = s.sats_id
	       LEFT JOIN (
	            	SELECT drd.sats_id,
	            	       SUM (drd.quantity) sale_qty,
	            	       SUM (drd.finished_price) sale_amount
	            	FROM   sale.day_report_detail AS drd
	            	WHERE  drd.sale_dt > now()::DATE - INTERVAL'14 day'
	            	GROUP BY
	            	       drd.sats_id
	            ) wbsw
	            ON  wbsw.sats_id = wbs.sats_id
	       LEFT JOIN (
	            	SELECT drd2.sats_id,
	            	       SUM (drd2.quantity) sale_qty,
	            	       SUM (drd2.finished_price) sale_amount
	            	FROM   sale.day_report_detail AS drd2
	            	WHERE  drd2.sale_dt > now()::DATE - INTERVAL'30 day'
	            	GROUP BY
	            	       drd2.sats_id
	            ) wbsm
	            ON  wbsm.sats_id = wbs.sats_id
	       LEFT JOIN (
	            	SELECT drd.sats_id,
	            	       SUM (drd.quantity) sale_qty,
	            	       SUM (drd.finished_price) sale_amount
	            	FROM   sale.day_report_detail AS drd
	            	WHERE  drd.sale_dt > now()::DATE - INTERVAL'120 day'
	            	GROUP BY
	            	       drd.sats_id
	            ) wbs4m
	            ON  wbs4m.sats_id = wbs.sats_id
	       LEFT JOIN (
	            	SELECT ws.sats_id,
	            	       MAX (ws.in_way_to_client) in_way_to_client,
	            	       MAX (ws.in_way_from_client) in_way_from_client
	            	FROM   warehouse.wb_stock AS ws
	            	WHERE  ws.stock_dt >= now()::DATE - INTERVAL'7 day'
	            	GROUP BY
	            	       ws.sats_id
	            ) wbw
	            ON  wbw.sats_id = wbs.sats_id
	       LEFT JOIN (
	            	SELECT ord.sats_id,
	            	       SUM (ord.quantity) order_qty
	            	FROM   sale.order_report_detail AS ord
	            	WHERE  ord.order_dt >= now()::DATE - INTERVAL'7 day'
	            	GROUP BY
	            	       ord.sats_id
	            ) wbow
	            ON  wbow.sats_id = wbs.sats_id
	ORDER BY
	       sa.sa_name,
	       ts.ts_name ;
$$;

ALTER FUNCTION warehouse.wb_stock_get() OWNER TO postgres;
