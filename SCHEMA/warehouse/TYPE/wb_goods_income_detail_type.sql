CREATE TYPE warehouse.wb_goods_income_detail_type AS (
	gi_id integer,
	gi_dt date,
	last_change_dt timestamp with time zone,
	close_dt timestamp with time zone,
	office_name character varying(50),
	nm_id integer,
	sa_name character varying(36),
	ts_name character varying(15),
	barcode character varying(30),
	quantity smallint,
	price numeric(15,2),
	status_name character varying(50)
);

ALTER TYPE warehouse.wb_goods_income_detail_type OWNER TO postgres;
