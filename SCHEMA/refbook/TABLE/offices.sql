CREATE TABLE refbook.offices (
	office_id integer DEFAULT nextval('refbook.offices_office_id_seq'::regclass) NOT NULL,
	office_name character varying(50) NOT NULL
);

ALTER TABLE refbook.offices OWNER TO postgres;

GRANT ALL ON TABLE refbook.offices TO user1c;

--------------------------------------------------------------------------------

ALTER TABLE refbook.offices
	ADD CONSTRAINT uq_offices_country_name UNIQUE (office_name);

--------------------------------------------------------------------------------

ALTER TABLE refbook.offices
	ADD CONSTRAINT pk_offices PRIMARY KEY (office_id);
