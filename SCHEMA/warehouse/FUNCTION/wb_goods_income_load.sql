CREATE OR REPLACE FUNCTION warehouse.wb_goods_income_load(_data text) RETURNS void
    LANGUAGE plpgsql
    AS $$
	BEGIN
		CREATE TEMPORARY TABLE temp_tab ON COMMIT DROP 
		AS
		SELECT d.gi_id,
		       d.gi_dt,
		       d.last_change_dt,
		       d.close_dt,
		       COALESCE (d.office_name, '') office_name,
		       d.nm_id,
		       COALESCE (d.sa_name, '')     sa_name,
		       CASE 
		       	WHEN d.ts_name = '40-48' OR d.ts_name = '50-54' OR d.ts_name = '40-50' THEN 'ONE SIZE'
		       	ELSE COALESCE (d.ts_name, '')
		       END                          ts_name,
		       COALESCE (d.barcode, '')     barcode,
		       d.quantity,
		       d.price,
		       d.status_name
		FROM   json_populate_recordset(
		       	NULL::warehouse.wb_goods_income_detail_type,
		       	CAST (_data AS json)
		       )d;
		
		UPDATE
			products.supplier_article sa
		SET
			nm_id = v.nm_id 
			FROM (
				SELECT dt.sa_name,
				       MAX (dt.nm_id)     nm_id
				FROM   temp_tab           dt
				GROUP BY
				       dt.sa_name
			) v
		WHERE
			sa.sa_name = v.sa_name
			AND COALESCE (sa.nm_id, 0) = 0
			AND COALESCE (v.nm_id, 0) != 0;
		
		INSERT INTO products.supplier_article
		  (
		    sa_name,
		    nm_id
		  )
		SELECT dt.sa_name,
		       MAX (dt.nm_id)     nm_id
		FROM   temp_tab           dt
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
			nm_id = v.nm_id 
			FROM (
				SELECT dt.barcode,
				       MAX (dt.nm_id)     nm_id
				FROM   temp_tab           dt
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
		
		INSERT INTO products.sats
		  (
		    sa_id,
		    ts_id
		  )
		SELECT sa.sa_id,
		       ts.ts_id
		FROM   temp_tab dt
		       INNER JOIN products.supplier_article AS sa
		            ON  sa.sa_name = dt.sa_name
		       INNER JOIN products.tech_size AS ts
		            ON  ts.ts_name = dt.ts_name
		WHERE  NOT EXISTS (
		       	SELECT 1
		       	FROM   products.sats dc
		       	WHERE  dc.sa_id = sa.sa_id
		       	       AND dc.ts_id = ts.ts_id
		       )
		GROUP BY
		       sa.sa_id,
		       ts.ts_id;
		
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
		
		INSERT INTO refbook.gi_statuses
		  (
		    status_name
		  )
		SELECT DISTINCT dt.status_name
		FROM   temp_tab dt
		WHERE  NOT EXISTS (
		       	SELECT 1
		       	FROM   refbook.gi_statuses dc
		       	WHERE  dc.status_name = dt.status_name
		       );
		
		INSERT INTO warehouse.wb_goods_income AS gi
		  (
		    gi_id,
		    status_id,
		    dt_first_packages,
		    dt_last_packages,
		    gi_dt,
		    close_dt,
		    last_change_dt,
		    office_id
		  )
		SELECT dt.gi_id,
		       MAX (gs.status_id)          status_id,
		       now()                       dt_first_packages,
		       now()                       dt_last_packages,
		       MAX (dt.gi_dt)              gi_dt,
		       MAX (dt.close_dt)           close_dt,
		       MAX (dt.last_change_dt)     last_change_dt,
		       MAX (o.office_id)           office_id
		FROM   temp_tab                 AS dt
		       INNER JOIN refbook.gi_statuses gs
		            ON  gs.status_name = dt.status_name
		       INNER JOIN refbook.offices o
		            ON  o.office_name = dt.office_name
		GROUP BY
		       dt.gi_id
		       ON CONFLICT (gi_id) DO 
		       UPDATE
		       SET
		       	status_id = EXCLUDED.status_id,
		       	dt_last_packages = now(),
		       	gi_dt = CASE 
		       	        	WHEN EXCLUDED.gi_dt = CAST ('01-01-0001T0:00:00' AS DATE) THEN EXCLUDED.last_change_dt
		       	        	WHEN EXCLUDED.gi_dt >= gi.gi_dt THEN EXCLUDED.gi_dt
		       	        	ELSE gi.gi_dt
		       	        END ,
		       	close_dt = CASE 
		       	           	WHEN EXCLUDED.close_dt >= gi.close_dt THEN EXCLUDED.close_dt
		       	           	ELSE gi.close_dt
		       	           END ,
		       	last_change_dt = CASE 
		       	                 	WHEN EXCLUDED.last_change_dt >= gi.last_change_dt THEN EXCLUDED.last_change_dt
		       	                 	ELSE gi.last_change_dt
		       	                 END ,
		       	office_id = EXCLUDED.office_id;
		
		WITH cte AS(
			SELECT dt.gi_id,
			       sa.sa_id,
			       ts.ts_id,
			       bc.barcode_id,
			       dt.nm_id,
			       dt.quantity,
			       dt.price
			FROM   temp_tab AS dt
			       INNER JOIN products.barcodes bc
			            ON  bc.barcode = dt.barcode
			       INNER JOIN products.supplier_article sa
			            ON  sa.sa_name = dt.sa_name
			       INNER JOIN products.tech_size ts
			            ON  ts.ts_name = dt.ts_name
		) 
		UPDATE warehouse.wb_goods_income_detail gid
		SET quantity = v.quantity,
		price = 
		CASE 
			WHEN COALESCE (v.price, 0) = 0 THEN gid.price
			ELSE v.price
		END FROM cte AS v
		    WHERE gid.gi_id = v.gi_id AND gid.barcode_id = v.barcode_id;
		
		
		INSERT INTO warehouse.wb_goods_income_detail AS gid
		  (
		    gi_id,
		    barcode_id,
		    quantity,
		    price,
		    sats_id
		  )
		SELECT dt.gi_id,
		       bc.barcode_id,
		       SUM (dt.quantity)            quantity,
		       MAX (dt.price)               price,
		       MAX (s.sats_id)
		FROM   temp_tab                  AS dt
		       INNER JOIN products.barcodes bc
		            ON  bc.barcode = dt.barcode
		       INNER JOIN products.supplier_article AS sa
		            ON  sa.sa_name = dt.sa_name
		       INNER JOIN products.tech_size AS ts
		            ON  ts.ts_name = dt.ts_name
		       INNER JOIN products.sats  AS s
		            ON  s.sa_id = sa.sa_id
		            AND s.ts_id = ts.ts_id
		WHERE  NOT EXISTS (
		       	SELECT 1
		       	FROM   warehouse.wb_goods_income_detail AS wgid
		       	WHERE  wgid.gi_id = dt.gi_id
		       	       AND wgid.barcode_id = bc.barcode_id
		       )
		GROUP BY
		       dt.gi_id,
		       bc.barcode_id;
	END;
$$;

ALTER FUNCTION warehouse.wb_goods_income_load(_data text) OWNER TO postgres;
