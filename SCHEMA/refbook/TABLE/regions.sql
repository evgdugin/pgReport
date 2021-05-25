CREATE TABLE refbook.regions (
	region_id smallint DEFAULT nextval('refbook.regions_region_id_seq'::regclass) NOT NULL,
	region_name character varying(50) NOT NULL
);

ALTER TABLE refbook.regions OWNER TO postgres;

GRANT ALL ON TABLE refbook.regions TO user1c;

--------------------------------------------------------------------------------

ALTER TABLE refbook.regions
	ADD CONSTRAINT uq_regions_region_name UNIQUE (region_name);

--------------------------------------------------------------------------------

ALTER TABLE refbook.regions
	ADD CONSTRAINT pk_regions PRIMARY KEY (region_id);
