CREATE TABLE products.brands (
	brand_id integer DEFAULT nextval('products.brands_brand_id_seq'::regclass) NOT NULL,
	brand_name character varying(50) NOT NULL
);

ALTER TABLE products.brands OWNER TO postgres;

GRANT ALL ON TABLE products.brands TO user1c;

--------------------------------------------------------------------------------

ALTER TABLE products.brands
	ADD CONSTRAINT uq_brands_brand_name UNIQUE (brand_name);

--------------------------------------------------------------------------------

ALTER TABLE products.brands
	ADD CONSTRAINT pk_brands PRIMARY KEY (brand_id);
