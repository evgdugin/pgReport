CREATE OR REPLACE FUNCTION warehouse.wb_stock_load(_data text, _period_dt date) RETURNS void
    LANGUAGE plpgsql
    AS $$
	BEGIN
		CREATE TEMPORARY TABLE temp_tab ON COMMIT DROP 
		AS
		SELECT COALESCE (d.barcode, '')     barcode,
		       d.nm_id,
		       COALESCE (d.brand_name, '') brand_name,
		       COALESCE (d.sa_name, '')     sa_name,
		       COALESCE (d.ts_name, '')     ts_name,
		       COALESCE (d.subject_name, '') subject_name,
		       COALESCE (d.suppliercontract_code, '') suppliercontract_code,
		       COALESCE (d.office_name, '') office_name,
		       d.is_supply,
		       d.is_realization,
		       d.quantity,
		       d.quantity_full,
		       d.quantity_not_in_orders,
		       d.in_way_to_client,
		       d.in_way_from_client,
		       d.days_on_site
		FROM   json_populate_recordset (NULL::warehouse.wb_stock_type, CAST (_data AS json))d;
		
		INSERT INTO products.supplier_article
		  (
		    sa_name
		  )
		SELECT dt.sa_name
		FROM   temp_tab dt
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
		
		UPDATE
			products.barcodes b
		SET
			nm_id          = v.nm_id			
			FROM (
				SELECT dt.barcode,
				       MAX (dt.nm_id)        nm_id
				FROM   temp_tab dt
				GROUP BY
		       			dt.barcode
			) v
		WHERE
			b.barcode = v.barcode
			AND b.nm_id = 0
			AND v.nm_id != 0;
		
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
		
		INSERT INTO refbook.offices
		  (
		    office_name
		  )
		SELECT DISTINCT dt.office_name
		FROM   temp_tab dt
		WHERE  NOT EXISTS (
		       	SELECT 1
		       	FROM   refbook.offices dc
		       	WHERE  dc.office_name = dt.office_name
		       );
		
		INSERT INTO refbook.supplier_contract
		  (
		    suppliercontract_code
		  )
		SELECT DISTINCT dt.suppliercontract_code
		FROM   temp_tab dt
		WHERE  NOT EXISTS (
		       	SELECT 1
		       	FROM   refbook.supplier_contract sc
		       	WHERE  sc.suppliercontract_code = dt.suppliercontract_code
		       );
		
		
		INSERT INTO warehouse.wb_stock
		  (
		    stock_dt,
		    barcode_id,
		    office_id,
		    suppliercontract_code_id,
		    is_supply,
		    is_realization,
		    quantity,
		    quantity_full,
		    quantity_not_in_orders,
		    in_way_to_client,
		    in_way_from_client,
		    days_on_site
		  )
		SELECT _period_dt                    stock_dt,
		       b.barcode_id,
		       o.office_id,
		       sc.suppliercontract_code_id,
		       CAST (MAX (CAST (dt.is_supply AS INT)) AS BIT (1)) is_supply,
		       CAST (MAX (CAST (dt.is_realization AS INT)) AS BIT (1)) is_realization,
		       SUM (dt.quantity)             quantity,
		       SUM (dt.quantity_full)        quantity_full,
		       SUM (dt.quantity_not_in_orders) quantity_not_in_orders,
		       SUM (dt.in_way_to_client)     in_way_to_client,
		       SUM (dt.in_way_from_client) in_way_from_client,
		       MAX (dt.days_on_site)         days_on_site
		FROM   temp_tab dt
		       INNER JOIN products.barcodes AS b
		            ON  b.barcode = dt.barcode
		       INNER JOIN refbook.offices o
		            ON  o.office_name = dt.office_name
		       INNER JOIN refbook.supplier_contract sc
		            ON  sc.suppliercontract_code = dt.suppliercontract_code
		WHERE  NOT EXISTS (
		       	SELECT 1
		       	FROM   warehouse.wb_stock AS ws
		       	WHERE  ws.stock_dt = _period_dt
		       	       AND ws.barcode_id = b.barcode_id
		       	       AND ws.office_id = o.office_id
		       	       AND ws.suppliercontract_code_id = sc.suppliercontract_code_id
		       )
		GROUP BY
		       b.barcode_id,
		       o.office_id,
		       sc.suppliercontract_code_id;
	END;
$$;

ALTER FUNCTION warehouse.wb_stock_load(_data text, _period_dt date) OWNER TO postgres;
