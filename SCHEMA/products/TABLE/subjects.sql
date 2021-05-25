CREATE TABLE products.subjects (
	subject_id integer DEFAULT nextval('products.subjects_subject_id_seq'::regclass) NOT NULL,
	subject_name character varying(50) NOT NULL
);

ALTER TABLE products.subjects OWNER TO postgres;

GRANT ALL ON TABLE products.subjects TO user1c;

--------------------------------------------------------------------------------

ALTER TABLE products.subjects
	ADD CONSTRAINT uq_subjects_region_name UNIQUE (subject_name);

--------------------------------------------------------------------------------

ALTER TABLE products.subjects
	ADD CONSTRAINT pk_subjects PRIMARY KEY (subject_id);
