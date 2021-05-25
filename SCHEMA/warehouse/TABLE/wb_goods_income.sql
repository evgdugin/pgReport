CREATE TABLE warehouse.wb_goods_income (
	gi_id integer NOT NULL,
	status_id smallint NOT NULL,
	dt_first_packages timestamp with time zone NOT NULL,
	dt_last_packages timestamp with time zone NOT NULL,
	gi_dt date NOT NULL,
	close_dt timestamp with time zone NOT NULL,
	last_change_dt timestamp with time zone NOT NULL,
	office_id smallint NOT NULL
);

ALTER TABLE warehouse.wb_goods_income OWNER TO postgres;

GRANT ALL ON TABLE warehouse.wb_goods_income TO user1c;

--------------------------------------------------------------------------------

ALTER TABLE warehouse.wb_goods_income
	ADD CONSTRAINT fk_goods_income_office_id FOREIGN KEY (office_id) REFERENCES refbook.offices(office_id);

--------------------------------------------------------------------------------

ALTER TABLE warehouse.wb_goods_income
	ADD CONSTRAINT fk_goods_income_status_id FOREIGN KEY (status_id) REFERENCES refbook.gi_statuses(status_id);

--------------------------------------------------------------------------------

ALTER TABLE warehouse.wb_goods_income
	ADD CONSTRAINT pk_goods_income PRIMARY KEY (gi_id);
