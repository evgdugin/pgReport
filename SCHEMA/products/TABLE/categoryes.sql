CREATE TABLE products.categoryes (
	category_id integer DEFAULT nextval('products.categoryes_category_id_seq'::regclass) NOT NULL,
	category_name character varying(50) NOT NULL
);

ALTER TABLE products.categoryes OWNER TO postgres;

GRANT ALL ON TABLE products.categoryes TO user1c;

--------------------------------------------------------------------------------

ALTER TABLE products.categoryes
	ADD CONSTRAINT uq_categoryes_category_name UNIQUE (category_name);

--------------------------------------------------------------------------------

ALTER TABLE products.categoryes
	ADD CONSTRAINT pk_categoryes PRIMARY KEY (category_id);
