CREATE TABLE refbook.gi_statuses (
	status_id smallint DEFAULT nextval('refbook.gi_statuses_status_id_seq'::regclass) NOT NULL,
	status_name character varying(50) NOT NULL
);

ALTER TABLE refbook.gi_statuses OWNER TO postgres;

GRANT ALL ON TABLE refbook.gi_statuses TO user1c;

--------------------------------------------------------------------------------

ALTER TABLE refbook.gi_statuses
	ADD CONSTRAINT uq_gi_statuses_name UNIQUE (status_name);

--------------------------------------------------------------------------------

ALTER TABLE refbook.gi_statuses
	ADD CONSTRAINT pk_gi_statuses PRIMARY KEY (status_id);
