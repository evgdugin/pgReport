CREATE SEQUENCE products.subjects_subject_id_seq
	AS integer
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE products.subjects_subject_id_seq OWNER TO postgres;

ALTER SEQUENCE products.subjects_subject_id_seq
	OWNED BY products.subjects.subject_id;
