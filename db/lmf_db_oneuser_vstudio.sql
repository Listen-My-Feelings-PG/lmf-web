--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: calibracion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.calibracion (
    cl_id integer NOT NULL,
    cl_ca_id integer NOT NULL,
    cl_calif_usuario integer,
    cl_ts_prediccion numeric,
    cl_fecha_calibracion timestamp with time zone DEFAULT now() NOT NULL,
    cl_estatus_calibracion text,
    cl_id_modelo integer
);


ALTER TABLE public.calibracion OWNER TO postgres;

--
-- Name: calibracion_cl_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.calibracion ALTER COLUMN cl_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.calibracion_cl_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: canciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.canciones (
    ca_id integer NOT NULL,
    ca_nombre text NOT NULL,
    ca_calif_usuario integer,
    ca_file_size integer,
    ca_file_name text,
    ca_train_level_global integer DEFAULT 0 NOT NULL,
    ca_id_tipodato integer,
    ca_activo boolean DEFAULT true NOT NULL,
    ca_ts_features text,
    ca_ts_prediccion numeric,
    ca_ts_init_status text NOT NULL,
    ca_ts_status text
);


ALTER TABLE public.canciones OWNER TO postgres;

--
-- Name: canciones_ca_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.canciones ALTER COLUMN ca_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.canciones_ca_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: canciones_playlists; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.canciones_playlists (
    cp_id integer NOT NULL,
    cp_ca_id integer,
    cp_pl_id integer
);


ALTER TABLE public.canciones_playlists OWNER TO postgres;

--
-- Name: canciones_playlists_cp_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.canciones_playlists_cp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.canciones_playlists_cp_id_seq OWNER TO postgres;

--
-- Name: canciones_playlists_cp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.canciones_playlists_cp_id_seq OWNED BY public.canciones_playlists.cp_id;


--
-- Name: modelos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.modelos (
    mo_id integer NOT NULL,
    mo_filename text NOT NULL,
    mo_descripcion text,
    mo_fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    mo_train_count integer NOT NULL,
    mo_global boolean NOT NULL,
    mo_activo boolean NOT NULL
);


ALTER TABLE public.modelos OWNER TO postgres;

--
-- Name: modelos_mo_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.modelos_mo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.modelos_mo_id_seq OWNER TO postgres;

--
-- Name: modelos_mo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.modelos_mo_id_seq OWNED BY public.modelos.mo_id;


--
-- Name: playlists; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.playlists (
    pl_id integer NOT NULL,
    pl_nombre text,
    pl_id_modelo integer,
    pl_activo boolean DEFAULT true NOT NULL,
    pl_fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    pl_default boolean NOT NULL
);


ALTER TABLE public.playlists OWNER TO postgres;

--
-- Name: playlists_pl_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.playlists_pl_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.playlists_pl_id_seq OWNER TO postgres;

--
-- Name: playlists_pl_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.playlists_pl_id_seq OWNED BY public.playlists.pl_id;


--
-- Name: tipos_datos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipos_datos (
    td_id integer NOT NULL,
    td_tipo text,
    td_descripcion text,
    td_activo boolean DEFAULT true NOT NULL
);


ALTER TABLE public.tipos_datos OWNER TO postgres;

--
-- Name: tipos_datos_td_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tipos_datos ALTER COLUMN td_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tipos_datos_td_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: canciones_playlists cp_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.canciones_playlists ALTER COLUMN cp_id SET DEFAULT nextval('public.canciones_playlists_cp_id_seq'::regclass);


--
-- Name: modelos mo_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modelos ALTER COLUMN mo_id SET DEFAULT nextval('public.modelos_mo_id_seq'::regclass);


--
-- Name: playlists pl_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlists ALTER COLUMN pl_id SET DEFAULT nextval('public.playlists_pl_id_seq'::regclass);


--
-- Data for Name: calibracion; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: canciones; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: canciones_playlists; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.canciones_playlists VALUES
	(1, NULL, NULL),
	(3, NULL, NULL);


--
-- Data for Name: modelos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.modelos VALUES
	(4, 'sdfwf we we f', 'Este es un modelo de prueba', '2025-01-31 09:44:17.862837-06', 0, true, true);


--
-- Data for Name: playlists; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: tipos_datos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tipos_datos OVERRIDING SYSTEM VALUE VALUES
	(1, 'file', 'Archivo local cargado desde el ordenador', true);


--
-- Name: calibracion_cl_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.calibracion_cl_id_seq', 1, false);


--
-- Name: canciones_ca_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.canciones_ca_id_seq', 318, true);


--
-- Name: canciones_playlists_cp_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.canciones_playlists_cp_id_seq', 3, true);


--
-- Name: modelos_mo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.modelos_mo_id_seq', 4, true);


--
-- Name: playlists_pl_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.playlists_pl_id_seq', 2, true);


--
-- Name: tipos_datos_td_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tipos_datos_td_id_seq', 1, true);


--
-- Name: canciones PK_ca_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.canciones
    ADD CONSTRAINT "PK_ca_id" PRIMARY KEY (ca_id);


--
-- Name: calibracion PK_cl_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calibracion
    ADD CONSTRAINT "PK_cl_id" PRIMARY KEY (cl_id);


--
-- Name: canciones_playlists PK_cp_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.canciones_playlists
    ADD CONSTRAINT "PK_cp_id" PRIMARY KEY (cp_id);


--
-- Name: modelos PK_mo_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modelos
    ADD CONSTRAINT "PK_mo_id" PRIMARY KEY (mo_id);


--
-- Name: playlists PK_pl_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlists
    ADD CONSTRAINT "PK_pl_id" PRIMARY KEY (pl_id);


--
-- Name: tipos_datos PK_td_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipos_datos
    ADD CONSTRAINT "PK_td_id" PRIMARY KEY (td_id);


--
-- Name: playlists FK_07efb6da311257f07e7b26102c2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlists
    ADD CONSTRAINT "FK_07efb6da311257f07e7b26102c2" FOREIGN KEY (pl_id_modelo) REFERENCES public.modelos(mo_id) ON DELETE SET NULL;


--
-- Name: canciones_playlists FK_6e0e4f8b7d0a3e539a0aad74e71; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.canciones_playlists
    ADD CONSTRAINT "FK_6e0e4f8b7d0a3e539a0aad74e71" FOREIGN KEY (cp_pl_id) REFERENCES public.playlists(pl_id) ON DELETE SET NULL;


--
-- Name: calibracion FK_c086e6a11a8dded8d67c9d35b8d; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calibracion
    ADD CONSTRAINT "FK_c086e6a11a8dded8d67c9d35b8d" FOREIGN KEY (cl_id_modelo) REFERENCES public.modelos(mo_id) ON DELETE SET NULL;


--
-- Name: canciones_playlists FK_eae80d3fc22b6ff0311a167d115; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.canciones_playlists
    ADD CONSTRAINT "FK_eae80d3fc22b6ff0311a167d115" FOREIGN KEY (cp_ca_id) REFERENCES public.canciones(ca_id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

