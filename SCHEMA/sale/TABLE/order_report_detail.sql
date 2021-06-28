CREATE TABLE sale.order_report_detail (
	order_dt date NOT NULL,
	od_id bigint NOT NULL,
	order_num bigint NOT NULL,
	last_change_dt timestamp with time zone NOT NULL,
	barcode_id integer NOT NULL,
	quantity smallint NOT NULL,
	total_price numeric(9,2) NOT NULL,
	discount_percent smallint NOT NULL,
	office_id integer NOT NULL,
	okrug_id smallint NOT NULL,
	gi_id integer,
	is_cancel bit(1) NOT NULL,
	cancel_dt date,
	sats_id integer NOT NULL
);

ALTER TABLE sale.order_report_detail OWNER TO postgres;

GRANT ALL ON TABLE sale.order_report_detail TO user1c;

--------------------------------------------------------------------------------

CREATE INDEX ix_order_report_detail_order_dt_barcode_id ON sale.order_report_detail USING btree (order_dt, barcode_id) INCLUDE (quantity, total_price, is_cancel);

--------------------------------------------------------------------------------

CREATE INDEX ix_order_report_detail_order_dt_sats_id ON sale.order_report_detail USING btree (order_dt, sats_id) INCLUDE (quantity, total_price, is_cancel);

--------------------------------------------------------------------------------

ALTER TABLE sale.order_report_detail
	ADD CONSTRAINT fk_order_report_detail_okrug_id FOREIGN KEY (okrug_id) REFERENCES refbook.okrugs(okrug_id);

--------------------------------------------------------------------------------

ALTER TABLE sale.order_report_detail
	ADD CONSTRAINT fk_order_report_detail_office_id FOREIGN KEY (office_id) REFERENCES refbook.offices(office_id);

--------------------------------------------------------------------------------

ALTER TABLE sale.order_report_detail
	ADD CONSTRAINT fk_order_report_detail_barcode_id FOREIGN KEY (barcode_id) REFERENCES products.barcodes(barcode_id);

--------------------------------------------------------------------------------

ALTER TABLE sale.order_report_detail
	ADD CONSTRAINT pk_order_report_detail PRIMARY KEY (order_dt, od_id, order_num);

--------------------------------------------------------------------------------

ALTER TABLE sale.order_report_detail
	ADD CONSTRAINT fk_order_report_detail_sats_id FOREIGN KEY (sats_id) REFERENCES products.sats(sats_id);
