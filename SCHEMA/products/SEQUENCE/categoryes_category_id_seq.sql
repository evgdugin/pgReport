CREATE SEQUENCE products.categoryes_category_id_seq
	AS integer
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE products.categoryes_category_id_seq OWNER TO postgres;

GRANT ALL ON SEQUENCE products.categoryes_category_id_seq TO user1c;

ALTER SEQUENCE products.categoryes_category_id_seq
	OWNED BY products.categoryes.category_id;
