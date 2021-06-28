CREATE OR REPLACE FUNCTION warehouse.ozon_stock_load(_data text, _period_dt date) RETURNS void
    LANGUAGE plpgsql
    AS $$
	BEGIN
		CREATE TEMPORARY TABLE temp_tab ON COMMIT DROP 
		AS
		SELECT COALESCE (d.barcode, '')     barcode,
		       COALESCE (d.ozon_sa, '')     ozon_sa,
		       COALESCE (d.sa_name, '')     sa_name,
		       CASE 
		       	WHEN d.ts_name = '40-48' OR d.ts_name = '50-54' OR d.ts_name = '40-50' THEN 'ONE SIZE'
		       	ELSE COALESCE (d.ts_name, '')
		       END                          ts_name,
		       d.create_dt,
		       d.product_id,
		       d.marketing_price,
		       d.price,
		       d.recommended_price,
		       d.old_price,
		       d.price_index,
		       d.visible,
		       d.present,
		       d.reserved
		FROM   json_populate_recordset (NULL::warehouse.ozon_stock_type, CAST (_data AS json))d;
		
		INSERT INTO products.supplier_article
		  (
		    sa_name,
		    nm_id
		  )
		SELECT dt.sa_name,
		       NULL         nm_id
		FROM   temp_tab     dt
		WHERE  NOT EXISTS (
		       	SELECT 1
		       	FROM   products.supplier_article dc
		       	WHERE  dc.sa_name = dt.sa_name
		       )
		GROUP BY
		       dt.sa_name;
		
		INSERT INTO products.tech_size
		  (
		    ts_name
		  )
		SELECT DISTINCT dt.ts_name
		FROM   temp_tab dt
		WHERE  NOT EXISTS (
		       	SELECT 1
		       	FROM   products.tech_size dc
		       	WHERE  dc.ts_name = dt.ts_name
		       );
		
		INSERT INTO products.barcodes
		  (
		    barcode,
		    nm_id,
		    sa_id,
		    ts_id
		  )
		SELECT dt.barcode,
		       NULL,
		       MAX (sa.sa_id),
		       MAX (ts.ts_id)
		FROM   temp_tab dt
		       INNER JOIN products.supplier_article AS sa
		            ON  sa.sa_name = dt.sa_name
		       INNER JOIN products.tech_size AS ts
		            ON  ts.ts_name = dt.ts_name
		WHERE  NOT EXISTS (
		       	SELECT 1
		       	FROM   products.barcodes dc
		       	WHERE  dc.barcode = dt.barcode
		       )
		GROUP BY
		       dt.barcode;
		
		INSERT INTO products.ozon_article_info
		  (
		    barcode_id,
		    sats_id,
		    create_dt,
		    product_id,
		    ozon_sa,
		    marketing_price,
		    price,
		    recommended_price,
		    old_price,
		    price_index,
		    visible
		  )
		SELECT b.barcode_id,
		       MAX (s.sats_id),
		       MAX (dt.create_dt),
		       MAX (dt.product_id),
		       MAX (dt.ozon_sa),
		       MAX (dt.marketing_price),
		       MAX (dt.price),
		       MAX (dt.recommended_price),
		       MAX (dt.old_price),
		       MAX (dt.price_index),
		       CAST (MAX (CAST (dt.visible AS INT)) AS BIT (1))
		FROM   temp_tab dt
		       INNER JOIN products.barcodes AS b
		            ON  b.barcode = dt.barcode
		       INNER JOIN products.sats AS s
		            ON  s.sa_id = b.sa_id
		            AND s.ts_id = b.ts_id
		WHERE  NOT EXISTS (
		       	SELECT 1
		       	FROM   products.ozon_article_info AS oai
		       	WHERE  b.barcode_id = oai.barcode_id
		       )
		GROUP BY
		       b.barcode_id;
		
		
		INSERT INTO warehouse.ozon_stock
		  (
		    stock_dt,
		    barcode_id,
		    sats_id,
		    present,
		    reserved
		  )
		SELECT _period_dt                   stock_dt,
		       b.barcode_id,
		       MAX (s.sats_id)              sats_id,
		       SUM (dt.present)             present,
		       SUM (dt.reserved)            reserved
		FROM   temp_tab dt
		       INNER JOIN products.barcodes AS b
		            ON  b.barcode = dt.barcode
		       INNER JOIN products.sats  AS s
		            ON  s.sa_id = b.sa_id
		            AND s.ts_id = b.ts_id
		WHERE  NOT EXISTS (
		       	SELECT 1
		       	FROM   warehouse.ozon_stock AS ws
		       	WHERE  ws.stock_dt = _period_dt
		       	       AND ws.barcode_id = b.barcode_id
		       )
		GROUP BY
		       b.barcode_id;
	END;
$$;

ALTER FUNCTION warehouse.ozon_stock_load(_data text, _period_dt date) OWNER TO postgres;
