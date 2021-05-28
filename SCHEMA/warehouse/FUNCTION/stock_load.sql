CREATE OR REPLACE FUNCTION warehouse.stock_load(_data text, _period_dt date) RETURNS void
    LANGUAGE plpgsql
    AS $$
	BEGIN
		CREATE TEMPORARY TABLE temp_tab ON COMMIT DROP 
		AS
		SELECT COALESCE (d.barcode, '')	barcode,
		       d.pants_id,
		       COALESCE (d.sa_name, '')     sa_name,
		       COALESCE (d.ts_name, '')     ts_name,
		       d.whprice,
		       d.price,
		       d.qty,
		       COALESCE (d.nm_id, 0) nm_id,
		       COALESCE (d.subject_name, '') subject_name,
		       COALESCE (d.brand_name, '') brand_name
		FROM   json_populate_recordset (NULL::warehouse.stock_type, CAST (_data AS json))d;
		
		INSERT INTO products.supplier_article
		  (
		    sa_name
		  )
		SELECT DISTINCT dt.sa_name
		FROM   temp_tab dt
		WHERE  NOT EXISTS (
		       	SELECT 1
		       	FROM   products.supplier_article dc
		       	WHERE  dc.sa_name = dt.sa_name
		       );
		
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
		       MAX (dt.nm_id),
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
		
		INSERT INTO products.subjects
		  (
		    subject_name
		  )
		SELECT DISTINCT dt.subject_name
		FROM   temp_tab dt
		WHERE  NOT EXISTS (
		       	SELECT 1
		       	FROM   products.subjects dc
		       	WHERE  dc.subject_name = dt.subject_name
		       );
		
		INSERT INTO products.brands
		  (
		    brand_name
		  )
		SELECT DISTINCT dt.brand_name
		FROM   temp_tab dt
		WHERE  NOT EXISTS (
		       	SELECT 1
		       	FROM   products.brands dc
		       	WHERE  dc.brand_name = dt.brand_name
		       );      
		
		INSERT INTO products.barcodes_info
		  (
		    barcode_id,
		    brand_id,
		    subject_id
		  )
		SELECT b.barcode_id,
		       MAX (br.brand_id)       brand_id,
		       MAX (s.subject_id)      subject_id
		FROM   temp_tab dt
		       INNER JOIN products.barcodes AS b
		            ON  b.barcode = dt.barcode
		       INNER JOIN products.brands AS br
		            ON  br.brand_name = dt.brand_name
		       INNER JOIN products.subjects AS s
		            ON  s.subject_name = dt.subject_name
		WHERE  NOT EXISTS (
		       	SELECT 1
		       	FROM   products.barcodes_info AS bi
		       	WHERE  b.barcode_id = bi.barcode_id
		       )
		GROUP BY
		       b.barcode_id; 
		
		DELETE FROM warehouse.stock;
		
		INSERT INTO warehouse.stock
		  (
		    barcode_id,
		    pants_id,
		    whprice,
		    price,
		    qty,
		    dt
		  )
		SELECT b.barcode_id,
		       MAX (dt.pants_id)     pants_id,
		       MAX (dt.whprice)      whprice,
		       MAX (dt.price)        price,
		       SUM (dt.qty)          qty,
		       _period_dt            dt
		FROM   temp_tab           AS dt
		       INNER JOIN products.barcodes b
		            ON  b.barcode = dt.barcode
		GROUP BY
		       b.barcode_id;
	END;
$$;

ALTER FUNCTION warehouse.stock_load(_data text, _period_dt date) OWNER TO postgres;
