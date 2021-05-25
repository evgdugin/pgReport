CREATE TABLE refbook.countryes (
	country_id smallint DEFAULT nextval('refbook.countryes_country_id_seq'::regclass) NOT NULL,
	country_name character varying(50) NOT NULL
);

ALTER TABLE refbook.countryes OWNER TO postgres;

GRANT ALL ON TABLE refbook.countryes TO user1c;

--------------------------------------------------------------------------------

ALTER TABLE refbook.countryes
	ADD CONSTRAINT uq_countryes_country_name UNIQUE (country_name);

--------------------------------------------------------------------------------

ALTER TABLE refbook.countryes
	ADD CONSTRAINT pk_countryes PRIMARY KEY (country_id);
