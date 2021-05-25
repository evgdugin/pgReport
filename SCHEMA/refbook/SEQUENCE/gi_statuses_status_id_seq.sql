CREATE SEQUENCE refbook.gi_statuses_status_id_seq
	AS smallint
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE refbook.gi_statuses_status_id_seq OWNER TO postgres;

ALTER SEQUENCE refbook.gi_statuses_status_id_seq
	OWNED BY refbook.gi_statuses.status_id;
