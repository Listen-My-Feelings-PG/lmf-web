--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.2

-- Started on 2025-01-26 16:20:59

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

DROP DATABASE lmf_db_oneuser;
--
-- TOC entry 4907 (class 1262 OID 16508)
-- Name: lmf_db_oneuser; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE lmf_db_oneuser WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Spanish_Mexico.1252';


ALTER DATABASE lmf_db_oneuser OWNER TO postgres;

\connect lmf_db_oneuser

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
-- TOC entry 222 (class 1259 OID 16537)
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
-- TOC entry 221 (class 1259 OID 16536)
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
-- TOC entry 218 (class 1259 OID 16518)
-- Name: canciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.canciones (
    ca_id integer NOT NULL,
    ca_nombre text NOT NULL,
    ca_calif_usuario integer,
    ca_file_size integer,
    ca_file_name text,
    ca_train_level_global integer DEFAULT 0 NOT NULL,
    ca_id_tipodato integer NOT NULL,
    ca_activo boolean DEFAULT true NOT NULL,
    ca_ts_features text,
    ca_ts_prediccion numeric,
    ca_ts_init_status text NOT NULL,
    "idDataTypeId" integer,
    ca_ts_status text
);


ALTER TABLE public.canciones OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16517)
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
-- TOC entry 225 (class 1259 OID 16618)
-- Name: canciones_playlists; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.canciones_playlists (
    cp_id integer NOT NULL,
    ca_id integer,
    pl_id integer
);


ALTER TABLE public.canciones_playlists OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16653)
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
-- TOC entry 4908 (class 0 OID 0)
-- Dependencies: 228
-- Name: canciones_playlists_cp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.canciones_playlists_cp_id_seq OWNED BY public.canciones_playlists.cp_id;


--
-- TOC entry 223 (class 1259 OID 16560)
-- Name: modelos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.modelos (
    mo_id integer NOT NULL,
    mo_filename text NOT NULL,
    mo_descripcion text,
    mo_fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    mo_train_count integer NOT NULL,
    mo_global boolean NOT NULL
);


ALTER TABLE public.modelos OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16647)
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
-- TOC entry 4909 (class 0 OID 0)
-- Dependencies: 226
-- Name: modelos_mo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.modelos_mo_id_seq OWNED BY public.modelos.mo_id;


--
-- TOC entry 224 (class 1259 OID 16595)
-- Name: playlists; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.playlists (
    pl_id integer NOT NULL,
    pl_nombre text,
    pl_id_modelo integer,
    pl_activo boolean NOT NULL,
    pl_fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    pl_default boolean NOT NULL
);


ALTER TABLE public.playlists OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16650)
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
-- TOC entry 4910 (class 0 OID 0)
-- Dependencies: 227
-- Name: playlists_pl_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.playlists_pl_id_seq OWNED BY public.playlists.pl_id;


--
-- TOC entry 220 (class 1259 OID 16528)
-- Name: tipos_datos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipos_datos (
    td_id integer NOT NULL,
    td_tipo text,
    td_tipo_modelo text NOT NULL,
    td_descripcion text
);


ALTER TABLE public.tipos_datos OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16527)
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
-- TOC entry 4727 (class 2604 OID 16654)
-- Name: canciones_playlists cp_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.canciones_playlists ALTER COLUMN cp_id SET DEFAULT nextval('public.canciones_playlists_cp_id_seq'::regclass);


--
-- TOC entry 4723 (class 2604 OID 16648)
-- Name: modelos mo_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modelos ALTER COLUMN mo_id SET DEFAULT nextval('public.modelos_mo_id_seq'::regclass);


--
-- TOC entry 4725 (class 2604 OID 16651)
-- Name: playlists pl_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlists ALTER COLUMN pl_id SET DEFAULT nextval('public.playlists_pl_id_seq'::regclass);


--
-- TOC entry 4895 (class 0 OID 16537)
-- Dependencies: 222
-- Data for Name: calibracion; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4891 (class 0 OID 16518)
-- Dependencies: 218
-- Data for Name: canciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.canciones (ca_id, ca_nombre, ca_calif_usuario, ca_file_size, ca_file_name, ca_train_level_global, ca_id_tipodato, ca_activo, ca_ts_features, ca_ts_prediccion, ca_ts_init_status, "idDataTypeId", ca_ts_status) OVERRIDING SYSTEM VALUE VALUES
	(171, '[Hatsune Miku] After Rain SweetDrops [English Sub].mp3', 2, 6143688, '1737925812019_[Hatsune Miku] After Rain SweetDrops [English Sub].mp3', 0, 1, true, '1737925812019_[Hatsune Miku] After Rain SweetDrops [English Sub].mp3.json.gz', NULL, 'train', 1, NULL),
	(172, '[Hatsune Miku] Sayonara Arpeggio [VOSTFR].mp3', 2, 6080189, '1737925812269_[Hatsune Miku] Sayonara Arpeggio [VOSTFR].mp3', 0, 1, true, '1737925812269_[Hatsune Miku] Sayonara Arpeggio [VOSTFR].mp3.json.gz', NULL, 'train', 1, NULL),
	(173, '[MV]さよならカンパニュラ  mehikari feat 初音ミ�.mp3', 3, 5636316, '1737925812341_[MV]さよならカンパニュラ  mehikari feat 初音ミ�.mp3', 0, 1, true, '1737925812341_[MV]さよならカンパニュラ  mehikari feat 初音ミ�.mp3.json.gz', NULL, 'train', 1, NULL);


--
-- TOC entry 4898 (class 0 OID 16618)
-- Dependencies: 225
-- Data for Name: canciones_playlists; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4896 (class 0 OID 16560)
-- Dependencies: 223
-- Data for Name: modelos; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4897 (class 0 OID 16595)
-- Dependencies: 224
-- Data for Name: playlists; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4893 (class 0 OID 16528)
-- Dependencies: 220
-- Data for Name: tipos_datos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tipos_datos (td_id, td_tipo, td_tipo_modelo, td_descripcion) OVERRIDING SYSTEM VALUE VALUES
	(1, 'file', 'tensorflow', 'Archivo local cargado desde el ordenador');


--
-- TOC entry 4911 (class 0 OID 0)
-- Dependencies: 221
-- Name: calibracion_cl_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.calibracion_cl_id_seq', 1, false);


--
-- TOC entry 4912 (class 0 OID 0)
-- Dependencies: 217
-- Name: canciones_ca_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.canciones_ca_id_seq', 173, true);


--
-- TOC entry 4913 (class 0 OID 0)
-- Dependencies: 228
-- Name: canciones_playlists_cp_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.canciones_playlists_cp_id_seq', 1, false);


--
-- TOC entry 4914 (class 0 OID 0)
-- Dependencies: 226
-- Name: modelos_mo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.modelos_mo_id_seq', 1, false);


--
-- TOC entry 4915 (class 0 OID 0)
-- Dependencies: 227
-- Name: playlists_pl_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.playlists_pl_id_seq', 1, false);


--
-- TOC entry 4916 (class 0 OID 0)
-- Dependencies: 219
-- Name: tipos_datos_td_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tipos_datos_td_id_seq', 1, true);


--
-- TOC entry 4729 (class 2606 OID 16526)
-- Name: canciones PK_ca_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.canciones
    ADD CONSTRAINT "PK_ca_id" PRIMARY KEY (ca_id);


--
-- TOC entry 4733 (class 2606 OID 16578)
-- Name: calibracion PK_cl_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calibracion
    ADD CONSTRAINT "PK_cl_id" PRIMARY KEY (cl_id);


--
-- TOC entry 4739 (class 2606 OID 16623)
-- Name: canciones_playlists PK_cp_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.canciones_playlists
    ADD CONSTRAINT "PK_cp_id" PRIMARY KEY (cp_id);


--
-- TOC entry 4735 (class 2606 OID 16568)
-- Name: modelos PK_mo_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modelos
    ADD CONSTRAINT "PK_mo_id" PRIMARY KEY (mo_id);


--
-- TOC entry 4737 (class 2606 OID 16603)
-- Name: playlists PK_pl_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlists
    ADD CONSTRAINT "PK_pl_id" PRIMARY KEY (pl_id);


--
-- TOC entry 4731 (class 2606 OID 16534)
-- Name: tipos_datos PK_td_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipos_datos
    ADD CONSTRAINT "PK_td_id" PRIMARY KEY (td_id);


--
-- TOC entry 4742 (class 2606 OID 16660)
-- Name: playlists FK_07efb6da311257f07e7b26102c2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlists
    ADD CONSTRAINT "FK_07efb6da311257f07e7b26102c2" FOREIGN KEY (pl_id_modelo) REFERENCES public.modelos(mo_id);


--
-- TOC entry 4743 (class 2606 OID 16670)
-- Name: canciones_playlists FK_9613767d9d39cd2e85d346f87be; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.canciones_playlists
    ADD CONSTRAINT "FK_9613767d9d39cd2e85d346f87be" FOREIGN KEY (pl_id) REFERENCES public.playlists(pl_id);


--
-- TOC entry 4740 (class 2606 OID 16680)
-- Name: canciones FK_9739bcd488328c0acc993252665; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.canciones
    ADD CONSTRAINT "FK_9739bcd488328c0acc993252665" FOREIGN KEY ("idDataTypeId") REFERENCES public.tipos_datos(td_id);


--
-- TOC entry 4741 (class 2606 OID 16655)
-- Name: calibracion FK_c086e6a11a8dded8d67c9d35b8d; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calibracion
    ADD CONSTRAINT "FK_c086e6a11a8dded8d67c9d35b8d" FOREIGN KEY (cl_id_modelo) REFERENCES public.modelos(mo_id);


--
-- TOC entry 4744 (class 2606 OID 16665)
-- Name: canciones_playlists FK_fb9e626a02d79bc193ad71b3e19; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.canciones_playlists
    ADD CONSTRAINT "FK_fb9e626a02d79bc193ad71b3e19" FOREIGN KEY (ca_id) REFERENCES public.canciones(ca_id);


-- Completed on 2025-01-26 16:20:59

--
-- PostgreSQL database dump complete
--

