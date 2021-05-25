CREATE TABLE refbook.okrugs (
	okrug_id smallint DEFAULT nextval('refbook.okrugs_okrug_id_seq'::regclass) NOT NULL,
	okrug_name character varying(50) NOT NULL
);

ALTER TABLE refbook.okrugs OWNER TO postgres;

GRANT ALL ON TABLE refbook.okrugs TO user1c;

--------------------------------------------------------------------------------

ALTER TABLE refbook.okrugs
	ADD CONSTRAINT uq_okrugs_okrug_name UNIQUE (okrug_name);

--------------------------------------------------------------------------------

ALTER TABLE refbook.okrugs
	ADD CONSTRAINT pk_okrugs PRIMARY KEY (okrug_id);
