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
-- Name: calibracion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.calibracion (
    cl_id integer NOT NULL,
    cl_ca_id integer NOT NULL,
    cl_calif_usuario integer,
    cl_ts_prediccion numeric,
    cl_fecha_calibracion timestamp with time zone DEFAULT now() NOT NULL,
    cl_estatus_calibracion text,
    cl_id_modelo integer,
    cl_activo boolean NOT NULL
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
    ca_id_tipodato integer NOT NULL,
    ca_activo boolean DEFAULT true NOT NULL,
    ca_ts_features text,
    ca_ts_prediccion numeric,
    ca_ts_init_status text NOT NULL,
    ca_ts_status text,
    "idDataTypeId" integer
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
    mo_activo boolean DEFAULT true NOT NULL
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
    pl_global boolean DEFAULT false NOT NULL
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
    td_activo boolean NOT NULL,
    td_tipo_modelo text
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

COPY public.calibracion (cl_id, cl_ca_id, cl_calif_usuario, cl_ts_prediccion, cl_fecha_calibracion, cl_estatus_calibracion, cl_id_modelo, cl_activo) FROM stdin;
\.


--
-- Data for Name: canciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.canciones (ca_id, ca_nombre, ca_calif_usuario, ca_file_size, ca_file_name, ca_train_level_global, ca_id_tipodato, ca_activo, ca_ts_features, ca_ts_prediccion, ca_ts_init_status, ca_ts_status, "idDataTypeId") FROM stdin;
927	(ゆうゆ) clock[07_07].mp3	2	5083192	1742347216391_(ゆうゆ) clock[07_07].mp3	0	1	t	1742347216391_(ゆうゆ) clock[07_07].mp3.json.gz	\N	train	trained	1
929	[Hatsune Miku] Sayonara Arpeggio [VOSTFR].mp3	1	6084413	1742347216554_[Hatsune Miku] Sayonara Arpeggio [VOSTFR].mp3	0	1	t	1742347216554_[Hatsune Miku] Sayonara Arpeggio [VOSTFR].mp3.json.gz	\N	train	trained	1
934	[Trance] Inu Machine   Cancer ft Hatsune Miku [Original Mix].mp3	0	12388909	1742347216977_[Trance] Inu Machine   Cancer ft Hatsune Miku [Original Mix].mp3	0	1	t	1742347216977_[Trance] Inu Machine   Cancer ft Hatsune Miku [Original Mix].mp3.json.gz	\N	train	\N	1
932	[Music] Livetune (feat Hatsune Miku)   Redia.mp3	2	6832978	1742347216821_[Music] Livetune (feat Hatsune Miku)   Redia.mp3	0	1	t	1742347216821_[Music] Livetune (feat Hatsune Miku)   Redia.mp3.json.gz	\N	train	trained	1
931	[MIKU LUKA] Cintaku (REDSHiFT Remix).mp3	2	5753389	1742347216755_[MIKU LUKA] Cintaku (REDSHiFT Remix).mp3	0	1	t	1742347216755_[MIKU LUKA] Cintaku (REDSHiFT Remix).mp3.json.gz	\N	train	trained	1
935	[Vocaloid] Hatsune Miku   Crystal Quartz + mp3 ♪♪.mp3	0	6340738	1742347217132_[Vocaloid] Hatsune Miku   Crystal Quartz + mp3 ♪♪.mp3	0	1	t	1742347217132_[Vocaloid] Hatsune Miku   Crystal Quartz + mp3 ♪♪.mp3.json.gz	\N	train	\N	1
936	[VOCALOID] Sailing  初音ミク [公式.mp3	0	7771505	1742347217214_[VOCALOID] Sailing  初音ミク [公式.mp3	0	1	t	1742347217214_[VOCALOID] Sailing  初音ミク [公式.mp3.json.gz	\N	train	\N	1
938	「carol」song by 初音ミク【ロボだこれー!】English and romaji subs.mp3	0	5143378	1742347217405_「carol」song by 初音ミク【ロボだこれー!】English and romaji subs.mp3	0	1	t	1742347217405_「carol」song by 初音ミク【ロボだこれー!】English and romaji subs.mp3.json.gz	\N	train	\N	1
939	「ＣＬＯＷＮ」初音ミクオリジナル.mp3	0	6351396	1742347217487_「ＣＬＯＷＮ」初音ミクオリジナル.mp3	0	1	t	1742347217487_「ＣＬＯＷＮ」初音ミクオリジナル.mp3.json.gz	\N	train	\N	1
940	「code Dystopia」 feat初音ミク.mp3	0	10220328	1742347217568_「code Dystopia」 feat初音ミク.mp3	0	1	t	1742347217568_「code Dystopia」 feat初音ミク.mp3.json.gz	\N	train	\N	1
942	【Clover Life】  Hatsune Miku【初音ミク】.mp3	0	10546243	1742347217756_【Clover Life】  Hatsune Miku【初音ミク】.mp3	0	1	t	1742347217756_【Clover Life】  Hatsune Miku【初音ミク】.mp3.json.gz	\N	train	\N	1
943	【Hatsune Miku, Yamine Renri】Cat's Story【Original】.mp3	0	4931472	1742347217846_【Hatsune Miku, Yamine Renri】Cat's Story【Original】.mp3	0	1	t	1742347217846_【Hatsune Miku, Yamine Renri】Cat's Story【Original】.mp3.json.gz	\N	train	\N	1
945	【Hatsune Miku】Body Music【Original Song】.mp3	0	4738909	1742347218031_【Hatsune Miku】Body Music【Original Song】.mp3	0	1	t	1742347218031_【Hatsune Miku】Body Music【Original Song】.mp3.json.gz	\N	train	\N	1
946	【Hatsune Miku】Brownie【Original Song】.mp3	0	5771477	1742347218093_【Hatsune Miku】Brownie【Original Song】.mp3	0	1	t	1742347218093_【Hatsune Miku】Brownie【Original Song】.mp3.json.gz	\N	train	\N	1
948	【Hatsune Miku】COTTON CANDY【Vocaloid Original Song】.mp3	0	4956203	1742347218249_【Hatsune Miku】COTTON CANDY【Vocaloid Original Song】.mp3	0	1	t	1742347218249_【Hatsune Miku】COTTON CANDY【Vocaloid Original Song】.mp3.json.gz	\N	train	\N	1
949	【Independent Animation】『Cirque le coeur』.mp3	0	4342150	1742347218329_【Independent Animation】『Cirque le coeur』.mp3	0	1	t	1742347218329_【Independent Animation】『Cirque le coeur』.mp3.json.gz	\N	train	\N	1
951	【Kasane Teto u0026 Hatsune Miku】Crystal Snow (Negi Drill Ver)【Original Song】.mp3	0	5770224	1742347218443_【Kasane Teto u0026 Hatsune Miku】Crystal Snow (Negi Drill Ver)【Original Song】.mp3	0	1	t	1742347218443_【Kasane Teto u0026 Hatsune Miku】Crystal Snow (Negi Drill Ver)【Original Song】.mp3.json.gz	\N	train	\N	1
952	【Macne Nana, Gumi, Miku, and Gachapoid】 C'est Le Brate 【Vocaloid Original ft Mizudori Dreamer】.mp3	0	6019838	1742347218515_【Macne Nana, Gumi, Miku, and Gachapoid】 C'est Le Brate 【Vocaloid Original ft Mizudori Dreamer】.mp3	0	1	t	1742347218515_【Macne Nana, Gumi, Miku, and Gachapoid】 C'est Le Brate 【Vocaloid Original ft Mizudori Dreamer】.mp3.json.gz	\N	train	\N	1
953	【MMD PV】初音ミク   COLORFUL HEART [Papikorin].mp3	0	7082499	1742347218567_【MMD PV】初音ミク   COLORFUL HEART [Papikorin].mp3	0	1	t	1742347218567_【MMD PV】初音ミク   COLORFUL HEART [Papikorin].mp3.json.gz	\N	train	\N	1
955	【Robo feat 初音ミク】 SKY HIGHWAY【オリジナル曲�.mp3	0	5549634	1742347218759_【Robo feat 初音ミク】 SKY HIGHWAY【オリジナル曲�.mp3	0	1	t	1742347218759_【Robo feat 初音ミク】 SKY HIGHWAY【オリジナル曲�.mp3.json.gz	\N	train	\N	1
956	【Torero】　Chaika　【VOCARAP】.mp3	0	6628503	1742347218859_【Torero】　Chaika　【VOCARAP】.mp3	0	1	t	1742347218859_【Torero】　Chaika　【VOCARAP】.mp3.json.gz	\N	train	\N	1
957	【Vocaloid Inst】Carmine Cube【Dubstep】.mp3	0	4138929	1742347218999_【Vocaloid Inst】Carmine Cube【Dubstep】.mp3	0	1	t	1742347218999_【Vocaloid Inst】Carmine Cube【Dubstep】.mp3.json.gz	\N	train	\N	1
959	【VOCALOID】 【初音ミク】 Cross Heart in Iris 【オリジナル】.mp3	0	6930060	1742347219111_【VOCALOID】 【初音ミク】 Cross Heart in Iris 【オリジナル】.mp3	0	1	t	1742347219111_【VOCALOID】 【初音ミク】 Cross Heart in Iris 【オリジナル】.mp3.json.gz	\N	train	\N	1
960	【オリジナル】CLOVER LOVE【初音ミク】.mp3	0	6190992	1742347219204_【オリジナル】CLOVER LOVE【初音ミク】.mp3	0	1	t	1742347219204_【オリジナル】CLOVER LOVE【初音ミク】.mp3.json.gz	\N	train	\N	1
962	【オリジナル曲PV】clock lock works【初音ミク】.mp3	0	6247951	1742347219389_【オリジナル曲PV】clock lock works【初音ミク】.mp3	0	1	t	1742347219389_【オリジナル曲PV】clock lock works【初音ミク】.mp3.json.gz	\N	train	\N	1
1085	celluloid.mp3	0	5760819	1742347231399_celluloid.mp3	0	1	t	1742347231399_celluloid.mp3.json.gz	\N	train	\N	1
964	【ミク・MAYU・がくぽ】「Ib」 forever 【オリジナルPV】.mp3	0	5669379	1742347219567_【ミク・MAYU・がくぽ】「Ib」 forever 【オリジナルPV】.mp3	0	1	t	1742347219567_【ミク・MAYU・がくぽ】「Ib」 forever 【オリジナルPV】.mp3.json.gz	\N	train	\N	1
966	【初音ミク   Hatsune Miku】 BREAKING DAWN 【Original】.mp3	0	6919495	1742347219698_【初音ミク   Hatsune Miku】 BREAKING DAWN 【Original】.mp3	0	1	t	1742347219698_【初音ミク   Hatsune Miku】 BREAKING DAWN 【Original】.mp3.json.gz	\N	train	\N	1
967	【初音ミク   Hatsune Miku】ChaiN DestructioN【Original】.mp3	0	6390359	1742347219807_【初音ミク   Hatsune Miku】ChaiN DestructioN【Original】.mp3	0	1	t	1742347219807_【初音ミク   Hatsune Miku】ChaiN DestructioN【Original】.mp3.json.gz	\N	train	\N	1
968	【初音ミク x Gumsyrop】Crossalgia【オリジナル曲】.mp3	0	5637406	1742347219932_【初音ミク x Gumsyrop】Crossalgia【オリジナル曲】.mp3	0	1	t	1742347219932_【初音ミク x Gumsyrop】Crossalgia【オリジナル曲】.mp3.json.gz	\N	train	\N	1
970	【初音ミク】 Anata no Utahime (8ch arr) 【休闲の1月曲】.mp3	0	2801668	1742347220129_【初音ミク】 Anata no Utahime (8ch arr) 【休闲の1月曲】.mp3	0	1	t	1742347220129_【初音ミク】 Anata no Utahime (8ch arr) 【休闲の1月曲】.mp3.json.gz	\N	train	\N	1
971	【初音ミク】 Baby Steps 【オリジナル�.mp3	0	6394121	1742347220224_【初音ミク】 Baby Steps 【オリジナル�.mp3	0	1	t	1742347220224_【初音ミク】 Baby Steps 【オリジナル�.mp3.json.gz	\N	train	\N	1
973	【初音ミク】 BrainHeadCrasher 【オリジナルproject UNT】.mp3	0	5142658	1742347220409_【初音ミク】 BrainHeadCrasher 【オリジナルproject UNT】.mp3	0	1	t	1742347220409_【初音ミク】 BrainHeadCrasher 【オリジナルproject UNT】.mp3.json.gz	\N	train	\N	1
974	【初音ミク】 Brilliant Landscape 【オリジナル曲】.mp3	0	6904356	1742347220499_【初音ミク】 Brilliant Landscape 【オリジナル曲】.mp3	0	1	t	1742347220499_【初音ミク】 Brilliant Landscape 【オリジナル曲】.mp3.json.gz	\N	train	\N	1
976	【初音ミク】 Carry on 【オリジナル！】[HD1080p].mp3	0	7855515	1742347220690_【初音ミク】 Carry on 【オリジナル！】[HD1080p].mp3	0	1	t	1742347220690_【初音ミク】 Carry on 【オリジナル！】[HD1080p].mp3.json.gz	\N	train	\N	1
977	【初音ミク】　Change　【オリジナル】.mp3	0	5807306	1742347220815_【初音ミク】　Change　【オリジナル】.mp3	0	1	t	1742347220815_【初音ミク】　Change　【オリジナル】.mp3.json.gz	\N	train	\N	1
978	【初音ミク】 Cherry 【オリジナル】[HD1080p].mp3	0	6846143	1742347220928_【初音ミク】 Cherry 【オリジナル】[HD1080p].mp3	0	1	t	1742347220928_【初音ミク】 Cherry 【オリジナル】[HD1080p].mp3.json.gz	\N	train	\N	1
980	【初音ミク】 Chip Tears   Glitch DUB 【セルフリミックス】.mp3	0	7609035	1742347221142_【初音ミク】 Chip Tears   Glitch DUB 【セルフリミックス】.mp3	0	1	t	1742347221142_【初音ミク】 Chip Tears   Glitch DUB 【セルフリミックス】.mp3.json.gz	\N	train	\N	1
981	【初音ミク】 clear blue echo 【オリジナル】.mp3	0	7227856	1742347221241_【初音ミク】 clear blue echo 【オリジナル】.mp3	0	1	t	1742347221241_【初音ミク】 clear blue echo 【オリジナル】.mp3.json.gz	\N	train	\N	1
983	【初音ミク】　CO2はもう潮時　【オリジナル】.mp3	0	2849409	1742347221535_【初音ミク】　CO2はもう潮時　【オリジナル】.mp3	0	1	t	1742347221535_【初音ミク】　CO2はもう潮時　【オリジナル】.mp3.json.gz	\N	train	\N	1
984	【初音ミク】 cocoon 【オリジナル】.mp3	0	7958240	1742347221568_【初音ミク】 cocoon 【オリジナル】.mp3	0	1	t	1742347221568_【初音ミク】 cocoon 【オリジナル】.mp3.json.gz	\N	train	\N	1
986	【初音ミク】 CONNECTION 【オリジナル】.mp3	0	8027830	1742347221717_【初音ミク】 CONNECTION 【オリジナル】.mp3	0	1	t	1742347221717_【初音ミク】 CONNECTION 【オリジナル】.mp3.json.gz	\N	train	\N	1
987	【初音ミク】　Counter　【オリジナル】.mp3	0	8433206	1742347221835_【初音ミク】　Counter　【オリジナル】.mp3	0	1	t	1742347221835_【初音ミク】　Counter　【オリジナル】.mp3.json.gz	\N	train	\N	1
989	【初音ミク】 だんだん早くなる Getting Faster and Faster【オリジナル�.mp3	0	3340929	1742347222039_【初音ミク】 だんだん早くなる Getting Faster and Faster【オリジナル�.mp3	0	1	t	1742347222039_【初音ミク】 だんだん早くなる Getting Faster and Faster【オリジナル�.mp3.json.gz	\N	train	\N	1
990	【初音ミク】 紫陽花が咲く頃に、君と恋をする 【nk】.mp3	0	6366535	1742347222114_【初音ミク】 紫陽花が咲く頃に、君と恋をする 【nk】.mp3	0	1	t	1742347222114_【初音ミク】 紫陽花が咲く頃に、君と恋をする 【nk】.mp3.json.gz	\N	train	\N	1
991	【初音ミク】　表面張力　【オリジナル�.mp3	0	5194160	1742347222182_【初音ミク】　表面張力　【オリジナル�.mp3	0	1	t	1742347222182_【初音ミク】　表面張力　【オリジナル�.mp3.json.gz	\N	train	\N	1
993	【初音ミク】Another Mine【オリジナル21】[HD720p].mp3	0	7950183	1742347222371_【初音ミク】Another Mine【オリジナル21】[HD720p].mp3	0	1	t	1742347222371_【初音ミク】Another Mine【オリジナル21】[HD720p].mp3.json.gz	\N	train	\N	1
994	【初音ミク】aria【オリジナル曲PV付】.mp3	0	5260371	1742347222490_【初音ミク】aria【オリジナル曲PV付】.mp3	0	1	t	1742347222490_【初音ミク】aria【オリジナル曲PV付】.mp3.json.gz	\N	train	\N	1
995	【初音ミク】BossDeath【PV by riria009】.mp3	0	5914419	1742347222596_【初音ミク】BossDeath【PV by riria009】.mp3	0	1	t	1742347222596_【初音ミク】BossDeath【PV by riria009】.mp3.json.gz	\N	train	\N	1
997	【初音ミク】BRaNE WoRLD【オリジナル曲】.mp3	0	8200331	1742347222768_【初音ミク】BRaNE WoRLD【オリジナル曲】.mp3	0	1	t	1742347222768_【初音ミク】BRaNE WoRLD【オリジナル曲】.mp3.json.gz	\N	train	\N	1
998	【初音ミク】BREAK IT【オリジナル曲】.mp3	0	6074382	1742347222872_【初音ミク】BREAK IT【オリジナル曲】.mp3	0	1	t	1742347222872_【初音ミク】BREAK IT【オリジナル曲】.mp3.json.gz	\N	train	\N	1
1005	【初音ミク】chemicalout【オリジナル曲】.mp3	0	0	1742347223460_【初音ミク】chemicalout【オリジナル曲】.mp3	0	1	t	\N	\N	train	\N	1
1002	【初音ミク】BUILD AND SCRAP【オリジナル】.mp3	0	4987177	1742347223238_【初音ミク】BUILD AND SCRAP【オリジナル】.mp3	0	1	t	1742347223238_【初音ミク】BUILD AND SCRAP【オリジナル】.mp3.json.gz	\N	train	\N	1
1003	【初音ミク】CHAIN【オリジナルMV】.mp3	0	5231149	1742347223328_【初音ミク】CHAIN【オリジナルMV】.mp3	0	1	t	1742347223328_【初音ミク】CHAIN【オリジナルMV】.mp3.json.gz	\N	train	\N	1
1006	【初音ミク】Cher【オリジナルPV】[HD1080p].mp3	0	6685647	1742347223479_【初音ミク】Cher【オリジナルPV】[HD1080p].mp3	0	1	t	1742347223479_【初音ミク】Cher【オリジナルPV】[HD1080p].mp3.json.gz	\N	train	\N	1
1007	【初音ミク】Cherry Kiss Baby Kiss【オリジナル曲】.mp3	0	7510072	1742347223559_【初音ミク】Cherry Kiss Baby Kiss【オリジナル曲】.mp3	0	1	t	1742347223559_【初音ミク】Cherry Kiss Baby Kiss【オリジナル曲】.mp3.json.gz	\N	train	\N	1
1009	【初音ミク】Chocolate Charm 【オリジナル曲】.mp3	0	4436098	1742347223845_【初音ミク】Chocolate Charm 【オリジナル曲】.mp3	0	1	t	1742347223845_【初音ミク】Chocolate Charm 【オリジナル曲】.mp3.json.gz	\N	train	\N	1
1010	【初音ミク】Christmas Night【オリジナル】mp4.mp3	0	6873102	1742347224065_【初音ミク】Christmas Night【オリジナル】mp4.mp3	0	1	t	1742347224065_【初音ミク】Christmas Night【オリジナル】mp4.mp3.json.gz	\N	train	\N	1
1011	【初音ミク】Chrysoberyl【オリジナル曲】.mp3	0	5181621	1742347224166_【初音ミク】Chrysoberyl【オリジナル曲】.mp3	0	1	t	1742347224166_【初音ミク】Chrysoberyl【オリジナル曲】.mp3.json.gz	\N	train	\N	1
1013	【初音ミク】Cold Eye【オリジナル】.mp3	0	6962127	1742347224345_【初音ミク】Cold Eye【オリジナル】.mp3	0	1	t	1742347224345_【初音ミク】Cold Eye【オリジナル】.mp3.json.gz	\N	train	\N	1
1014	【初音ミク】ColLapse【オリジナルPV】画質改善版.mp3	0	7918209	1742347224450_【初音ミク】ColLapse【オリジナルPV】画質改善版.mp3	0	1	t	1742347224450_【初音ミク】ColLapse【オリジナルPV】画質改善版.mp3.json.gz	\N	train	\N	1
1016	【初音ミク】colorful【オリジナル曲】.mp3	0	6063004	1742347224654_【初音ミク】colorful【オリジナル曲】.mp3	0	1	t	1742347224654_【初音ミク】colorful【オリジナル曲】.mp3.json.gz	\N	train	\N	1
1017	【初音ミク】Connect feat初音ミク【オリジナル】.mp3	0	6439887	1742347224729_【初音ミク】Connect feat初音ミク【オリジナル】.mp3	0	1	t	1742347224729_【初音ミク】Connect feat初音ミク【オリジナル】.mp3.json.gz	\N	train	\N	1
1019	【初音ミク】Crying Air (附中文字幕).mp3	0	7632859	1742347224917_【初音ミク】Crying Air (附中文字幕).mp3	0	1	t	1742347224917_【初音ミク】Crying Air (附中文字幕).mp3.json.gz	\N	train	\N	1
1020	【初音ミク】Ｃｕｒｓｅｄ　Ｐａｉｎ【オリジナル】.mp3	0	7207167	1742347225021_【初音ミク】Ｃｕｒｓｅｄ　Ｐａｉｎ【オリジナル】.mp3	0	1	t	1742347225021_【初音ミク】Ｃｕｒｓｅｄ　Ｐａｉｎ【オリジナル】.mp3.json.gz	\N	train	\N	1
1022	【初音ミク】アクリルスター【オリジナル】.mp3	0	5042348	1742347225220_【初音ミク】アクリルスター【オリジナル】.mp3	0	1	t	1742347225220_【初音ミク】アクリルスター【オリジナル】.mp3.json.gz	\N	train	\N	1
1023	【初音ミク】アネモネ【オリジナル】.mp3	0	8406594	1742347225303_【初音ミク】アネモネ【オリジナル】.mp3	0	1	t	1742347225303_【初音ミク】アネモネ【オリジナル】.mp3.json.gz	\N	train	\N	1
1024	【初音ミク】アポロ【オリジナルMMD PV】.mp3	0	6113159	1742347225389_【初音ミク】アポロ【オリジナルMMD PV】.mp3	0	1	t	1742347225389_【初音ミク】アポロ【オリジナルMMD PV】.mp3.json.gz	\N	train	\N	1
1026	【初音ミク】オリジナル『Bravery』.mp3	0	5393433	1742347225594_【初音ミク】オリジナル『Bravery』.mp3	0	1	t	1742347225594_【初音ミク】オリジナル『Bravery』.mp3.json.gz	\N	train	\N	1
1027	【初音ミク】スターナイトスノウ【オリジナルMV�.mp3	0	6742072	1742347225688_【初音ミク】スターナイトスノウ【オリジナルMV�.mp3	0	1	t	1742347225688_【初音ミク】スターナイトスノウ【オリジナルMV�.mp3.json.gz	\N	train	\N	1
1029	【初音ミク×アルクロ】センセーションはおわらない！ フルver【コラボオリジナル楽曲�.mp3	0	4831162	1742347225876_【初音ミク×アルクロ】センセーションはおわらない！ フルver【コラボオリジナル楽曲�.mp3	0	1	t	1742347225876_【初音ミク×アルクロ】センセーションはおわらない！ フルver【コラボオリジナル楽曲�.mp3.json.gz	\N	train	\N	1
1031	【初音ミク・巡音ルカ】CROSS+LINK  another material 【セルフリミックス】.mp3	0	6375219	1742347226047_【初音ミク・巡音ルカ】CROSS+LINK  another material 【セルフリミックス】.mp3	0	1	t	1742347226047_【初音ミク・巡音ルカ】CROSS+LINK  another material 【セルフリミックス】.mp3.json.gz	\N	train	\N	1
1032	【初音ミク・巡音ルカ】オリジナル曲「Catch up dream」.mp3	0	7812163	1742347226140_【初音ミク・巡音ルカ】オリジナル曲「Catch up dream」.mp3	0	1	t	1742347226140_【初音ミク・巡音ルカ】オリジナル曲「Catch up dream」.mp3.json.gz	\N	train	\N	1
1033	【初音ミク・結月ゆかり】Catastrophe【オリジナルPV】.mp3	0	6607187	1742347226256_【初音ミク・結月ゆかり】Catastrophe【オリジナルPV】.mp3	0	1	t	1742347226256_【初音ミク・結月ゆかり】Catastrophe【オリジナルPV】.mp3.json.gz	\N	train	\N	1
1035	【初音ミクAppend DARK】Carbuncle【オリジナル曲】.mp3	0	6693704	1742347226382_【初音ミクAppend DARK】Carbuncle【オリジナル曲】.mp3	0	1	t	1742347226382_【初音ミクAppend DARK】Carbuncle【オリジナル曲】.mp3.json.gz	\N	train	\N	1
1036	【初音ミクMMD】Brand New Day【オリジナル曲】 ミク誕.mp3	0	2224885	1742347226481_【初音ミクMMD】Brand New Day【オリジナル曲】 ミク誕.mp3	0	1	t	1742347226481_【初音ミクMMD】Brand New Day【オリジナル曲】 ミク誕.mp3.json.gz	\N	train	\N	1
1039	【初音ミクオリジナル】Cinderella of Halloween【ハロウィン曲】.mp3	0	4763360	1742347226648_【初音ミクオリジナル】Cinderella of Halloween【ハロウィン曲】.mp3	0	1	t	1742347226648_【初音ミクオリジナル】Cinderella of Halloween【ハロウィン曲】.mp3.json.gz	\N	train	\N	1
1040	【初音ミクオリジナル】Closed Time Leaper【修正版】avi.mp3	0	7458570	1742347226741_【初音ミクオリジナル】Closed Time Leaper【修正版】avi.mp3	0	1	t	1742347226741_【初音ミクオリジナル】Closed Time Leaper【修正版】avi.mp3.json.gz	\N	train	\N	1
1041	【水野大輔 feat 初音ミく】 Brilliance.mp3	0	7576434	1742347226834_【水野大輔 feat 初音ミく】 Brilliance.mp3	0	1	t	1742347226834_【水野大輔 feat 初音ミく】 Brilliance.mp3.json.gz	\N	train	\N	1
1043	┗ ∵ ┓夢ファンファーレ／HoneyWorks feat初音ミクu0026GUM.mp3	0	5817964	1742347227054_┗ ∵ ┓夢ファンファーレ／HoneyWorks feat初音ミクu0026GUM.mp3	0	1	t	1742347227054_┗ ∵ ┓夢ファンファーレ／HoneyWorks feat初音ミクu0026GUM.mp3.json.gz	\N	train	\N	1
1044	01 EARTH DAY.mp3	0	5561339	1742347227162_01 EARTH DAY.mp3	0	1	t	1742347227162_01 EARTH DAY.mp3.json.gz	\N	train	\N	1
1045	01 Hand in Hand.mp3	0	7658536	1742347227242_01 Hand in Hand.mp3	0	1	t	1742347227242_01 Hand in Hand.mp3.json.gz	\N	train	\N	1
1046	01 Tell Your World.mp3	0	4129298	1742347227328_01 Tell Your World.mp3	0	1	t	1742347227328_01 Tell Your World.mp3.json.gz	\N	train	\N	1
1048	02 CivitaS Re constructioN.mp3	0	7508818	1742347227433_02 CivitaS Re constructioN.mp3	0	1	t	1742347227433_02 CivitaS Re constructioN.mp3.json.gz	\N	train	\N	1
1049	03 Palette.mp3	0	8224103	1742347227503_03 Palette.mp3	0	1	t	1742347227503_03 Palette.mp3.json.gz	\N	train	\N	1
1050	03 ワールズエンド・ダンスホール.mp3	0	8460849	1742347227583_03 ワールズエンド・ダンスホール.mp3	0	1	t	1742347227583_03 ワールズエンド・ダンスホール.mp3.json.gz	\N	train	\N	1
1051	04 彼方まで虹を架けて.mp3	0	9410964	1742347227629_04 彼方まで虹を架けて.mp3	0	1	t	1742347227629_04 彼方まで虹を架けて.mp3.json.gz	\N	train	\N	1
1053	05REDALiCE Connects with Me.mp3	0	7311866	1742347227824_05REDALiCE Connects with Me.mp3	0	1	t	1742347227824_05REDALiCE Connects with Me.mp3.json.gz	\N	train	\N	1
1054	08 雨のちSweet-Drops.mp3	0	6143816	1742347227926_08 雨のちSweet-Drops.mp3	0	1	t	1742347227926_08 雨のちSweet-Drops.mp3.json.gz	\N	train	\N	1
1056	09 ☆Fighting Pose☆.mp3	0	8783761	1742347228043_09 ☆Fighting Pose☆.mp3	0	1	t	1742347228043_09 ☆Fighting Pose☆.mp3.json.gz	\N	train	\N	1
1057	09 GIFT.mp3	0	7637962	1742347228189_09 GIFT.mp3	0	1	t	1742347228189_09 GIFT.mp3.json.gz	\N	train	\N	1
1058	09 キューティージェリー.mp3	0	15100066	1742347228274_09 キューティージェリー.mp3	0	1	t	1742347228274_09 キューティージェリー.mp3.json.gz	\N	train	\N	1
1059	09 ツユメロ.mp3	0	9631379	1742347228409_09 ツユメロ.mp3	0	1	t	1742347228409_09 ツユメロ.mp3.json.gz	\N	train	\N	1
1060	11 396.mp3	0	5874858	1742347228510_11 396.mp3	0	1	t	1742347228510_11 396.mp3.json.gz	\N	train	\N	1
1061	11 Angel voice.mp3	0	15735746	1742347228595_11 Angel voice.mp3	0	1	t	1742347228595_11 Angel voice.mp3.json.gz	\N	train	\N	1
1062	11 Anti X'mas Superstar.mp3	0	6123034	1742347228709_11 Anti X'mas Superstar.mp3	0	1	t	1742347228709_11 Anti X'mas Superstar.mp3.json.gz	\N	train	\N	1
1064	12 Ievan Polkka.mp3	0	2384919	1742347228890_12 Ievan Polkka.mp3	0	1	t	1742347228890_12 Ievan Polkka.mp3.json.gz	\N	train	\N	1
1065	13 アンダンテ.mp3	0	6677916	1742347228959_13 アンダンテ.mp3	0	1	t	1742347228959_13 アンダンテ.mp3.json.gz	\N	train	\N	1
1066	16 スイートマジック.mp3	0	5303487	1742347229031_16 スイートマジック.mp3	0	1	t	1742347229031_16 スイートマジック.mp3.json.gz	\N	train	\N	1
1068	17 Ievan Polkka.mp3	0	4558903	1742347229184_17 Ievan Polkka.mp3	0	1	t	1742347229184_17 Ievan Polkka.mp3.json.gz	\N	train	\N	1
1069	17 Yellow.mp3	0	8411420	1742347229278_17 Yellow.mp3	0	1	t	1742347229278_17 Yellow.mp3.json.gz	\N	train	\N	1
1070	18 リンリンシグナル.mp3	0	8169778	1742347229367_18 リンリンシグナル.mp3	0	1	t	1742347229367_18 リンリンシグナル.mp3.json.gz	\N	train	\N	1
1072	Amaotopetrichor (feat. Hatsune Miku).mp3	0	6109320	1742347229544_Amaotopetrichor (feat. Hatsune Miku).mp3	0	1	t	1742347229544_Amaotopetrichor (feat. Hatsune Miku).mp3.json.gz	\N	train	\N	1
1073	An ／ DECO＊27 feat初音ミク.mp3	0	7015417	1742347229611_An ／ DECO＊27 feat初音ミク.mp3	0	1	t	1742347229611_An ／ DECO＊27 feat初音ミク.mp3.json.gz	\N	train	\N	1
1074	AOHARU.mp3	0	6067327	1742347229740_AOHARU.mp3	0	1	t	1742347229740_AOHARU.mp3.json.gz	\N	train	\N	1
1076	BOX CAT   daniwell feat Hatsune Miku u0026 Momone Momo.mp3	0	6595995	1742347229935_BOX CAT   daniwell feat Hatsune Miku u0026 Momone Momo.mp3	0	1	t	1742347229935_BOX CAT   daniwell feat Hatsune Miku u0026 Momone Momo.mp3.json.gz	\N	train	\N	1
1077	BoYFRieND   Hatsune Miku 【Uploaded by Kronos Sama】.mp3	0	4954669	1742347230036_BoYFRieND   Hatsune Miku 【Uploaded by Kronos Sama】.mp3	0	1	t	1742347230036_BoYFRieND   Hatsune Miku 【Uploaded by Kronos Sama】.mp3.json.gz	\N	train	\N	1
1079	Break The Mirror  初音ミク.mp3	0	5046202	1742347230279_Break The Mirror  初音ミク.mp3	0	1	t	1742347230279_Break The Mirror  初音ミク.mp3.json.gz	\N	train	\N	1
1080	Breath of Urban   keisei feat Hatsune Miku.mp3	0	7372052	1742347230516_Breath of Urban   keisei feat Hatsune Miku.mp3	0	1	t	1742347230516_Breath of Urban   keisei feat Hatsune Miku.mp3.json.gz	\N	train	\N	1
1081	Bright future Ein schritt.mp3	0	4315585	1742347230637_Bright future Ein schritt.mp3	0	1	t	1742347230637_Bright future Ein schritt.mp3.json.gz	\N	train	\N	1
1083	caress   Chocolate Factory (vocals by Hatsune Miku).mp3	0	5406692	1742347230933_caress   Chocolate Factory (vocals by Hatsune Miku).mp3	0	1	t	1742347230933_caress   Chocolate Factory (vocals by Hatsune Miku).mp3.json.gz	\N	train	\N	1
1115	ephemera 05 Charge.mp3	0	0	1742347281919_ephemera 05 Charge.mp3	0	1	t	\N	\N	train	\N	1
1087	Child   初音ミク.mp3	0	5121435	1742347232026_Child   初音ミク.mp3	0	1	t	1742347232026_Child   初音ミク.mp3.json.gz	\N	train	\N	1
1088	China Girl (HUMAN).mp3	0	6366535	1742347232397_China Girl (HUMAN).mp3	0	1	t	1742347232397_China Girl (HUMAN).mp3.json.gz	\N	train	\N	1
1090	Classical Memory【リンレンがくぽミクオリジナル曲】.mp3	0	5656121	1742347238339_Classical Memory【リンレンがくぽミクオリジナル曲】.mp3	0	1	t	1742347238339_Classical Memory【リンレンがくぽミクオリジナル曲】.mp3.json.gz	\N	train	\N	1
1091	Claw／初音ミク   Claw  Hatsune Miku.mp3	0	6187858	1742347240371_Claw／初音ミク   Claw  Hatsune Miku.mp3	0	1	t	1742347240371_Claw／初音ミク   Claw  Hatsune Miku.mp3.json.gz	\N	train	\N	1
1093	Clock  市瀬るぽ.mp3	0	5503241	1742347245441_Clock  市瀬るぽ.mp3	0	1	t	1742347245441_Clock  市瀬るぽ.mp3.json.gz	\N	train	\N	1
1094	cloudway (feat Hatsune Miku)   keisei.mp3	0	5852446	1742347247523_cloudway (feat Hatsune Miku)   keisei.mp3	0	1	t	1742347247523_cloudway (feat Hatsune Miku)   keisei.mp3.json.gz	\N	train	\N	1
1096	COCOLOの時計 feat HATSUNE MIKU u0026 KAGAMINE RIN by X Plorez[1].mp3	0	5947020	1742347252100_COCOLOの時計 feat HATSUNE MIKU u0026 KAGAMINE RIN by X Plorez[1].mp3	0	1	t	1742347252100_COCOLOの時計 feat HATSUNE MIKU u0026 KAGAMINE RIN by X Plorez[1].mp3.json.gz	\N	train	\N	1
1097	Codependency  Udayu feat Hatsune Miku.mp3	0	5911378	1742347254461_Codependency  Udayu feat Hatsune Miku.mp3	0	1	t	1742347254461_Codependency  Udayu feat Hatsune Miku.mp3.json.gz	\N	train	\N	1
1098	COLOR   beatica feat miku [Official].mp3	0	6006672	1742347256705_COLOR   beatica feat miku [Official].mp3	0	1	t	1742347256705_COLOR   beatica feat miku [Official].mp3.json.gz	\N	train	\N	1
1100	Correa  mao sasagawa feat初音ミク.mp3	0	4701248	1742347262039_Correa  mao sasagawa feat初音ミク.mp3	0	1	t	1742347262039_Correa  mao sasagawa feat初音ミク.mp3.json.gz	\N	train	\N	1
1101	Corruption初音ミク【オリジナル】.mp3	0	3077476	1742347263887_Corruption初音ミク【オリジナル】.mp3	0	1	t	1742347263887_Corruption初音ミク【オリジナル】.mp3.json.gz	\N	train	\N	1
1102	Cryogenic  Hatsune Miku Original.mp3	0	6557032	1742347265013_Cryogenic  Hatsune Miku Original.mp3	0	1	t	1742347265013_Cryogenic  Hatsune Miku Original.mp3.json.gz	\N	train	\N	1
1104	DECO27   ハートアラモード feat 初音ミ�.mp3	0	5743358	1742347269443_DECO27   ハートアラモード feat 初音ミ�.mp3	0	1	t	1742347269443_DECO27   ハートアラモード feat 初音ミ�.mp3.json.gz	\N	train	\N	1
1105	DECO27   夜行性ハイズ feat 初音ミ�.mp3	0	5708877	1742347271510_DECO27   夜行性ハイズ feat 初音ミ�.mp3	0	1	t	1742347271510_DECO27   夜行性ハイズ feat 初音ミ�.mp3.json.gz	\N	train	\N	1
1106	DECO27  愛言葉Ⅲ feat 初音ミク.mp3	0	3934431	1742347273618_DECO27  愛言葉Ⅲ feat 初音ミク.mp3	0	1	t	1742347273618_DECO27  愛言葉Ⅲ feat 初音ミク.mp3.json.gz	\N	train	\N	1
1107	Deco27 ft 初音ミク.mp3	0	6410421	1742347275037_Deco27 ft 初音ミク.mp3	0	1	t	1742347275037_Deco27 ft 初音ミク.mp3.json.gz	\N	train	\N	1
1109	DokiDokiBeat 初音ミク for Lamaze.mp3	0	2889533	1742347279979_DokiDokiBeat 初音ミク for Lamaze.mp3	0	1	t	1742347279979_DokiDokiBeat 初音ミク for Lamaze.mp3.json.gz	\N	train	\N	1
1110	doriko「bouquet」PV.mp3	0	7740785	1742347281111_doriko「bouquet」PV.mp3	0	1	t	1742347281111_doriko「bouquet」PV.mp3.json.gz	\N	train	\N	1
1111	Dream Chase.mp3	0	5673768	1742347281640_Dream Chase.mp3	0	1	t	1742347281640_Dream Chase.mp3.json.gz	\N	train	\N	1
1113	east end and bocci  feat初音ミク.mp3	0	4121259	1742347281825_east end and bocci  feat初音ミク.mp3	0	1	t	1742347281825_east end and bocci  feat初音ミク.mp3.json.gz	\N	train	\N	1
1114	ephemera 03 Clockwise.mp3	0	5968429	1742347281853_ephemera 03 Clockwise.mp3	0	1	t	1742347281853_ephemera 03 Clockwise.mp3.json.gz	\N	train	\N	1
1116	Equation.mp3	0	4239123	1742347281938_Equation.mp3	0	1	t	1742347281938_Equation.mp3.json.gz	\N	train	\N	1
1118	Hatsune Miku   Akeomeakeomeakeomeakeome (Happy New Year).mp3	0	3791071	1742347282068_Hatsune Miku   Akeomeakeomeakeomeakeome (Happy New Year).mp3	0	1	t	1742347282068_Hatsune Miku   Akeomeakeomeakeomeakeome (Happy New Year).mp3.json.gz	\N	train	\N	1
1119	Hatsune Miku   Bouncing Betty.mp3	0	4454372	1742347282093_Hatsune Miku   Bouncing Betty.mp3	0	1	t	1742347282093_Hatsune Miku   Bouncing Betty.mp3.json.gz	\N	train	\N	1
1121	Hatsune Miku   brand new day   VOCALOID.mp3	0	6649819	1742347282229_Hatsune Miku   brand new day   VOCALOID.mp3	0	1	t	1742347282229_Hatsune Miku   brand new day   VOCALOID.mp3.json.gz	\N	train	\N	1
1122	Hatsune Miku   Bullet For My Bloody Valentine   VOCALOID.mp3	0	10197665	1742347282307_Hatsune Miku   Bullet For My Bloody Valentine   VOCALOID.mp3	0	1	t	1742347282307_Hatsune Miku   Bullet For My Bloody Valentine   VOCALOID.mp3.json.gz	\N	train	\N	1
1124	Hatsune Miku   Calc (English  Romaji Subs).mp3	0	5667499	1742347282400_Hatsune Miku   Calc (English  Romaji Subs).mp3	0	1	t	1742347282400_Hatsune Miku   Calc (English  Romaji Subs).mp3.json.gz	\N	train	\N	1
1125	Hatsune Miku   Cat Bang   Nuko Hedoban   Hardcore   Metal.mp3	0	1662521	1742347282434_Hatsune Miku   Cat Bang   Nuko Hedoban   Hardcore   Metal.mp3	0	1	t	1742347282434_Hatsune Miku   Cat Bang   Nuko Hedoban   Hardcore   Metal.mp3.json.gz	\N	train	\N	1
1126	Hatsune Miku   Celestial Symphony   Romaji  MP3.mp3	0	7745801	1742347282482_Hatsune Miku   Celestial Symphony   Romaji  MP3.mp3	0	1	t	1742347282482_Hatsune Miku   Celestial Symphony   Romaji  MP3.mp3.json.gz	\N	train	\N	1
1127	Hatsune Miku   CUTIE88.mp3	0	6649819	1742347282520_Hatsune Miku   CUTIE88.mp3	0	1	t	1742347282520_Hatsune Miku   CUTIE88.mp3.json.gz	\N	train	\N	1
1130	Hatsune Miku (FLEET)   Cipher サイファ (Original Song).mp3	0	6860470	1742347282654_Hatsune Miku (FLEET)   Cipher サイファ (Original Song).mp3	0	1	t	1742347282654_Hatsune Miku (FLEET)   Cipher サイファ (Original Song).mp3.json.gz	\N	train	\N	1
1137	kaichi   cider cider  feat初音ミク.mp3	0	0	1742347283001_kaichi   cider cider  feat初音ミク.mp3	0	1	t	\N	\N	train	\N	1
1132	Hatsune Miku Original Song.mp3	0	6601010	1742347282744_Hatsune Miku Original Song.mp3	0	1	t	1742347282744_Hatsune Miku Original Song.mp3.json.gz	\N	train	\N	1
1133	Hatsune Miku Two Faced Lovers.mp3	0	4503295	1742347282826_Hatsune Miku Two Faced Lovers.mp3	0	1	t	1742347282826_Hatsune Miku Two Faced Lovers.mp3.json.gz	\N	train	\N	1
1135	Heavenz   アルファ.mp3	0	8056042	1742347282908_Heavenz   アルファ.mp3	0	1	t	1742347282908_Heavenz   アルファ.mp3.json.gz	\N	train	\N	1
1136	irucaice   White Step feat Hatsune Mik.mp3	0	6782196	1742347282942_irucaice   White Step feat Hatsune Mik.mp3	0	1	t	1742347282942_irucaice   White Step feat Hatsune Mik.mp3.json.gz	\N	train	\N	1
1138	kiRakiLa  gaogao feat初音ミ�.mp3	0	5845549	1742347283019_kiRakiLa  gaogao feat初音ミ�.mp3	0	1	t	1742347283019_kiRakiLa  gaogao feat初音ミ�.mp3.json.gz	\N	train	\N	1
1139	Lamaze P ft 初音ミク.mp3	0	4775365	1742347283072_Lamaze P ft 初音ミク.mp3	0	1	t	1742347283072_Lamaze P ft 初音ミク.mp3.json.gz	\N	train	\N	1
1141	lilium.mp3	0	5711324	1742347283161_lilium.mp3	0	1	t	1742347283161_lilium.mp3.json.gz	\N	train	\N	1
1143	livetune   never ende.mp3	0	6458068	1742347283259_livetune   never ende.mp3	0	1	t	1742347283259_livetune   never ende.mp3.json.gz	\N	train	\N	1
1144	LOST NOTE  No85 feat初音ミ�.mp3	0	6385343	1742347283345_LOST NOTE  No85 feat初音ミ�.mp3	0	1	t	1742347283345_LOST NOTE  No85 feat初音ミ�.mp3.json.gz	\N	train	\N	1
1145	MASA WORKS DESIGN ft初音ミクu0026GUMI   BRASS NOISE FLAMENC.mp3	0	4374124	1742347283442_MASA WORKS DESIGN ft初音ミクu0026GUMI   BRASS NOISE FLAMENC.mp3	0	1	t	1742347283442_MASA WORKS DESIGN ft初音ミクu0026GUMI   BRASS NOISE FLAMENC.mp3.json.gz	\N	train	\N	1
1146	Melancholic  Junky ft Rin Kagamine.mp3	0	5197294	1742347283519_Melancholic  Junky ft Rin Kagamine.mp3	0	1	t	1742347283519_Melancholic  Junky ft Rin Kagamine.mp3.json.gz	\N	train	\N	1
1147	METEOR  DIVELA feat初音ミク.mp3	0	4345285	1742347283586_METEOR  DIVELA feat初音ミク.mp3	0	1	t	1742347283586_METEOR  DIVELA feat初音ミク.mp3.json.gz	\N	train	\N	1
1149	miku hatsune - po pi po356.mp3	0	3980123	1742347283702_miku hatsune - po pi po356.mp3	0	1	t	1742347283702_miku hatsune - po pi po356.mp3.json.gz	\N	train	\N	1
1150	Musunde Hiraite Rasetsu to Mukuro ORIGINAL.mp3	0	4251662	1742347283729_Musunde Hiraite Rasetsu to Mukuro ORIGINAL.mp3	0	1	t	1742347283729_Musunde Hiraite Rasetsu to Mukuro ORIGINAL.mp3.json.gz	\N	train	\N	1
1151	Neo.mp3	0	5485059	1742347283786_Neo.mp3	0	1	t	1742347283786_Neo.mp3.json.gz	\N	train	\N	1
1153	night  (t)rain  初音ミ�.mp3	0	5964041	1742347283964_night  (t)rain  初音ミ�.mp3	0	1	t	1742347283964_night  (t)rain  初音ミ�.mp3.json.gz	\N	train	\N	1
1154	Onesided Love Samba  Hatsune Miku Traduccion.mp3	0	2856514	1742347283993_Onesided Love Samba  Hatsune Miku Traduccion.mp3	0	1	t	1742347283993_Onesided Love Samba  Hatsune Miku Traduccion.mp3.json.gz	\N	train	\N	1
1156	Palette Off Vocal.mp3	0	5548287	1742347284091_Palette Off Vocal.mp3	0	1	t	1742347284091_Palette Off Vocal.mp3.json.gz	\N	train	\N	1
1157	PinocchioP (feat Hatsune Miku and Yukkuri)   Proliferation of Imamur.mp3	0	4362839	1742347284161_PinocchioP (feat Hatsune Miku and Yukkuri)   Proliferation of Imamur.mp3	0	1	t	1742347284161_PinocchioP (feat Hatsune Miku and Yukkuri)   Proliferation of Imamur.mp3.json.gz	\N	train	\N	1
1158	Rainbow Palace feat Hatsune Miku   Jonathan Parecki 【Vocaloid Original�.mp3	0	6713232	1742347284196_Rainbow Palace feat Hatsune Miku   Jonathan Parecki 【Vocaloid Original�.mp3	0	1	t	1742347284196_Rainbow Palace feat Hatsune Miku   Jonathan Parecki 【Vocaloid Original�.mp3.json.gz	\N	train	\N	1
1159	Rin Kagamine Sweet Magic.mp3	0	5102534	1742347284257_Rin Kagamine Sweet Magic.mp3	0	1	t	1742347284257_Rin Kagamine Sweet Magic.mp3.json.gz	\N	train	\N	1
1160	Robo feat. Hatsune Miku SPACERUN オリジナル曲.mp3	0	7012282	1742347284291_Robo feat. Hatsune Miku SPACERUN オリジナル曲.mp3	0	1	t	1742347284291_Robo feat. Hatsune Miku SPACERUN オリジナル曲.mp3.json.gz	\N	train	\N	1
1162	sasakureUK x DECO27   39 feat Hatsune Miku.mp3	0	5262496	1742347284448_sasakureUK x DECO27   39 feat Hatsune Miku.mp3	0	1	t	1742347284448_sasakureUK x DECO27   39 feat Hatsune Miku.mp3.json.gz	\N	train	\N	1
1163	spica- hatsune miku.mp3	0	4354178	1742347284491_spica- hatsune miku.mp3	0	1	t	1742347284491_spica- hatsune miku.mp3.json.gz	\N	train	\N	1
1165	Touhou Music 絃奏水琴樂章   Confutatis.mp3	0	8558847	1742347284685_Touhou Music 絃奏水琴樂章   Confutatis.mp3	0	1	t	1742347284685_Touhou Music 絃奏水琴樂章   Confutatis.mp3.json.gz	\N	train	\N	1
1166	tradd   Cineraria.mp3	0	7641729	1742347284725_tradd   Cineraria.mp3	0	1	t	1742347284725_tradd   Cineraria.mp3.json.gz	\N	train	\N	1
1167	triple baka - miku hatsune.mp3	0	9821039	1742347284783_triple baka - miku hatsune.mp3	0	1	t	1742347284783_triple baka - miku hatsune.mp3.json.gz	\N	train	\N	1
1168	TsunTsun  ftHatsune Miku_192kbps.mp3	0	5999149	1742347284927_TsunTsun  ftHatsune Miku_192kbps.mp3	0	1	t	1742347284927_TsunTsun  ftHatsune Miku_192kbps.mp3.json.gz	\N	train	\N	1
1170	Weekender Girl   Hatsune Miku Project Diva F (HD).mp3	0	5117066	1742347285262_Weekender Girl   Hatsune Miku Project Diva F (HD).mp3	0	1	t	1742347285262_Weekender Girl   Hatsune Miku Project Diva F (HD).mp3.json.gz	\N	train	\N	1
1171	White Dove with English  Romaji Sub  Hatsune Miku  ハト  sm2583719  HQ.mp3	0	6314499	1742347285403_White Dove with English  Romaji Sub  Hatsune Miku  ハト  sm2583719  HQ.mp3	0	1	t	1742347285403_White Dove with English  Romaji Sub  Hatsune Miku  ハト  sm2583719  HQ.mp3.json.gz	\N	train	\N	1
1172	Wisp X   Crimson ft Hatsune Miku (Original Mix).mp3	0	4069294	1742347285449_Wisp X   Crimson ft Hatsune Miku (Original Mix).mp3	0	1	t	1742347285449_Wisp X   Crimson ft Hatsune Miku (Original Mix).mp3.json.gz	\N	train	\N	1
1174	yt1s.com - Far Away.mp3	0	4904932	1742347285670_yt1s.com - Far Away.mp3	0	1	t	1742347285670_yt1s.com - Far Away.mp3.json.gz	\N	train	\N	1
1175	yt1s.com - Mizusano feat 初音ミク Universe.mp3	0	3014503	1742347285751_yt1s.com - Mizusano feat 初音ミク Universe.mp3	0	1	t	1742347285751_yt1s.com - Mizusano feat 初音ミク Universe.mp3.json.gz	\N	train	\N	1
1177	アンドロメダアンドロメダ   ナユタン星人 feat 初音ミク.mp3	0	4399108	1742347285878_アンドロメダアンドロメダ   ナユタン星人 feat 初音ミク.mp3	0	1	t	1742347285878_アンドロメダアンドロメダ   ナユタン星人 feat 初音ミク.mp3.json.gz	\N	train	\N	1
1178	ウミユリ海底譚(umiyuri kaiteitan).mp3	0	5737281	1742347285910_ウミユリ海底譚(umiyuri kaiteitan).mp3	0	1	t	1742347285910_ウミユリ海底譚(umiyuri kaiteitan).mp3.json.gz	\N	train	\N	1
1180	くるくるついんてーる_192kbps.mp3	0	5372210	1742347286003_くるくるついんてーる_192kbps.mp3	0	1	t	1742347286003_くるくるついんてーる_192kbps.mp3.json.gz	\N	train	\N	1
1181	シネマセレク�.mp3	0	6313246	1742347286069_シネマセレク�.mp3	0	1	t	1742347286069_シネマセレク�.mp3.json.gz	\N	train	\N	1
1182	なりすましゲンガー鏡音リン初音ミクオリジナルPV.mp3	0	3632246	1742347286153_なりすましゲンガー鏡音リン初音ミクオリジナルPV.mp3	0	1	t	1742347286153_なりすましゲンガー鏡音リン初音ミクオリジナルPV.mp3.json.gz	\N	train	\N	1
1183	ハチ MV「Christmas Morgue」HACHI.mp3	0	6248578	1742347286227_ハチ MV「Christmas Morgue」HACHI.mp3	0	1	t	1742347286227_ハチ MV「Christmas Morgue」HACHI.mp3.json.gz	\N	train	\N	1
1185	プリエ  初音ミク  Hatsune Miku.mp3	0	4102032	1742347286408_プリエ  初音ミク  Hatsune Miku.mp3	0	1	t	1742347286408_プリエ  初音ミク  Hatsune Miku.mp3.json.gz	\N	train	\N	1
1186	みきとP Hoi MV.mp3	0	5887554	1742347286483_みきとP Hoi MV.mp3	0	1	t	1742347286483_みきとP Hoi MV.mp3.json.gz	\N	train	\N	1
1187	みきとP『 だいあもんど 』M.mp3	0	5233030	1742347286515_みきとP『 だいあもんど 』M.mp3	0	1	t	1742347286515_みきとP『 だいあもんど 』M.mp3.json.gz	\N	train	\N	1
1189	ゆうきまさみ×kz[livetune]Crosslight  07 Crosslight.mp3	0	7813417	1742347286657_ゆうきまさみ×kz[livetune]Crosslight  07 Crosslight.mp3	0	1	t	1742347286657_ゆうきまさみ×kz[livetune]Crosslight  07 Crosslight.mp3.json.gz	\N	train	\N	1
1190	八王子P「Carry Me Off feat 初音ミク」Music Video.mp3	0	5171590	1742347286695_八王子P「Carry Me Off feat 初音ミク」Music Video.mp3	0	1	t	1742347286695_八王子P「Carry Me Off feat 初音ミク」Music Video.mp3.json.gz	\N	train	\N	1
1191	初音ミク poppin' jumpin まらしぃ kors k.mp3	0	6081645	1742347286797_初音ミク poppin' jumpin まらしぃ kors k.mp3	0	1	t	1742347286797_初音ミク poppin' jumpin まらしぃ kors k.mp3.json.gz	\N	train	\N	1
1193	初音ミク　オリジナル曲　『アンダワ』.mp3	0	3597881	1742347286970_初音ミク　オリジナル曲　『アンダワ』.mp3	0	1	t	1742347286970_初音ミク　オリジナル曲　『アンダワ』.mp3.json.gz	\N	train	\N	1
1194	初音ミク（Θ）どういうことなの！？中文字幕.mp3	0	5789125	1742347286994_初音ミク（Θ）どういうことなの！？中文字幕.mp3	0	1	t	1742347286994_初音ミク（Θ）どういうことなの！？中文字幕.mp3.json.gz	\N	train	\N	1
1195	初音ミクオリジナル曲 「Breath of mechanical」.mp3	0	6602171	1742347287069_初音ミクオリジナル曲 「Breath of mechanical」.mp3	0	1	t	1742347287069_初音ミクオリジナル曲 「Breath of mechanical」.mp3.json.gz	\N	train	\N	1
1196	初音ミクオリジナル曲「Singularity�.mp3	0	6067486	1742347287149_初音ミクオリジナル曲「Singularity�.mp3	0	1	t	1742347287149_初音ミクオリジナル曲「Singularity�.mp3.json.gz	\N	train	\N	1
1198	初音ミクオリジナル曲『Callin'』.mp3	0	6752637	1742347287276_初音ミクオリジナル曲『Callin'』.mp3	0	1	t	1742347287276_初音ミクオリジナル曲『Callin'』.mp3.json.gz	\N	train	\N	1
1200	初音ミク灯火syudou_192kbps.mp3	0	5628001	1742347287372_初音ミク灯火syudou_192kbps.mp3	0	1	t	1742347287372_初音ミク灯火syudou_192kbps.mp3.json.gz	\N	train	\N	1
1201	古川本舗   browny.mp3	0	4299425	1742347287485_古川本舗   browny.mp3	0	1	t	1742347287485_古川本舗   browny.mp3.json.gz	\N	train	\N	1
1202	夏至の踊り子 ／初音ミ�.mp3	0	6625461	1742347287515_夏至の踊り子 ／初音ミ�.mp3	0	1	t	1742347287515_夏至の踊り子 ／初音ミ�.mp3.json.gz	\N	train	\N	1
1203	大嫌いなはずだったHoneyWorks feat.GUMI初音ミク.mp3	0	7311959	1742347287574_大嫌いなはずだったHoneyWorks feat.GUMI初音ミク.mp3	0	1	t	1742347287574_大嫌いなはずだったHoneyWorks feat.GUMI初音ミク.mp3.json.gz	\N	train	\N	1
1204	愛の詩（V3） 初音ミク for lamaze.mp3	0	5261869	1742347287679_愛の詩（V3） 初音ミク for lamaze.mp3	0	1	t	1742347287679_愛の詩（V3） 初音ミク for lamaze.mp3.json.gz	\N	train	\N	1
1205	手�.mp3	0	6647404	1742347287778_手�.mp3	0	1	t	1742347287778_手�.mp3.json.gz	\N	train	\N	1
1207	私は足りないでいっぱい_192kbps.mp3	0	5408573	1742347287994_私は足りないでいっぱい_192kbps.mp3	0	1	t	1742347287994_私は足りないでいっぱい_192kbps.mp3.json.gz	\N	train	\N	1
1208	膵臓  Luna feat 初音ミク ガールズコレクション.mp3	0	7087515	1742347288091_膵臓  Luna feat 初音ミク ガールズコレクション.mp3	0	1	t	1742347288091_膵臓  Luna feat 初音ミク ガールズコレクション.mp3.json.gz	\N	train	\N	1
1210	01 - Tell Your World.mp3	0	4129298	1742347435079_01 - Tell Your World.mp3	0	1	t	1742347435079_01 - Tell Your World.mp3.json.gz	\N	train	\N	1
1211	04 CALL ME CALL ME.mp3	0	6794009	1742347437320_04 CALL ME CALL ME.mp3	0	1	t	1742347437320_04 CALL ME CALL ME.mp3.json.gz	\N	train	\N	1
1212	05 Night Glitter (Featuring Hatsune Miku).mp3	0	3675539	1742347438484_05 Night Glitter (Featuring Hatsune Miku).mp3	0	1	t	1742347438484_05 Night Glitter (Featuring Hatsune Miku).mp3.json.gz	\N	train	\N	1
1213	09 キューティージェリー (feat. 初音ミク).mp3	0	15100066	1742347440528_09 キューティージェリー (feat. 初音ミク).mp3	0	1	t	1742347440528_09 キューティージェリー (feat. 初音ミク).mp3.json.gz	\N	train	\N	1
1215	Hand in Hand.mp3	0	7662709	1742347491528_Hand in Hand.mp3	0	1	t	1742347491528_Hand in Hand.mp3.json.gz	\N	train	\N	1
1216	八王子Pデスクトップシンデレラ feat. 初音ミクMusic Video.mp3	0	6525151	1742347594352_八王子Pデスクトップシンデレラ feat. 初音ミクMusic Video.mp3	0	1	t	1742347594352_八王子Pデスクトップシンデレラ feat. 初音ミクMusic Video.mp3.json.gz	\N	train	\N	1
933	[MV]さよならカンパニュラ  mehikari feat 初音ミ�.mp3	0	5640540	1742347216901_[MV]さよならカンパニュラ  mehikari feat 初音ミ�.mp3	0	1	t	1742347216901_[MV]さよならカンパニュラ  mehikari feat 初音ミ�.mp3.json.gz	\N	train	\N	1
937	“Copycat Registry” with 開発コードmiki, 初音ミク.mp3	0	3408500	1742347217317_“Copycat Registry” with 開発コードmiki, 初音ミク.mp3	0	1	t	1742347217317_“Copycat Registry” with 開発コードmiki, 初音ミク.mp3.json.gz	\N	train	\N	1
941	「cosmology」初音ミクボカロオリジナル.mp3	0	7319972	1742347217658_「cosmology」初音ミクボカロオリジナル.mp3	0	1	t	1742347217658_「cosmology」初音ミクボカロオリジナル.mp3.json.gz	\N	train	\N	1
944	【Hatsune Miku】 Bucin (Budak Cinta) 「Original Song」.mp3	0	4547786	1742347217953_【Hatsune Miku】 Bucin (Budak Cinta) 「Original Song」.mp3	0	1	t	1742347217953_【Hatsune Miku】 Bucin (Budak Cinta) 「Original Song」.mp3.json.gz	\N	train	\N	1
947	‪【Hatsune Miku】‬Cerita SMU【Original】‬.mp3	0	5384749	1742347218165_‪【Hatsune Miku】‬Cerita SMU【Original】‬.mp3	0	1	t	1742347218165_‪【Hatsune Miku】‬Cerita SMU【Original】‬.mp3.json.gz	\N	train	\N	1
954	【Robo feat 初音ミク】 CALL ME CALL ME 【PV by Thanks】.mp3	0	6797869	1742347218649_【Robo feat 初音ミク】 CALL ME CALL ME 【PV by Thanks】.mp3	0	1	t	1742347218649_【Robo feat 初音ミク】 CALL ME CALL ME 【PV by Thanks】.mp3.json.gz	\N	train	\N	1
958	【VOCALOID】 【初音ミク】 Born Tonight 【オリジナル】.mp3	0	4495123	1742347219033_【VOCALOID】 【初音ミク】 Born Tonight 【オリジナル】.mp3	0	1	t	1742347219033_【VOCALOID】 【初音ミク】 Born Tonight 【オリジナル】.mp3.json.gz	\N	train	\N	1
961	【オリジナルMV】ユメノアメ feat初音ミク  ドッシ�.mp3	0	6716994	1742347219289_【オリジナルMV】ユメノアメ feat初音ミク  ドッシ�.mp3	0	1	t	1742347219289_【オリジナルMV】ユメノアメ feat初音ミク  ドッシ�.mp3.json.gz	\N	train	\N	1
963	【ミク  ルカ  リン  レン】Christmas Time Together   MJQ ft ShinRa (Vocaloid Chorus).mp3	0	2547851	1742347219489_【ミク  ルカ  リン  レン】Christmas Time Together   MJQ ft ShinRa (Vocaloid Chorus).mp3	0	1	t	1742347219489_【ミク  ルカ  リン  レン】Christmas Time Together   MJQ ft ShinRa (Vocaloid Chorus).mp3.json.gz	\N	train	\N	1
965	【公式】アイシテ  とあ feat 初音ミク　  LOVE ME  toa feat Hatsune Miku.mp3	0	5142658	1742347219646_【公式】アイシテ  とあ feat 初音ミク　  LOVE ME  toa feat Hatsune Miku.mp3	0	1	t	1742347219646_【公式】アイシテ  とあ feat 初音ミク　  LOVE ME  toa feat Hatsune Miku.mp3.json.gz	\N	train	\N	1
969	【初音ミク、鏡音リン・レン】『Can't Buy Me An Angel』.mp3	0	7063598	1742347219993_【初音ミク、鏡音リン・レン】『Can't Buy Me An Angel』.mp3	0	1	t	1742347219993_【初音ミク、鏡音リン・レン】『Can't Buy Me An Angel』.mp3.json.gz	\N	train	\N	1
972	【初音ミク】 BOY MEETS GIRL  trf 【耳コピ】.mp3	0	6916988	1742347220319_【初音ミク】 BOY MEETS GIRL  trf 【耳コピ】.mp3	0	1	t	1742347220319_【初音ミク】 BOY MEETS GIRL  trf 【耳コピ】.mp3.json.gz	\N	train	\N	1
975	【初音ミク】 Can We Hold Hands 【オリジナル曲PV】.mp3	0	7446658	1742347220581_【初音ミク】 Can We Hold Hands 【オリジナル曲PV】.mp3	0	1	t	1742347220581_【初音ミク】 Can We Hold Hands 【オリジナル曲PV】.mp3.json.gz	\N	train	\N	1
979	【初音ミク】 children 【オリジナル曲】.mp3	0	7854795	1742347221034_【初音ミク】 children 【オリジナル曲】.mp3	0	1	t	1742347221034_【初音ミク】 children 【オリジナル曲】.mp3.json.gz	\N	train	\N	1
982	【初音ミク】 CLOSE 2U 【オリジナル】.mp3	0	7104976	1742347221363_【初音ミク】 CLOSE 2U 【オリジナル】.mp3	0	1	t	1742347221363_【初音ミク】 CLOSE 2U 【オリジナル】.mp3.json.gz	\N	train	\N	1
985	【初音ミク】 coffee time 【オリジナル】.mp3	0	5334594	1742347221641_【初音ミク】 coffee time 【オリジナル】.mp3	0	1	t	1742347221641_【初音ミク】 coffee time 【オリジナル】.mp3.json.gz	\N	train	\N	1
988	【初音ミク】 Hatsune Miku   City Night Lights 【VOCALOID】ボーカロイド.mp3	0	5638032	1742347221951_【初音ミク】 Hatsune Miku   City Night Lights 【VOCALOID】ボーカロイド.mp3	0	1	t	1742347221951_【初音ミク】 Hatsune Miku   City Night Lights 【VOCALOID】ボーカロイド.mp3.json.gz	\N	train	\N	1
992	【初音ミク】a tail of the wind【Cazオリジナル】.mp3	0	6521296	1742347222270_【初音ミク】a tail of the wind【Cazオリジナル】.mp3	0	1	t	1742347222270_【初音ミク】a tail of the wind【Cazオリジナル】.mp3.json.gz	\N	train	\N	1
1218	初音ミクメイウェンティーオリジナルPV.mp3	0	5332086	1742347610986_初音ミクメイウェンティーオリジナルPV.mp3	0	1	t	1742347610986_初音ミクメイウェンティーオリジナルPV.mp3.json.gz	\N	train	\N	1
930	[HatsuneMikuV3] Mwk   Branch Points [Glitch Hop].mp3	2	6434245	1742347216648_[HatsuneMikuV3] Mwk   Branch Points [Glitch Hop].mp3	0	1	t	1742347216648_[HatsuneMikuV3] Mwk   Branch Points [Glitch Hop].mp3.json.gz	\N	train	error	1
1219	小説3こちら幸福安心委員会です女王様とハピネスサマーゲーム.mp3	0	1661360	1742347623858_小説3こちら幸福安心委員会です女王様とハピネスサマーゲーム.mp3	0	1	t	1742347623858_小説3こちら幸福安心委員会です女王様とハピネスサマーゲーム.mp3.json.gz	\N	train	\N	1
1221	鏡音レン唐傘さんが通るオリジナルPV.mp3	0	2568958	1742347640507_鏡音レン唐傘さんが通るオリジナルPV.mp3	0	1	t	1742347640507_鏡音レン唐傘さんが通るオリジナルPV.mp3.json.gz	\N	train	\N	1
950	【Kagamine Rin V4X】 Hop! Step! Instant Death! A Happiness Dance Death Trap 【VOCALOID Cover�.mp3	2	5286947	1742347218365_【Kagamine Rin V4X】 Hop! Step! Instant Death! A Happiness Dance Death Trap 【VOCALOID Cover�.mp3	0	1	t	1742347218365_【Kagamine Rin V4X】 Hop! Step! Instant Death! A Happiness Dance Death Trap 【VOCALOID Cover�.mp3.json.gz	\N	train	\N	1
926	- 初音ミクねこみみスイッチオリジナル.mp3	2	3762650	1742347216307_- 初音ミクねこみみスイッチオリジナル.mp3	0	1	t	1742347216307_- 初音ミクねこみみスイッチオリジナル.mp3.json.gz	\N	train	trained	1
996	【初音ミク】bpm full ver 【PV】.mp3	0	5931974	1742347222672_【初音ミク】bpm full ver 【PV】.mp3	0	1	t	1742347222672_【初音ミク】bpm full ver 【PV】.mp3.json.gz	\N	train	\N	1
999	【初音ミク】Break UP!!【オリジナル楽曲】.mp3	0	5628001	1742347222963_【初音ミク】Break UP!!【オリジナル楽曲】.mp3	0	1	t	1742347222963_【初音ミク】Break UP!!【オリジナル楽曲】.mp3.json.gz	\N	train	\N	1
1000	【初音ミク】Breakthrough【ボカロ オリジナル】.mp3	0	6104382	1742347223045_【初音ミク】Breakthrough【ボカロ オリジナル】.mp3	0	1	t	1742347223045_【初音ミク】Breakthrough【ボカロ オリジナル】.mp3.json.gz	\N	train	\N	1
1001	【初音ミク】breath【オリジナルMV】.mp3	0	6245536	1742347223147_【初音ミク】breath【オリジナルMV】.mp3	0	1	t	1742347223147_【初音ミク】breath【オリジナルMV】.mp3.json.gz	\N	train	\N	1
1004	【初音ミク】CHAINED【オリジナル曲】.mp3	0	6592767	1742347223389_【初音ミク】CHAINED【オリジナル曲】.mp3	0	1	t	1742347223389_【初音ミク】CHAINED【オリジナル曲】.mp3.json.gz	\N	train	\N	1
1008	【初音ミク】Chocolat,Close to you【オシャレワルツ】.mp3	0	7319482	1742347223657_【初音ミク】Chocolat,Close to you【オシャレワルツ】.mp3	0	1	t	1742347223657_【初音ミク】Chocolat,Close to you【オシャレワルツ】.mp3.json.gz	\N	train	\N	1
928	[Eng Sub] Circle of Friends [Hatsune Miku, GUMI, Kagamine Rin, IA, Aoki Lapis].mp3	1	6701855	1742347216473_[Eng Sub] Circle of Friends [Hatsune Miku, GUMI, Kagamine Rin, IA, Aoki Lapis].mp3	0	1	t	1742347216473_[Eng Sub] Circle of Friends [Hatsune Miku, GUMI, Kagamine Rin, IA, Aoki Lapis].mp3.json.gz	\N	train	\N	1
1012	【初音ミク】Circuitry Light 【オリジナル】.mp3	0	6938837	1742347224249_【初音ミク】Circuitry Light 【オリジナル】.mp3	0	1	t	1742347224249_【初音ミク】Circuitry Light 【オリジナル】.mp3.json.gz	\N	train	\N	1
1015	【初音ミク】Colorful Candy Rain【オリジナル】.mp3	0	4716966	1742347224561_【初音ミク】Colorful Candy Rain【オリジナル】.mp3	0	1	t	1742347224561_【初音ミク】Colorful Candy Rain【オリジナル】.mp3.json.gz	\N	train	\N	1
1018	【初音ミク】Coppelia【オリジナル曲】.mp3	0	4906884	1742347224829_【初音ミク】Coppelia【オリジナル曲】.mp3	0	1	t	1742347224829_【初音ミク】Coppelia【オリジナル曲】.mp3.json.gz	\N	train	\N	1
1021	【初音ミク】Hatsune Miku「DECORATOR」MP3 High Quality![8].mp3	0	4929612	1742347225128_【初音ミク】Hatsune Miku「DECORATOR」MP3 High Quality![8].mp3	0	1	t	1742347225128_【初音ミク】Hatsune Miku「DECORATOR」MP3 High Quality![8].mp3.json.gz	\N	train	\N	1
1025	【初音ミク】アンドロメダの夢【SmileR】ChineseSub.mp3	0	6607907	1742347225492_【初音ミク】アンドロメダの夢【SmileR】ChineseSub.mp3	0	1	t	1742347225492_【初音ミク】アンドロメダの夢【SmileR】ChineseSub.mp3.json.gz	\N	train	\N	1
1028	【初音ミク】名前のない誰か【オリジナル�.mp3	0	6236759	1742347225793_【初音ミク】名前のない誰か【オリジナル�.mp3	0	1	t	1742347225793_【初音ミク】名前のない誰か【オリジナル�.mp3.json.gz	\N	train	\N	1
1030	【初音ミク・GUMI】あの日、描いたDIARY【オリジナル曲PV】OFFICIAL　MV.mp3	0	6175226	1742347225966_【初音ミク・GUMI】あの日、描いたDIARY【オリジナル曲PV】OFFICIAL　MV.mp3	0	1	t	1742347225966_【初音ミク・GUMI】あの日、描いたDIARY【オリジナル曲PV】OFFICIAL　MV.mp3.json.gz	\N	train	\N	1
1034	【初音ミク・鏡音リン】CHOTTO 【オリジナル曲】【仮アップ】.mp3	0	3033009	1742347226351_【初音ミク・鏡音リン】CHOTTO 【オリジナル曲】【仮アップ】.mp3	0	1	t	1742347226351_【初音ミク・鏡音リン】CHOTTO 【オリジナル曲】【仮アップ】.mp3.json.gz	\N	train	\N	1
1037	【初音ミクMMD】Buche de Noel【クリスマスオリジナル曲】.mp3	0	3195479	1742347226556_【初音ミクMMD】Buche de Noel【クリスマスオリジナル曲】.mp3	0	1	t	1742347226556_【初音ミクMMD】Buche de Noel【クリスマスオリジナル曲】.mp3.json.gz	\N	train	\N	1
1038	【初音ミクu0026鏡音リン】Cho Cho Chocolate【オリジナル曲】.mp3	0	4405471	1742347226586_【初音ミクu0026鏡音リン】Cho Cho Chocolate【オリジナル曲】.mp3	0	1	t	1742347226586_【初音ミクu0026鏡音リン】Cho Cho Chocolate【オリジナル曲】.mp3.json.gz	\N	train	\N	1
1042	【第9回MMD杯本選遅刻組】bouquet【MMD PV】[HD1080p].mp3	0	7927613	1742347226948_【第9回MMD杯本選遅刻組】bouquet【MMD PV】[HD1080p].mp3	0	1	t	1742347226948_【第9回MMD杯本選遅刻組】bouquet【MMD PV】[HD1080p].mp3.json.gz	\N	train	\N	1
925	- Ranaエレクトロサチュレイタ ElectrosaturatorVSQx.mp3	1	3250232	1742347215998_- Ranaエレクトロサチュレイタ ElectrosaturatorVSQx.mp3	0	1	t	1742347215998_- Ranaエレクトロサチュレイタ ElectrosaturatorVSQx.mp3.json.gz	\N	train	error	1
1047	01 アンドロイド Voc@loid ～I am not a robot～.mp3	0	5372012	1742347227358_01 アンドロイド Voc@loid ～I am not a robot～.mp3	0	1	t	1742347227358_01 アンドロイド Voc@loid ～I am not a robot～.mp3.json.gz	\N	train	\N	1
1052	05 One Minute Winter, kevinlyspirit, コーヒー先生.mp3	0	8486842	1742347227740_05 One Minute Winter, kevinlyspirit, コーヒー先生.mp3	0	1	t	1742347227740_05 One Minute Winter, kevinlyspirit, コーヒー先生.mp3.json.gz	\N	train	\N	1
1055	8 bit darling project  DELUXE 07 Brandnew Wave (★STAR GUiTAR meets 初音ミク Re mix).mp3	0	6757745	1742347227962_8 bit darling project  DELUXE 07 Brandnew Wave (★STAR GUiTAR meets 初音ミク Re mix).mp3	0	1	t	1742347227962_8 bit darling project  DELUXE 07 Brandnew Wave (★STAR GUiTAR meets 初音ミク Re mix).mp3.json.gz	\N	train	\N	1
1063	11 ハロー、プラネット.mp3	0	8975210	1742347228798_11 ハロー、プラネット.mp3	0	1	t	1742347228798_11 ハロー、プラネット.mp3.json.gz	\N	train	\N	1
1067	16 ローリンガール.mp3	0	6483666	1742347229117_16 ローリンガール.mp3	0	1	t	1742347229117_16 ローリンガール.mp3.json.gz	\N	train	\N	1
1071	20 どういうことなの! (Game Version).mp3	0	5785263	1742347229463_20 どういうことなの! (Game Version).mp3	0	1	t	1742347229463_20 どういうことなの! (Game Version).mp3.json.gz	\N	train	\N	1
1075	AVTechno! (Feat Hatsune Miku)  Charmee (Less EP).mp3	0	6679285	1742347229850_AVTechno! (Feat Hatsune Miku)  Charmee (Less EP).mp3	0	1	t	1742347229850_AVTechno! (Feat Hatsune Miku)  Charmee (Less EP).mp3.json.gz	\N	train	\N	1
1078	boys初音ミク【オリジナル】.mp3	0	4527724	1742347230210_boys初音ミク【オリジナル】.mp3	0	1	t	1742347230210_boys初音ミク【オリジナル】.mp3.json.gz	\N	train	\N	1
1082	by your side   小川大輝 feat初音ミク.mp3	0	6068739	1742347230800_by your side   小川大輝 feat初音ミク.mp3	0	1	t	1742347230800_by your side   小川大輝 feat初音ミク.mp3.json.gz	\N	train	\N	1
1084	CATS RULE THE WORLD   daniwell feat Hatsune Miku  Momone Momo.mp3	0	6536436	1742347231115_CATS RULE THE WORLD   daniwell feat Hatsune Miku  Momone Momo.mp3	0	1	t	1742347231115_CATS RULE THE WORLD   daniwell feat Hatsune Miku  Momone Momo.mp3.json.gz	\N	train	\N	1
1086	Chain  Mayslap feat Hatsune Miku.mp3	0	5729566	1742347231693_Chain  Mayslap feat Hatsune Miku.mp3	0	1	t	1742347231693_Chain  Mayslap feat Hatsune Miku.mp3.json.gz	\N	train	\N	1
1089	CITY NIGHT WALKR Sound Design feat初音ミク.mp3	0	5118300	1742347236903_CITY NIGHT WALKR Sound Design feat初音ミク.mp3	0	1	t	1742347236903_CITY NIGHT WALKR Sound Design feat初音ミク.mp3.json.gz	\N	train	\N	1
1092	Clear Age【初音ミク featGUMI】.mp3	0	6654207	1742347242708_Clear Age【初音ミク featGUMI】.mp3	0	1	t	1742347242708_Clear Age【初音ミク featGUMI】.mp3.json.gz	\N	train	\N	1
1095	COCOLOの時計 feat HATSUNE MIKU u0026 KAGAMINE RIN by X Plorez.mp3	0	5947020	1742347249707_COCOLOの時計 feat HATSUNE MIKU u0026 KAGAMINE RIN by X Plorez.mp3	0	1	t	1742347249707_COCOLOの時計 feat HATSUNE MIKU u0026 KAGAMINE RIN by X Plorez.mp3.json.gz	\N	train	\N	1
1099	Computer Music Love   RUBY CATMAN ft Hatsune Miku.mp3	0	7301301	1742347259333_Computer Music Love   RUBY CATMAN ft Hatsune Miku.mp3	0	1	t	1742347259333_Computer Music Love   RUBY CATMAN ft Hatsune Miku.mp3.json.gz	\N	train	\N	1
1103	Cute, Cheap, Hunted a Dancehall  鏡音リン・レンとうちのボカロたち.mp3	0	5246823	1742347267563_Cute, Cheap, Hunted a Dancehall  鏡音リン・レンとうちのボカロたち.mp3	0	1	t	1742347267563_Cute, Cheap, Hunted a Dancehall  鏡音リン・レンとうちのボカロたち.mp3.json.gz	\N	train	\N	1
1108	Dog tails feat Hatsune Miku   Breaker.mp3	0	6986578	1742347277243_Dog tails feat Hatsune Miku   Breaker.mp3	0	1	t	1742347277243_Dog tails feat Hatsune Miku   Breaker.mp3.json.gz	\N	train	\N	1
1112	DreamerTeary Planet feat. 初音ミク.mp3	0	6799123	1742347281742_DreamerTeary Planet feat. 初音ミク.mp3	0	1	t	1742347281742_DreamerTeary Planet feat. 初音ミク.mp3.json.gz	\N	train	\N	1
1117	Hatsune Miku    Citrullus lanatus.mp3	0	9614612	1742347282002_Hatsune Miku    Citrullus lanatus.mp3	0	1	t	1742347282002_Hatsune Miku    Citrullus lanatus.mp3.json.gz	\N	train	\N	1
1120	Hatsune Miku   Brain Shake   Electronica.mp3	0	7689910	1742347282148_Hatsune Miku   Brain Shake   Electronica.mp3	0	1	t	1742347282148_Hatsune Miku   Brain Shake   Electronica.mp3.json.gz	\N	train	\N	1
1123	Hatsune Miku   Burenai ai de (PROJECTデジアイ第2弾初音ミクVR Special).mp3	0	5286320	1742347282348_Hatsune Miku   Burenai ai de (PROJECTデジアイ第2弾初音ミクVR Special).mp3	0	1	t	1742347282348_Hatsune Miku   Burenai ai de (PROJECTデジアイ第2弾初音ミクVR Special).mp3.json.gz	\N	train	\N	1
1128	Hatsune Miku   Sayonara·Good bye [English Sub].mp3	0	4216042	1742347282572_Hatsune Miku   Sayonara·Good bye [English Sub].mp3	0	1	t	1742347282572_Hatsune Miku   Sayonara·Good bye [English Sub].mp3.json.gz	\N	train	\N	1
1129	Hatsune Miku   Torinoko City  (トリノコシティ)(Left Behind City) Sub Esp (+mp3 + romaji.mp3	0	5052472	1742347282603_Hatsune Miku   Torinoko City  (トリノコシティ)(Left Behind City) Sub Esp (+mp3 + romaji.mp3	0	1	t	1742347282603_Hatsune Miku   Torinoko City  (トリノコシティ)(Left Behind City) Sub Esp (+mp3 + romaji.mp3.json.gz	\N	train	\N	1
1131	Hatsune Miku Original Song Bright City.mp3	0	6269360	1742347282691_Hatsune Miku Original Song Bright City.mp3	0	1	t	1742347282691_Hatsune Miku Original Song Bright City.mp3.json.gz	\N	train	\N	1
1134	Hatsune Miku u0026 Megurine Luka Choutsuba Vocaloid2.mp3	0	5451739	1742347282855_Hatsune Miku u0026 Megurine Luka Choutsuba Vocaloid2.mp3	0	1	t	1742347282855_Hatsune Miku u0026 Megurine Luka Choutsuba Vocaloid2.mp3.json.gz	\N	train	\N	1
1140	Landscape  初音ミク   歩く人×春�.mp3	0	4629288	1742347283106_Landscape  初音ミク   歩く人×春�.mp3	0	1	t	1742347283106_Landscape  初音ミク   歩く人×春�.mp3.json.gz	\N	train	\N	1
1142	LiSA   Crossing Field feat Hatsune Miku   Drumstep [ dj Jo Remix ].mp3	0	7347068	1742347283196_LiSA   Crossing Field feat Hatsune Miku   Drumstep [ dj Jo Remix ].mp3	0	1	t	1742347283196_LiSA   Crossing Field feat Hatsune Miku   Drumstep [ dj Jo Remix ].mp3.json.gz	\N	train	\N	1
1148	Miku Hatsune   Chaining Intention  Music Video.mp3	0	6750849	1742347283615_Miku Hatsune   Chaining Intention  Music Video.mp3	0	1	t	1742347283615_Miku Hatsune   Chaining Intention  Music Video.mp3.json.gz	\N	train	\N	1
1152	Neru - ロストワンの号哭(Lost One's Weeping) feat. Kagamine Rin.mp3	0	5234911	1742347283870_Neru - ロストワンの号哭(Lost One's Weeping) feat. Kagamine Rin.mp3	0	1	t	1742347283870_Neru - ロストワンの号哭(Lost One's Weeping) feat. Kagamine Rin.mp3.json.gz	\N	train	\N	1
1155	Ordinary   ポリスピカデリー feat 初音ミク  Ordinary   Police Piccadilly feat Hatsune Mik.mp3	0	6144599	1742347284055_Ordinary   ポリスピカデリー feat 初音ミク  Ordinary   Police Piccadilly feat Hatsune Mik.mp3	0	1	t	1742347284055_Ordinary   ポリスピカデリー feat 初音ミク  Ordinary   Police Piccadilly feat Hatsune Mik.mp3.json.gz	\N	train	\N	1
1161	ryuryu   Flowers featHatsune Miku 初音ミ�.mp3	0	5964668	1742347284374_ryuryu   Flowers featHatsune Miku 初音ミ�.mp3	0	1	t	1742347284374_ryuryu   Flowers featHatsune Miku 初音ミ�.mp3.json.gz	\N	train	\N	1
1164	SushiP ft 初音ミク 'Align' アライン (English Subtitles).mp3	0	6155257	1742347284553_SushiP ft 初音ミク 'Align' アライン (English Subtitles).mp3	0	1	t	1742347284553_SushiP ft 初音ミク 'Align' アライン (English Subtitles).mp3.json.gz	\N	train	\N	1
1169	VOCALOID2 Hatsune Miku   'Chemical Inversion' [HD  MP3].mp3	0	9217226	1742347285017_VOCALOID2 Hatsune Miku   'Chemical Inversion' [HD  MP3].mp3	0	1	t	1742347285017_VOCALOID2 Hatsune Miku   'Chemical Inversion' [HD  MP3].mp3.json.gz	\N	train	\N	1
1173	yt1s.com - ElectronicMizusano ft Hatsune Miku  Smile Walker.mp3	0	3495156	1742347285586_yt1s.com - ElectronicMizusano ft Hatsune Miku  Smile Walker.mp3	0	1	t	1742347285586_yt1s.com - ElectronicMizusano ft Hatsune Miku  Smile Walker.mp3.json.gz	\N	train	\N	1
1176	あいまいクエスチョン／yamada feat初音ミク   The Quizmaste.mp3	0	4874421	1742347285781_あいまいクエスチョン／yamada feat初音ミク   The Quizmaste.mp3	0	1	t	1742347285781_あいまいクエスチョン／yamada feat初音ミク   The Quizmaste.mp3.json.gz	\N	train	\N	1
1179	えいえんがみつからない - daniwell feat. Hatsune Miku & Momone Momo.mp3	0	3723988	1742347285972_えいえんがみつからない - daniwell feat. Hatsune Miku & Momone Momo.mp3	0	1	t	1742347285972_えいえんがみつからない - daniwell feat. Hatsune Miku & Momone Momo.mp3.json.gz	\N	train	\N	1
1184	ひとりぼっちとココロの本と - PIPPO feat. 初音ミク.mp3	0	6318888	1742347286315_ひとりぼっちとココロの本と - PIPPO feat. 初音ミク.mp3	0	1	t	1742347286315_ひとりぼっちとココロの本と - PIPPO feat. 初音ミク.mp3.json.gz	\N	train	\N	1
1188	モノクロブルースカイ  のぼる feat 初音ミク  MonochromeBlueSky.mp3	0	5891316	1742347286574_モノクロブルースカイ  のぼる feat 初音ミク  MonochromeBlueSky.mp3	0	1	t	1742347286574_モノクロブルースカイ  のぼる feat 初音ミク  MonochromeBlueSky.mp3.json.gz	\N	train	\N	1
1192	初音ミク Project Diva f 2nd  nanou  Hatsune Miku  Glory 3usi9  Best of nanou (high volume).mp3	0	4160129	1742347286880_初音ミク Project Diva f 2nd  nanou  Hatsune Miku  Glory 3usi9  Best of nanou (high volume).mp3	0	1	t	1742347286880_初音ミク Project Diva f 2nd  nanou  Hatsune Miku  Glory 3usi9  Best of nanou (high volume).mp3.json.gz	\N	train	\N	1
1197	初音ミクオリジナル曲『breakthrough』.mp3	0	5399703	1742347287233_初音ミクオリジナル曲『breakthrough』.mp3	0	1	t	1742347287233_初音ミクオリジナル曲『breakthrough』.mp3.json.gz	\N	train	\N	1
1199	初音ミクリンレンルカ夢の続きオリジナル中文字幕.mp3	0	5216312	1742347287338_初音ミクリンレンルカ夢の続きオリジナル中文字幕.mp3	0	1	t	1742347287338_初音ミクリンレンルカ夢の続きオリジナル中文字幕.mp3.json.gz	\N	train	\N	1
1206	神経衰弱  初音ミク 【 Nervous Breakdown  Hatsune Miku �.mp3	0	7278104	1742347287869_神経衰弱  初音ミク 【 Nervous Breakdown  Hatsune Miku �.mp3	0	1	t	1742347287869_神経衰弱  初音ミク 【 Nervous Breakdown  Hatsune Miku �.mp3.json.gz	\N	train	\N	1
1209	[VnSharing] Umi Yuri Kaiteitan   Hatsune Miku   Vocaloid vietsub.mp3	0	5737281	1742347368094_[VnSharing] Umi Yuri Kaiteitan   Hatsune Miku   Vocaloid vietsub.mp3	0	1	t	1742347368094_[VnSharing] Umi Yuri Kaiteitan   Hatsune Miku   Vocaloid vietsub.mp3.json.gz	\N	train	\N	1
1214	Cressida   ftHatsune Miku 【english subtitles】.mp3	0	4043380	1742347473109_Cressida   ftHatsune Miku 【english subtitles】.mp3	0	1	t	1742347473109_Cressida   ftHatsune Miku 【english subtitles】.mp3.json.gz	\N	train	\N	1
1217	初音ミク ラストペインター オリジナルMIKULast painteroriginal.mp3	0	4944011	1742347603266_初音ミク ラストペインター オリジナルMIKULast painteroriginal.mp3	0	1	t	1742347603266_初音ミク ラストペインター オリジナルMIKULast painteroriginal.mp3.json.gz	\N	train	\N	1
1220	神のまにまに - れるりりfeat.ミク&リン&GUMI  At God's Mercy - rerulili feat.Vocaloids.mp3	0	6117641	1742347629435_神のまにまに - れるりりfeat.ミク&リン&GUMI  At God's Mercy - rerulili feat.Vocaloids.mp3	0	1	t	1742347629435_神のまにまに - れるりりfeat.ミク&リン&GUMI  At God's Mercy - rerulili feat.Vocaloids.mp3.json.gz	\N	train	\N	1
\.


--
-- Data for Name: canciones_playlists; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.canciones_playlists (cp_id, cp_ca_id, cp_pl_id) FROM stdin;
624	925	6
625	926	6
626	927	6
627	928	6
628	929	6
629	930	6
630	931	6
631	932	6
632	933	6
633	934	6
634	935	6
635	936	6
636	937	6
637	938	6
638	939	6
639	940	6
640	941	6
641	942	6
642	943	6
643	944	6
644	945	6
645	946	6
646	947	6
647	948	6
648	949	6
649	950	6
650	951	6
651	952	6
652	953	6
653	954	6
654	955	6
655	956	6
656	957	6
657	958	6
658	959	6
659	960	6
660	961	6
661	962	6
662	963	6
663	964	6
664	965	6
665	966	6
666	967	6
667	968	6
668	969	6
669	970	6
670	971	6
671	972	6
672	973	6
673	974	6
674	975	6
675	976	6
676	977	6
677	978	6
678	979	6
679	980	6
680	981	6
681	982	6
682	983	6
683	984	6
684	985	6
685	986	6
686	987	6
687	988	6
688	989	6
689	990	6
690	991	6
691	992	6
692	993	6
693	994	6
694	995	6
695	996	6
696	997	6
697	998	6
698	999	6
699	1000	6
700	1001	6
701	1002	6
702	1003	6
703	1004	6
704	1005	6
705	1006	6
706	1007	6
707	1008	6
708	1009	6
709	1010	6
710	1011	6
711	1012	6
712	1013	6
713	1014	6
714	1015	6
715	1016	6
716	1017	6
717	1018	6
718	1019	6
719	1020	6
720	1021	6
721	1022	6
722	1023	6
723	1024	6
724	1025	6
725	1026	6
726	1027	6
727	1028	6
728	1029	6
729	1030	6
730	1031	6
731	1032	6
732	1033	6
733	1034	6
734	1035	6
735	1036	6
736	1037	6
737	1038	6
738	1039	6
739	1040	6
740	1041	6
741	1042	6
742	1043	6
743	1044	6
744	1045	6
745	1046	6
746	1047	6
747	1048	6
748	1049	6
749	1050	6
750	1051	6
751	1052	6
752	1053	6
753	1054	6
754	1055	6
755	1056	6
756	1057	6
757	1058	6
758	1059	6
759	1060	6
760	1061	6
761	1062	6
762	1063	6
763	1064	6
764	1065	6
765	1066	6
766	1067	6
767	1068	6
768	1069	6
769	1070	6
770	1071	6
771	1072	6
772	1073	6
773	1074	6
774	1075	6
775	1076	6
776	1077	6
777	1078	6
778	1079	6
779	1080	6
780	1081	6
781	1082	6
782	1083	6
783	1084	6
784	1085	6
785	1086	6
786	1087	6
787	1088	6
788	1089	6
789	1090	6
790	1091	6
791	1092	6
792	1093	6
793	1094	6
794	1095	6
795	1096	6
796	1097	6
797	1098	6
798	1099	6
799	1100	6
800	1101	6
801	1102	6
802	1103	6
803	1104	6
804	1105	6
805	1106	6
806	1107	6
807	1108	6
808	1109	6
809	1110	6
810	1111	6
811	1112	6
812	1113	6
813	1114	6
814	1115	6
815	1116	6
816	1117	6
817	1118	6
818	1119	6
819	1120	6
820	1121	6
821	1122	6
822	1123	6
823	1124	6
824	1125	6
825	1126	6
826	1127	6
827	1128	6
828	1129	6
829	1130	6
830	1131	6
831	1132	6
832	1133	6
833	1134	6
834	1135	6
835	1136	6
836	1137	6
837	1138	6
838	1139	6
839	1140	6
840	1141	6
841	1142	6
842	1143	6
843	1144	6
844	1145	6
845	1146	6
846	1147	6
847	1148	6
848	1149	6
849	1150	6
850	1151	6
851	1152	6
852	1153	6
853	1154	6
854	1155	6
855	1156	6
856	1157	6
857	1158	6
858	1159	6
859	1160	6
860	1161	6
861	1162	6
862	1163	6
863	1164	6
864	1165	6
865	1166	6
866	1167	6
867	1168	6
868	1169	6
869	1170	6
870	1171	6
871	1172	6
872	1173	6
873	1174	6
874	1175	6
875	1176	6
876	1177	6
877	1178	6
878	1179	6
879	1180	6
880	1181	6
881	1182	6
882	1183	6
883	1184	6
884	1185	6
885	1186	6
886	1187	6
887	1188	6
888	1189	6
889	1190	6
890	1191	6
891	1192	6
892	1193	6
893	1194	6
894	1195	6
895	1196	6
896	1197	6
897	1198	6
898	1199	6
899	1200	6
900	1201	6
901	1202	6
902	1203	6
903	1204	6
904	1205	6
905	1206	6
906	1207	6
907	1208	6
908	925	8
909	926	8
910	929	8
911	932	8
912	933	8
913	1209	8
914	936	8
915	945	8
916	947	8
917	950	8
918	955	8
919	961	8
920	964	8
921	965	8
922	970	8
923	971	8
924	979	8
925	989	8
926	990	8
927	991	8
928	992	8
929	993	8
930	994	8
931	996	8
932	1021	8
933	1022	8
934	1023	8
935	1024	8
936	1025	8
937	1027	8
938	1028	8
939	1029	8
940	1030	8
941	1035	8
942	1041	8
943	1043	8
944	1210	8
945	1044	8
946	1047	8
947	1049	8
948	1050	8
949	1211	8
950	1051	8
951	1212	8
952	1054	8
953	1056	8
954	1057	8
955	1213	8
956	1059	8
957	1060	8
958	1062	8
959	1063	8
960	1065	8
961	1066	8
962	1067	8
963	1068	8
964	1069	8
965	1070	8
966	1071	8
967	1072	8
968	1073	8
969	1074	8
970	1080	8
971	1081	8
972	1082	8
973	1084	8
974	1087	8
975	1094	8
976	1214	8
977	1104	8
978	1105	8
979	1106	8
980	1107	8
981	1109	8
982	1111	8
983	1112	8
984	1113	8
985	1116	8
986	1215	8
987	1118	8
988	1124	8
989	1128	8
990	1129	8
991	1131	8
992	1132	8
993	1133	8
994	1135	8
995	1136	8
996	1138	8
997	1139	8
998	1140	8
999	1143	8
1000	1144	8
1001	1145	8
1002	1146	8
1003	1147	8
1004	1149	8
1005	1150	8
1006	1151	8
1007	1152	8
1008	1153	8
1009	1154	8
1010	1155	8
1011	1157	8
1012	1158	8
1013	1160	8
1014	1161	8
1015	1162	8
1016	1163	8
1017	1164	8
1018	1167	8
1019	1168	8
1020	1170	8
1021	1171	8
1022	1173	8
1023	1174	8
1024	1175	8
1025	1176	8
1026	1177	8
1027	1179	8
1028	1180	8
1029	1181	8
1030	1182	8
1031	1184	8
1032	1185	8
1033	1186	8
1034	1187	8
1035	1188	8
1036	1216	8
1037	1191	8
1038	1192	8
1039	1193	8
1040	1217	8
1041	1195	8
1042	1196	8
1043	1218	8
1044	1199	8
1045	1200	8
1046	1202	8
1047	1203	8
1048	1219	8
1049	1204	8
1050	1205	8
1051	1220	8
1052	1206	8
1053	1207	8
1054	1208	8
1055	1221	8
\.


--
-- Data for Name: modelos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.modelos (mo_id, mo_filename, mo_descripcion, mo_fecha_creacion, mo_train_count, mo_global, mo_activo) FROM stdin;
83	1743371615291_model-weights.json	\N	2025-03-30 15:53:20.142672-06	2	t	t
\.


--
-- Data for Name: playlists; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.playlists (pl_id, pl_nombre, pl_id_modelo, pl_activo, pl_fecha_creacion, pl_global) FROM stdin;
8	lista1	\N	t	2025-03-18 19:21:39.047596-06	f
6	lista global	83	t	2025-03-18 18:49:05.179971-06	t
\.


--
-- Data for Name: tipos_datos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tipos_datos (td_id, td_tipo, td_descripcion, td_activo, td_tipo_modelo) FROM stdin;
1	file	Archivo local cargado desde el ordenador	t	\N
\.


--
-- Name: calibracion_cl_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.calibracion_cl_id_seq', 1, false);


--
-- Name: canciones_ca_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.canciones_ca_id_seq', 1221, true);


--
-- Name: canciones_playlists_cp_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.canciones_playlists_cp_id_seq', 1055, true);


--
-- Name: modelos_mo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.modelos_mo_id_seq', 83, true);


--
-- Name: playlists_pl_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.playlists_pl_id_seq', 8, true);


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
    ADD CONSTRAINT "FK_07efb6da311257f07e7b26102c2" FOREIGN KEY (pl_id_modelo) REFERENCES public.modelos(mo_id);


--
-- Name: canciones_playlists FK_6e0e4f8b7d0a3e539a0aad74e71; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.canciones_playlists
    ADD CONSTRAINT "FK_6e0e4f8b7d0a3e539a0aad74e71" FOREIGN KEY (cp_pl_id) REFERENCES public.playlists(pl_id);


--
-- Name: canciones FK_9739bcd488328c0acc993252665; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.canciones
    ADD CONSTRAINT "FK_9739bcd488328c0acc993252665" FOREIGN KEY ("idDataTypeId") REFERENCES public.tipos_datos(td_id);


--
-- Name: calibracion FK_c086e6a11a8dded8d67c9d35b8d; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calibracion
    ADD CONSTRAINT "FK_c086e6a11a8dded8d67c9d35b8d" FOREIGN KEY (cl_id_modelo) REFERENCES public.modelos(mo_id);


--
-- Name: canciones_playlists FK_eae80d3fc22b6ff0311a167d115; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.canciones_playlists
    ADD CONSTRAINT "FK_eae80d3fc22b6ff0311a167d115" FOREIGN KEY (cp_ca_id) REFERENCES public.canciones(ca_id);


--
-- PostgreSQL database dump complete
--

