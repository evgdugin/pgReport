CREATE OR REPLACE FUNCTION warehouse.goods_income_get(_start_dt date, _finish_dt date) RETURNS TABLE(gi_id integer, status_name character varying, gi_dt date, close_dt timestamp with time zone, last_change_dt timestamp with time zone, office_name character varying, sa_name character varying, ts_name character varying, barcode character varying, nm_id integer, quantity smallint, price numeric)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
	BEGIN
		RETURN query(
			SELECT wgi.gi_id,
			       gs.status_name,
			       wgi.gi_dt,
			       wgi.close_dt,
			       wgi.last_change_dt,
			       o.office_name,
			       sa.sa_name,
			       ts.ts_name,
			       b.barcode,
			       b.nm_id,
			       wgid.quantity,
			       wgid.price
			FROM   warehouse.wb_goods_income wgi
			       INNER JOIN warehouse.wb_goods_income_detail wgid
			            ON  wgid.gi_id = wgi.gi_id
			       INNER JOIN refbook.gi_statuses gs
			            ON  gs.status_id = wgi.status_id
			       INNER JOIN refbook.offices o
			            ON  o.office_id = wgi.office_id
			       INNER JOIN products.barcodes b
			            ON  b.barcode_id = wgid.barcode_id
			       INNER JOIN products.supplier_article sa
			            ON  sa.sa_id = b.sa_id
			       INNER JOIN products.tech_size ts
			            ON  ts.ts_id = b.ts_id
			WHERE  wgi.gi_dt >= _start_dt
			       AND wgi.gi_dt <= _finish_dt
		);
	END;
$$;

ALTER FUNCTION warehouse.goods_income_get(_start_dt date, _finish_dt date) OWNER TO postgres;
