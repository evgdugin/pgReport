CREATE TABLE products.ozon_article_info (
	barcode_id integer NOT NULL,
	sats_id integer NOT NULL,
	create_dt date NOT NULL,
	product_id integer NOT NULL,
	ozon_sa character varying(100) NOT NULL,
	marketing_price numeric(9,2),
	price numeric(9,2),
	recommended_price numeric(9,2),
	old_price numeric(9,2),
	price_index numeric(5,2),
	visible bit(1) NOT NULL
);

ALTER TABLE products.ozon_article_info OWNER TO postgres;

GRANT ALL ON TABLE products.ozon_article_info TO user1c;

--------------------------------------------------------------------------------

ALTER TABLE products.ozon_article_info
	ADD CONSTRAINT pk_ozon_article_info PRIMARY KEY (barcode_id);

--------------------------------------------------------------------------------

ALTER TABLE products.ozon_article_info
	ADD CONSTRAINT fk_ozon_article_info_barcode_id FOREIGN KEY (barcode_id) REFERENCES products.barcodes(barcode_id);

--------------------------------------------------------------------------------

ALTER TABLE products.ozon_article_info
	ADD CONSTRAINT fk_ozon_article_info_sats_id FOREIGN KEY (sats_id) REFERENCES products.sats(sats_id);
