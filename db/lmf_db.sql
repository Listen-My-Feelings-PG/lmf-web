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
    cl_ts_prediccion numeric(2,10),
    cl_user_score integer NOT NULL,
    cl_ts_config_epocas integer NOT NULL
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
    ca_ts_prediccion numeric,
    ca_train_level_global integer DEFAULT 0 NOT NULL
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
    ts_perdida numeric(8,6) DEFAULT '0'::numeric NOT NULL,
    ts_presicion numeric(5,4) DEFAULT '0'::numeric NOT NULL,
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
	(826, NULL, 3322812, '[Hatsune Miku] That Rich Guy is a Tetromino - tadanoco English subs [Ik8DHj5zcrs].mp3', 0, 1, B'1', NULL, NULL, 0),
	(827, NULL, 4347135, '[Rin Kagamine and Miku Hatsune] Cold Back (English Subs) [HGtUmG1v9no].mp3', 0, 1, B'1', NULL, NULL, 0),
	(828, NULL, 3612810, '┗_∵_┓ヤキモチの答え-another story-／HoneyWorks feat.初音ミク [Qlkezcz3tt4].mp3', 0, 1, B'1', NULL, NULL, 0),
	(829, NULL, 3862228, '┗_∵_┓吉田、家出するってよ／HoneyWorks feat.初音ミク [fd0uHUAy6TU].mp3', 0, 1, B'1', NULL, NULL, 0),
	(830, NULL, 1945642, '┗_∵_┓第三次プリン戦争　／　HoneyWorks feat.初音ミク、GUMI [A_zZ4SY0kp0].mp3', 0, 1, B'1', NULL, NULL, 0),
	(831, NULL, 4103244, '「キズ」 - KEI feat.初音ミク [D9UFIFujRyo].mp3', 0, 1, B'1', NULL, NULL, 0),
	(832, NULL, 2959411, '【2013-05-01 _ Carlos Hakamada(debut)】 タイムトラベラー！(Time traveller_)- MIKU(original)_カルロス袴田(music) [udobYRGEeNg].mp3', 0, 1, B'1', NULL, NULL, 0),
	(833, NULL, 4179634, '【Hatsune Miku】 【L】ucy【Eve】【Original MV】 [49c4aO99Etg].mp3', 0, 1, B'1', NULL, NULL, 0),
	(835, NULL, 4006520, '【Hatsune Miku】Lost My Love【Original Song】 [Hg0xobCxaI8].mp3', 0, 1, B'1', NULL, NULL, 0),
	(836, NULL, 4427473, '【Miku·GUMI·Lily·Iroha】「Violet Blue Fantasy ～Fantasy of Iolite～」【Sub Español】 [d86r3_HR5kw].mp3', 0, 1, B'1', NULL, NULL, 0),
	(837, NULL, 6215701, '【MIKU】Bianca [8a3lVn8rzmA].mp3', 0, 1, B'1', NULL, NULL, 0),
	(838, NULL, 2871204, '【MV】現代ササクレ概論／なすP feat. 初音ミク (Modern Hangnail Outline／Nasu feat. Miku Hatsune) [OEXZ5Ml4vKk].mp3', 0, 1, B'1', NULL, NULL, 0),
	(839, NULL, 2495759, '【MV】絶望の砂漠／なすP feat. 初音ミク (Desert of Despair／Nasu feat. Miku Hatsune) [rDL6huvbJM0].mp3', 0, 1, B'1', NULL, NULL, 0),
	(840, NULL, 6059129, '【SKEW】カノジョの選択肢と独りぼっちの北の空【PSGOZ】 [Ei22xcvPXy8].mp3', 0, 1, B'1', NULL, NULL, 0),
	(841, NULL, 5422033, '【VOCALOID_IA】_ 午前４時の金星 _ AM4 Venus _ by Ashin Kuroda [Zhc9onqv-QM].mp3', 0, 1, B'1', NULL, NULL, 0),
	(842, NULL, 4147173, '【_years_ 5_12】May【初音ミクDarkオリジナルPV】 [wxXQJBMeW94].mp3', 0, 1, B'1', NULL, NULL, 0),
	(843, NULL, 5339349, '【ミクAPPENDsolid】僕の一部【オリジナルPV】 [Po-oRnoT-ts].mp3', 0, 1, B'1', NULL, NULL, 0),
	(844, NULL, 5812731, '【初音ミク - Hatsune Miku】your anniversary【PV subs】 [rUd8zvq63Ro] (1).mp3', 0, 1, B'1', NULL, NULL, 0),
	(845, NULL, 5812731, '【初音ミク - Hatsune Miku】your anniversary【PV subs】 [rUd8zvq63Ro] (2).mp3', 0, 1, B'1', NULL, NULL, 0),
	(846, NULL, 5812731, '【初音ミク - Hatsune Miku】your anniversary【PV subs】 [rUd8zvq63Ro].mp3', 0, 1, B'1', NULL, NULL, 0),
	(847, NULL, 5063310, '【初音ミク - Hatsune Miku】ウタヲウタエ - Uta o Utae - Sing a Song【PV subs】 [j_AtIAPeIsU].mp3', 0, 1, B'1', NULL, NULL, 0),
	(848, NULL, 4205575, '【初音ミク - Hatsune Miku】心の片隅に - Kokoro no Katasumi ni【subs】 [p6cQU2bQitU].mp3', 0, 1, B'1', NULL, NULL, 0),
	(849, NULL, 4790748, '【初音ミクAppend】miss you【中文字幕】 [MrVuRQHJhYs].mp3', 0, 1, B'1', NULL, NULL, 0),
	(873, NULL, 5009650, 'サテライト [h3bNut-SVpg].mp3', 0, 1, B'1', NULL, NULL, 0),
	(850, NULL, 4513925, '【初音ミクAppend】Quiet【オリジナル曲】 [fihI7EuO0eA].mp3', 0, 1, B'1', NULL, NULL, 0),
	(851, NULL, 5377606, '【初音ミクDark】ゆらゆら English and romaji subs [04fGKdznrkw].mp3', 0, 1, B'1', NULL, NULL, 0),
	(852, NULL, 5016696, '【初音ミクdark】シロツメクサの花冠 【オリジナル】 [rwXpIeZm-Sc].mp3', 0, 1, B'1', NULL, NULL, 0),
	(853, NULL, 4837996, '【初音ミクDark】ループ・ループ・ループ【オリジナル】 [wpV2EbPYnrY].mp3', 0, 1, B'1', NULL, NULL, 0),
	(854, NULL, 3566009, '【初音ミク】 名無しの詩 【オリジナル曲】 [2ZayXb8YfyY].mp3', 0, 1, B'1', NULL, NULL, 0),
	(855, NULL, 3899633, '【初音ミク】 幻奏サティスファクション 【オリジナル曲】 [RHqTWidK9DE].mp3', 0, 1, B'1', NULL, NULL, 0),
	(856, NULL, 4083751, '【初音ミク】 心音 【オリジナル曲】 [EztEXXCheSk].mp3', 0, 1, B'1', NULL, NULL, 0),
	(857, NULL, 5568544, '【初音ミク】Calla Soiled - 虚構の光【オリジナル曲】 [FiukeDh9WKo].mp3', 0, 1, B'1', NULL, NULL, 0),
	(858, NULL, 3899541, '【初音ミク】Oriental Cybernetic QT Girl【SUB ENG_ITA】 [mCPH4OGATq8].mp3', 0, 1, B'1', NULL, NULL, 0),
	(859, NULL, 4809098, '【初音ミク】Twinkle Days【オリジナル曲PV】 [m9DTGxCT5-0].mp3', 0, 1, B'1', NULL, NULL, 0),
	(860, NULL, 3683148, '【初音ミク】　 オトシメセルフ 　【オリジナル曲】 [hTQKJQWMQ-4].mp3', 0, 1, B'1', NULL, NULL, 0),
	(861, NULL, 3559505, '【初音ミク】　曇りのち腐乱臭　【オリジナルPV】 [kKtLt901HDw].mp3', 0, 1, B'1', NULL, NULL, 0),
	(862, NULL, 5609899, '【初音ミク】わたしと君とを繋ぐもの【オリジナル】 [IKOookjqXhU].mp3', 0, 1, B'1', NULL, NULL, 0),
	(863, NULL, 5612525, '【初音ミク】ゲーセン上のアリア【オリジナル曲】 [PEHddBaJyUA].mp3', 0, 1, B'1', NULL, NULL, 0),
	(864, NULL, 3072887, '【初音ミク】ムラサキ【オリジナル曲PV付】 [omYEruBpSM8].mp3', 0, 1, B'1', NULL, NULL, 0),
	(865, NULL, 3016114, '【初音ミク】夢で逢いましょう【オリジナル】 [YI492W4Qb3g].mp3', 0, 1, B'1', NULL, NULL, 0),
	(866, NULL, 3491991, '【初音ミク】天空の六分儀【オリジナルMV】 [x0_e0yQZibY].mp3', 0, 1, B'1', NULL, NULL, 0),
	(817, 0, 3024424, 'ATOLS - LAST SIGNAL feat. Hatsune Miku _ ラストシグナル feat. 初音ミク [d2M3z797sQ8].mp3', 0, 1, B'1', NULL, NULL, 0),
	(819, 0, 6655813, 'Calla Soiled - 亜 [tqI5vcYYQY0].mp3', 0, 1, B'1', NULL, NULL, 0),
	(818, 0, 4057727, 'Blindness (feat. 初音ミク) [nlLGzmErKWE].mp3', 0, 1, B'1', NULL, NULL, 0),
	(820, 0, 4548609, 'EXLIUM - EXLIUM feat. Miku [06KskCU_d-M].mp3', 0, 1, B'1', NULL, NULL, 0),
	(823, 0, 4163060, 'Koi wa Maboroshi de Ai wa Karamawari _ Nashimoto Ui (恋は幻で愛は空回り_梨本うい) [CfUZYBL6pr0].mp3', 0, 1, B'1', NULL, NULL, 0),
	(824, 0, 5785319, 'Reality _ Dog tails feat. Miku [MMDPV] [UPhsMAdDGfM].mp3', 0, 1, B'1', NULL, NULL, 0),
	(822, 0, 4173522, 'Kikuo feat. Hatsune Miku - Shimizu Curry Song [English Subbed] [Q2P76nOpeDs].mp3', 0, 1, B'1', NULL, NULL, 0),
	(821, 0, 5228556, 'float (feat. 初音ミク) [gKWxuB14zOQ].mp3', 0, 1, B'1', NULL, NULL, 0),
	(815, 0, 3325418, '(Reprint) 小悪魔笑顔とワガママボディー【初音ﾐｸﾀﾞﾖｰ オリジナルPV】 [ErksldUjSUI].mp3', 0, 1, B'1', NULL, NULL, 0),
	(834, 1, 3150189, '【Hatsune Miku】 たのしい逃避行 [5Tef_SSOe40].mp3', 0, 1, B'1', NULL, NULL, 0),
	(825, 0, 6771075, 'sasakure.UK - Spider Thread Monopoly feat. Hatsune Miku  蜘蛛糸モノポリー.mp3', 0, 1, B'1', NULL, NULL, 0),
	(867, NULL, 4512043, '【初音ミク】祝祭と流転 English and romaji subs [ieEk2hXFkOw].mp3', 0, 1, B'1', NULL, NULL, 0),
	(868, NULL, 5434338, '【初音ミクオリジナル】リダクト [A9JripMnIMc].mp3', 0, 1, B'1', NULL, NULL, 0),
	(869, NULL, 4647758, '【初音ミク・VY1V3】PROGRAM BREAKER【オリジナルPV】 [NIDa7HqGqc4].mp3', 0, 1, B'1', NULL, NULL, 0),
	(870, NULL, 4765562, '【初音ミク（ぐにょ）】福寿草【作曲してみた】 [15HNvDg0Gq4].mp3', 0, 1, B'1', NULL, NULL, 0),
	(871, NULL, 4586189, 'とあ - 飛行機雲 - ft.初音ミク ( Toa - Contrail - ft.Hatsune Miku ) [RHCoZroZySA].mp3', 0, 1, B'1', NULL, NULL, 0),
	(872, NULL, 4753744, 'キャラメルティアドロップ_初音ミク [d4qecYvfWgw].mp3', 0, 1, B'1', NULL, NULL, 0),
	(874, NULL, 4771135, 'ピノキオピー - ゲームスペクター2 feat. 初音ミク _ Game Specter 2 [OfXUHMYccu4].mp3', 0, 1, B'1', NULL, NULL, 0),
	(875, NULL, 4298997, 'ミルキーオンザクレープ [hdoG6pvGxA0].mp3', 0, 1, B'1', NULL, NULL, 0),
	(876, NULL, 3853027, '初音ミクオリジナル曲 「PYX」中日字幕 [36UirlGT-iY].mp3', 0, 1, B'1', NULL, NULL, 0),
	(877, NULL, 3956089, '唸る刃と群青正義 [aSp3DvQS7BI].mp3', 0, 1, B'1', NULL, NULL, 0),
	(878, NULL, 3749064, '徒花満ちて _ ふる feat. 初音ミク [LRCKlcAECQ4].mp3', 0, 1, B'1', NULL, NULL, 0),
	(879, NULL, 7472180, '微熱の微笑み、微少女は微かに微睡ーム [FYTsVgSO-ms].mp3', 0, 1, B'1', NULL, NULL, 0),
	(880, NULL, 4468974, '恋人一首 _ 初音ミク [f7vloBZBp6c].mp3', 0, 1, B'1', NULL, NULL, 0),
	(881, NULL, 5130954, '明日も良い日になるでしょう (feat. IA＆初音ミク) [fHhV6tz2_Rs].mp3', 0, 1, B'1', NULL, NULL, 0),
	(882, NULL, 3489005, '最憂間で君は [fmbOTo1t1dk].mp3', 0, 1, B'1', NULL, NULL, 0),
	(883, NULL, 4643130, '洗濯　（初音ミクAppend） [yargFkG0q0o] (1).mp3', 0, 1, B'1', NULL, NULL, 0),
	(884, NULL, 4643130, '洗濯　（初音ミクAppend） [yargFkG0q0o].mp3', 0, 1, B'1', NULL, NULL, 0),
	(885, NULL, 2156993, '第1話　予測の先にカノジョは走馬灯を見るか PSGO-Z【SKEW PV】 [Ih6NBS9OcPo].mp3', 0, 1, B'1', NULL, NULL, 0),
	(886, NULL, 4240510, '雀色コンデンサ [Rh3XRrvzl50].mp3', 0, 1, B'1', NULL, NULL, 0),
	(887, NULL, 3885563, '霞む森 _ 初音ミク＆GUMI [5UIfTqACqJ8] (1).mp3', 0, 1, B'1', NULL, NULL, 0),
	(888, NULL, 3885563, '霞む森 _ 初音ミク＆GUMI [5UIfTqACqJ8].mp3', 0, 1, B'1', NULL, NULL, 0),
	(814, 0, 3658842, '(Reprint) 初音ミク『アンダー・プリテンダー』オリジナル [A2zTCOY-uPI].mp3', 0, 1, B'1', NULL, NULL, 0),
	(816, 0, 3851200, 'After that feat. Hatsune Miku [xRoF-MAJ5O8].mp3', 0, 1, B'1', NULL, NULL, 0);


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
	(75, 888, 1, '2026-02-22 22:25:21.948495-06');


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

SELECT pg_catalog.setval('public.canciones_evaluadas_ce_id_seq', 888, true);


--
-- Name: playlists_pl_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.playlists_pl_id_seq', 1, true);


--
-- Name: rel_playlists_canciones_pc_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rel_playlists_canciones_pc_id_seq', 75, true);


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

