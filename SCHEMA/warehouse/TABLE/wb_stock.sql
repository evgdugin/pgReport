CREATE TABLE warehouse.wb_stock (
	stock_dt date NOT NULL,
	barcode_id integer NOT NULL,
	office_id smallint NOT NULL,
	suppliercontract_code_id smallint NOT NULL,
	is_supply bit(1) NOT NULL,
	is_realization bit(1) NOT NULL,
	quantity smallint NOT NULL,
	quantity_full smallint NOT NULL,
	quantity_not_in_orders smallint NOT NULL,
	in_way_to_client smallint NOT NULL,
	in_way_from_client smallint NOT NULL,
	days_on_site smallint NOT NULL,
	sats_id integer NOT NULL
);

ALTER TABLE warehouse.wb_stock OWNER TO postgres;

GRANT ALL ON TABLE warehouse.wb_stock TO user1c;

--------------------------------------------------------------------------------

CREATE INDEX ix_wb_stock_stock_dt_stock_dt_sa_id_ts_id ON warehouse.wb_stock USING btree (stock_dt, barcode_id) INCLUDE (quantity, days_on_site, in_way_to_client, in_way_from_client, quantity_full, quantity_not_in_orders);

--------------------------------------------------------------------------------

CREATE INDEX ix_wb_stock_stock_dt_stock_dt_sats_id ON warehouse.wb_stock USING btree (stock_dt, sats_id) INCLUDE (quantity, days_on_site, in_way_to_client, in_way_from_client, quantity_full, quantity_not_in_orders);

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX uq_wb_stock_stock_dt_sats_id_barcode_id_office_id_suppliercontr ON warehouse.wb_stock USING btree (stock_dt, sats_id, barcode_id, office_id, suppliercontract_code_id) INCLUDE (quantity, days_on_site, in_way_to_client, in_way_from_client);

--------------------------------------------------------------------------------

ALTER TABLE warehouse.wb_stock
	ADD CONSTRAINT fk_wb_stock_suppliercontract_code_id FOREIGN KEY (suppliercontract_code_id) REFERENCES refbook.supplier_contract(suppliercontract_code_id);

--------------------------------------------------------------------------------

ALTER TABLE warehouse.wb_stock
	ADD CONSTRAINT fk_wb_stock_office_id FOREIGN KEY (office_id) REFERENCES refbook.offices(office_id);

--------------------------------------------------------------------------------

ALTER TABLE warehouse.wb_stock
	ADD CONSTRAINT fk_wb_stock_barcode_id FOREIGN KEY (barcode_id) REFERENCES products.barcodes(barcode_id);

--------------------------------------------------------------------------------

ALTER TABLE warehouse.wb_stock
	ADD CONSTRAINT pk_wb_stock PRIMARY KEY (stock_dt, barcode_id, office_id, suppliercontract_code_id);

--------------------------------------------------------------------------------

ALTER TABLE warehouse.wb_stock
	ADD CONSTRAINT fk_wb_stosk_sats_id FOREIGN KEY (sats_id) REFERENCES products.sats(sats_id);
