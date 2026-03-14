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
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: lmf_db; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE lmf_db WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'es_ES.UTF-8';


ALTER DATABASE lmf_db OWNER TO postgres;

\connect lmf_db

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
    cl_id_cancion integer NOT NULL,
    cl_id_modelo integer NOT NULL,
    cl_tipo_interaccion text NOT NULL,
    cl_fecha_interaccion timestamp with time zone NOT NULL,
    cl_ts_calif_global numeric(6,5),
    cl_user_score integer NOT NULL,
    cl_ts_config_epocas integer NOT NULL,
    cl_loss numeric(10,6),
    cl_accuracy numeric(6,4),
    cl_learning_rate numeric(10,8),
    cl_batch_size integer
);


ALTER TABLE public.calibracion OWNER TO postgres;

--
-- Name: COLUMN calibracion.cl_tipo_interaccion; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.calibracion.cl_tipo_interaccion IS '''fit'': Entrenamiento
''predict'': Prediccion
''infer'': inferencia o ajuste';


--
-- Name: COLUMN calibracion.cl_loss; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.calibracion.cl_loss IS 'Loss del modelo al momento de la interacciÃ³n';


--
-- Name: COLUMN calibracion.cl_accuracy; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.calibracion.cl_accuracy IS 'Accuracy del modelo al momento de la interacciÃ³n';


--
-- Name: COLUMN calibracion.cl_learning_rate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.calibracion.cl_learning_rate IS 'Learning rate usado en la interacciÃ³n';


--
-- Name: COLUMN calibracion.cl_batch_size; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.calibracion.cl_batch_size IS 'Batch size usado en la interacciÃ³n';


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
    ca_calif_usuario integer,
    ca_filesize integer,
    ca_filename text,
    ca_id_tipodato integer NOT NULL,
    ca_activo bit(1) DEFAULT '1'::"bit" NOT NULL,
    ca_metadata text,
    ca_ts_calif_global numeric(6,5),
    ca_train_level_global integer DEFAULT 0 NOT NULL,
    ca_ts_features_filename text
);


ALTER TABLE public.canciones OWNER TO postgres;

--
-- Name: canciones_evaluadas_ce_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.canciones ALTER COLUMN ca_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.canciones_evaluadas_ce_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
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
    pl_is_default bit(1) DEFAULT '0'::"bit" NOT NULL
);


ALTER TABLE public.playlists OWNER TO postgres;

--
-- Name: playlists_pl_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.playlists ALTER COLUMN pl_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.playlists_pl_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
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

ALTER TABLE public.rel_playlists_canciones ALTER COLUMN pc_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rel_playlists_canciones_pc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
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

ALTER TABLE public.tipos_datos ALTER COLUMN td_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tipos_datos_td_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: ts_modelos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ts_modelos (
    ts_id integer NOT NULL,
    ts_activo bit(1) DEFAULT '1'::"bit" NOT NULL,
    ts_canciones_entrenadas integer DEFAULT 0 NOT NULL,
    ts_epocas_completadas integer DEFAULT 0 NOT NULL,
    ts_fechacreacion timestamp with time zone NOT NULL,
    ts_fecharegistro timestamp with time zone DEFAULT now() NOT NULL,
    ts_filename text NOT NULL,
    ts_perdida numeric(10,6) DEFAULT '0'::numeric NOT NULL,
    ts_precision numeric(6,4) DEFAULT '0'::numeric NOT NULL,
    ts_version integer DEFAULT 1 NOT NULL,
    ts_is_global bit(1) NOT NULL,
    ts_learning_rate numeric(10,8) DEFAULT 0.001 NOT NULL,
    ts_batch_size integer DEFAULT 32 NOT NULL,
    ts_num_clases integer DEFAULT 4 NOT NULL,
    ts_input_dim integer DEFAULT 128 NOT NULL,
    ts_arquitectura text
);


ALTER TABLE public.ts_modelos OWNER TO postgres;

--
-- Name: COLUMN ts_modelos.ts_learning_rate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.ts_modelos.ts_learning_rate IS 'Tasa de aprendizaje del optimizador Adam';


--
-- Name: COLUMN ts_modelos.ts_batch_size; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.ts_modelos.ts_batch_size IS 'TamaÃ±o de batch para entrenamiento';


--
-- Name: COLUMN ts_modelos.ts_num_clases; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.ts_modelos.ts_num_clases IS 'NÃºmero de clases de salida (4: scores 0-3)';


--
-- Name: COLUMN ts_modelos.ts_input_dim; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.ts_modelos.ts_input_dim IS 'DimensiÃ³n de entrada (128 para VGGish embeddings)';


--
-- Name: COLUMN ts_modelos.ts_arquitectura; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.ts_modelos.ts_arquitectura IS 'Arquitectura del modelo en formato JSON';


--
-- Name: ts_modelos_ts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.ts_modelos ALTER COLUMN ts_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ts_modelos_ts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


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
-- Name: calibracion unique_calibracion_cl_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calibracion
    ADD CONSTRAINT unique_calibracion_cl_id UNIQUE (cl_id);


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
-- Name: ts_modelos unique_ts_modelos_ts_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ts_modelos
    ADD CONSTRAINT unique_ts_modelos_ts_id UNIQUE (ts_id);


--
-- Name: index_cl_id_cancion; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_cl_id_cancion ON public.calibracion USING btree (cl_id_cancion);


--
-- Name: index_cl_id_modelo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_cl_id_modelo ON public.calibracion USING btree (cl_id_modelo);


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

CREATE INDEX tipos_datos_td_id ON public.tipos_datos USING btree (td_id) WITH (deduplicate_items='false');


--
-- Name: canciones FK_canciones_tipos_datos; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.canciones
    ADD CONSTRAINT "FK_canciones_tipos_datos" FOREIGN KEY (ca_id_tipodato) REFERENCES public.tipos_datos(td_id) NOT VALID;


--
-- Name: calibracion link_canciones_calibracion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calibracion
    ADD CONSTRAINT link_canciones_calibracion FOREIGN KEY (cl_id_cancion) REFERENCES public.canciones(ca_id) MATCH FULL ON UPDATE CASCADE;


--
-- Name: rel_playlists_canciones link_canciones_rel_playlists_canciones; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rel_playlists_canciones
    ADD CONSTRAINT link_canciones_rel_playlists_canciones FOREIGN KEY (pr_ca_id) REFERENCES public.canciones(ca_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: rel_playlists_canciones link_playlists_rel_playlists_canciones; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rel_playlists_canciones
    ADD CONSTRAINT link_playlists_rel_playlists_canciones FOREIGN KEY (pr_pl_id) REFERENCES public.playlists(pl_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: calibracion link_ts_modelos_calibracion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calibracion
    ADD CONSTRAINT link_ts_modelos_calibracion FOREIGN KEY (cl_id_modelo) REFERENCES public.ts_modelos(ts_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: playlists link_ts_modelos_playlists; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlists
    ADD CONSTRAINT link_ts_modelos_playlists FOREIGN KEY (pl_id_ts_modelo) REFERENCES public.ts_modelos(ts_id) MATCH FULL ON UPDATE CASCADE;


--
-- PostgreSQL database dump complete
--

