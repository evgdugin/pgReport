CREATE TABLE products.tech_size (
	ts_id smallint DEFAULT nextval('products.tech_size_ts_id_seq'::regclass) NOT NULL,
	ts_name character varying(15) NOT NULL
);

ALTER TABLE products.tech_size OWNER TO postgres;

GRANT ALL ON TABLE products.tech_size TO user1c;

--------------------------------------------------------------------------------

ALTER TABLE products.tech_size
	ADD CONSTRAINT uq_tech_size_region_name UNIQUE (ts_name);

--------------------------------------------------------------------------------

ALTER TABLE products.tech_size
	ADD CONSTRAINT pk_tech_size PRIMARY KEY (ts_id);
