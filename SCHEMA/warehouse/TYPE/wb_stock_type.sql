CREATE TYPE warehouse.wb_stock_type AS (
	barcode character varying(30),
	nm_id integer,
	brand_name character varying(50),
	sa_name character varying(36),
	ts_name character varying(15),
	subject_name character varying(50),
	suppliercontract_code character varying(15),
	office_name character varying(50),
	is_supply bit(1),
	is_realization bit(1),
	quantity smallint,
	quantity_full smallint,
	quantity_not_in_orders smallint,
	in_way_to_client smallint,
	in_way_from_client smallint,
	days_on_site smallint
);

ALTER TYPE warehouse.wb_stock_type OWNER TO postgres;
