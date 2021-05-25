CREATE TABLE refbook.days (
	dt date NOT NULL
);

ALTER TABLE refbook.days OWNER TO postgres;

GRANT ALL ON TABLE refbook.days TO user1c;

GRANT ALL(dt) ON TABLE refbook.days TO user1c;

--------------------------------------------------------------------------------

ALTER TABLE refbook.days
	ADD CONSTRAINT pk_days PRIMARY KEY (dt);
