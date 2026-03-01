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
    cl_ts_prob_calif_0 numeric(6,3),
    cl_ts_prob_calif_1 numeric(6,3),
    cl_ts_prob_calif_2 numeric(6,3),
    cl_ts_prob_calif_3 numeric(6,3)
);


ALTER TABLE public.calibracion OWNER TO postgres;

--
-- Name: COLUMN calibracion.cl_tipo_interaccion; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.calibracion.cl_tipo_interaccion IS '''fit'': Entrenamiento
''predict'': Prediccion
''infer'': inferencia o ajuste';


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
    ca_train_level_local integer DEFAULT 0 NOT NULL,
    ca_id_tipodato integer NOT NULL,
    ca_activo bit(1) DEFAULT '1'::"bit" NOT NULL,
    ca_metadata text,
    ca_ts_calif_global numeric(6,5),
    ca_train_level_global integer DEFAULT 0 NOT NULL,
    ca_ts_prob_calif_0 numeric(6,3),
    ca_ts_prob_calif_1 numeric(6,3),
    ca_ts_prob_calif_2 numeric(6,3),
    ca_ts_prob_calif_3 numeric(6,3),
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
    ts_epocas_competadas integer DEFAULT 0 NOT NULL,
    ts_fechacreacion timestamp with time zone NOT NULL,
    ts_fecharegistro timestamp with time zone DEFAULT now() NOT NULL,
    ts_filename text NOT NULL,
    ts_perdida numeric(10,6) DEFAULT '0'::numeric NOT NULL,
    ts_precision numeric(6,4) DEFAULT '0'::numeric NOT NULL,
    ts_version integer DEFAULT 1 NOT NULL,
    ts_is_global bit(1) NOT NULL
);


ALTER TABLE public.ts_modelos OWNER TO postgres;

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
-- Data for Name: calibracion; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: canciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.canciones OVERRIDING SYSTEM VALUE VALUES
	(854, NULL, 3566009, '【初音ミク】 名無しの詩 【オリジナル曲】 [2ZayXb8YfyY].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(855, NULL, 3899633, '【初音ミク】 幻奏サティスファクション 【オリジナル曲】 [RHqTWidK9DE].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(856, NULL, 4083751, '【初音ミク】 心音 【オリジナル曲】 [EztEXXCheSk].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(861, NULL, 3559505, '【初音ミク】　曇りのち腐乱臭　【オリジナルPV】 [kKtLt901HDw].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(865, NULL, 3016114, '【初音ミク】夢で逢いましょう【オリジナル】 [YI492W4Qb3g].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(866, NULL, 3491991, '【初音ミク】天空の六分儀【オリジナルMV】 [x0_e0yQZibY].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(817, 0, 3024424, 'ATOLS - LAST SIGNAL feat. Hatsune Miku _ ラストシグナル feat. 初音ミク [d2M3z797sQ8].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(819, 0, 6655813, 'Calla Soiled - 亜 [tqI5vcYYQY0].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(818, 0, 4057727, 'Blindness (feat. 初音ミク) [nlLGzmErKWE].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(820, 0, 4548609, 'EXLIUM - EXLIUM feat. Miku [06KskCU_d-M].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(823, 0, 4163060, 'Koi wa Maboroshi de Ai wa Karamawari _ Nashimoto Ui (恋は幻で愛は空回り_梨本うい) [CfUZYBL6pr0].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(824, 0, 5785319, 'Reality _ Dog tails feat. Miku [MMDPV] [UPhsMAdDGfM].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(822, 0, 4173522, 'Kikuo feat. Hatsune Miku - Shimizu Curry Song [English Subbed] [Q2P76nOpeDs].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(821, 0, 5228556, 'float (feat. 初音ミク) [gKWxuB14zOQ].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(815, 0, 3325418, '(Reprint) 小悪魔笑顔とワガママボディー【初音ﾐｸﾀﾞﾖｰ オリジナルPV】 [ErksldUjSUI].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(825, 0, 6771075, 'sasakure.UK - Spider Thread Monopoly feat. Hatsune Miku  蜘蛛糸モノポリー.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(867, NULL, 4512043, '【初音ミク】祝祭と流転 English and romaji subs [ieEk2hXFkOw].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(827, 0, 4347135, '[Rin Kagamine and Miku Hatsune] Cold Back (English Subs) [HGtUmG1v9no].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(829, 0, 3862228, '┗_∵_┓吉田、家出するってよ／HoneyWorks feat.初音ミク [fd0uHUAy6TU].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(830, 0, 1945642, '┗_∵_┓第三次プリン戦争　／　HoneyWorks feat.初音ミク、GUMI [A_zZ4SY0kp0].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(831, 0, 4103244, '「キズ」 - KEI feat.初音ミク [D9UFIFujRyo].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(832, 0, 2959411, '【2013-05-01 _ Carlos Hakamada(debut)】 タイムトラベラー！(Time traveller_)- MIKU(original)_カルロス袴田(music) [udobYRGEeNg].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(833, 0, 4179634, '【Hatsune Miku】 【L】ucy【Eve】【Original MV】 [49c4aO99Etg].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(836, 0, 4427473, '【Miku·GUMI·Lily·Iroha】「Violet Blue Fantasy ～Fantasy of Iolite～」【Sub Español】 [d86r3_HR5kw].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(837, 1, 6215701, '【MIKU】Bianca [8a3lVn8rzmA].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(834, 0, 3150189, '【Hatsune Miku】 たのしい逃避行 [5Tef_SSOe40].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(838, 0, 2871204, '【MV】現代ササクレ概論／なすP feat. 初音ミク (Modern Hangnail Outline／Nasu feat. Miku Hatsune) [OEXZ5Ml4vKk].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(839, 0, 2495759, '【MV】絶望の砂漠／なすP feat. 初音ミク (Desert of Despair／Nasu feat. Miku Hatsune) [rDL6huvbJM0].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(840, 0, 6059129, '【SKEW】カノジョの選択肢と独りぼっちの北の空【PSGOZ】 [Ei22xcvPXy8].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(841, 0, 5422033, '【VOCALOID_IA】_ 午前４時の金星 _ AM4 Venus _ by Ashin Kuroda [Zhc9onqv-QM].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(842, 0, 4147173, '【_years_ 5_12】May【初音ミクDarkオリジナルPV】 [wxXQJBMeW94].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(843, 0, 5339349, '【ミクAPPENDsolid】僕の一部【オリジナルPV】 [Po-oRnoT-ts].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(844, 0, 5812731, '【初音ミク - Hatsune Miku】your anniversary【PV subs】 [rUd8zvq63Ro] (1).mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(845, 0, 5812731, '【初音ミク - Hatsune Miku】your anniversary【PV subs】 [rUd8zvq63Ro] (2).mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(846, 0, 5812731, '【初音ミク - Hatsune Miku】your anniversary【PV subs】 [rUd8zvq63Ro].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(848, 0, 4205575, '【初音ミク - Hatsune Miku】心の片隅に - Kokoro no Katasumi ni【subs】 [p6cQU2bQitU].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(849, 0, 4790748, '【初音ミクAppend】miss you【中文字幕】 [MrVuRQHJhYs].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(850, 0, 4513925, '【初音ミクAppend】Quiet【オリジナル曲】 [fihI7EuO0eA].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(851, 0, 5377606, '【初音ミクDark】ゆらゆら English and romaji subs [04fGKdznrkw].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(852, 0, 5016696, '【初音ミクdark】シロツメクサの花冠 【オリジナル】 [rwXpIeZm-Sc].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(853, 0, 4837996, '【初音ミクDark】ループ・ループ・ループ【オリジナル】 [wpV2EbPYnrY].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(873, 0, 5009650, 'サテライト [h3bNut-SVpg].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(857, 0, 5568544, '【初音ミク】Calla Soiled - 虚構の光【オリジナル曲】 [FiukeDh9WKo].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(858, 0, 3899541, '【初音ミク】Oriental Cybernetic QT Girl【SUB ENG_ITA】 [mCPH4OGATq8].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(859, 1, 4809098, '【初音ミク】Twinkle Days【オリジナル曲PV】 [m9DTGxCT5-0].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(860, 0, 3683148, '【初音ミク】　 オトシメセルフ 　【オリジナル曲】 [hTQKJQWMQ-4].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(868, 0, 5434338, '【初音ミクオリジナル】リダクト [A9JripMnIMc].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(863, 0, 5612525, '【初音ミク】ゲーセン上のアリア【オリジナル曲】 [PEHddBaJyUA].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(864, 0, 3072887, '【初音ミク】ムラサキ【オリジナル曲PV付】 [omYEruBpSM8].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(862, 0, 5609899, '【初音ミク】わたしと君とを繋ぐもの【オリジナル】 [IKOookjqXhU].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(835, 2, 4006520, '【Hatsune Miku】Lost My Love【Original Song】 [Hg0xobCxaI8].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(877, NULL, 3956089, '唸る刃と群青正義 [aSp3DvQS7BI].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(878, NULL, 3749064, '徒花満ちて _ ふる feat. 初音ミク [LRCKlcAECQ4].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(879, NULL, 7472180, '微熱の微笑み、微少女は微かに微睡ーム [FYTsVgSO-ms].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(880, NULL, 4468974, '恋人一首 _ 初音ミク [f7vloBZBp6c].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(881, NULL, 5130954, '明日も良い日になるでしょう (feat. IA＆初音ミク) [fHhV6tz2_Rs].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(882, NULL, 3489005, '最憂間で君は [fmbOTo1t1dk].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(883, NULL, 4643130, '洗濯　（初音ミクAppend） [yargFkG0q0o] (1).mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(884, NULL, 4643130, '洗濯　（初音ミクAppend） [yargFkG0q0o].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(885, NULL, 2156993, '第1話　予測の先にカノジョは走馬灯を見るか PSGO-Z【SKEW PV】 [Ih6NBS9OcPo].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(886, NULL, 4240510, '雀色コンデンサ [Rh3XRrvzl50].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(887, NULL, 3885563, '霞む森 _ 初音ミク＆GUMI [5UIfTqACqJ8] (1).mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(888, NULL, 3885563, '霞む森 _ 初音ミク＆GUMI [5UIfTqACqJ8].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(816, 0, 3851200, 'After that feat. Hatsune Miku [xRoF-MAJ5O8].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(826, 0, 3322812, '[Hatsune Miku] That Rich Guy is a Tetromino - tadanoco English subs [Ik8DHj5zcrs].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(828, 0, 3612810, '┗_∵_┓ヤキモチの答え-another story-／HoneyWorks feat.初音ミク [Qlkezcz3tt4].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(893, 1, 5372012, '01 アンドロイド Voc@loid ～I am not a robot～.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(891, 2, 4129298, '01 - Tell Your World.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(894, 3, 8224103, '03 Palette.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(895, 1, 8460849, '03 ワールズエンド・ダンスホール.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(896, 1, 6794009, '04 CALL ME CALL ME.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(897, 2, 9410964, '04 彼方まで虹を架けて.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(898, 2, 3675539, '05 Night Glitter (Featuring Hatsune Miku).mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(899, 2, 6143816, '08 雨のちSweet-Drops.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(901, 2, 8783761, '09 ☆Fighting Pose☆.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(900, 2, 7637962, '09 GIFT.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(903, 3, 9631379, '09 ツユメロ.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(904, 1, 5874858, '11 396.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(905, 1, 6123034, '11 Anti X''mas Superstar.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(906, 2, 8975210, '11 ハロー、プラネット.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(907, 2, 6677916, '13 アンダンテ.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(908, 3, 5303487, '16 スイートマジック.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(909, 2, 6483666, '16 ローリンガール.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(910, 2, 4558903, '17 Ievan Polkka.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(911, 3, 8411420, '17 Yellow.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(912, 2, 8169778, '18 リンリンシグナル.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(913, 2, 5785263, '20 どういうことなの! (Game Version).mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(915, 1, 7015417, 'An ／ DECO＊27 feat初音ミク.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(916, 0, 3662996, 'Anti Selector_初音ミク [ShTbgwaKkiQ].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(917, 1, 6067327, 'AOHARU.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(918, 1, 7372052, 'Breath of Urban   keisei feat Hatsune Miku.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(920, 2, 6536436, 'CATS RULE THE WORLD   daniwell feat Hatsune Miku  Momone Momo.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(919, 0, 4315585, 'Bright future Ein schritt.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(921, 1, 5121435, 'Child   初音ミク.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(922, 1, 5852446, 'cloudway (feat Hatsune Miku)   keisei.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(923, 1, 4043380, 'Cressida   ftHatsune Miku 【english subtitles】.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(927, 2, 6410421, 'Deco27 ft 初音ミク.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(924, 2, 5743358, 'DECO27   ハートアラモード feat 初音ミ�.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(925, 1, 5708877, 'DECO27   夜行性ハイズ feat 初音ミ�.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(926, 2, 3934431, 'DECO27  愛言葉Ⅲ feat 初音ミク.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(929, 1, 5673768, 'Dream Chase.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(930, 1, 6799123, 'DreamerTeary Planet feat. 初音ミク.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(931, 1, 4121259, 'east end and bocci  feat初音ミク.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(932, 2, 4239123, 'Equation.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(933, 1, 4128127, 'Find Me feat. Hatsune Miku [P7UJeX6WE4Q].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(934, 2, 7662709, 'Hand in Hand.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(935, 1, 3791071, 'Hatsune Miku   Akeomeakeomeakeomeakeome (Happy New Year).mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(936, 1, 5667499, 'Hatsune Miku   Calc (English  Romaji Subs).mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(889, 1, 3250232, '- Ranaエレクトロサチュレイタ ElectrosaturatorVSQx.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(872, 0, 4753744, 'キャラメルティアドロップ_初音ミク [d4qecYvfWgw].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(874, 0, 4771135, 'ピノキオピー - ゲームスペクター2 feat. 初音ミク _ Game Specter 2 [OfXUHMYccu4].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(875, 0, 4298997, 'ミルキーオンザクレープ [hdoG6pvGxA0].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(869, 0, 4647758, '【初音ミク・VY1V3】PROGRAM BREAKER【オリジナルPV】 [NIDa7HqGqc4].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(876, 0, 3853027, '初音ミクオリジナル曲 「PYX」中日字幕 [36UirlGT-iY].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(870, 0, 4765562, '【初音ミク（ぐにょ）】福寿草【作曲してみた】 [15HNvDg0Gq4].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(890, 2, 3762650, '- 初音ミクねこみみスイッチオリジナル.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(814, 0, 3658842, '(Reprint) 初音ミク『アンダー・プリテンダー』オリジナル [A2zTCOY-uPI].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(998, NULL, 6366535, '【初音ミク】 紫陽花が咲く頃に、君と恋をする 【nk】.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(974, 1, 4184609, '[Eng Sub] To the Lonely You and the Lone Me [Suzumu ft. Hatsune Miku] [EHxFEHPBDP8].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(983, 1, 4738909, '【Hatsune Miku】Body Music【Original Song】.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(981, 1, 5384749, '‪【Hatsune Miku】‬Cerita SMU【Original】‬.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(939, 1, 6269360, 'Hatsune Miku Original Song Bright City.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(940, 1, 6601010, 'Hatsune Miku Original Song.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(937, 2, 4216042, 'Hatsune Miku   Sayonara·Good bye [English Sub].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(941, 1, 4503295, 'Hatsune Miku Two Faced Lovers.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(942, 1, 8056042, 'Heavenz   アルファ.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(943, 1, 6782196, 'irucaice   White Step feat Hatsune Mik.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(984, 1, 5286947, '【Kagamine Rin V4X】 Hop! Step! Instant Death! A Happiness Dance Death Trap 【VOCALOID Cover�.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(944, 1, 5845549, 'kiRakiLa  gaogao feat初音ミ�.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(945, 2, 4775365, 'Lamaze P ft 初音ミク.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(946, 1, 4629288, 'Landscape  初音ミク   歩く人×春�.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(947, 1, 6458068, 'livetune   never ende.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(948, 1, 6385343, 'LOST NOTE  No85 feat初音ミ�.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(950, 1, 4374124, 'MASA WORKS DESIGN ft初音ミクu0026GUMI   BRASS NOISE FLAMENC.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(949, 2, 4201412, 'lumo - ネットチルナノグ feat. 初音ミク [fSOK6pGHI5Q].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(951, 2, 5197294, 'Melancholic  Junky ft Rin Kagamine.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(952, 1, 4345285, 'METEOR  DIVELA feat初音ミク.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(953, 2, 3980123, 'miku hatsune - po pi po356.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(976, 2, 6832978, '[Music] Livetune (feat Hatsune Miku)   Redia.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(954, 2, 4251662, 'Musunde Hiraite Rasetsu to Mukuro ORIGINAL.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(977, 1, 5640540, '[MV]さよならカンパニュラ  mehikari feat 初音ミ�.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(955, 1, 5485059, 'Neo.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(956, 1, 5234911, 'Neru - ロストワンの号哭(Lost One''s Weeping) feat. Kagamine Rin.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(957, 1, 5964041, 'night  (t)rain  初音ミ�.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(958, 1, 2856514, 'Onesided Love Samba  Hatsune Miku Traduccion.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(961, 3, 6713232, 'Rainbow Palace feat Hatsune Miku   Jonathan Parecki 【Vocaloid Original�.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(960, 3, 4362839, 'PinocchioP (feat Hatsune Miku and Yukkuri)   Proliferation of Imamur.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(962, 1, 7012282, 'Robo feat. Hatsune Miku SPACERUN オリジナル曲.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(985, 1, 5549634, '【Robo feat 初音ミク】 SKY HIGHWAY【オリジナル曲�.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(963, 1, 5964668, 'ryuryu   Flowers featHatsune Miku 初音ミ�.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(964, 3, 5262496, 'sasakureUK x DECO27   39 feat Hatsune Miku.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(965, 2, 4354178, 'spica- hatsune miku.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(978, 1, 4346243, '[Subs+Lyrics] Contrast [Hatsune Miku] [O6FrUaQVqlQ].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(966, 1, 6155257, 'SushiP ft 初音ミク ''Align'' アライン (English Subtitles).mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(968, 2, 5999149, 'TsunTsun  ftHatsune Miku_192kbps.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(967, 2, 9821039, 'triple baka - miku hatsune.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(979, 3, 5737281, '[VnSharing] Umi Yuri Kaiteitan   Hatsune Miku   Vocaloid vietsub.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(980, 1, 7771505, '[VOCALOID] Sailing  初音ミク [公式.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(969, 1, 5117066, 'Weekender Girl   Hatsune Miku Project Diva F (HD).mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(970, 2, 6314499, 'White Dove with English  Romaji Sub  Hatsune Miku  ハト  sm2583719  HQ.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(971, 1, 3495156, 'yt1s.com - ElectronicMizusano ft Hatsune Miku  Smile Walker.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(972, 1, 4904932, 'yt1s.com - Far Away.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(973, 1, 3014503, 'yt1s.com - Mizusano feat 初音ミク Universe.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(986, 1, 6716994, '【オリジナルMV】ユメノアメ feat初音ミク  ドッシ�.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(987, 2, 5669379, '【ミク・MAYU・がくぽ】「Ib」 forever 【オリジナルPV】.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(992, 1, 4831162, '【初音ミク×アルクロ】センセーションはおわらない！ フルver【コラボオリジナル楽曲�.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1000, 1, 7950183, '【初音ミク】Another Mine【オリジナル21】[HD720p].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(993, 1, 2801668, '【初音ミク】 Anata no Utahime (8ch arr) 【休闲の1月曲】.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(990, 3, 6693704, '【初音ミクAppend DARK】Carbuncle【オリジナル曲】.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(999, 1, 6521296, '【初音ミク】a tail of the wind【Cazオリジナル】.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(994, 1, 6394121, '【初音ミク】 Baby Steps 【オリジナル�.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(995, 0, 7854795, '【初音ミク】 children 【オリジナル曲】.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(989, 1, 4176877, '【初音ミク - Hatsune Miku】Electro Saturator -Starry electro mix-【MMD-PV】 [UX4II4sy1IQ].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(996, 1, 3347864, '【初音ミク】 Lap Tap Love 【オリジナル】_[Hatsune Miku] Lap Tap Love [Original] [yhBQfbvHmdw].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(997, 2, 3340929, '【初音ミク】 だんだん早くなる Getting Faster and Faster【オリジナル�.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(991, 1, 3551772, '【初音ミクSweet】街路灯を横切って English and romaji subs [CKqpXsny5W0].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(975, 3, 6084413, '[Hatsune Miku] Sayonara Arpeggio [VOSTFR].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1004, NULL, 5194160, '【初音ミク】　表面張力　【オリジナル�.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1010, NULL, 5141020, '【初音ミク】空に花束を【オリジナル】 [4OLuVzAyYZ0].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1012, NULL, 7576434, '【水野大輔 feat 初音ミく】 Brilliance.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1033, NULL, 5628001, '初音ミク灯火syudou_192kbps.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1034, NULL, 6625461, '夏至の踊り子 ／初音ミ�.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1035, NULL, 7311959, '大嫌いなはずだったHoneyWorks feat.GUMI初音ミク.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1036, NULL, 1661360, '小説3こちら幸福安心委員会です女王様とハピネスサマーゲーム.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1037, NULL, 6647404, '手�.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1038, NULL, 6117641, '神のまにまに - れるりりfeat.ミク&リン&GUMI  At God''s Mercy - rerulili feat.Vocaloids.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1039, NULL, 7278104, '神経衰弱  初音ミク 【 Nervous Breakdown  Hatsune Miku �.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1040, NULL, 5408573, '私は足りないでいっぱい_192kbps.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1041, NULL, 4048736, '空海月 - -STL001- MIKUHOP LP - 08 チョコレートサンデー [nt8RupYeHlc].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1042, NULL, 7087515, '膵臓  Luna feat 初音ミク ガールズコレクション.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1043, NULL, 2568958, '鏡音レン唐傘さんが通るオリジナルPV.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(847, 0, 5063310, '【初音ミク - Hatsune Miku】ウタヲウタエ - Uta o Utae - Sing a Song【PV subs】 [j_AtIAPeIsU].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(982, 1, 5817964, '┗ ∵ ┓夢ファンファーレ／HoneyWorks feat初音ミクu0026GUM.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(892, 2, 5561339, '01 EARTH DAY.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(902, 1, 15100066, '09 キューティージェリー (feat. 初音ミク).mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(914, 1, 6109320, 'Amaotopetrichor (feat. Hatsune Miku).mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(928, 1, 2889533, 'DokiDokiBeat 初音ミク for Lamaze.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(938, 2, 5052472, 'Hatsune Miku   Torinoko City  (トリノコシティ)(Left Behind City) Sub Esp (+mp3 + romaji.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(959, 3, 6144599, 'Ordinary   ポリスピカデリー feat 初音ミク  Ordinary   Police Piccadilly feat Hatsune Mik.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1013, 2, 4874421, 'あいまいクエスチョン／yamada feat初音ミク   The Quizmaste.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1015, 1, 5372210, 'くるくるついんてーる_192kbps.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1020, 1, 4399108, 'アンドロメダアンドロメダ   ナユタン星人 feat 初音ミク.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1014, 2, 3723988, 'えいえんがみつからない - daniwell feat. Hatsune Miku & Momone Momo.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1021, 1, 6313246, 'シネマセレク�.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(871, 0, 4586189, 'とあ - 飛行機雲 - ft.初音ミク ( Toa - Contrail - ft.Hatsune Miku ) [RHCoZroZySA].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1016, 1, 6318888, 'ひとりぼっちとココロの本と - PIPPO feat. 初音ミク.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(988, 3, 5142658, '【公式】アイシテ  とあ feat 初音ミク　  LOVE ME  toa feat Hatsune Miku.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1019, 2, 5233030, 'みきとP『 だいあもんど 』M.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1022, 1, 4102032, 'プリエ  初音ミク  Hatsune Miku.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1017, 2, 5887554, 'みきとP Hoi MV.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1018, 0, 4653386, 'みきとP『 kiss 』MV [9tjA9S281wg].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1023, 1, 5891316, 'モノクロブルースカイ  のぼる feat 初音ミク  MonochromeBlueSky.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1024, 1, 6525151, '八王子Pデスクトップシンデレラ feat. 初音ミクMusic Video.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1001, 1, 5260371, '【初音ミク】aria【オリジナル曲PV付】.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1002, 1, 5931974, '【初音ミク】bpm full ver 【PV】.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1011, 1, 6175226, '【初音ミク・GUMI】あの日、描いたDIARY【オリジナル曲PV】OFFICIAL　MV.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1003, 3, 4929612, '【初音ミク】Hatsune Miku「DECORATOR」MP3 High Quality![8].mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1005, 3, 5042348, '【初音ミク】アクリルスター【オリジナル】.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1006, 1, 8406594, '【初音ミク】アネモネ【オリジナル】.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1025, 1, 6081645, '初音ミク poppin'' jumpin まらしぃ kors k.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1026, 2, 4160129, '初音ミク Project Diva f 2nd  nanou  Hatsune Miku  Glory 3usi9  Best of nanou (high volume).mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1007, 1, 6113159, '【初音ミク】アポロ【オリジナルMMD PV】.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1029, 1, 6602171, '初音ミクオリジナル曲 「Breath of mechanical」.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1030, 1, 6067486, '初音ミクオリジナル曲「Singularity�.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1028, 1, 3597881, '初音ミク　オリジナル曲　『アンダワ』.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1008, 1, 6742072, '【初音ミク】スターナイトスノウ【オリジナルMV�.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1031, 1, 5332086, '初音ミクメイウェンティーオリジナルPV.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1027, 1, 4944011, '初音ミク ラストペインター オリジナルMIKULast painteroriginal.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1032, 2, 5216312, '初音ミクリンレンルカ夢の続きオリジナル中文字幕.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
	(1009, 1, 6236759, '【初音ミク】名前のない誰か【オリジナル�.mp3', 0, 1, B'1', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL);


--
-- Data for Name: playlists; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.playlists OVERRIDING SYSTEM VALUE VALUES
	(1, 'Favoritos', NULL, '2026-02-22 18:57:37.569194-06', B'1', B'1');


--
-- Data for Name: rel_playlists_canciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.rel_playlists_canciones OVERRIDING SYSTEM VALUE VALUES
	(1, 814, 1, '2026-02-22 22:25:21.911593-06'),
	(2, 815, 1, '2026-02-22 22:25:21.912944-06'),
	(3, 816, 1, '2026-02-22 22:25:21.913479-06'),
	(4, 817, 1, '2026-02-22 22:25:21.914002-06'),
	(5, 818, 1, '2026-02-22 22:25:21.914607-06'),
	(6, 819, 1, '2026-02-22 22:25:21.915139-06'),
	(7, 820, 1, '2026-02-22 22:25:21.915628-06'),
	(8, 821, 1, '2026-02-22 22:25:21.916036-06'),
	(9, 822, 1, '2026-02-22 22:25:21.916563-06'),
	(10, 823, 1, '2026-02-22 22:25:21.917255-06'),
	(11, 824, 1, '2026-02-22 22:25:21.917863-06'),
	(12, 825, 1, '2026-02-22 22:25:21.918371-06'),
	(13, 826, 1, '2026-02-22 22:25:21.918902-06'),
	(14, 827, 1, '2026-02-22 22:25:21.919478-06'),
	(15, 828, 1, '2026-02-22 22:25:21.920162-06'),
	(16, 829, 1, '2026-02-22 22:25:21.920744-06'),
	(17, 830, 1, '2026-02-22 22:25:21.921241-06'),
	(18, 831, 1, '2026-02-22 22:25:21.921762-06'),
	(19, 832, 1, '2026-02-22 22:25:21.92219-06'),
	(20, 833, 1, '2026-02-22 22:25:21.922696-06'),
	(21, 834, 1, '2026-02-22 22:25:21.923147-06'),
	(22, 835, 1, '2026-02-22 22:25:21.923565-06'),
	(23, 836, 1, '2026-02-22 22:25:21.923957-06'),
	(24, 837, 1, '2026-02-22 22:25:21.924358-06'),
	(25, 838, 1, '2026-02-22 22:25:21.924815-06'),
	(26, 839, 1, '2026-02-22 22:25:21.925383-06'),
	(27, 840, 1, '2026-02-22 22:25:21.925864-06'),
	(28, 841, 1, '2026-02-22 22:25:21.926278-06'),
	(29, 842, 1, '2026-02-22 22:25:21.926675-06'),
	(30, 843, 1, '2026-02-22 22:25:21.9271-06'),
	(31, 844, 1, '2026-02-22 22:25:21.927631-06'),
	(32, 845, 1, '2026-02-22 22:25:21.928102-06'),
	(33, 846, 1, '2026-02-22 22:25:21.9285-06'),
	(34, 847, 1, '2026-02-22 22:25:21.928885-06'),
	(35, 848, 1, '2026-02-22 22:25:21.929288-06'),
	(36, 849, 1, '2026-02-22 22:25:21.929668-06'),
	(37, 850, 1, '2026-02-22 22:25:21.930068-06'),
	(38, 851, 1, '2026-02-22 22:25:21.930458-06'),
	(39, 852, 1, '2026-02-22 22:25:21.930837-06'),
	(40, 853, 1, '2026-02-22 22:25:21.93127-06'),
	(41, 854, 1, '2026-02-22 22:25:21.931678-06'),
	(42, 855, 1, '2026-02-22 22:25:21.932062-06'),
	(43, 856, 1, '2026-02-22 22:25:21.932495-06'),
	(44, 857, 1, '2026-02-22 22:25:21.933229-06'),
	(45, 858, 1, '2026-02-22 22:25:21.93384-06'),
	(46, 859, 1, '2026-02-22 22:25:21.934451-06'),
	(47, 860, 1, '2026-02-22 22:25:21.935106-06'),
	(48, 861, 1, '2026-02-22 22:25:21.935789-06'),
	(49, 862, 1, '2026-02-22 22:25:21.936501-06'),
	(50, 863, 1, '2026-02-22 22:25:21.937188-06'),
	(51, 864, 1, '2026-02-22 22:25:21.937798-06'),
	(52, 865, 1, '2026-02-22 22:25:21.938397-06'),
	(53, 866, 1, '2026-02-22 22:25:21.938866-06'),
	(54, 867, 1, '2026-02-22 22:25:21.939447-06'),
	(55, 868, 1, '2026-02-22 22:25:21.939918-06'),
	(56, 869, 1, '2026-02-22 22:25:21.940382-06'),
	(57, 870, 1, '2026-02-22 22:25:21.940841-06'),
	(58, 871, 1, '2026-02-22 22:25:21.941252-06'),
	(59, 872, 1, '2026-02-22 22:25:21.941737-06'),
	(60, 873, 1, '2026-02-22 22:25:21.942178-06'),
	(61, 874, 1, '2026-02-22 22:25:21.942585-06'),
	(62, 875, 1, '2026-02-22 22:25:21.943018-06'),
	(63, 876, 1, '2026-02-22 22:25:21.943412-06'),
	(64, 877, 1, '2026-02-22 22:25:21.944047-06'),
	(65, 878, 1, '2026-02-22 22:25:21.944451-06'),
	(66, 879, 1, '2026-02-22 22:25:21.94484-06'),
	(67, 880, 1, '2026-02-22 22:25:21.945225-06'),
	(68, 881, 1, '2026-02-22 22:25:21.945616-06'),
	(69, 882, 1, '2026-02-22 22:25:21.946019-06'),
	(70, 883, 1, '2026-02-22 22:25:21.94641-06'),
	(71, 884, 1, '2026-02-22 22:25:21.946798-06'),
	(72, 885, 1, '2026-02-22 22:25:21.94719-06'),
	(73, 886, 1, '2026-02-22 22:25:21.94762-06'),
	(74, 887, 1, '2026-02-22 22:25:21.948087-06'),
	(75, 888, 1, '2026-02-22 22:25:21.948495-06'),
	(76, 889, 1, '2026-02-24 19:04:35.775904-06'),
	(77, 890, 1, '2026-02-24 19:04:35.777168-06'),
	(78, 891, 1, '2026-02-24 19:04:35.777892-06'),
	(79, 892, 1, '2026-02-24 19:04:35.778708-06'),
	(80, 893, 1, '2026-02-24 19:04:35.779742-06'),
	(81, 894, 1, '2026-02-24 19:04:35.780629-06'),
	(82, 895, 1, '2026-02-24 19:04:35.781371-06'),
	(83, 896, 1, '2026-02-24 19:04:35.781892-06'),
	(84, 897, 1, '2026-02-24 19:04:35.78251-06'),
	(85, 898, 1, '2026-02-24 19:04:35.783052-06'),
	(86, 899, 1, '2026-02-24 19:04:35.783667-06'),
	(87, 900, 1, '2026-02-24 19:04:35.784166-06'),
	(88, 901, 1, '2026-02-24 19:04:35.784763-06'),
	(89, 902, 1, '2026-02-24 19:04:35.785239-06'),
	(90, 903, 1, '2026-02-24 19:04:35.785692-06'),
	(91, 904, 1, '2026-02-24 19:04:35.78614-06'),
	(92, 905, 1, '2026-02-24 19:04:35.786587-06'),
	(93, 906, 1, '2026-02-24 19:04:35.787337-06'),
	(94, 907, 1, '2026-02-24 19:04:35.787982-06'),
	(95, 908, 1, '2026-02-24 19:04:35.788544-06'),
	(96, 909, 1, '2026-02-24 19:04:35.789173-06'),
	(97, 910, 1, '2026-02-24 19:04:35.789674-06'),
	(98, 911, 1, '2026-02-24 19:04:35.790244-06'),
	(99, 912, 1, '2026-02-24 19:04:35.790966-06'),
	(100, 913, 1, '2026-02-24 19:04:35.791526-06'),
	(101, 914, 1, '2026-02-24 19:04:35.792063-06'),
	(102, 915, 1, '2026-02-24 19:04:35.792836-06'),
	(103, 916, 1, '2026-02-24 19:04:35.793809-06'),
	(104, 917, 1, '2026-02-24 19:04:35.794587-06'),
	(105, 918, 1, '2026-02-24 19:04:35.795234-06'),
	(106, 919, 1, '2026-02-24 19:04:35.795858-06'),
	(107, 920, 1, '2026-02-24 19:04:35.79646-06'),
	(108, 921, 1, '2026-02-24 19:04:35.797511-06'),
	(109, 922, 1, '2026-02-24 19:04:35.798251-06'),
	(110, 923, 1, '2026-02-24 19:04:35.798959-06'),
	(111, 924, 1, '2026-02-24 19:04:35.799535-06'),
	(112, 925, 1, '2026-02-24 19:04:35.80006-06'),
	(113, 926, 1, '2026-02-24 19:04:35.800967-06'),
	(114, 927, 1, '2026-02-24 19:04:35.801449-06'),
	(115, 928, 1, '2026-02-24 19:04:35.801907-06'),
	(116, 929, 1, '2026-02-24 19:04:35.802358-06'),
	(117, 930, 1, '2026-02-24 19:04:35.802808-06'),
	(118, 931, 1, '2026-02-24 19:04:35.803292-06'),
	(119, 932, 1, '2026-02-24 19:04:35.803994-06'),
	(120, 933, 1, '2026-02-24 19:04:35.804742-06'),
	(121, 934, 1, '2026-02-24 19:04:35.805372-06'),
	(122, 935, 1, '2026-02-24 19:04:35.806073-06'),
	(123, 936, 1, '2026-02-24 19:04:35.806757-06'),
	(124, 937, 1, '2026-02-24 19:04:35.807374-06'),
	(125, 938, 1, '2026-02-24 19:04:35.807909-06'),
	(126, 939, 1, '2026-02-24 19:04:35.808466-06'),
	(127, 940, 1, '2026-02-24 19:04:35.809107-06'),
	(128, 941, 1, '2026-02-24 19:04:35.80971-06'),
	(129, 942, 1, '2026-02-24 19:04:35.810221-06'),
	(130, 943, 1, '2026-02-24 19:04:35.810791-06'),
	(131, 944, 1, '2026-02-24 19:04:35.811283-06'),
	(132, 945, 1, '2026-02-24 19:04:35.81175-06'),
	(133, 946, 1, '2026-02-24 19:04:35.812182-06'),
	(134, 947, 1, '2026-02-24 19:04:35.812689-06'),
	(135, 948, 1, '2026-02-24 19:04:35.81312-06'),
	(136, 949, 1, '2026-02-24 19:04:35.813531-06'),
	(137, 950, 1, '2026-02-24 19:04:35.814312-06'),
	(138, 951, 1, '2026-02-24 19:04:35.814953-06'),
	(139, 952, 1, '2026-02-24 19:04:35.815428-06'),
	(140, 953, 1, '2026-02-24 19:04:35.815867-06'),
	(141, 954, 1, '2026-02-24 19:04:35.816314-06'),
	(142, 955, 1, '2026-02-24 19:04:35.816788-06'),
	(143, 956, 1, '2026-02-24 19:04:35.817319-06'),
	(144, 957, 1, '2026-02-24 19:04:35.817768-06'),
	(145, 958, 1, '2026-02-24 19:04:35.818192-06'),
	(146, 959, 1, '2026-02-24 19:04:35.818601-06'),
	(147, 960, 1, '2026-02-24 19:04:35.819092-06'),
	(148, 961, 1, '2026-02-24 19:04:35.819613-06'),
	(149, 962, 1, '2026-02-24 19:04:35.820306-06'),
	(150, 963, 1, '2026-02-24 19:04:35.82097-06'),
	(151, 964, 1, '2026-02-24 19:04:35.821575-06'),
	(152, 965, 1, '2026-02-24 19:04:35.822124-06'),
	(153, 966, 1, '2026-02-24 19:04:35.822635-06'),
	(154, 967, 1, '2026-02-24 19:04:35.823115-06'),
	(155, 968, 1, '2026-02-24 19:04:35.823544-06'),
	(156, 969, 1, '2026-02-24 19:04:35.823976-06'),
	(157, 970, 1, '2026-02-24 19:04:35.824388-06'),
	(158, 971, 1, '2026-02-24 19:04:35.824901-06'),
	(159, 972, 1, '2026-02-24 19:04:35.826614-06'),
	(160, 973, 1, '2026-02-24 19:04:35.827587-06'),
	(161, 974, 1, '2026-02-24 19:04:35.828331-06'),
	(162, 975, 1, '2026-02-24 19:04:35.829096-06'),
	(163, 976, 1, '2026-02-24 19:04:35.829816-06'),
	(164, 977, 1, '2026-02-24 19:04:35.83035-06'),
	(165, 978, 1, '2026-02-24 19:04:35.831292-06'),
	(166, 979, 1, '2026-02-24 19:04:35.83175-06'),
	(167, 980, 1, '2026-02-24 19:04:35.832478-06'),
	(168, 981, 1, '2026-02-24 19:04:35.832981-06'),
	(169, 982, 1, '2026-02-24 19:04:35.833494-06'),
	(170, 983, 1, '2026-02-24 19:04:35.834011-06'),
	(171, 984, 1, '2026-02-24 19:04:35.834428-06'),
	(172, 985, 1, '2026-02-24 19:04:35.834849-06'),
	(173, 986, 1, '2026-02-24 19:04:35.835603-06'),
	(174, 987, 1, '2026-02-24 19:04:35.836157-06'),
	(175, 988, 1, '2026-02-24 19:04:35.836638-06'),
	(176, 989, 1, '2026-02-24 19:04:35.837263-06'),
	(177, 990, 1, '2026-02-24 19:04:35.837833-06'),
	(178, 991, 1, '2026-02-24 19:04:35.838346-06'),
	(179, 992, 1, '2026-02-24 19:04:35.838907-06'),
	(180, 993, 1, '2026-02-24 19:04:35.839422-06'),
	(181, 994, 1, '2026-02-24 19:04:35.839848-06'),
	(182, 995, 1, '2026-02-24 19:04:35.840317-06'),
	(183, 996, 1, '2026-02-24 19:04:35.840743-06'),
	(184, 997, 1, '2026-02-24 19:04:35.841154-06'),
	(185, 998, 1, '2026-02-24 19:04:35.841598-06'),
	(186, 999, 1, '2026-02-24 19:04:35.842319-06'),
	(187, 1000, 1, '2026-02-24 19:04:35.842874-06'),
	(188, 1001, 1, '2026-02-24 19:04:35.843397-06'),
	(189, 1002, 1, '2026-02-24 19:04:35.84395-06'),
	(190, 1003, 1, '2026-02-24 19:04:35.844455-06'),
	(191, 1004, 1, '2026-02-24 19:04:35.845011-06'),
	(192, 1005, 1, '2026-02-24 19:04:35.845475-06'),
	(193, 1006, 1, '2026-02-24 19:04:35.846039-06'),
	(194, 1007, 1, '2026-02-24 19:04:35.846471-06'),
	(195, 1008, 1, '2026-02-24 19:04:35.846892-06'),
	(196, 1009, 1, '2026-02-24 19:04:35.847319-06'),
	(197, 1010, 1, '2026-02-24 19:04:35.847741-06'),
	(198, 1011, 1, '2026-02-24 19:04:35.848164-06'),
	(199, 1012, 1, '2026-02-24 19:04:35.848585-06'),
	(200, 1013, 1, '2026-02-24 19:04:35.849314-06'),
	(201, 1014, 1, '2026-02-24 19:04:35.84981-06'),
	(202, 1015, 1, '2026-02-24 19:04:35.850236-06'),
	(203, 1016, 1, '2026-02-24 19:04:35.850657-06'),
	(204, 1017, 1, '2026-02-24 19:04:35.851058-06'),
	(205, 1018, 1, '2026-02-24 19:04:35.851472-06'),
	(206, 1019, 1, '2026-02-24 19:04:35.851878-06'),
	(207, 1020, 1, '2026-02-24 19:04:35.852498-06'),
	(208, 1021, 1, '2026-02-24 19:04:35.852923-06'),
	(209, 1022, 1, '2026-02-24 19:04:35.853433-06'),
	(210, 1023, 1, '2026-02-24 19:04:35.854028-06'),
	(211, 1024, 1, '2026-02-24 19:04:35.854684-06'),
	(212, 1025, 1, '2026-02-24 19:04:35.855122-06'),
	(213, 1026, 1, '2026-02-24 19:04:35.855617-06'),
	(214, 1027, 1, '2026-02-24 19:04:35.856125-06'),
	(215, 1028, 1, '2026-02-24 19:04:35.856577-06'),
	(216, 1029, 1, '2026-02-24 19:04:35.856997-06'),
	(217, 1030, 1, '2026-02-24 19:04:35.857407-06'),
	(218, 1031, 1, '2026-02-24 19:04:35.857879-06'),
	(219, 1032, 1, '2026-02-24 19:04:35.858464-06'),
	(220, 1033, 1, '2026-02-24 19:04:35.859072-06'),
	(221, 1034, 1, '2026-02-24 19:04:35.859488-06'),
	(222, 1035, 1, '2026-02-24 19:04:35.859912-06'),
	(223, 1036, 1, '2026-02-24 19:04:35.860357-06'),
	(224, 1037, 1, '2026-02-24 19:04:35.860789-06'),
	(225, 1038, 1, '2026-02-24 19:04:35.861204-06'),
	(226, 1039, 1, '2026-02-24 19:04:35.861602-06'),
	(227, 1040, 1, '2026-02-24 19:04:35.862-06'),
	(228, 1041, 1, '2026-02-24 19:04:35.862441-06'),
	(229, 1042, 1, '2026-02-24 19:04:35.863091-06'),
	(230, 1043, 1, '2026-02-24 19:04:35.863572-06');


--
-- Data for Name: tipos_datos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tipos_datos OVERRIDING SYSTEM VALUE VALUES
	(1, 'archivo', 'file', 'archivos que se guardan en disco con formato .mp3 (primeras pruebas)'),
	(2, 'enlace', 'link', 'enlaces extraidos de otros sitios (por definir)');


--
-- Data for Name: ts_modelos; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Name: calibracion_cl_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.calibracion_cl_id_seq', 1, false);


--
-- Name: canciones_evaluadas_ce_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.canciones_evaluadas_ce_id_seq', 1043, true);


--
-- Name: playlists_pl_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.playlists_pl_id_seq', 1, true);


--
-- Name: rel_playlists_canciones_pc_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rel_playlists_canciones_pc_id_seq', 230, true);


--
-- Name: tipos_datos_td_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tipos_datos_td_id_seq', 2, true);


--
-- Name: ts_modelos_ts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ts_modelos_ts_id_seq', 1, false);


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

