CREATE SEQUENCE warehouse.wb_goods_income_detail_gid_id_seq
	AS integer
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE warehouse.wb_goods_income_detail_gid_id_seq OWNER TO postgres;

GRANT ALL ON SEQUENCE warehouse.wb_goods_income_detail_gid_id_seq TO user1c;

ALTER SEQUENCE warehouse.wb_goods_income_detail_gid_id_seq
	OWNED BY warehouse.wb_goods_income_detail.gid_id;
