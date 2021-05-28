CREATE TABLE products.barcodes_info (
	barcode_id integer NOT NULL,
	brand_id integer NOT NULL,
	subject_id integer NOT NULL
);

ALTER TABLE products.barcodes_info OWNER TO postgres;

GRANT ALL ON TABLE products.barcodes_info TO user1c;

--------------------------------------------------------------------------------

ALTER TABLE products.barcodes_info
	ADD CONSTRAINT fk_barcodes_info_subject_id FOREIGN KEY (subject_id) REFERENCES products.subjects(subject_id);

--------------------------------------------------------------------------------

ALTER TABLE products.barcodes_info
	ADD CONSTRAINT fk_barcodes_info_brand_id FOREIGN KEY (brand_id) REFERENCES products.brands(brand_id);

--------------------------------------------------------------------------------

ALTER TABLE products.barcodes_info
	ADD CONSTRAINT fk_barcodes_info_barcode_id FOREIGN KEY (barcode_id) REFERENCES products.barcodes(barcode_id);

--------------------------------------------------------------------------------

ALTER TABLE products.barcodes_info
	ADD CONSTRAINT pk_barcodes_info PRIMARY KEY (barcode_id);
