CREATE TABLE refbook.supplier_contract (
	suppliercontract_code_id smallint DEFAULT nextval('refbook.supplier_contract_suppliercontract_code_id_seq'::regclass) NOT NULL,
	suppliercontract_code character varying(15) NOT NULL
);

ALTER TABLE refbook.supplier_contract OWNER TO postgres;

GRANT ALL ON TABLE refbook.supplier_contract TO user1c;

--------------------------------------------------------------------------------

ALTER TABLE refbook.supplier_contract
	ADD CONSTRAINT pk_supplier_contract PRIMARY KEY (suppliercontract_code_id);
