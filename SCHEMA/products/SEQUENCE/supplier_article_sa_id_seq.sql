CREATE SEQUENCE products.supplier_article_sa_id_seq
	AS integer
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE products.supplier_article_sa_id_seq OWNER TO postgres;

GRANT ALL ON SEQUENCE products.supplier_article_sa_id_seq TO user1c;

ALTER SEQUENCE products.supplier_article_sa_id_seq
	OWNED BY products.supplier_article.sa_id;
