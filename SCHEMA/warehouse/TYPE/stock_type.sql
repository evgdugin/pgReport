CREATE TYPE warehouse.stock_type AS (
	pants_id integer,
	sa_name character varying(36),
	ts_name character varying(15),
	whprice numeric(9,2),
	price numeric(9,2),
	qty smallint
);

ALTER TYPE warehouse.stock_type OWNER TO postgres;
