CREATE TABLE warehouse.ozon_stock (
	stock_dt date NOT NULL,
	barcode_id integer NOT NULL,
	sats_id integer NOT NULL,
	present smallint NOT NULL,
	reserved smallint NOT NULL
);

ALTER TABLE warehouse.ozon_stock OWNER TO postgres;

GRANT ALL ON TABLE warehouse.ozon_stock TO user1c;

--------------------------------------------------------------------------------

CREATE INDEX ix_ozon_stock_stock_dt_sats_id ON warehouse.ozon_stock USING btree (stock_dt, sats_id) INCLUDE (present, reserved);

--------------------------------------------------------------------------------

ALTER TABLE warehouse.ozon_stock
	ADD CONSTRAINT pk_ozon_stock PRIMARY KEY (stock_dt, barcode_id);

--------------------------------------------------------------------------------

ALTER TABLE warehouse.ozon_stock
	ADD CONSTRAINT fk_ozon_stock_barcode_id FOREIGN KEY (barcode_id) REFERENCES products.barcodes(barcode_id);

--------------------------------------------------------------------------------

ALTER TABLE warehouse.ozon_stock
	ADD CONSTRAINT fk_ozon_stosk_sats_id FOREIGN KEY (sats_id) REFERENCES products.sats(sats_id);
