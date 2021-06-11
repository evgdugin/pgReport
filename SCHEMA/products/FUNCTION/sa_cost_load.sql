CREATE OR REPLACE FUNCTION products.sa_cost_load(_data text, _period_dt date) RETURNS void
    LANGUAGE plpgsql
    AS $$
	BEGIN
		CREATE TEMPORARY TABLE temp_tab ON COMMIT DROP 
		AS
		SELECT COALESCE (d.sa_name, '') sa_name,
		       d.whprice,
		       d.price,
		       d.art_name,
		       d.pics_dt
		FROM   json_populate_recordset (NULL::products.sa_cost_type, CAST (_data AS json))d;
		
		UPDATE
			products.sa_cost s
		SET
			whprice = dt.whprice,
			price = dt.price,
			dt = _period_dt,
			art_name = dt.art_name,
			pics_dt = dt.pics_dt
			FROM temp_tab AS dt
			INNER JOIN products.supplier_article sa
			ON sa.sa_name = dt.sa_name
		WHERE
			sa.sa_id = s.sa_id
			AND (
			    	s.whprice <> dt.whprice
			    	OR COALESCE (s.art_name, '') = ''
			    	OR (dt.pics_dt IS NOT NULL AND s.pics_dt IS NULL)
			    	OR dt.pics_dt != dt.pics_dt
			    );
		
		INSERT INTO products.sa_cost
		  (
		    sa_id,
		    whprice,
		    price,
		    dt,
		    art_name,
		    pics_dt
		  )
		SELECT sa.sa_id,
		       dt.whprice,
		       dt.price,
		       _period_dt     dt,
		       dt.art_name,
		       dt.pics_dt
		FROM   temp_tab    AS dt
		       INNER JOIN products.supplier_article sa
		            ON  sa.sa_name = dt.sa_name
		WHERE  NOT EXISTS(
		       	SELECT 1
		       	FROM   products.sa_cost c
		       	WHERE  c.sa_id = sa.sa_id
		       );
	END;
$$;

ALTER FUNCTION products.sa_cost_load(_data text, _period_dt date) OWNER TO postgres;
