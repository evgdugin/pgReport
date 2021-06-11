CREATE OR REPLACE FUNCTION sale.day_report_detail_load(_data text, _period_dt date) RETURNS void
    LANGUAGE plpgsql
    AS $$
	BEGIN
		CREATE TEMPORARY TABLE temp_tab ON COMMIT DROP 
		AS
		SELECT d.od_id,
		       d.sale_type,
		       d.sale_id,
		       _period_dt                   sale_dt,
		       d.last_change_dt,
		       COALESCE (d.subject_name, '') subject_name,
		       d.nm_id,
		       COALESCE (d.brand_name, '') brand_name,
		       COALESCE (d.sa_name, '')     sa_name,
		       CASE 
		       	WHEN d.ts_name = '40-48' OR d.ts_name = '50-54' OR d.ts_name = '40-50' THEN 'ONE SIZE'
		       	ELSE COALESCE (d.ts_name, '')
		       END                          ts_name,
		       COALESCE (d.barcode, '')     barcode,
		       d.quantity,
		       d.total_price,
		       d.discount_percent,
		       d.is_supply,
		       d.is_realization,
		       d.promo_code_discount,
		       COALESCE (d.office_name, '') office_name,
		       COALESCE (d.country_name, '') country_name,
		       COALESCE (d.okrug_name, '') okrug_name,
		       COALESCE (d.region_name, '') region_name,
		       d.gi_id,
		       d.spp,
		       d.forpay,
		       d.finished_price,
		       d.price_with_disc,
		       d.is_storno
		FROM   json_populate_recordset (NULL::sale.day_report_detail_type, CAST (_data AS json))d;
		
		UPDATE
			products.supplier_article sa
		SET
			nm_id          = v.nm_id			
			FROM (
				SELECT dt.sa_name,
				       MAX (dt.nm_id)        nm_id
				FROM   temp_tab dt
				GROUP BY
		       			dt.sa_name
			) v
		WHERE
			sa.sa_name = v.sa_name
			AND COALESCE(sa.nm_id, 0) = 0
			AND COALESCE(v.nm_id, 0) != 0;

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
		       	WHERE  dc.sa_id = sa.sa_id AND dc.ts_id = ts.ts_id
		       )
		GROUP BY
		       sa.sa_id,
		       ts.ts_id;
		
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
		       
		INSERT INTO products.supplier_article_info
		  (
		    sa_id,
		    brand_id,
		    subject_id
		  )
		SELECT sa.sa_id,
		       MAX (br.brand_id)       brand_id,
		       MAX (s.subject_id)      subject_id
		FROM   temp_tab dt
		       INNER JOIN products.supplier_article AS sa
		            ON  sa.sa_name = dt.sa_name
		       INNER JOIN products.brands AS br
		            ON  br.brand_name = dt.brand_name
		       INNER JOIN products.subjects AS s
		            ON  s.subject_name = dt.subject_name
		WHERE  NOT EXISTS (
		       	SELECT 1
		       	FROM   products.supplier_article_info AS sai
		       	WHERE  sai.sa_id = sa.sa_id
		       )
		GROUP BY
		       sa.sa_id; 
		
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
				
		INSERT INTO refbook.countryes
		  (
		    country_name
		  )
		SELECT DISTINCT dt.country_name
		FROM   temp_tab dt
		WHERE  NOT EXISTS (
		       	SELECT 1
		       	FROM   refbook.countryes dc
		       	WHERE  dc.country_name = dt.country_name
		       );
		
		INSERT INTO refbook.okrugs
		  (
		    okrug_name
		  )
		SELECT DISTINCT dt.okrug_name
		FROM   temp_tab dt
		WHERE  NOT EXISTS (
		       	SELECT 1
		       	FROM   refbook.okrugs dc
		       	WHERE  dc.okrug_name = dt.okrug_name
		       );
		
		INSERT INTO refbook.regions
		  (
		    region_name
		  )
		SELECT DISTINCT dt.region_name
		FROM   temp_tab dt
		WHERE  NOT EXISTS (
		       	SELECT 1
		       	FROM   refbook.regions dc
		       	WHERE  dc.region_name = dt.region_name
		       );              
		
		DELETE FROM sale.day_report_detail
		WHERE
			sale_dt = _period_dt;
		
		INSERT INTO sale.day_report_detail
		  (
		    od_id,
		    sale_type,
		    sale_id,
		    sale_dt,
		    last_change_dt,
		    barcode_id,
		    quantity,
		    total_price,
		    discount_percent,
		    is_supply,
		    is_realization,
		    promo_code_discount,
		    office_id,
		    country_id,
		    okrug_id,
		    region_id,
		    gi_id,
		    spp,
		    forpay,
		    finished_price,
		    price_with_disc,
		    is_storno,
		    sats_id
		  )
		SELECT dt.od_id,
		       dt.sale_type,
		       dt.sale_id,
		       dt.sale_dt,
		       dt.last_change_dt,
		       bc.barcode_id,
		       dt.quantity,
		       dt.total_price,
		       dt.discount_percent,
		       dt.is_supply,
		       dt.is_realization,
		       dt.promo_code_discount,
		       o.office_id,
		       cou.country_id,
		       okr.okrug_id,
		       r.region_id,
		       dt.gi_id,
		       dt.spp,
		       dt.forpay,
		       dt.finished_price,
		       dt.price_with_disc,
		       dt.is_storno,
		       s.sats_id
		FROM   temp_tab dt
		       INNER JOIN products.barcodes bc
		            ON  bc.barcode = dt.barcode
		       INNER JOIN refbook.offices o
		            ON  o.office_name = dt.office_name
		       INNER JOIN refbook.countryes AS cou
		            ON  cou.country_name = dt.country_name
		       INNER JOIN refbook.okrugs AS okr
		            ON  okr.okrug_name = dt.okrug_name
		       INNER JOIN refbook.regions AS r
		            ON  r.region_name = dt.region_name
		       INNER JOIN products.supplier_article AS sa
		       		ON sa.sa_name = dt.sa_name
		       INNER JOIN products.tech_size AS ts
		       		ON ts.ts_name = dt.ts_name
		       INNER JOIN products.sats AS s
		       		ON s.sa_id = sa.sa_id AND s.ts_id = ts.ts_id;
	END;
$$;

ALTER FUNCTION sale.day_report_detail_load(_data text, _period_dt date) OWNER TO postgres;
