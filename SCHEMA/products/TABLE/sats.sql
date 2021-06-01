CREATE TABLE products.sats (
	sats_id integer DEFAULT nextval('products.sats_sats_id_seq'::regclass) NOT NULL,
	sa_id integer NOT NULL,
	ts_id smallint NOT NULL
);

ALTER TABLE products.sats OWNER TO postgres;

GRANT ALL ON TABLE products.sats TO user1c;

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX uq_sats_sa_id_ts_id ON products.sats USING btree (sa_id, ts_id);

--------------------------------------------------------------------------------

ALTER TABLE products.sats
	ADD CONSTRAINT fk_sats_ts_id FOREIGN KEY (ts_id) REFERENCES products.tech_size(ts_id);

--------------------------------------------------------------------------------

ALTER TABLE products.sats
	ADD CONSTRAINT fk_sats_sa_id FOREIGN KEY (sa_id) REFERENCES products.supplier_article(sa_id);

--------------------------------------------------------------------------------

ALTER TABLE products.sats
	ADD CONSTRAINT pk_sats PRIMARY KEY (sats_id);
