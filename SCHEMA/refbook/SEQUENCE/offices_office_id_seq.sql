CREATE SEQUENCE refbook.offices_office_id_seq
	AS integer
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE refbook.offices_office_id_seq OWNER TO postgres;

GRANT ALL ON SEQUENCE refbook.offices_office_id_seq TO user1c;

ALTER SEQUENCE refbook.offices_office_id_seq
	OWNED BY refbook.offices.office_id;
