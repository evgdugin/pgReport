CREATE TYPE sale.order_report_detail_type AS (
	od_id bigint,
	order_num bigint,
	last_change_dt timestamp with time zone,
	barcode character varying(30),
	brand_name character varying(50),
	subject_name character varying(50),
	sa_name character varying(36),
	ts_name character varying(15),
	nm_id integer,
	quantity smallint,
	total_price numeric(9,2),
	discount_percent smallint,
	office_name character varying(50),
	okrug_name character varying(50),
	gi_id integer,
	is_cancel bit(1),
	cancel_dt date
);

ALTER TYPE sale.order_report_detail_type OWNER TO postgres;
