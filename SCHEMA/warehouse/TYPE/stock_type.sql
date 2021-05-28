CREATE TYPE warehouse.stock_type AS (
	barcode character varying(30),
	pants_id integer,
	sa_name character varying(36),
	ts_name character varying(15),
	whprice numeric(9,2),
	price numeric(9,2),
	qty smallint,
	nm_id integer,
	brand_name character varying(50),
	subject_name character varying(50)
);

ALTER TYPE warehouse.stock_type OWNER TO postgres;
