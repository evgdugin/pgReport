CREATE TABLE products.supplier_article (
	sa_id integer DEFAULT nextval('products.supplier_article_sa_id_seq'::regclass) NOT NULL,
	sa_name character varying(36) NOT NULL,
	nm_id integer
);

ALTER TABLE products.supplier_article OWNER TO postgres;

GRANT ALL ON TABLE products.supplier_article TO user1c;

--------------------------------------------------------------------------------

ALTER TABLE products.supplier_article
	ADD CONSTRAINT uq_supplier_article_sa_name UNIQUE (sa_name);

--------------------------------------------------------------------------------

ALTER TABLE products.supplier_article
	ADD CONSTRAINT pk_supplier_article PRIMARY KEY (sa_id);
