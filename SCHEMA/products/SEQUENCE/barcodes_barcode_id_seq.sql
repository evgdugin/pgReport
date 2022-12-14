CREATE SEQUENCE products.barcodes_barcode_id_seq
	AS integer
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE products.barcodes_barcode_id_seq OWNER TO postgres;

GRANT ALL ON SEQUENCE products.barcodes_barcode_id_seq TO user1c;

ALTER SEQUENCE products.barcodes_barcode_id_seq
	OWNED BY products.barcodes.barcode_id;
