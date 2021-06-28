CREATE TABLE products.barcodes (
	barcode_id integer DEFAULT nextval('products.barcodes_barcode_id_seq'::regclass) NOT NULL,
	barcode character varying(30),
	nm_id integer,
	sa_id integer NOT NULL,
	ts_id smallint NOT NULL
);

ALTER TABLE products.barcodes OWNER TO postgres;

GRANT ALL ON TABLE products.barcodes TO user1c;

--------------------------------------------------------------------------------

ALTER TABLE products.barcodes
	ADD CONSTRAINT fk_barcodes_ts_id FOREIGN KEY (ts_id) REFERENCES products.tech_size(ts_id);

--------------------------------------------------------------------------------

ALTER TABLE products.barcodes
	ADD CONSTRAINT fk_barcodes_sa_id FOREIGN KEY (sa_id) REFERENCES products.supplier_article(sa_id);

--------------------------------------------------------------------------------

ALTER TABLE products.barcodes
	ADD CONSTRAINT uq_barcodes_barcode UNIQUE (barcode);

--------------------------------------------------------------------------------

ALTER TABLE products.barcodes
	ADD CONSTRAINT pk_barcodes PRIMARY KEY (barcode_id);
