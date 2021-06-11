CREATE TABLE products.sa_cost (
	sa_id integer NOT NULL,
	whprice numeric(9,2) NOT NULL,
	price numeric(9,2) NOT NULL,
	art_name character varying(100) NOT NULL,
	dt date NOT NULL,
	pics_dt date
);

ALTER TABLE products.sa_cost OWNER TO postgres;

GRANT ALL ON TABLE products.sa_cost TO user1c;

--------------------------------------------------------------------------------

ALTER TABLE products.sa_cost
	ADD CONSTRAINT fk_sa_cost_sa_id FOREIGN KEY (sa_id) REFERENCES products.supplier_article(sa_id);

--------------------------------------------------------------------------------

ALTER TABLE products.sa_cost
	ADD CONSTRAINT pk_sa_cost PRIMARY KEY (sa_id);
