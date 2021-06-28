CREATE TABLE warehouse.stock (
	barcode_id integer NOT NULL,
	pants_id integer,
	whprice numeric(9,2),
	price numeric(9,2),
	qty smallint,
	dt date,
	sats_id integer NOT NULL
);

ALTER TABLE warehouse.stock OWNER TO postgres;

GRANT ALL ON TABLE warehouse.stock TO user1c;

--------------------------------------------------------------------------------

CREATE INDEX ix_stock_sata_id ON warehouse.stock USING btree (sats_id) INCLUDE (whprice, price, qty, pants_id);

--------------------------------------------------------------------------------

ALTER TABLE warehouse.stock
	ADD CONSTRAINT fk_stock_barcode_id FOREIGN KEY (barcode_id) REFERENCES products.barcodes(barcode_id);

--------------------------------------------------------------------------------

ALTER TABLE warehouse.stock
	ADD CONSTRAINT pk_stock PRIMARY KEY (barcode_id);

--------------------------------------------------------------------------------

ALTER TABLE warehouse.stock
	ADD CONSTRAINT fk_stosk_sats_id FOREIGN KEY (sats_id) REFERENCES products.sats(sats_id);
