--
-- PostgreSQL database dump
--

-- Dumped from database version 17.7
-- Dumped by pg_dump version 17.2

SET statement_timeout = 0;

SET lock_timeout = 0;

SET idle_in_transaction_session_timeout = 0;

SET transaction_timeout = 0;

SET client_encoding = 'UTF8';

SET standard_conforming_strings = on;

SELECT pg_catalog.set_config ('search_path', '', false);

SET check_function_bodies = false;

SET xmloption = content;

SET client_min_messages = warning;

SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: canciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.canciones (
    ca_id integer NOT NULL,
    ca_calif_usuario integer,
    ca_filesize integer,
    ca_filename text,
    ca_train_level_local integer DEFAULT 0 NOT NULL,
    ca_id_tipodato integer NOT NULL,
    ca_activo boolean DEFAULT true NOT NULL,
    ca_metadata text,
    ca_ts_prediccion numeric,
    ca_train_level_global integer DEFAULT 0 NOT NULL
);

ALTER TABLE public.canciones OWNER TO postgres;

--
-- Name: canciones_evaluadas_ce_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.canciones
ALTER COLUMN ca_id
ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.canciones_evaluadas_ce_id_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: playlists; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.playlists (
    pl_id integer NOT NULL,
    pl_nombre text NOT NULL,
    pl_id_ts_modelo integer,
    pl_id_fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    pl_activo bit(1) DEFAULT '1'::"bit" NOT NULL,
    pl_is_global bit(1) DEFAULT '0'::"bit" NOT NULL
);

ALTER TABLE public.playlists OWNER TO postgres;

--
-- Name: playlists_pl_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.playlists
ALTER COLUMN pl_id
ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.playlists_pl_id_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: rel_playlists_canciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rel_playlists_canciones (
    pc_id integer NOT NULL,
    pr_ca_id integer NOT NULL,
    pr_pl_id integer NOT NULL,
    pr_pl_fecha_adicion timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE public.rel_playlists_canciones OWNER TO postgres;

--
-- Name: rel_playlists_canciones_pc_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.rel_playlists_canciones
ALTER COLUMN pc_id
ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rel_playlists_canciones_pc_id_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tipos_datos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipos_datos (
    td_id integer NOT NULL,
    td_tipo text,
    td_tipo_model text NOT NULL,
    td_descripcion text
);

ALTER TABLE public.tipos_datos OWNER TO postgres;

--
-- Name: tipos_datos_td_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tipos_datos
ALTER COLUMN td_id
ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tipos_datos_td_id_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Data for Name: canciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

--
-- Data for Name: playlists; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO
    public.playlists OVERRIDING SYSTEM VALUE
VALUES (
        1,
        'global',
        NULL,
        '2026-02-22 18:57:37.569194-06',
        B'1',
        B'0'
    );

--
-- Data for Name: rel_playlists_canciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

--
-- Data for Name: tipos_datos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO
    public.tipos_datos OVERRIDING SYSTEM VALUE
VALUES (
        1,
        'archivo',
        'file',
        'archivos que se guardan en disco con formato .mp3 (primeras pruebas)'
    ),
    (
        2,
        'enlace',
        'link',
        'enlaces extraidos de otros sitios (por definir)'
    );

--
-- Name: canciones_evaluadas_ce_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval (
        'public.canciones_evaluadas_ce_id_seq', 738, true
    );

--
-- Name: playlists_pl_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval ( 'public.playlists_pl_id_seq', 1, true );

--
-- Name: rel_playlists_canciones_pc_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval (
        'public.rel_playlists_canciones_pc_id_seq', 1, false
    );

--
-- Name: tipos_datos_td_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval ( 'public.tipos_datos_td_id_seq', 2, true );

--
-- Name: canciones PK_509f2887bb0bd963b5f723f27be; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.canciones
ADD CONSTRAINT "PK_509f2887bb0bd963b5f723f27be" PRIMARY KEY (ca_id);

--
-- Name: tipos_datos tipos_datos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipos_datos
ADD CONSTRAINT tipos_datos_pkey PRIMARY KEY (td_id);

--
-- Name: playlists unique_playlists_pl_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlists
ADD CONSTRAINT unique_playlists_pl_id UNIQUE (pl_id);

--
-- Name: rel_playlists_canciones unique_rel_playlists_canciones_pc_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rel_playlists_canciones
ADD CONSTRAINT unique_rel_playlists_canciones_pc_id UNIQUE (pc_id);

--
-- Name: index_pr_ca_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_pr_ca_id ON public.rel_playlists_canciones USING btree (pr_ca_id);

--
-- Name: index_pr_pl_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_pr_pl_id ON public.rel_playlists_canciones USING btree (pr_pl_id);

--
-- Name: tipos_datos_td_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tipos_datos_td_id ON public.tipos_datos USING btree (td_id)
WITH (deduplicate_items = 'false');

--
-- Name: canciones FK_canciones_tipos_datos; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.canciones
ADD CONSTRAINT "FK_canciones_tipos_datos" FOREIGN KEY (ca_id_tipodato) REFERENCES public.tipos_datos (td_id) NOT VALID;

--
-- Name: rel_playlists_canciones link_canciones_rel_playlists_canciones; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rel_playlists_canciones
ADD CONSTRAINT link_canciones_rel_playlists_canciones FOREIGN KEY (pr_ca_id) REFERENCES public.canciones (ca_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;

--
-- Name: rel_playlists_canciones link_playlists_rel_playlists_canciones; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rel_playlists_canciones
ADD CONSTRAINT link_playlists_rel_playlists_canciones FOREIGN KEY (pr_pl_id) REFERENCES public.playlists (pl_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;

--
-- PostgreSQL database dump complete
--