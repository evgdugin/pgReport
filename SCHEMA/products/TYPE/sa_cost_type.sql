CREATE TYPE products.sa_cost_type AS (
	sa_name character varying(36),
	whprice numeric(9,2),
	price numeric(9,2),
	art_name character varying(100)
);

ALTER TYPE products.sa_cost_type OWNER TO postgres;
