CREATE SEQUENCE refbook.countryes_country_id_seq
	AS smallint
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE refbook.countryes_country_id_seq OWNER TO postgres;

GRANT ALL ON SEQUENCE refbook.countryes_country_id_seq TO user1c;

ALTER SEQUENCE refbook.countryes_country_id_seq
	OWNED BY refbook.countryes.country_id;
