--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: beverages; Type: TABLE; Schema: public; Owner: cocktail; Tablespace: 
--

CREATE TABLE beverages (
    id integer NOT NULL,
    name character varying,
    description character varying
);


ALTER TABLE public.beverages OWNER TO cocktail;

--
-- Name: beverages_id_seq; Type: SEQUENCE; Schema: public; Owner: cocktail
--

CREATE SEQUENCE beverages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.beverages_id_seq OWNER TO cocktail;

--
-- Name: beverages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cocktail
--

ALTER SEQUENCE beverages_id_seq OWNED BY beverages.id;


--
-- Name: ingredients; Type: TABLE; Schema: public; Owner: cocktail; Tablespace: 
--

CREATE TABLE ingredients (
    id integer NOT NULL,
    name character varying,
    description character varying
);


ALTER TABLE public.ingredients OWNER TO cocktail;

--
-- Name: ingredients_id_seq; Type: SEQUENCE; Schema: public; Owner: cocktail
--

CREATE SEQUENCE ingredients_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ingredients_id_seq OWNER TO cocktail;

--
-- Name: ingredients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cocktail
--

ALTER SEQUENCE ingredients_id_seq OWNED BY ingredients.id;


--
-- Name: instructions; Type: TABLE; Schema: public; Owner: cocktail; Tablespace: 
--

CREATE TABLE instructions (
    beverage integer NOT NULL,
    instruction text,
    id integer NOT NULL
);


ALTER TABLE public.instructions OWNER TO cocktail;

--
-- Name: instructions_id_seq; Type: SEQUENCE; Schema: public; Owner: cocktail
--

CREATE SEQUENCE instructions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.instructions_id_seq OWNER TO cocktail;

--
-- Name: instructions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cocktail
--

ALTER SEQUENCE instructions_id_seq OWNED BY instructions.id;


--
-- Name: measurements; Type: TABLE; Schema: public; Owner: cocktail; Tablespace: 
--

CREATE TABLE measurements (
    id integer NOT NULL,
    name character varying,
    unit character varying
);


ALTER TABLE public.measurements OWNER TO cocktail;

--
-- Name: measurements_id_seq; Type: SEQUENCE; Schema: public; Owner: cocktail
--

CREATE SEQUENCE measurements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.measurements_id_seq OWNER TO cocktail;

--
-- Name: measurements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cocktail
--

ALTER SEQUENCE measurements_id_seq OWNED BY measurements.id;


--
-- Name: recipes; Type: TABLE; Schema: public; Owner: cocktail; Tablespace: 
--

CREATE TABLE recipes (
    beverage integer NOT NULL,
    ingredient integer NOT NULL,
    measurement integer NOT NULL,
    quantity character varying
);


ALTER TABLE public.recipes OWNER TO cocktail;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: cocktail
--

ALTER TABLE ONLY beverages ALTER COLUMN id SET DEFAULT nextval('beverages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: cocktail
--

ALTER TABLE ONLY ingredients ALTER COLUMN id SET DEFAULT nextval('ingredients_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: cocktail
--

ALTER TABLE ONLY instructions ALTER COLUMN id SET DEFAULT nextval('instructions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: cocktail
--

ALTER TABLE ONLY measurements ALTER COLUMN id SET DEFAULT nextval('measurements_id_seq'::regclass);


--
-- Name: beverages_pkey; Type: CONSTRAINT; Schema: public; Owner: cocktail; Tablespace: 
--

ALTER TABLE ONLY beverages
    ADD CONSTRAINT beverages_pkey PRIMARY KEY (id);


--
-- Name: ingredients_pkey; Type: CONSTRAINT; Schema: public; Owner: cocktail; Tablespace: 
--

ALTER TABLE ONLY ingredients
    ADD CONSTRAINT ingredients_pkey PRIMARY KEY (id);


--
-- Name: instructions_pkey; Type: CONSTRAINT; Schema: public; Owner: cocktail; Tablespace: 
--

ALTER TABLE ONLY instructions
    ADD CONSTRAINT instructions_pkey PRIMARY KEY (id);


--
-- Name: measurements_pkey; Type: CONSTRAINT; Schema: public; Owner: cocktail; Tablespace: 
--

ALTER TABLE ONLY measurements
    ADD CONSTRAINT measurements_pkey PRIMARY KEY (id);


--
-- Name: recipes_pkey; Type: CONSTRAINT; Schema: public; Owner: cocktail; Tablespace: 
--

ALTER TABLE ONLY recipes
    ADD CONSTRAINT recipes_pkey PRIMARY KEY (beverage, ingredient);


--
-- Name: unique_beverage; Type: CONSTRAINT; Schema: public; Owner: cocktail; Tablespace: 
--

ALTER TABLE ONLY beverages
    ADD CONSTRAINT unique_beverage UNIQUE (name);


--
-- Name: unique_ingredient; Type: CONSTRAINT; Schema: public; Owner: cocktail; Tablespace: 
--

ALTER TABLE ONLY ingredients
    ADD CONSTRAINT unique_ingredient UNIQUE (name);


--
-- Name: instructions_beverage_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cocktail
--

ALTER TABLE ONLY instructions
    ADD CONSTRAINT instructions_beverage_fkey FOREIGN KEY (beverage) REFERENCES beverages(id);


--
-- Name: recipes_beverage_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cocktail
--

ALTER TABLE ONLY recipes
    ADD CONSTRAINT recipes_beverage_fkey FOREIGN KEY (beverage) REFERENCES beverages(id);


--
-- Name: recipes_ingredient_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cocktail
--

ALTER TABLE ONLY recipes
    ADD CONSTRAINT recipes_ingredient_fkey FOREIGN KEY (ingredient) REFERENCES ingredients(id);


--
-- Name: recipes_measurement_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cocktail
--

ALTER TABLE ONLY recipes
    ADD CONSTRAINT recipes_measurement_fkey FOREIGN KEY (measurement) REFERENCES measurements(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

