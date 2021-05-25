CREATE SEQUENCE products.tech_size_ts_id_seq
	AS smallint
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE products.tech_size_ts_id_seq OWNER TO postgres;

ALTER SEQUENCE products.tech_size_ts_id_seq
	OWNED BY products.tech_size.ts_id;
