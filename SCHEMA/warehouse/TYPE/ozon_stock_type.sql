CREATE TYPE warehouse.ozon_stock_type AS (
	barcode character varying(30),
	ozon_sa character varying(100),
	sa_name character varying(36),
	ts_name character varying(15),
	subject_name character varying(50),
	create_dt date,
	product_id integer,
	marketing_price numeric(9,2),
	price numeric(9,2),
	recommended_price numeric(9,2),
	old_price numeric(9,2),
	price_index numeric(5,2),
	visible bit(1),
	present smallint,
	reserved smallint,
	fbo_present smallint,
	fbo_reserved smallint,
	fbs_present smallint,
	fbs_reserved smallint
);

ALTER TYPE warehouse.ozon_stock_type OWNER TO postgres;
