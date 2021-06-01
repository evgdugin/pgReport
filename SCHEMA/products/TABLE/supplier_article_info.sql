CREATE TABLE products.supplier_article_info (
	sa_id integer NOT NULL,
	brand_id integer NOT NULL,
	subject_id integer NOT NULL
);

ALTER TABLE products.supplier_article_info OWNER TO postgres;

GRANT ALL ON TABLE products.supplier_article_info TO user1c;

--------------------------------------------------------------------------------

ALTER TABLE products.supplier_article_info
	ADD CONSTRAINT fk_supplier_article_info_subject_id FOREIGN KEY (subject_id) REFERENCES products.subjects(subject_id);

--------------------------------------------------------------------------------

ALTER TABLE products.supplier_article_info
	ADD CONSTRAINT fk_supplier_article_info_brand_id FOREIGN KEY (brand_id) REFERENCES products.brands(brand_id);

--------------------------------------------------------------------------------

ALTER TABLE products.supplier_article_info
	ADD CONSTRAINT fk_supplier_article_info_sa_id FOREIGN KEY (sa_id) REFERENCES products.supplier_article(sa_id);

--------------------------------------------------------------------------------

ALTER TABLE products.supplier_article_info
	ADD CONSTRAINT pk_supplier_article_info PRIMARY KEY (sa_id);
