CREATE TABLE warehouse.wb_goods_income_detail (
	gid_id integer DEFAULT nextval('warehouse.wb_goods_income_detail_gid_id_seq'::regclass) NOT NULL,
	gi_id integer NOT NULL,
	barcode_id integer NOT NULL,
	quantity smallint NOT NULL,
	price numeric(15,2) NOT NULL
);

ALTER TABLE warehouse.wb_goods_income_detail OWNER TO postgres;

GRANT ALL ON TABLE warehouse.wb_goods_income_detail TO user1c;

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX uq_wb_goods_income_detail_gi_id ON warehouse.wb_goods_income_detail USING btree (gi_id, barcode_id) INCLUDE (quantity);

--------------------------------------------------------------------------------

ALTER TABLE warehouse.wb_goods_income_detail
	ADD CONSTRAINT fk_wb_goods_income_detail_gi_id FOREIGN KEY (gi_id) REFERENCES warehouse.wb_goods_income(gi_id);

--------------------------------------------------------------------------------

ALTER TABLE warehouse.wb_goods_income_detail
	ADD CONSTRAINT fk_wb_goods_income_detail_barcode_id FOREIGN KEY (barcode_id) REFERENCES products.barcodes(barcode_id);

--------------------------------------------------------------------------------

ALTER TABLE warehouse.wb_goods_income_detail
	ADD CONSTRAINT pk_wb_goods_income_detail PRIMARY KEY (gid_id);
