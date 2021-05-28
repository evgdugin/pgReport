CREATE TABLE sale.day_report_detail (
	od_id bigint NOT NULL,
	sale_type character(1) NOT NULL,
	sale_id bigint NOT NULL,
	sale_dt date NOT NULL,
	last_change_dt timestamp with time zone NOT NULL,
	barcode_id integer NOT NULL,
	quantity smallint NOT NULL,
	total_price numeric(9,2) NOT NULL,
	discount_percent smallint NOT NULL,
	is_supply bit(1) NOT NULL,
	is_realization bit(1) NOT NULL,
	promo_code_discount smallint NOT NULL,
	office_id integer NOT NULL,
	country_id smallint NOT NULL,
	okrug_id smallint NOT NULL,
	region_id smallint NOT NULL,
	gi_id integer,
	spp smallint NOT NULL,
	forpay numeric(9,2),
	finished_price numeric(9,2),
	price_with_disc numeric(9,2),
	is_storno bit(1) NOT NULL
);

ALTER TABLE sale.day_report_detail OWNER TO postgres;

GRANT ALL ON TABLE sale.day_report_detail TO user1c;

--------------------------------------------------------------------------------

CREATE INDEX ix_day_report_detail_stock_dt_barcode_id ON sale.day_report_detail USING btree (sale_dt, barcode_id) INCLUDE (quantity, finished_price);

--------------------------------------------------------------------------------

ALTER TABLE sale.day_report_detail
	ADD CONSTRAINT fk_day_report_detail_region_id FOREIGN KEY (region_id) REFERENCES refbook.regions(region_id);

--------------------------------------------------------------------------------

ALTER TABLE sale.day_report_detail
	ADD CONSTRAINT fk_day_report_detail_okrug_id FOREIGN KEY (okrug_id) REFERENCES refbook.okrugs(okrug_id);

--------------------------------------------------------------------------------

ALTER TABLE sale.day_report_detail
	ADD CONSTRAINT fk_day_report_detail_office_id FOREIGN KEY (office_id) REFERENCES refbook.offices(office_id);

--------------------------------------------------------------------------------

ALTER TABLE sale.day_report_detail
	ADD CONSTRAINT fk_day_report_detail_country_id FOREIGN KEY (country_id) REFERENCES refbook.countryes(country_id);

--------------------------------------------------------------------------------

ALTER TABLE sale.day_report_detail
	ADD CONSTRAINT fk_day_report_detail_barcode_id FOREIGN KEY (barcode_id) REFERENCES products.barcodes(barcode_id);

--------------------------------------------------------------------------------

ALTER TABLE sale.day_report_detail
	ADD CONSTRAINT pk_day_report_detail PRIMARY KEY (sale_dt, od_id, sale_type, sale_id);
