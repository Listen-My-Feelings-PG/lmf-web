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
    ca_id_tipodato integer NOT NULL,
    ca_activo bit(1) DEFAULT '1'::"bit" NOT NULL,
    ca_metadata text,
    ca_ts_prediccion numeric(6,5),
    ca_train_level_global integer DEFAULT 0 NOT NULL,
    ca_ts_features_filename text,
    ca_youtube_link text,
    ca_us_id integer
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
-- Name: entrenamientos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.entrenamientos (
    en_id integer NOT NULL,
    en_id_cancion integer NOT NULL,
    en_is_fine_tuning bit(1) DEFAULT '0'::"bit" NOT NULL,
    en_id_modelo integer NOT NULL,
    en_fecha timestamp with time zone DEFAULT now() NOT NULL,
    en_calif_usuario integer NOT NULL,
    en_ts_epocas integer NOT NULL,
    en_ts_loss numeric(10,5) NOT NULL,
    en_ts_batch_size text NOT NULL,
    en_ts_validation_split numeric(6,3) NOT NULL,
    en_ts_mae numeric(10,5) NOT NULL
);


ALTER TABLE public.entrenamientos OWNER TO postgres;

--
-- Name: entrenamientos_en_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.entrenamientos ALTER COLUMN en_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.entrenamientos_en_id_seq
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
    pl_is_default bit(1) DEFAULT '0'::"bit" NOT NULL,
    pl_us_id integer
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
-- Name: predicciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.predicciones (
    pd_id integer NOT NULL,
    pd_id_cancion integer NOT NULL,
    pd_id_modelo integer NOT NULL,
    pd_fecha timestamp with time zone DEFAULT now() NOT NULL,
    pd_ts_prediccion numeric(6,5) NOT NULL,
    pd_user_score integer,
    pd_accuracy numeric(6,3),
    pd_id_last_fit integer NOT NULL
);


ALTER TABLE public.predicciones OWNER TO postgres;

--
-- Name: predicciones_pd_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.predicciones ALTER COLUMN pd_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.predicciones_pd_id_seq
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
-- Name: usuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuarios (
    us_id integer NOT NULL,
    us_username text NOT NULL,
    us_password text NOT NULL,
    us_activo bit(1) DEFAULT '1'::"bit" NOT NULL
);


ALTER TABLE public.usuarios OWNER TO postgres;

--
-- Name: usuarios_us_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.usuarios ALTER COLUMN us_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.usuarios_us_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Data for Name: canciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.canciones OVERRIDING SYSTEM VALUE VALUES
	(1150, 0, 8218889, 'Taisetsunakoto (feat. Hatsune Miku, Kagamine Rin, Kagamine Len, Megurine Luka, KAITO, MEIKO &... (128kbit_AAC).mp3', 1, B'1', NULL, 0.67620, 1, 'features_1150.npy', NULL, NULL),
	(857, 0, 5568544, '【初音ミク】Calla Soiled - 虚構の光【オリジナル曲】 [FiukeDh9WKo].mp3', 1, B'1', NULL, 1.40552, 1, 'features_857.npy', NULL, NULL),
	(832, 0, 2959411, '【2013-05-01 _ Carlos Hakamada(debut)】 タイムトラベラー！(Time traveller_)- MIKU(original)_カルロス袴田(music) [udobYRGEeNg].mp3', 1, B'1', NULL, 0.12534, 1, 'features_832.npy', NULL, NULL),
	(947, 1, 6458068, 'livetune   never ende.mp3', 1, B'1', NULL, 1.21966, 1, 'features_947.npy', NULL, NULL),
	(848, 0, 4205575, '【初音ミク - Hatsune Miku】心の片隅に - Kokoro no Katasumi ni【subs】 [p6cQU2bQitU].mp3', 1, B'1', NULL, 0.29862, 1, 'features_848.npy', NULL, NULL),
	(858, 0, 3899541, '【初音ミク】Oriental Cybernetic QT Girl【SUB ENG_ITA】 [mCPH4OGATq8].mp3', 1, B'1', NULL, 1.12838, 1, 'features_858.npy', NULL, NULL),
	(1098, 0, 4091869, '初音ミクキマシメ少女のアカルイ未来計画オリジナルMV付き.mp3', 1, B'1', NULL, 0.26832, 1, 'features_1098.npy', NULL, NULL),
	(984, 1, 5286947, '【Kagamine Rin V4X】 Hop! Step! Instant Death! A Happiness Dance Death Trap 【VOCALOID Cover�.mp3', 1, B'1', NULL, 0.53582, 1, 'features_984.npy', NULL, NULL),
	(1041, 2, 4048736, '空海月 - -STL001- MIKUHOP LP - 08 チョコレートサンデー [nt8RupYeHlc].mp3', 1, B'1', NULL, 1.93114, 1, 'features_1041.npy', NULL, NULL),
	(991, 1, 3551772, '【初音ミクSweet】街路灯を横切って English and romaji subs [CKqpXsny5W0].mp3', 1, B'1', NULL, 0.44190, 1, 'features_991.npy', NULL, NULL),
	(874, 0, 4771135, 'ピノキオピー - ゲームスペクター2 feat. 初音ミク _ Game Specter 2 [OfXUHMYccu4].mp3', 1, B'1', NULL, 0.72218, 1, 'features_874.npy', NULL, NULL),
	(988, 3, 5142658, '【公式】アイシテ  とあ feat 初音ミク　  LOVE ME  toa feat Hatsune Miku.mp3', 1, B'1', NULL, 2.97378, 1, 'features_988.npy', NULL, NULL),
	(840, 0, 6059129, '【SKEW】カノジョの選択肢と独りぼっちの北の空【PSGOZ】 [Ei22xcvPXy8].mp3', 1, B'1', NULL, 1.69161, 1, 'features_840.npy', NULL, NULL),
	(997, 2, 3340929, '【初音ミク】 だんだん早くなる Getting Faster and Faster【オリジナル�.mp3', 1, B'1', NULL, 1.78327, 1, 'features_997.npy', NULL, NULL),
	(1026, 2, 4160129, '初音ミク Project Diva f 2nd  nanou  Hatsune Miku  Glory 3usi9  Best of nanou (high volume).mp3', 1, B'1', NULL, 1.87652, 1, 'features_1026.npy', NULL, NULL),
	(1032, 2, 5216312, '初音ミクリンレンルカ夢の続きオリジナル中文字幕.mp3', 1, B'1', NULL, 1.45299, 1, 'features_1032.npy', NULL, NULL),
	(1078, 0, 3481810, 'ピノキオピー - ストレンジアニマル feat. 初音ミク鏡音リン  Strange Animal.mp3', 1, B'1', NULL, 0.66839, 1, 'features_1078.npy', NULL, NULL),
	(842, 0, 4147173, '【_years_ 5_12】May【初音ミクDarkオリジナルPV】 [wxXQJBMeW94].mp3', 1, B'1', NULL, 1.03026, 1, 'features_842.npy', NULL, NULL),
	(1107, 0, 2860890, '四ツ谷さんによろしく.mp3', 1, B'1', NULL, 0.45254, 1, 'features_1107.npy', NULL, NULL),
	(1108, 0, 2518572, '天音サクラAlien初音ミク.mp3', 1, B'1', NULL, 0.11086, 1, 'features_1108.npy', NULL, NULL),
	(895, 1, 8460849, '03 ワールズエンド・ダンスホール.mp3', 1, B'1', NULL, 1.76421, 1, 'features_895.npy', NULL, NULL),
	(901, 2, 8783761, '09 ☆Fighting Pose☆.mp3', 1, B'1', NULL, 1.73258, 1, 'features_901.npy', NULL, NULL),
	(889, 1, 3250232, '- Ranaエレクトロサチュレイタ ElectrosaturatorVSQx.mp3', 1, B'1', NULL, 1.61508, 1, 'features_889.npy', NULL, NULL),
	(838, 0, 2871204, '【MV】現代ササクレ概論／なすP feat. 初音ミク (Modern Hangnail Outline／Nasu feat. Miku Hatsune) [OEXZ5Ml4vKk].mp3', 1, B'1', NULL, 0.79124, 1, 'features_838.npy', NULL, NULL),
	(864, 0, 3072887, '【初音ミク】ムラサキ【オリジナル曲PV付】 [omYEruBpSM8].mp3', 1, B'1', NULL, 1.24297, 1, 'features_864.npy', NULL, NULL),
	(839, 0, 2495759, '【MV】絶望の砂漠／なすP feat. 初音ミク (Desert of Despair／Nasu feat. Miku Hatsune) [rDL6huvbJM0].mp3', 1, B'1', NULL, 0.50145, 1, 'features_839.npy', NULL, NULL),
	(1122, 0, 3219681, '【公式】 テレストテレス／かいりきベア feat.初音ミク (128kbit_AAC).mp3', 1, B'1', NULL, 1.21278, 1, 'features_1122.npy', NULL, NULL),
	(1093, 0, 4588623, '初音ミクTearsオリジナルMV (1).mp3', 1, B'1', NULL, 0.42260, 1, 'features_1093.npy', NULL, NULL),
	(872, 0, 4753744, 'キャラメルティアドロップ_初音ミク [d4qecYvfWgw].mp3', 1, B'1', NULL, 0.36358, 1, 'features_872.npy', NULL, NULL),
	(941, 1, 4503295, 'Hatsune Miku Two Faced Lovers.mp3', 1, B'1', NULL, 1.19816, 1, 'features_941.npy', NULL, NULL),
	(869, 0, 4647758, '【初音ミク・VY1V3】PROGRAM BREAKER【オリジナルPV】 [NIDa7HqGqc4].mp3', 1, B'1', NULL, 0.56068, 1, 'features_869.npy', NULL, NULL),
	(897, 2, 9410964, '04 彼方まで虹を架けて.mp3', 1, B'1', NULL, 1.97754, 1, 'features_897.npy', NULL, NULL),
	(970, 2, 6314499, 'White Dove with English  Romaji Sub  Hatsune Miku  ハト  sm2583719  HQ.mp3', 1, B'1', NULL, 1.71259, 1, 'features_970.npy', NULL, NULL),
	(1091, 0, 7071877, '初音ミクidiolectオリシナル.mp3', 1, B'1', NULL, 0.42899, 1, 'features_1091.npy', NULL, NULL),
	(1092, 0, 4024965, '初音ミクLast Time to Sayオリジナル.mp3', 1, B'1', NULL, 0.27369, 1, 'features_1092.npy', NULL, NULL),
	(1187, 0, 5175796, 'クレイジー・ビート (128kbit_AAC).mp3', 1, B'1', NULL, 0.94522, 1, 'features_1187.npy', NULL, NULL),
	(1028, 1, 3597881, '初音ミク　オリジナル曲　『アンダワ』.mp3', 1, B'1', NULL, 1.82217, 1, 'features_1028.npy', NULL, NULL),
	(1106, 0, 3442266, '君が君がfeat. 初音ミク.mp3', 1, B'1', NULL, 0.45951, 1, 'features_1106.npy', NULL, NULL),
	(985, 1, 5549634, '【Robo feat 初音ミク】 SKY HIGHWAY【オリジナル曲�.mp3', 1, B'1', NULL, 0.75565, 1, 'features_985.npy', NULL, NULL),
	(1063, 0, 4290415, 'Vivid Wave feat. Hatsune Miku.mp3', 1, B'1', NULL, 0.74552, 1, 'features_1063.npy', NULL, NULL),
	(1064, 0, 2707053, 'VOCALOIDBox of MadenMETALDUBSTEP.mp3', 1, B'1', NULL, 0.08046, 1, 'features_1064.npy', NULL, NULL),
	(903, 3, 9631379, '09 ツユメロ.mp3', 1, B'1', NULL, 2.96273, 1, 'features_903.npy', NULL, NULL),
	(879, 0, 7472180, '微熱の微笑み、微少女は微かに微睡ーム [FYTsVgSO-ms].mp3', 1, B'1', NULL, 1.00723, 1, 'features_879.npy', NULL, NULL),
	(932, 2, 4239123, 'Equation.mp3', 1, B'1', NULL, 1.89141, 1, 'features_932.npy', NULL, NULL),
	(1146, 1, 3877755, 'MASA WORKS DESIGN ft.初音ミク&GUMI - BRASS NOISE FLAMENCO (128kbit_AAC).mp3', 1, B'1', NULL, 1.54228, 1, 'features_1146.npy', NULL, NULL),
	(854, 0, 3566009, '【初音ミク】 名無しの詩 【オリジナル曲】 [2ZayXb8YfyY].mp3', 1, B'1', NULL, 0.83764, 1, 'features_854.npy', NULL, NULL),
	(924, 2, 5743358, 'DECO27   ハートアラモード feat 初音ミ�.mp3', 1, B'1', NULL, 1.90361, 1, 'features_924.npy', NULL, NULL),
	(1100, 0, 4370093, '初音ミクホシゾラレインオリジナルMV付き.mp3', 1, B'1', NULL, 1.30629, 1, 'features_1100.npy', NULL, NULL),
	(1105, 0, 2331126, '初音ロックンロールアイラヴド [Mu-fullauto].mp3', 1, B'1', NULL, 0.20879, 1, 'features_1105.npy', NULL, NULL),
	(1166, 1, 5916732, 'どぅーまいべすと！ (feat. 音街ウナ) (128kbit_AAC).mp3', 1, B'1', NULL, 1.78292, 1, 'features_1166.npy', NULL, NULL),
	(1017, 2, 5887554, 'みきとP Hoi MV.mp3', 1, B'1', NULL, 1.68097, 1, 'features_1017.npy', NULL, NULL),
	(835, 2, 4006520, '【Hatsune Miku】Lost My Love【Original Song】 [Hg0xobCxaI8].mp3', 1, B'1', NULL, 1.77329, 1, 'features_835.npy', NULL, NULL),
	(929, 1, 5673768, 'Dream Chase.mp3', 1, B'1', NULL, 1.10149, 1, 'features_929.npy', NULL, NULL),
	(1065, 0, 4244644, 'VOCALOIDflower of sorrow初音ミク (1).mp3', 1, B'1', NULL, 1.30937, 1, 'features_1065.npy', NULL, NULL),
	(1031, 1, 5332086, '初音ミクメイウェンティーオリジナルPV.mp3', 1, B'1', NULL, 1.16482, 1, 'features_1031.npy', NULL, NULL),
	(833, 0, 4179634, '【Hatsune Miku】 【L】ucy【Eve】【Original MV】 [49c4aO99Etg].mp3', 1, B'1', NULL, 1.34707, 1, 'features_833.npy', NULL, NULL),
	(1004, 1, 5194160, '【初音ミク】　表面張力　【オリジナル�.mp3', 1, B'1', NULL, 1.56690, 1, 'features_1004.npy', NULL, NULL),
	(908, 3, 5303487, '16 スイートマジック.mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1077, 0, 3845987, 'ニカソヒテキ 初音ミク.mp3', 1, B'1', NULL, 1.78972, 1, 'features_1077.npy', NULL, NULL),
	(814, 0, 3658842, '(Reprint) 初音ミク『アンダー・プリテンダー』オリジナル [A2zTCOY-uPI].mp3', 1, B'1', NULL, 1.22629, 1, 'features_814.npy', NULL, NULL),
	(1191, 0, 5286623, 'スチールワンダー (128kbit_AAC).mp3', 1, B'1', NULL, 1.20572, 1, 'features_1191.npy', NULL, NULL),
	(875, 0, 4298997, 'ミルキーオンザクレープ [hdoG6pvGxA0].mp3', 1, B'1', NULL, 1.14052, 1, 'features_875.npy', NULL, NULL),
	(1199, 0, 5174992, 'ディザーチューン ／ DIVELA feat.初音ミク (128kbit_AAC).mp3', 1, B'1', NULL, 0.55525, 4, 'features_1199.npy', NULL, NULL),
	(1175, 0, 7347601, 'ゆらゆら／音街ウナ (128kbit_AAC).mp3', 1, B'1', NULL, 0.62028, 2, 'features_1175.npy', NULL, NULL),
	(979, 3, 5737281, '[VnSharing] Umi Yuri Kaiteitan   Hatsune Miku   Vocaloid vietsub.mp3', 1, B'1', NULL, 2.96959, 1, 'features_979.npy', NULL, NULL),
	(946, 1, 4629288, 'Landscape  初音ミク   歩く人×春�.mp3', 1, B'1', NULL, 1.56893, 1, 'features_946.npy', NULL, NULL),
	(877, 0, 3956089, '唸る刃と群青正義 [aSp3DvQS7BI].mp3', 1, B'1', NULL, 0.82103, 1, 'features_877.npy', NULL, NULL),
	(930, 1, 6799123, 'DreamerTeary Planet feat. 初音ミク.mp3', 1, B'1', NULL, 2.54759, 1, 'features_930.npy', NULL, NULL),
	(1152, 2, 5652228, 'TsunTsun (128kbit_AAC).mp3', 1, B'1', NULL, 2.01203, 1, 'features_1152.npy', NULL, NULL),
	(1067, 0, 4443069, 'VocaloidIROHADrumstepDubstep.mp3', 1, B'1', NULL, 0.32268, 1, 'features_1067.npy', NULL, NULL),
	(861, 0, 3559505, '【初音ミク】　曇りのち腐乱臭　【オリジナルPV】 [kKtLt901HDw].mp3', 1, B'1', NULL, 0.47343, 1, 'features_861.npy', NULL, NULL),
	(1062, 0, 5427546, 'Utsu-P - Poster Girl''s Prank  看板娘の悪巫山戯.mp3', 1, B'1', NULL, 0.60208, 1, 'features_1062.npy', NULL, NULL),
	(939, 1, 6269360, 'Hatsune Miku Original Song Bright City.mp3', 1, B'1', NULL, 1.31113, 1, 'features_939.npy', NULL, NULL),
	(909, 2, 6483666, '16 ローリンガール.mp3', 1, B'1', NULL, 2.55290, 1, 'features_909.npy', NULL, NULL),
	(964, 3, 5262496, 'sasakureUK x DECO27   39 feat Hatsune Miku.mp3', 1, B'1', NULL, 2.97284, 1, 'features_964.npy', NULL, NULL),
	(890, 2, 3762650, '- 初音ミクねこみみスイッチオリジナル.mp3', 1, B'1', NULL, 1.68788, 1, 'features_890.npy', NULL, NULL),
	(987, 2, 5669379, '【ミク・MAYU・がくぽ】「Ib」 forever 【オリジナルPV】.mp3', 1, B'1', NULL, 1.86779, 1, 'features_987.npy', NULL, NULL),
	(945, 2, 4775365, 'Lamaze P ft 初音ミク.mp3', 1, B'1', NULL, 1.88547, 1, 'features_945.npy', NULL, NULL),
	(940, 1, 6601010, 'Hatsune Miku Original Song.mp3', 1, B'1', NULL, 1.56854, 1, 'features_940.npy', NULL, NULL),
	(1155, 0, 4841742, 'Yin Yang Relationship (128kbit_AAC).mp3', 1, B'1', NULL, 0.96639, 2, 'features_1155.npy', NULL, NULL),
	(1173, 0, 5321468, 'ゆよゆっぺ feat.巡音ルカ-Draw(Draw) (128kbit_AAC).mp3', 1, B'1', NULL, 0.22481, 1, 'features_1173.npy', NULL, NULL),
	(1163, 0, 5119165, '【巡音ルカ】Misery【オリジナル】 (128kbit_AAC).mp3', 1, B'1', NULL, 1.81680, 1, 'features_1163.npy', NULL, NULL),
	(1181, 0, 4711085, 'ウシノヒ☆アブダクション (128kbit_AAC).mp3', 1, B'1', NULL, 1.34225, 1, 'features_1181.npy', NULL, NULL),
	(899, 2, 6143816, '08 雨のちSweet-Drops.mp3', 1, B'1', NULL, 1.78673, 1, 'features_899.npy', NULL, NULL),
	(934, 2, 7662709, 'Hand in Hand.mp3', 1, B'1', NULL, 1.94244, 1, 'features_934.npy', NULL, NULL),
	(1125, 0, 7258330, '疑神暗鬼-⁄-しーくん-feat.-flower【Official】-_128kbit_AAC_.mp3', 1, B'1', NULL, 1.40431, 1, 'features_1125.npy', NULL, NULL),
	(1059, 0, 3407566, 'Q [Mu-fullauto].mp3', 1, B'1', NULL, 0.70139, 1, 'features_1059.npy', NULL, NULL),
	(1076, 0, 3803791, 'ナレ入り君ガ空コソカナシケレHoneyWorks feat.兎眠りおん初音ミク.mp3', 1, B'1', NULL, 0.65172, 1, 'features_1076.npy', NULL, NULL),
	(1046, 0, 3912413, 'ATOLS - EYE feat. Hatsune Miku  アイ feat. 初音ミク.mp3', 1, B'1', NULL, 0.16509, 1, 'features_1046.npy', NULL, NULL),
	(1056, 1, 6417551, 'MIKUHeliosphere.mp3', 1, B'1', NULL, 1.26934, 1, 'features_1056.npy', NULL, NULL),
	(1057, 0, 3554454, 'muship - 変な子ね [Official Audio].mp3', 1, B'1', NULL, 0.79810, 1, 'features_1057.npy', NULL, NULL),
	(999, 1, 6521296, '【初音ミク】a tail of the wind【Cazオリジナル】.mp3', 1, B'1', NULL, 0.55452, 1, 'features_999.npy', NULL, NULL),
	(878, 0, 3749064, '徒花満ちて _ ふる feat. 初音ミク [LRCKlcAECQ4].mp3', 1, B'1', NULL, 0.27133, 1, 'features_878.npy', NULL, NULL),
	(853, 0, 4837996, '【初音ミクDark】ループ・ループ・ループ【オリジナル】 [wpV2EbPYnrY].mp3', 1, B'1', NULL, 1.80057, 1, 'features_853.npy', NULL, NULL),
	(1119, 0, 6162518, '【Kanzaki Iori】 That Summer is Saturating 【Kagamine Rin ・ Len】(English Sub) (128kbit_AAC).mp3', 1, B'1', NULL, 0.29009, 1, 'features_1119.npy', NULL, NULL),
	(1145, 0, 5466451, 'Last Dance (128kbit_AAC).mp3', 1, B'1', NULL, 1.81603, 1, 'features_1145.npy', NULL, NULL),
	(1038, 3, 6117641, '神のまにまに - れるりりfeat.ミク&リン&GUMI  At God''s Mercy - rerulili feat.Vocaloids.mp3', 1, B'1', NULL, 2.95745, 1, 'features_1038.npy', NULL, NULL),
	(955, 1, 5485059, 'Neo.mp3', 1, B'1', NULL, 1.58428, 1, 'features_955.npy', NULL, NULL),
	(863, 0, 5612525, '【初音ミク】ゲーセン上のアリア【オリジナル曲】 [PEHddBaJyUA].mp3', 1, B'1', NULL, 1.61838, 1, 'features_863.npy', NULL, NULL),
	(1185, 0, 5385328, 'カタストロフ (feat. 初音ミク & KAITO) (128kbit_AAC).mp3', 1, B'1', NULL, 0.85546, 1, 'features_1185.npy', NULL, NULL),
	(1045, 0, 4210080, '(Reprint) 初音ミクファーストセラピー(初投稿)オリジナル.mp3', 1, B'1', NULL, 0.33447, 1, 'features_1045.npy', NULL, NULL),
	(1134, 0, 5880397, 'Circus-P - ''I Am Here (with Mo Qingxian)'' [Vocaloid Original Song] (128kbit_AAC).mp3', 1, B'1', NULL, 1.19646, 1, 'features_1134.npy', NULL, NULL),
	(1170, 0, 4619758, 'はらぺこのルベル (128kbit_AAC).mp3', 1, B'1', NULL, 1.57061, 1, 'features_1170.npy', NULL, NULL),
	(963, 1, 5964668, 'ryuryu   Flowers featHatsune Miku 初音ミ�.mp3', 1, B'1', NULL, 2.46567, 1, 'features_963.npy', NULL, NULL),
	(925, 1, 5708877, 'DECO27   夜行性ハイズ feat 初音ミ�.mp3', 1, B'1', NULL, 1.83849, 1, 'features_925.npy', NULL, NULL),
	(1068, 0, 7352616, 'VocaloidYADA!!Moombahton.mp3', 1, B'1', NULL, 0.26911, 1, 'features_1068.npy', NULL, NULL),
	(959, 3, 6144599, 'Ordinary   ポリスピカデリー feat 初音ミク  Ordinary   Police Piccadilly feat Hatsune Mik.mp3', 1, B'1', NULL, 2.97992, 1, 'features_959.npy', NULL, NULL),
	(823, 0, 4163060, 'Koi wa Maboroshi de Ai wa Karamawari _ Nashimoto Ui (恋は幻で愛は空回り_梨本うい) [CfUZYBL6pr0].mp3', 1, B'1', NULL, 1.38819, 1, 'features_823.npy', NULL, NULL),
	(841, 0, 5422033, '【VOCALOID_IA】_ 午前４時の金星 _ AM4 Venus _ by Ashin Kuroda [Zhc9onqv-QM].mp3', 1, B'1', NULL, 0.69148, 1, 'features_841.npy', NULL, NULL),
	(1126, 0, 6474143, '稲葉曇『浮遊月光街』Vo.-歌愛ユキ-_128kbit_AAC_.mp3', 1, B'1', NULL, 1.93198, 1, 'features_1126.npy', NULL, NULL),
	(1204, 0, 4428116, 'バイオレンストリガー (128kbit_AAC).mp3', 1, B'1', NULL, 0.95703, 1, 'features_1204.npy', NULL, NULL),
	(1200, 0, 4265978, 'デレレレ (feat. Hatsune Miku) (128kbit_AAC).mp3', 1, B'1', NULL, 1.32337, 1, 'features_1200.npy', NULL, NULL),
	(1193, 0, 4968558, 'セブンティーナ (128kbit_AAC).mp3', 1, B'1', NULL, 1.50816, 1, 'features_1193.npy', NULL, NULL),
	(1218, 0, 4587699, '天泣 (128kbit_AAC).mp3', 1, B'1', NULL, 1.86951, 1, 'features_1218.npy', NULL, NULL),
	(1203, 0, 4860360, 'ニビイロドロウレ ⁄ nibiiro dolore - rin [オリジナル] (128kbit_AAC).mp3', 1, B'1', NULL, 1.62521, 1, 'features_1203.npy', NULL, NULL),
	(951, 2, 5197294, 'Melancholic  Junky ft Rin Kagamine.mp3', 1, B'1', NULL, 1.43141, 1, 'features_951.npy', NULL, NULL),
	(1205, 1, 5199971, 'ビューティフルなフィクション (128kbit_AAC).mp3', 1, B'1', NULL, 2.55523, 1, 'features_1205.npy', NULL, NULL),
	(1088, 0, 6740940, '初音ミクArigatoオリジナル.mp3', 1, B'1', NULL, 0.31654, 1, 'features_1088.npy', NULL, NULL),
	(1094, 0, 4588623, '初音ミクTearsオリジナルMV.mp3', 1, B'1', NULL, 0.42260, 1, 'features_1094.npy', NULL, NULL),
	(926, 2, 3934431, 'DECO27  愛言葉Ⅲ feat 初音ミク.mp3', 1, B'1', NULL, 1.79027, 1, 'features_926.npy', NULL, NULL),
	(1049, 0, 4634971, 'Cryogenic (feat. 初音ミク).mp3', 1, B'1', NULL, 0.78462, 1, 'features_1049.npy', NULL, NULL),
	(1050, 0, 3877272, 'Desires-はるまきごはんfeat. 初音ミク.mp3', 1, B'1', NULL, 0.88078, 1, 'features_1050.npy', NULL, NULL),
	(1123, 0, 3937292, '【公式】撥条少女時計 feat.初音ミク【オリジナル曲】 (128kbit_AAC).mp3', 1, B'1', NULL, 1.49028, 1, 'features_1123.npy', NULL, NULL),
	(933, 1, 4128127, 'Find Me feat. Hatsune Miku [P7UJeX6WE4Q].mp3', 1, B'1', NULL, 1.40149, 1, 'features_933.npy', NULL, NULL),
	(826, 0, 3322812, '[Hatsune Miku] That Rich Guy is a Tetromino - tadanoco English subs [Ik8DHj5zcrs].mp3', 1, B'1', NULL, 0.75373, 1, 'features_826.npy', NULL, NULL),
	(911, 3, 8411420, '17 Yellow.mp3', 1, B'1', NULL, 2.94839, 1, 'features_911.npy', NULL, NULL),
	(1051, 1, 4387844, 'Hatsune Miku - World on Color [Original].mp3', 1, B'1', NULL, 0.89326, 1, 'features_1051.npy', NULL, NULL),
	(1019, 2, 5233030, 'みきとP『 だいあもんど 』M.mp3', 1, B'1', NULL, 1.80736, 1, 'features_1019.npy', NULL, NULL),
	(942, 1, 8056042, 'Heavenz   アルファ.mp3', 1, B'1', NULL, 1.26415, 1, 'features_942.npy', NULL, NULL),
	(921, 1, 5121435, 'Child   初音ミク.mp3', 1, B'1', NULL, 2.13926, 1, 'features_921.npy', NULL, NULL),
	(1143, 0, 6035166, 'Haruno Sora-sensei Will Praise You Endlessly (English subs for 無限にホメてくれる桜乃そら先生) (128kbit_AAC).mp3', 1, B'1', NULL, 0.71096, 1, 'features_1143.npy', NULL, NULL),
	(1217, 0, 4330334, '唯一、愛ノ詠 ⁄ ルカミクグミIAリン (128kbit_AAC).mp3', 1, B'1', NULL, 0.92262, 1, 'features_1217.npy', NULL, NULL),
	(1081, 0, 4083676, '八王子PGAME OVER feat. 初音ミクMusic Video.mp3', 1, B'1', NULL, 1.53388, 1, 'features_1081.npy', NULL, NULL),
	(1082, 2, 4693133, '八王子PHORIZON feat. 初音ミクMusic Video.mp3', 1, B'1', NULL, 1.70284, 1, 'features_1082.npy', NULL, NULL),
	(837, 1, 6215701, '【MIKU】Bianca [8a3lVn8rzmA].mp3', 1, B'1', NULL, 0.52699, 1, 'features_837.npy', NULL, NULL),
	(1025, 1, 6081645, '初音ミク poppin'' jumpin まらしぃ kors k.mp3', 1, B'1', NULL, 1.10073, 1, 'features_1025.npy', NULL, NULL),
	(1180, NULL, 4804883, 'インヤンカンケイ - 和田たけあき (VOCALOID ver.) (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1157, 0, 2845306, '【HikkieP feat. 鏡音リン】できるできない万里の長城 (The Do''s and Don''t''s of the Great Wall)【ENGLISH SUBTITLES】 (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1182, NULL, 4725388, 'ウシノヒ☆アブダクション - cosMo＠暴走P feat. 音街ウナ (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1183, NULL, 1365555, 'エゴロック／ すりぃ feat.鏡音レン【OFFICIAL】 (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1184, NULL, 3532684, 'エロルヤ光線P ⁄ 門松円化 - 骨  (Eroruya Kousenp ⁄ Madoka Kadomatsu - Bone) (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1186, NULL, 5277779, 'カタストロフ（Catastrophe） feat.初音ミク KAITO - Dios⁄シグナルP (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1189, NULL, 5404121, 'クーロンズ・ホテル (feat. 鏡音リン & 鏡音レン) (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1117, 0, 2070747, '【HikkieP feat. 鏡音リン】できるできない万里の長城 (The Dos and Donts of the Great Wall)【ENGLISH SUBTITLES】 (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1159, NULL, 1125374, '【初音ミク】　トゥール　【オリジナル】 (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(960, 3, 4362839, 'PinocchioP (feat Hatsune Miku and Yukkuri)   Proliferation of Imamur.mp3', 1, B'1', NULL, 2.95483, 1, 'features_960.npy', NULL, NULL),
	(952, 1, 4345285, 'METEOR  DIVELA feat初音ミク.mp3', 1, B'1', NULL, 1.54866, 1, 'features_952.npy', NULL, NULL),
	(949, 2, 4201412, 'lumo - ネットチルナノグ feat. 初音ミク [fSOK6pGHI5Q].mp3', 1, B'1', NULL, 1.71405, 1, 'features_949.npy', NULL, NULL),
	(817, 0, 3024424, 'ATOLS - LAST SIGNAL feat. Hatsune Miku _ ラストシグナル feat. 初音ミク [d2M3z797sQ8].mp3', 1, B'1', NULL, 1.38806, 1, 'features_817.npy', NULL, NULL),
	(1112, 0, 3831653, '潔癖K毒滅グリモア.mp3', 1, B'1', NULL, 1.28130, 1, 'features_1112.npy', NULL, NULL),
	(1160, 0, 3507879, '【初音ミク】骨【エロルヤ光線P】2018⁄10⁄31 (128kbit_AAC).mp3', 1, B'1', NULL, 0.20881, 1, 'features_1160.npy', NULL, NULL),
	(830, 0, 1945642, '┗_∵_┓第三次プリン戦争　／　HoneyWorks feat.初音ミク、GUMI [A_zZ4SY0kp0].mp3', 1, B'1', NULL, 0.59672, 1, 'features_830.npy', NULL, NULL),
	(831, 0, 4103244, '「キズ」 - KEI feat.初音ミク [D9UFIFujRyo].mp3', 1, B'1', NULL, 1.77473, 1, 'features_831.npy', NULL, NULL),
	(873, 0, 5009650, 'サテライト [h3bNut-SVpg].mp3', 1, B'1', NULL, 1.13107, 1, 'features_873.npy', NULL, NULL),
	(1048, 0, 3935156, 'Brownie (feat. 初音ミク).mp3', 1, B'1', NULL, 0.35644, 1, 'features_1048.npy', NULL, NULL),
	(931, 1, 4121259, 'east end and bocci  feat初音ミク.mp3', 1, B'1', NULL, 1.39045, 1, 'features_931.npy', NULL, NULL),
	(1209, 0, 4978460, 'メアメア (128kbit_AAC).mp3', 1, B'1', NULL, 1.91187, 1, 'features_1209.npy', NULL, NULL),
	(888, 0, 3885563, '霞む森 _ 初音ミク＆GUMI [5UIfTqACqJ8].mp3', 1, B'1', NULL, 0.42832, 1, 'features_888.npy', NULL, NULL),
	(917, 1, 6067327, 'AOHARU.mp3', 1, B'1', NULL, 0.84907, 1, 'features_917.npy', NULL, NULL),
	(1005, 3, 5042348, '【初音ミク】アクリルスター【オリジナル】.mp3', 1, B'1', NULL, 2.97203, 1, 'features_1005.npy', NULL, NULL),
	(862, 0, 5609899, '【初音ミク】わたしと君とを繋ぐもの【オリジナル】 [IKOookjqXhU].mp3', 1, B'1', NULL, 0.71080, 1, 'features_862.npy', NULL, NULL),
	(927, 2, 6410421, 'Deco27 ft 初音ミク.mp3', 1, B'1', NULL, 2.13386, 1, 'features_927.npy', NULL, NULL),
	(1027, 1, 4944011, '初音ミク ラストペインター オリジナルMIKULast painteroriginal.mp3', 1, B'1', NULL, 1.52388, 1, 'features_1027.npy', NULL, NULL),
	(962, 1, 7012282, 'Robo feat. Hatsune Miku SPACERUN オリジナル曲.mp3', 1, B'1', NULL, 1.02501, 1, 'features_962.npy', NULL, NULL),
	(958, 1, 2856514, 'Onesided Love Samba  Hatsune Miku Traduccion.mp3', 1, B'1', NULL, 0.88681, 1, 'features_958.npy', NULL, NULL),
	(876, 0, 3853027, '初音ミクオリジナル曲 「PYX」中日字幕 [36UirlGT-iY].mp3', 1, B'1', NULL, 1.23665, 1, 'features_876.npy', NULL, NULL),
	(1131, 0, 4817976, 'bin - 音街ウナ (128kbit_AAC).mp3', 1, B'1', NULL, 1.03864, 1, 'features_1131.npy', NULL, NULL),
	(1074, 0, 5643594, 'とあ - HALO - ft.初音ミク ( Toa - HALO -  ft.Hatsune Miku ).mp3', 1, B'1', NULL, 1.08998, 1, 'features_1074.npy', NULL, NULL),
	(1071, 1, 3869657, '[附中譯]初音ミクハートフルメッセージオリジナル曲PV.mp3', 1, B'1', NULL, 1.14634, 1, 'features_1071.npy', NULL, NULL),
	(966, 1, 6155257, 'SushiP ft 初音ミク ''Align'' アライン (English Subtitles).mp3', 1, B'1', NULL, 1.89470, 1, 'features_966.npy', NULL, NULL),
	(856, 0, 4083751, '【初音ミク】 心音 【オリジナル曲】 [EztEXXCheSk].mp3', 1, B'1', NULL, 1.12211, 1, 'features_856.npy', NULL, NULL),
	(1101, 0, 2117076, '初音ミク人間失格オリジナル曲.mp3', 1, B'1', NULL, 0.66080, 1, 'features_1101.npy', NULL, NULL),
	(870, 0, 4765562, '【初音ミク（ぐにょ）】福寿草【作曲してみた】 [15HNvDg0Gq4].mp3', 1, B'1', NULL, 1.57788, 1, 'features_870.npy', NULL, NULL),
	(846, 0, 5812731, '【初音ミク - Hatsune Miku】your anniversary【PV subs】 [rUd8zvq63Ro].mp3', 1, B'1', NULL, 1.05279, 1, 'features_846.npy', NULL, NULL),
	(1158, 0, 5191600, '【初音ミク⁄鏡音レン】クレイジー・ビート【#コンパス】 (128kbit_AAC).mp3', 1, B'1', NULL, 0.60882, 1, 'features_1158.npy', NULL, NULL),
	(1197, 0, 6594463, 'ティアードクライシス … GUMI｜Tieredcrisis (128kbit_AAC).mp3', 1, B'1', NULL, 1.60769, 1, 'features_1197.npy', NULL, NULL),
	(1214, 0, 4473102, '八王子P 「バイオレンストリガー feat. 初音ミク」(#コンパス メグメグテーマソング） (128kbit_AAC).mp3', 1, B'1', NULL, 0.83699, 1, 'features_1214.npy', NULL, NULL),
	(1099, 0, 5089065, '初音ミクキミとボクまわるセカイオリジナル曲PV.mp3', 1, B'1', NULL, 0.44256, 1, 'features_1099.npy', NULL, NULL),
	(996, 1, 3347864, '【初音ミク】 Lap Tap Love 【オリジナル】_[Hatsune Miku] Lap Tap Love [Original] [yhBQfbvHmdw].mp3', 1, B'1', NULL, 1.66738, 1, 'features_996.npy', NULL, NULL),
	(822, 0, 4173522, 'Kikuo feat. Hatsune Miku - Shimizu Curry Song [English Subbed] [Q2P76nOpeDs].mp3', 1, B'1', NULL, 1.18478, 1, 'features_822.npy', NULL, NULL),
	(1118, 0, 3465855, '【Inaba Cumori ft. Kaai Yuki】Floating Moonlight City (浮遊月光街) - English Subtitles (128kbit_AAC).mp3', 1, B'1', NULL, 1.24711, 1, 'features_1118.npy', NULL, NULL),
	(1121, 2, 3411934, '【Police Piccadilly ft. Hatsune Miku】Separate «English sub» [TheBlackCero Hazuki No Yume] (128kbit_AAC).mp3', 1, B'1', NULL, 1.23474, 1, 'features_1121.npy', NULL, NULL),
	(1141, 0, 5056245, 'Don''t Return to Being a Drowned Corpse ⁄ Iyowa feat. V Flower & Hatsune Miku (English Subs) (128kbit_AAC).mp3', 1, B'1', NULL, 1.46181, 1, 'features_1141.npy', NULL, NULL),
	(1156, 0, 5527225, '∴煮ル果実「アイアルの勘違い」with Flower【Official】- A Mistaken Belief of Love (128kbit_AAC).mp3', 1, B'1', NULL, 1.03864, 1, 'features_1156.npy', NULL, NULL),
	(1052, 0, 3227552, 'Hatsune Miku, GUMI - M.S.S.Planet (Sub Eng).mp3', 1, B'1', NULL, 1.09908, 1, 'features_1052.npy', NULL, NULL),
	(1053, 0, 8530381, 'Inverse Relation (feat. 初音ミク).mp3', 1, B'1', NULL, 0.27471, 1, 'features_1053.npy', NULL, NULL),
	(1075, 0, 3927340, 'スノウドライヴ  Omoi feat. 初音ミク.mp3', 1, B'1', NULL, 1.54757, 1, 'features_1075.npy', NULL, NULL),
	(920, 2, 6536436, 'CATS RULE THE WORLD   daniwell feat Hatsune Miku  Momone Momo.mp3', 1, B'1', NULL, 1.85109, 1, 'features_920.npy', NULL, NULL),
	(1060, 0, 3550458, 'Starduster (Orchestral Ver.) - Hatsune Miku.mp3', 1, B'1', NULL, 0.11344, 1, 'features_1060.npy', NULL, NULL),
	(1061, 0, 8219614, 'TEN feat. Hatsune Miku & Kasane Teto TEN初音ミク&重音テト.mp3', 1, B'1', NULL, 0.38722, 1, 'features_1061.npy', NULL, NULL),
	(1103, 0, 3838955, '初音ミク東京レトロオリジナル曲PV付.mp3', 1, B'1', NULL, 1.19003, 1, 'features_1103.npy', NULL, NULL),
	(1013, 2, 4874421, 'あいまいクエスチョン／yamada feat初音ミク   The Quizmaste.mp3', 1, B'1', NULL, 1.96340, 1, 'features_1013.npy', NULL, NULL),
	(1115, 0, 2625772, '(FLASHING LIGHTS) Mercy Killing - iyowa ft. Hatsune Miku, flower (English Subtitles Remastered ;D) (128kbit_AAC).mp3', 1, B'1', NULL, 1.13390, 1, 'features_1115.npy', NULL, NULL),
	(972, 1, 4904932, 'yt1s.com - Far Away.mp3', 1, B'1', NULL, 1.79136, 1, 'features_972.npy', NULL, NULL),
	(821, 0, 5228556, 'float (feat. 初音ミク) [gKWxuB14zOQ].mp3', 1, B'1', NULL, 1.19187, 1, 'features_821.npy', NULL, NULL),
	(896, 1, 6794009, '04 CALL ME CALL ME.mp3', 1, B'1', NULL, 1.59079, 1, 'features_896.npy', NULL, NULL),
	(989, 1, 4176877, '【初音ミク - Hatsune Miku】Electro Saturator -Starry electro mix-【MMD-PV】 [UX4II4sy1IQ].mp3', 1, B'1', NULL, 1.39755, 1, 'features_989.npy', NULL, NULL),
	(992, 1, 4831162, '【初音ミク×アルクロ】センセーションはおわらない！ フルver【コラボオリジナル楽曲�.mp3', 1, B'1', NULL, 1.64905, 1, 'features_992.npy', NULL, NULL),
	(1084, 1, 3837517, '初音ミク A.I.210 オリジナル [Hatsune miku] A.I.210 [Official video].mp3', 1, B'1', NULL, 0.61564, 1, 'features_1084.npy', NULL, NULL),
	(1113, 0, 3802207, '花のない部屋 (feat. 初音ミク).mp3', 1, B'1', NULL, 1.39377, 1, 'features_1113.npy', NULL, NULL),
	(1010, 1, 5141020, '【初音ミク】空に花束を【オリジナル】 [4OLuVzAyYZ0].mp3', 1, B'1', NULL, 0.59197, 1, 'features_1010.npy', NULL, NULL),
	(1120, 0, 4246618, '【MV】Music Like Magic! feat. Hatsune Miku ⁄ 魔法みたいなミュージック！ feat. 初音ミク (128kbit_AAC).mp3', 1, B'1', NULL, 1.51165, 1, 'features_1120.npy', NULL, NULL),
	(1073, 0, 3736111, 'ただのCo 初音ミクアルカリ成人.mp3', 1, B'1', NULL, 1.27848, 1, 'features_1073.npy', NULL, NULL),
	(1111, 0, 3915751, '未来アタラシズム (feat. 初音ミク).mp3', 1, B'1', NULL, 1.56093, 1, 'features_1111.npy', NULL, NULL),
	(1144, 0, 2900725, 'HikkieP - できるできない万里の長城 [VOCALOID Kagamine Rin] (128kbit_AAC).mp3', 1, B'1', NULL, 0.97345, 1, 'features_1144.npy', NULL, NULL),
	(1154, 0, 1639737, 'Utsu-P - 自爆⁄Self-Destruct [Greatest Shits Ver.] (128kbit_AAC).mp3', 1, B'1', NULL, 1.12564, 1, 'features_1154.npy', NULL, NULL),
	(1169, 0, 5755031, 'ねぇ、どろどろさん YASUHIRO(康寛) feat.鏡音リン (128kbit_AAC).mp3', 1, B'1', NULL, 0.57559, 1, 'features_1169.npy', NULL, NULL),
	(1072, 0, 3011068, 'さよならワンダーノイズ.mp3', 1, B'1', NULL, 0.70234, 1, 'features_1072.npy', NULL, NULL),
	(820, 0, 4548609, 'EXLIUM - EXLIUM feat. Miku [06KskCU_d-M].mp3', 1, B'1', NULL, 0.38586, 1, 'features_820.npy', NULL, NULL),
	(1047, 0, 3615157, 'Audio-onlyえすぴあるWaroki  Hatsune Miku.mp3', 1, B'1', NULL, 0.35465, 1, 'features_1047.npy', NULL, NULL),
	(1110, 0, 3634609, '晴れのちメアリーシェーンにて (feat. 初音ミク).mp3', 1, B'1', NULL, 0.50175, 1, 'features_1110.npy', NULL, NULL),
	(954, 2, 4251662, 'Musunde Hiraite Rasetsu to Mukuro ORIGINAL.mp3', 1, B'1', NULL, 1.58192, 1, 'features_954.npy', NULL, NULL),
	(1070, 0, 4338308, 'YARUSE NAKIO - UFOが飛んでいる.mp3', 1, B'1', NULL, 0.27773, 1, 'features_1070.npy', NULL, NULL),
	(1194, NULL, 4900280, 'セブンティーナ ⁄ はるまきごはん feat.初音ミク アニメMV - Seventina (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(844, 0, 5812731, '【初音ミク - Hatsune Miku】your anniversary【PV subs】 [rUd8zvq63Ro] (1).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(845, 0, 5812731, '【初音ミク - Hatsune Miku】your anniversary【PV subs】 [rUd8zvq63Ro] (2).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1179, 0, 4892148, 'インヤンカンケイ (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(847, 0, 5063310, '【初音ミク - Hatsune Miku】ウタヲウタエ - Uta o Utae - Sing a Song【PV subs】 [j_AtIAPeIsU].mp3', 1, B'1', NULL, 0.59956, 1, 'features_847.npy', NULL, NULL),
	(852, 0, 5016696, '【初音ミクdark】シロツメクサの花冠 【オリジナル】 [rwXpIeZm-Sc].mp3', 1, B'1', NULL, 1.11591, 1, 'features_852.npy', NULL, NULL),
	(1178, 0, 5891229, 'アンチ・デジタリズム (feat. Hatsune Miku) (128kbit_AAC).mp3', 1, B'1', NULL, 0.98574, 1, 'features_1178.npy', NULL, NULL),
	(843, 0, 5339349, '【ミクAPPENDsolid】僕の一部【オリジナルPV】 [Po-oRnoT-ts].mp3', 1, B'1', NULL, 0.73712, 1, 'features_843.npy', NULL, NULL),
	(892, 2, 5561339, '01 EARTH DAY.mp3', 1, B'1', NULL, 1.52920, 1, 'features_892.npy', NULL, NULL),
	(859, 1, 4809098, '【初音ミク】Twinkle Days【オリジナル曲PV】 [m9DTGxCT5-0].mp3', 1, B'1', NULL, 1.70763, 1, 'features_859.npy', NULL, NULL),
	(1104, 1, 2527156, '初音ミク桃音モモ鏡音リンレンとてたてとてたオリジナル.mp3', 1, B'1', NULL, 0.58744, 1, 'features_1104.npy', NULL, NULL),
	(881, 1, 5130954, '明日も良い日になるでしょう (feat. IA＆初音ミク) [fHhV6tz2_Rs].mp3', 1, B'1', NULL, 1.88292, 1, 'features_881.npy', NULL, NULL),
	(1097, 0, 4572457, '初音ミクさとうささら 君キライ Reupload.mp3', 1, B'1', NULL, 0.62188, 1, 'features_1097.npy', NULL, NULL),
	(907, 2, 6677916, '13 アンダンテ.mp3', 1, B'1', NULL, 1.89780, 1, 'features_907.npy', NULL, NULL),
	(900, 2, 7637962, '09 GIFT.mp3', 1, B'1', NULL, 1.81217, 1, 'features_900.npy', NULL, NULL),
	(994, 1, 6394121, '【初音ミク】 Baby Steps 【オリジナル�.mp3', 1, B'1', NULL, 1.76902, 1, 'features_994.npy', NULL, NULL),
	(950, 1, 4374124, 'MASA WORKS DESIGN ft初音ミクu0026GUMI   BRASS NOISE FLAMENC.mp3', 1, B'1', NULL, 1.58772, 1, 'features_950.npy', NULL, NULL),
	(978, 1, 4346243, '[Subs+Lyrics] Contrast [Hatsune Miku] [O6FrUaQVqlQ].mp3', 1, B'1', NULL, 0.79494, 1, 'features_978.npy', NULL, NULL),
	(825, 0, 6771075, 'sasakure.UK - Spider Thread Monopoly feat. Hatsune Miku  蜘蛛糸モノポリー.mp3', 1, B'1', NULL, 1.77784, 1, 'features_825.npy', NULL, NULL),
	(1129, 0, 5543992, 'ATOLS - Don Gara Shan feat. Hatsune Miku ⁄ ドンガラシャン feat. 初音ミク (128kbit_AAC).mp3', 1, B'1', NULL, 1.89071, 1, 'features_1129.npy', NULL, NULL),
	(1128, 0, 4198554, '404：虚像■初音ミク_オリジナル (128kbit_AAC).mp3', 1, B'1', NULL, 1.70692, 1, 'features_1128.npy', NULL, NULL),
	(1114, 3, 5132257, '[1080P Full] Sweet Magic スイートマジック - Kagamine Rin 鏡音リン Project DIVA English Romaji PDA FT.mp3', 1, B'1', NULL, 2.97160, 1, 'features_1114.npy', NULL, NULL),
	(865, 0, 3016114, '【初音ミク】夢で逢いましょう【オリジナル】 [YI492W4Qb3g].mp3', 1, B'1', NULL, 0.97449, 1, 'features_865.npy', NULL, NULL),
	(1086, 0, 5875460, '初音ミク もう やめちゃってもいい かなァ 人生オリジナル.mp3', 1, B'1', NULL, 1.03814, 1, 'features_1086.npy', NULL, NULL),
	(986, 1, 6716994, '【オリジナルMV】ユメノアメ feat初音ミク  ドッシ�.mp3', 1, B'1', NULL, 1.77209, 1, 'features_986.npy', NULL, NULL),
	(1006, 1, 8406594, '【初音ミク】アネモネ【オリジナル】.mp3', 1, B'1', NULL, 1.89499, 1, 'features_1006.npy', NULL, NULL),
	(980, 1, 7771505, '[VOCALOID] Sailing  初音ミク [公式.mp3', 1, B'1', NULL, 0.77997, 1, 'features_980.npy', NULL, NULL),
	(976, 2, 6832978, '[Music] Livetune (feat Hatsune Miku)   Redia.mp3', 1, B'1', NULL, 2.42352, 1, 'features_976.npy', NULL, NULL),
	(827, 0, 4347135, '[Rin Kagamine and Miku Hatsune] Cold Back (English Subs) [HGtUmG1v9no].mp3', 1, B'1', NULL, 1.02182, 1, 'features_827.npy', NULL, NULL),
	(1219, 0, 6649463, '幾望の月 (128kbit_AAC).mp3', 1, B'1', NULL, 1.73471, 1, 'features_1219.npy', NULL, NULL),
	(967, 2, 9821039, 'triple baka - miku hatsune.mp3', 1, B'1', NULL, 1.83010, 1, 'features_967.npy', NULL, NULL),
	(816, 0, 3851200, 'After that feat. Hatsune Miku [xRoF-MAJ5O8].mp3', 1, B'1', NULL, 1.40290, 1, 'features_816.npy', NULL, NULL),
	(1024, 1, 6525151, '八王子Pデスクトップシンデレラ feat. 初音ミクMusic Video.mp3', 1, B'1', NULL, 2.22416, 1, 'features_1024.npy', NULL, NULL),
	(904, 1, 5874858, '11 396.mp3', 1, B'1', NULL, 1.86758, 1, 'features_904.npy', NULL, NULL),
	(868, 0, 5434338, '【初音ミクオリジナル】リダクト [A9JripMnIMc].mp3', 1, B'1', NULL, 0.28577, 1, 'features_868.npy', NULL, NULL),
	(1124, 0, 794639, '【初音ミク】 トゥール 【オリジナル】 (128kbit_AAC).mp3', 1, B'1', NULL, 0.73488, 1, 'features_1124.npy', NULL, NULL),
	(1007, 1, 6113159, '【初音ミク】アポロ【オリジナルMMD PV】.mp3', 1, B'1', NULL, 2.06090, 1, 'features_1007.npy', NULL, NULL),
	(819, 0, 6655813, 'Calla Soiled - 亜 [tqI5vcYYQY0].mp3', 1, B'1', NULL, 0.35435, 1, 'features_819.npy', NULL, NULL),
	(1167, NULL, 5908882, 'どぅーまいべすと！／キノシタ(kinoshita) feat.音街ウナ／Do my best! (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1130, 0, 4204303, 'ATOLS - MINT feat. Hatsune Miku ⁄ ミント feat. 初音ミク (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(883, 0, 4643130, '洗濯　（初音ミクAppend） [yargFkG0q0o] (1).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1195, 0, 5543388, 'センシティブサマー (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1140, NULL, 5474779, 'DECO#27 - 愛言葉Ⅲ feat. 初音ミク (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1220, NULL, 6568280, '幾望の月 feat. 結月ゆかり ⁄ Kibou no tsuki - Nakyamurya (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1168, NULL, 6493837, 'ぬゆり - ロンリーダンス ⁄ flower ; Lonely Dance (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(849, 0, 4790748, '【初音ミクAppend】miss you【中文字幕】 [MrVuRQHJhYs].mp3', 1, B'1', NULL, 1.54910, 1, 'features_849.npy', NULL, NULL),
	(1066, 0, 4244644, 'VOCALOIDflower of sorrow初音ミク.mp3', 1, B'1', NULL, 1.30937, 1, 'features_1066.npy', NULL, NULL),
	(973, 1, 3014503, 'yt1s.com - Mizusano feat 初音ミク Universe.mp3', 1, B'1', NULL, 1.33836, 1, 'features_973.npy', NULL, NULL),
	(1109, 0, 3770361, '少年Aと妄想少女.mp3', 1, B'1', NULL, 0.21787, 1, 'features_1109.npy', NULL, NULL),
	(887, 0, 3885563, '霞む森 _ 初音ミク＆GUMI [5UIfTqACqJ8] (1).mp3', 1, B'1', NULL, 0.42832, 1, 'features_887.npy', NULL, NULL),
	(915, 1, 7015417, 'An ／ DECO＊27 feat初音ミク.mp3', 1, B'1', NULL, 1.70540, 1, 'features_915.npy', NULL, NULL),
	(1085, 0, 3459565, '初音ミク White Prism 蝶々P.mp3', 1, B'1', NULL, 0.19519, 1, 'features_1085.npy', NULL, NULL),
	(834, 0, 3150189, '【Hatsune Miku】 たのしい逃避行 [5Tef_SSOe40].mp3', 1, B'1', NULL, 0.85456, 1, 'features_834.npy', NULL, NULL),
	(1096, 0, 4572457, '初音ミクさとうささら 君キライ Reupload (1).mp3', 1, B'1', NULL, 0.62188, 1, 'features_1096.npy', NULL, NULL),
	(968, 2, 5999149, 'TsunTsun  ftHatsune Miku_192kbps.mp3', 1, B'1', NULL, 1.88994, 1, 'features_968.npy', NULL, NULL),
	(969, 1, 5117066, 'Weekender Girl   Hatsune Miku Project Diva F (HD).mp3', 1, B'1', NULL, 1.74093, 1, 'features_969.npy', NULL, NULL),
	(855, 0, 3899633, '【初音ミク】 幻奏サティスファクション 【オリジナル曲】 [RHqTWidK9DE].mp3', 1, B'1', NULL, 0.64884, 1, 'features_855.npy', NULL, NULL),
	(1090, 0, 8880650, '初音ミクHatsune Miku - Shining Love.mp3', 1, B'1', NULL, 0.87785, 1, 'features_1090.npy', NULL, NULL),
	(922, 1, 5852446, 'cloudway (feat Hatsune Miku)   keisei.mp3', 1, B'1', NULL, 1.42258, 1, 'features_922.npy', NULL, NULL),
	(1080, 0, 4731644, '一触即発禅ガール - れるりりfeat.初音ミク&GUMI  Simmering ZEN Girl - rerulili feat.miku&gumi.mp3', 1, B'1', NULL, 1.72207, 1, 'features_1080.npy', NULL, NULL),
	(1089, 1, 3798990, '初音ミクGUMI(40) コトバのうた オリジナルPV.mp3', 1, B'1', NULL, 0.38302, 1, 'features_1089.npy', NULL, NULL),
	(828, 0, 3612810, '┗_∵_┓ヤキモチの答え-another story-／HoneyWorks feat.初音ミク [Qlkezcz3tt4].mp3', 1, B'1', NULL, 0.85365, 1, 'features_828.npy', NULL, NULL),
	(1033, 1, 5628001, '初音ミク灯火syudou_192kbps.mp3', 1, B'1', NULL, 1.19671, 1, 'features_1033.npy', NULL, NULL),
	(1030, 1, 6067486, '初音ミクオリジナル曲「Singularity�.mp3', 1, B'1', NULL, 1.65197, 1, 'features_1030.npy', NULL, NULL),
	(995, 0, 7854795, '【初音ミク】 children 【オリジナル曲】.mp3', 1, B'1', NULL, 1.62620, 1, 'features_995.npy', NULL, NULL),
	(824, 0, 5785319, 'Reality _ Dog tails feat. Miku [MMDPV] [UPhsMAdDGfM].mp3', 1, B'1', NULL, 0.29468, 1, 'features_824.npy', NULL, NULL),
	(851, 0, 5377606, '【初音ミクDark】ゆらゆら English and romaji subs [04fGKdznrkw].mp3', 1, B'1', NULL, 0.30978, 1, 'features_851.npy', NULL, NULL),
	(1035, 1, 7311959, '大嫌いなはずだったHoneyWorks feat.GUMI初音ミク.mp3', 1, B'1', NULL, 0.88028, 1, 'features_1035.npy', NULL, NULL),
	(1079, 1, 4707801, 'リンレンGUMIルカミクcLick cRackオリジナル.mp3', 1, B'1', NULL, 1.00384, 1, 'features_1079.npy', NULL, NULL),
	(1044, 0, 3954545, '【初音ミク】SEAHOLLY【オリジナルMV】 [LkCHlsJyV7Y].mp3', 1, B'1', NULL, 0.79968, 1, 'features_1044.npy', NULL, NULL),
	(916, 1, 3662996, 'Anti Selector_初音ミク [ShTbgwaKkiQ].mp3', 1, B'1', NULL, 0.38470, 1, 'features_916.npy', NULL, NULL),
	(1014, 2, 3723988, 'えいえんがみつからない - daniwell feat. Hatsune Miku & Momone Momo.mp3', 1, B'1', NULL, 1.95368, 1, 'features_1014.npy', NULL, NULL),
	(818, 0, 4057727, 'Blindness (feat. 初音ミク) [nlLGzmErKWE].mp3', 1, B'1', NULL, 0.41689, 1, 'features_818.npy', NULL, NULL),
	(935, 1, 3791071, 'Hatsune Miku   Akeomeakeomeakeomeakeome (Happy New Year).mp3', 1, B'1', NULL, 1.09053, 1, 'features_935.npy', NULL, NULL),
	(953, 2, 3980123, 'miku hatsune - po pi po356.mp3', 1, B'1', NULL, 1.97485, 1, 'features_953.npy', NULL, NULL),
	(1132, 2, 4020657, 'Booo! - TOKOTOKO（西沢さんP） feat.音街ウナ (128kbit_AAC).mp3', 1, B'1', NULL, 1.91018, 1, 'features_1132.npy', NULL, NULL),
	(1210, 2, 4410293, '僕が夢を捨てて大人になるまで (128kbit_AAC).mp3', 1, B'1', NULL, 1.92051, 1, 'features_1210.npy', NULL, NULL),
	(928, 1, 2889533, 'DokiDokiBeat 初音ミク for Lamaze.mp3', 1, B'1', NULL, 2.13419, 1, 'features_928.npy', NULL, NULL),
	(1223, 2, 7029300, '未来 (いつか) [feat. 初音ミク & 闇音レンリ] (128kbit_AAC).mp3', 1, B'1', NULL, 1.94745, 1, 'features_1223.npy', NULL, NULL),
	(871, 0, 4586189, 'とあ - 飛行機雲 - ft.初音ミク ( Toa - Contrail - ft.Hatsune Miku ) [RHCoZroZySA].mp3', 1, B'1', NULL, 0.37848, 1, 'features_871.npy', NULL, NULL),
	(914, 1, 6109320, 'Amaotopetrichor (feat. Hatsune Miku).mp3', 1, B'1', NULL, 1.99028, 1, 'features_914.npy', NULL, NULL),
	(1043, 1, 2568958, '鏡音レン唐傘さんが通るオリジナルPV.mp3', 1, B'1', NULL, 1.12174, 1, 'features_1043.npy', NULL, NULL),
	(866, 0, 3491991, '【初音ミク】天空の六分儀【オリジナルMV】 [x0_e0yQZibY].mp3', 1, B'1', NULL, 1.35212, 1, 'features_866.npy', NULL, NULL),
	(1054, 1, 4814456, 'JimmyThumbP - Crossroad feat. Hatsune Miku.mp3', 1, B'1', NULL, 0.71120, 1, 'features_1054.npy', NULL, NULL),
	(1165, 0, 5902699, 'とがびとごろし ⁄ 歌愛ユキ、音街ウナ (128kbit_AAC).mp3', 1, B'1', NULL, 0.97294, 1, 'features_1165.npy', NULL, NULL),
	(1153, NULL, 5080856, 'Ultimate (feat. Kagamine Len) (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1147, 0, 5616472, 'Off-Album Volume 7; Track 6-Reply to Gerbera (Okame-P) (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1142, NULL, 6635780, 'Flying away (feat. 初音ミク) (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1177, NULL, 5604621, 'アイアルの勘違い (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1230, NULL, 4936776, '稲葉曇『浮遊月光街』Vo. 歌愛ユキ (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1226, NULL, 5001056, '浮遊月光街 (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1229, NULL, 5424243, '疑神暗鬼 ⁄ しーくん feat. flower【Official】 (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1192, NULL, 5144318, 'スチールワンダー ⁄ はるまきごはん feat.初音ミク アニメMV - Steel Wonder (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1196, NULL, 5516370, 'センシティブサマー(SENSITIVE SUMMER) ⁄ ZLMS feat.初音ミク (ジグ・ルワン・はるまきごはん・雄之助） (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1003, 3, 4929612, '【初音ミク】Hatsune Miku「DECORATOR」MP3 High Quality![8].mp3', 1, B'1', NULL, 2.98177, 1, 'features_1003.npy', NULL, NULL),
	(891, 2, 4129298, '01 - Tell Your World.mp3', 1, B'1', NULL, 1.68797, 1, 'features_891.npy', NULL, NULL),
	(977, 1, 5640540, '[MV]さよならカンパニュラ  mehikari feat 初音ミ�.mp3', 1, B'1', NULL, 0.63128, 1, 'features_977.npy', NULL, NULL),
	(1216, 0, 6767001, '初音ミクの激唱(2018Remake) - cosMo＠暴走P (128kbit_AAC).mp3', 1, B'1', NULL, 0.53255, 1, 'features_1216.npy', NULL, NULL),
	(1034, 1, 6625461, '夏至の踊り子 ／初音ミ�.mp3', 1, B'1', NULL, 2.37201, 1, 'features_1034.npy', NULL, NULL),
	(1021, 1, 6313246, 'シネマセレク�.mp3', 1, B'1', NULL, 2.75588, 1, 'features_1021.npy', NULL, NULL),
	(905, 1, 6123034, '11 Anti X''mas Superstar.mp3', 1, B'1', NULL, 0.39622, 1, 'features_905.npy', NULL, NULL),
	(1018, 0, 4653386, 'みきとP『 kiss 』MV [9tjA9S281wg].mp3', 1, B'1', NULL, 0.85859, 1, 'features_1018.npy', NULL, NULL),
	(1036, 0, 1661360, '小説3こちら幸福安心委員会です女王様とハピネスサマーゲーム.mp3', 1, B'1', NULL, 0.23398, 1, 'features_1036.npy', NULL, NULL),
	(884, 0, 4643130, '洗濯　（初音ミクAppend） [yargFkG0q0o].mp3', 1, B'1', NULL, 1.31965, 1, 'features_884.npy', NULL, NULL),
	(1069, 0, 4404652, 'We Wait for Morning on the Last Train risou feat. Hatsune Miku (English sub).mp3', 1, B'1', NULL, 0.50570, 1, 'features_1069.npy', NULL, NULL),
	(910, 2, 4558903, '17 Ievan Polkka.mp3', 1, B'1', NULL, 2.08661, 1, 'features_910.npy', NULL, NULL),
	(1020, 1, 4399108, 'アンドロメダアンドロメダ   ナユタン星人 feat 初音ミク.mp3', 1, B'1', NULL, 2.16874, 1, 'features_1020.npy', NULL, NULL),
	(1151, 0, 6477311, 'TieredCrisis ⁄ youman feat. GUMI (English Subs) (128kbit_AAC).mp3', 1, B'1', NULL, 1.26492, 1, 'features_1151.npy', NULL, NULL),
	(923, 1, 4043380, 'Cressida   ftHatsune Miku 【english subtitles】.mp3', 1, B'1', NULL, 1.71288, 1, 'features_923.npy', NULL, NULL),
	(1133, NULL, 3608383, 'BRASS NOISE FLAMENCO (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1148, NULL, 4792269, 'Sleeping Awake  Aqu3ra feat 初音ミク (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1206, NULL, 5208086, 'ピノキオピー - ビューティフルなフィクション feat. 初音ミク ⁄ Beautiful Fiction (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1207, NULL, 3706535, 'マーシーキリング (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(965, 2, 4354178, 'spica- hatsune miku.mp3', 1, B'1', NULL, 1.29779, 1, 'features_965.npy', NULL, NULL),
	(971, 1, 3495156, 'yt1s.com - ElectronicMizusano ft Hatsune Miku  Smile Walker.mp3', 1, B'1', NULL, 1.66117, 1, 'features_971.npy', NULL, NULL),
	(1001, 1, 5260371, '【初音ミク】aria【オリジナル曲PV付】.mp3', 1, B'1', NULL, 1.37569, 1, 'features_1001.npy', NULL, NULL),
	(1002, 1, 5931974, '【初音ミク】bpm full ver 【PV】.mp3', 1, B'1', NULL, 1.69139, 1, 'features_1002.npy', NULL, NULL),
	(983, 1, 4738909, '【Hatsune Miku】Body Music【Original Song】.mp3', 1, B'1', NULL, 1.98816, 1, 'features_983.npy', NULL, NULL),
	(894, 3, 8224103, '03 Palette.mp3', 1, B'1', NULL, 2.97513, 1, 'features_894.npy', NULL, NULL),
	(1211, NULL, 4764333, '僕が夢を捨てて大人になるまで (152kbit_Opus).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1212, NULL, 4355916, '僕が夢を捨てて大人になるまで (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1213, NULL, 4987245, '僕が夢を捨てて大人になるまで　⁄  feat. 初音ミク (152kbit_Opus).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(981, 1, 5384749, '‪【Hatsune Miku】‬Cerita SMU【Original】‬.mp3', 1, B'1', NULL, 1.90771, 1, 'features_981.npy', NULL, NULL),
	(1012, 1, 7576434, '【水野大輔 feat 初音ミく】 Brilliance.mp3', 1, B'1', NULL, 0.98454, 1, 'features_1012.npy', NULL, NULL),
	(1022, 1, 4102032, 'プリエ  初音ミク  Hatsune Miku.mp3', 1, B'1', NULL, 0.93249, 1, 'features_1022.npy', NULL, NULL),
	(982, 1, 5817964, '┗ ∵ ┓夢ファンファーレ／HoneyWorks feat初音ミクu0026GUM.mp3', 1, B'1', NULL, 0.45500, 1, 'features_982.npy', NULL, NULL),
	(836, 0, 4427473, '【Miku·GUMI·Lily·Iroha】「Violet Blue Fantasy ～Fantasy of Iolite～」【Sub Español】 [d86r3_HR5kw].mp3', 1, B'1', NULL, 0.20664, 1, 'features_836.npy', NULL, NULL),
	(993, 1, 2801668, '【初音ミク】 Anata no Utahime (8ch arr) 【休闲の1月曲】.mp3', 1, B'1', NULL, 2.88493, 1, 'features_993.npy', NULL, NULL),
	(1102, 0, 3790109, '初音ミク愛に奇術師オリジナル1.mp3', 1, B'1', NULL, 0.43970, 1, 'features_1102.npy', NULL, NULL),
	(1161, 0, 4649780, '【巡音ルカ】Canvas【オリジナル】 (128kbit_AAC).mp3', 1, B'1', NULL, 0.96194, 1, 'features_1161.npy', NULL, NULL),
	(1162, 0, 5188554, '【巡音ルカ】Gerbera【オリジナル】 (128kbit_AAC).mp3', 1, B'1', NULL, 0.54710, 1, 'features_1162.npy', NULL, NULL),
	(1000, 1, 7950183, '【初音ミク】Another Mine【オリジナル21】[HD720p].mp3', 1, B'1', NULL, 0.90593, 1, 'features_1000.npy', NULL, NULL),
	(1215, NULL, 6842640, '初音ミク⁄そらをおよぐ (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1221, NULL, 5544129, '愛言葉III (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1222, NULL, 5646561, '撥条少女時計 (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1208, 0, 5068462, 'ミライゲイザー ／ DIVELA feat.初音ミク (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1198, NULL, 4658052, 'テレストテレス (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1228, 0, 6702060, '無限にホメてくれる桜乃そら先生 (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1023, 1, 5891316, 'モノクロブルースカイ  のぼる feat 初音ミク  MonochromeBlueSky.mp3', 1, B'1', NULL, 2.28272, 1, 'features_1023.npy', NULL, NULL),
	(893, 1, 5372012, '01 アンドロイド Voc@loid ～I am not a robot～.mp3', 1, B'1', NULL, 1.25100, 1, 'features_893.npy', NULL, NULL),
	(956, 1, 5234911, 'Neru - ロストワンの号哭(Lost One''s Weeping) feat. Kagamine Rin.mp3', 1, B'1', NULL, 2.22212, 1, 'features_956.npy', NULL, NULL),
	(1058, 0, 4028008, 'Psychokinesis (feat. Hatsune Miku) 2020 Version  Utsu-P.mp3', 1, B'1', NULL, 0.21573, 1, 'features_1058.npy', NULL, NULL),
	(1083, 0, 5693459, '初音ミク - Hatsune Miku AppendAllgatherOriginal.mp3', 1, B'1', NULL, 0.64376, 1, 'features_1083.npy', NULL, NULL),
	(1087, 0, 2861385, '初音ミク ｿﾄﾞﾑSodom Hatsune MikuOriginal.mp3', 1, B'1', NULL, 0.15975, 1, 'features_1087.npy', NULL, NULL),
	(829, 0, 3862228, '┗_∵_┓吉田、家出するってよ／HoneyWorks feat.初音ミク [fd0uHUAy6TU].mp3', 1, B'1', NULL, 1.62377, 1, 'features_829.npy', NULL, NULL),
	(1188, 0, 5409690, 'クーロンズ・ホテル(Kowloon''s HOTEL)／鏡音リン・てにをは (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1176, 0, 5307886, 'わいふぁい暴想ボーイ- れるりり feat 鏡音レン& Fukase ⁄ Wi-Fi Imagination Wild Boy - rerulili feat LEN &VOCALOID Fukase (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1172, 0, 3565028, 'ぼかろころしあむ (feat. Kagamine Rin) (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1225, NULL, 6217782, '泥中に咲く ⁄ HarryP ft. 初音ミク (Official Music Video) (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1201, NULL, 4305016, 'デレレレ ／ DIVELA feat.初音ミク (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1202, NULL, 5533589, 'ドンガラシャン (feat. 初音ミク) (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1008, 1, 6742072, '【初音ミク】スターナイトスノウ【オリジナルMV�.mp3', 1, B'1', NULL, 2.82452, 1, 'features_1008.npy', NULL, NULL),
	(860, 0, 3683148, '【初音ミク】　 オトシメセルフ 　【オリジナル曲】 [hTQKJQWMQ-4].mp3', 1, B'1', NULL, 0.65297, 1, 'features_860.npy', NULL, NULL),
	(919, 0, 4315585, 'Bright future Ein schritt.mp3', 1, B'1', NULL, 0.77399, 1, 'features_919.npy', NULL, NULL),
	(938, 2, 5052472, 'Hatsune Miku   Torinoko City  (トリノコシティ)(Left Behind City) Sub Esp (+mp3 + romaji.mp3', 1, B'1', NULL, 1.91774, 1, 'features_938.npy', NULL, NULL),
	(918, 1, 7372052, 'Breath of Urban   keisei feat Hatsune Miku.mp3', 1, B'1', NULL, 0.83780, 1, 'features_918.npy', NULL, NULL),
	(1029, 1, 6602171, '初音ミクオリジナル曲 「Breath of mechanical」.mp3', 1, B'1', NULL, 1.83997, 1, 'features_1029.npy', NULL, NULL),
	(912, 2, 8169778, '18 リンリンシグナル.mp3', 1, B'1', NULL, 2.72442, 1, 'features_912.npy', NULL, NULL),
	(882, 0, 3489005, '最憂間で君は [fmbOTo1t1dk].mp3', 1, B'1', NULL, 0.65911, 1, 'features_882.npy', NULL, NULL),
	(867, 0, 4512043, '【初音ミク】祝祭と流転 English and romaji subs [ieEk2hXFkOw].mp3', 1, B'1', NULL, 0.58840, 1, 'features_867.npy', NULL, NULL),
	(886, 0, 4240510, '雀色コンデンサ [Rh3XRrvzl50].mp3', 1, B'1', NULL, 0.68610, 1, 'features_886.npy', NULL, NULL),
	(961, 3, 6713232, 'Rainbow Palace feat Hatsune Miku   Jonathan Parecki 【Vocaloid Original�.mp3', 1, B'1', NULL, 1.71561, 1, 'features_961.npy', NULL, NULL),
	(1127, 0, 4979425, '#Luna - アルティメット (Ultimate) feat.Kagamine Len (128kbit_AAC).mp3', 1, B'1', NULL, 1.55796, 1, 'features_1127.npy', NULL, NULL),
	(1139, 0, 4162121, 'Dasu - Cur Ergo ft. IA & Kagamine Rin (Original) (128kbit_AAC).mp3', 1, B'1', NULL, 1.07203, 1, 'features_1139.npy', NULL, NULL),
	(1009, 1, 6236759, '【初音ミク】名前のない誰か【オリジナル�.mp3', 1, B'1', NULL, 1.91568, 1, 'features_1009.npy', NULL, NULL),
	(936, 1, 5667499, 'Hatsune Miku   Calc (English  Romaji Subs).mp3', 1, B'1', NULL, 1.51496, 1, 'features_936.npy', NULL, NULL),
	(957, 1, 5964041, 'night  (t)rain  初音ミ�.mp3', 1, B'1', NULL, 1.78427, 1, 'features_957.npy', NULL, NULL),
	(902, 1, 15100066, '09 キューティージェリー (feat. 初音ミク).mp3', 1, B'1', NULL, 1.61992, 1, 'features_902.npy', NULL, NULL),
	(898, 2, 3675539, '05 Night Glitter (Featuring Hatsune Miku).mp3', 1, B'1', NULL, 1.83745, 1, 'features_898.npy', NULL, NULL),
	(998, 1, 6366535, '【初音ミク】 紫陽花が咲く頃に、君と恋をする 【nk】.mp3', 1, B'1', NULL, 2.58172, 1, 'features_998.npy', NULL, NULL),
	(937, 3, 4216042, 'Hatsune Miku   Sayonara·Good bye [English Sub].mp3', 1, B'1', NULL, 2.56075, 2, 'features_937.npy', NULL, NULL),
	(1164, 0, 5616197, '【巡音ルカ】Reon - Remind【オリジナル】 (128kbit_AAC).mp3', 1, B'1', NULL, 1.91916, 1, 'features_1164.npy', NULL, NULL),
	(1037, 1, 6647404, '手�.mp3', 1, B'1', NULL, 1.65513, 1, 'features_1037.npy', NULL, NULL),
	(1016, 1, 6318888, 'ひとりぼっちとココロの本と - PIPPO feat. 初音ミク.mp3', 1, B'1', NULL, 2.07175, 1, 'features_1016.npy', NULL, NULL),
	(1136, 0, 6487236, 'Clean Tears - Flying Away feat.初音ミク (128kbit_AAC).mp3', 1, B'1', NULL, 1.66135, 1, 'features_1136.npy', NULL, NULL),
	(990, 3, 6693704, '【初音ミクAppend DARK】Carbuncle【オリジナル曲】.mp3', 1, B'1', NULL, 0.82077, 1, 'features_990.npy', NULL, NULL),
	(1116, 0, 3725369, 'Luna - アルティメット (Ultimate) feat.Kagamine Len (128kbit_AAC).mp3', 1, B'1', NULL, 1.35413, 1, 'features_1116.npy', NULL, NULL),
	(1135, 0, 5097935, 'Circus-P - ''See (with AZUKI)'' [Original Vocaloid Song] (128kbit_AAC).mp3', 1, B'1', NULL, 1.61313, 1, 'features_1135.npy', NULL, NULL),
	(1137, 0, 5284901, 'DADARUMA (128kbit_AAC).mp3', 1, B'1', NULL, 2.08924, 1, 'features_1137.npy', NULL, NULL),
	(1095, 0, 5176143, '初音ミクが声優のようにしゃべってラップする曲ビバハピ Mitchie M.mp3', 1, B'1', NULL, 1.28761, 1, 'features_1095.npy', NULL, NULL),
	(1040, 1, 5408573, '私は足りないでいっぱい_192kbps.mp3', 1, B'1', NULL, 2.83881, 1, 'features_1040.npy', NULL, NULL),
	(815, 0, 3325418, '(Reprint) 小悪魔笑顔とワガママボディー【初音ﾐｸﾀﾞﾖｰ オリジナルPV】 [ErksldUjSUI].mp3', 1, B'1', NULL, 0.37879, 1, 'features_815.npy', NULL, NULL),
	(1042, 1, 7087515, '膵臓  Luna feat 初音ミク ガールズコレクション.mp3', 1, B'1', NULL, 1.70489, 1, 'features_1042.npy', NULL, NULL),
	(1039, 1, 7278104, '神経衰弱  初音ミク 【 Nervous Breakdown  Hatsune Miku �.mp3', 1, B'1', NULL, 1.39471, 1, 'features_1039.npy', NULL, NULL),
	(974, 1, 4184609, '[Eng Sub] To the Lonely You and the Lone Me [Suzumu ft. Hatsune Miku] [EHxFEHPBDP8].mp3', 1, B'1', NULL, 1.13802, 1, 'features_974.npy', NULL, NULL),
	(906, 2, 8975210, '11 ハロー、プラネット.mp3', 1, B'1', NULL, 1.31668, 1, 'features_906.npy', NULL, NULL),
	(1011, 1, 6175226, '【初音ミク・GUMI】あの日、描いたDIARY【オリジナル曲PV】OFFICIAL　MV.mp3', 1, B'1', NULL, 2.05414, 1, 'features_1011.npy', NULL, NULL),
	(913, 2, 5785263, '20 どういうことなの! (Game Version).mp3', 1, B'1', NULL, 2.86678, 1, 'features_913.npy', NULL, NULL),
	(943, 1, 6782196, 'irucaice   White Step feat Hatsune Mik.mp3', 1, B'1', NULL, 1.83111, 1, 'features_943.npy', NULL, NULL),
	(1138, NULL, 5284440, 'DADARUMA／flower (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(975, 3, 6084413, '[Hatsune Miku] Sayonara Arpeggio [VOSTFR].mp3', 1, B'1', NULL, 2.52343, 2, 'features_975.npy', NULL, NULL),
	(944, 1, 5845549, 'kiRakiLa  gaogao feat初音ミ�.mp3', 1, B'1', NULL, 1.97522, 1, 'features_944.npy', NULL, NULL),
	(1190, 0, 5591923, 'コロナ (feat. Kagamine Rin) (128kbit_AAC).mp3', 1, B'1', NULL, 2.05850, 1, 'features_1190.npy', NULL, NULL),
	(1227, 0, 6121514, '無限にホメてくれる桜乃そら先生 (128kbit_AAC).mp3', 1, B'1', NULL, 0.70672, 1, 'features_1227.npy', NULL, NULL),
	(1224, 0, 6143344, '泥中に咲く (feat. 初音ミク) (128kbit_AAC).mp3', 1, B'1', NULL, 1.67152, 1, 'features_1224.npy', NULL, NULL),
	(1015, 1, 5372210, 'くるくるついんてーる_192kbps.mp3', 1, B'1', NULL, 1.50399, 1, 'features_1015.npy', NULL, NULL),
	(880, 1, 4468974, '恋人一首 _ 初音ミク [f7vloBZBp6c].mp3', 1, B'1', NULL, 1.65431, 1, 'features_880.npy', NULL, NULL),
	(1171, NULL, 4578462, 'はらぺこのルベル ⁄ 初音ミク (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1174, NULL, 4802378, 'ゆよゆっぺ feat.巡音ルカ-Fake(Draw) (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL, NULL),
	(1055, 0, 5957309, 'MASA WORKS DESIGN ft.初音ミク&GUMI - 狐の嫁入り.mp3', 1, B'1', NULL, 0.44144, 2, 'features_1055.npy', NULL, NULL),
	(850, 0, 4513925, '【初音ミクAppend】Quiet【オリジナル曲】 [fihI7EuO0eA].mp3', 1, B'1', NULL, 0.61369, 1, 'features_850.npy', NULL, NULL),
	(948, 1, 6385343, 'LOST NOTE  No85 feat初音ミ�.mp3', 1, B'1', NULL, 2.81487, 1, 'features_948.npy', NULL, NULL),
	(1149, 1, 5012316, 'Sleeping Awake ⁄ Aqu3ra feat.初音ミク (128kbit_AAC).mp3', 1, B'1', NULL, 1.26415, 1, 'features_1149.npy', NULL, NULL),
	(885, 0, 2156993, '第1話　予測の先にカノジョは走馬灯を見るか PSGO-Z【SKEW PV】 [Ih6NBS9OcPo].mp3', 1, B'1', NULL, 1.30166, 1, 'features_885.npy', NULL, NULL);


--
-- Data for Name: entrenamientos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.entrenamientos OVERRIDING SYSTEM VALUE VALUES
	(13197, 1150, B'0', 26, '2026-06-09 16:38:10.365865-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13198, 857, B'0', 26, '2026-06-09 16:38:10.367432-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13199, 832, B'0', 26, '2026-06-09 16:38:10.367955-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13200, 947, B'0', 26, '2026-06-09 16:38:10.368677-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13201, 848, B'0', 26, '2026-06-09 16:38:10.369172-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13202, 858, B'0', 26, '2026-06-09 16:38:10.370323-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13203, 1098, B'0', 26, '2026-06-09 16:38:10.370983-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13204, 984, B'0', 26, '2026-06-09 16:38:10.371758-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13205, 1041, B'0', 26, '2026-06-09 16:38:10.372182-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13206, 991, B'0', 26, '2026-06-09 16:38:10.372587-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13207, 874, B'0', 26, '2026-06-09 16:38:10.373048-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13208, 988, B'0', 26, '2026-06-09 16:38:10.373542-06', 3, 41, 0.57960, '32', 0.200, 0.76400),
	(13209, 840, B'0', 26, '2026-06-09 16:38:10.37392-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13210, 997, B'0', 26, '2026-06-09 16:38:10.374315-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13211, 1026, B'0', 26, '2026-06-09 16:38:10.374681-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13212, 1032, B'0', 26, '2026-06-09 16:38:10.375052-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13213, 1078, B'0', 26, '2026-06-09 16:38:10.375429-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13214, 842, B'0', 26, '2026-06-09 16:38:10.375794-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13215, 1107, B'0', 26, '2026-06-09 16:38:10.376288-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13216, 1108, B'0', 26, '2026-06-09 16:38:10.376728-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13217, 895, B'0', 26, '2026-06-09 16:38:10.377276-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13218, 901, B'0', 26, '2026-06-09 16:38:10.377641-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13219, 889, B'0', 26, '2026-06-09 16:38:10.378147-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13220, 838, B'0', 26, '2026-06-09 16:38:10.378826-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13221, 864, B'0', 26, '2026-06-09 16:38:10.379385-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13222, 839, B'0', 26, '2026-06-09 16:38:10.379793-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13223, 1122, B'0', 26, '2026-06-09 16:38:10.380142-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13224, 1093, B'0', 26, '2026-06-09 16:38:10.380503-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13225, 872, B'0', 26, '2026-06-09 16:38:10.381024-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13226, 941, B'0', 26, '2026-06-09 16:38:10.381436-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13227, 869, B'0', 26, '2026-06-09 16:38:10.381905-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13228, 897, B'0', 26, '2026-06-09 16:38:10.382433-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13229, 970, B'0', 26, '2026-06-09 16:38:10.382919-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13230, 1091, B'0', 26, '2026-06-09 16:38:10.383301-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13231, 1092, B'0', 26, '2026-06-09 16:38:10.383639-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13232, 1187, B'0', 26, '2026-06-09 16:38:10.383967-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13233, 1028, B'0', 26, '2026-06-09 16:38:10.384486-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13234, 1106, B'0', 26, '2026-06-09 16:38:10.384854-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13235, 985, B'0', 26, '2026-06-09 16:38:10.385244-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13236, 854, B'0', 26, '2026-06-09 16:38:10.385625-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13237, 924, B'0', 26, '2026-06-09 16:38:10.386913-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13238, 1100, B'0', 26, '2026-06-09 16:38:10.387548-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13239, 1105, B'0', 26, '2026-06-09 16:38:10.388251-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13240, 1175, B'0', 26, '2026-06-09 16:38:10.38894-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13241, 1166, B'0', 26, '2026-06-09 16:38:10.38953-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13242, 1017, B'0', 26, '2026-06-09 16:38:10.390147-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13243, 835, B'0', 26, '2026-06-09 16:38:10.390531-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13244, 929, B'0', 26, '2026-06-09 16:38:10.390863-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13245, 1065, B'0', 26, '2026-06-09 16:38:10.391246-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13246, 1031, B'0', 26, '2026-06-09 16:38:10.391675-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13247, 833, B'0', 26, '2026-06-09 16:38:10.392004-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13248, 1004, B'0', 26, '2026-06-09 16:38:10.392442-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13249, 1077, B'0', 26, '2026-06-09 16:38:10.39298-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13250, 814, B'0', 26, '2026-06-09 16:38:10.393432-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13251, 1191, B'0', 26, '2026-06-09 16:38:10.394184-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13252, 1199, B'0', 26, '2026-06-09 16:38:10.394868-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13253, 979, B'0', 26, '2026-06-09 16:38:10.395506-06', 3, 41, 0.57960, '32', 0.200, 0.76400),
	(13254, 946, B'0', 26, '2026-06-09 16:38:10.396137-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13255, 877, B'0', 26, '2026-06-09 16:38:10.39659-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13256, 1063, B'0', 26, '2026-06-09 16:38:10.397059-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13257, 1064, B'0', 26, '2026-06-09 16:38:10.397786-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13258, 903, B'0', 26, '2026-06-09 16:38:10.398423-06', 3, 41, 0.57960, '32', 0.200, 0.76400),
	(13259, 875, B'0', 26, '2026-06-09 16:38:10.398894-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13260, 879, B'0', 26, '2026-06-09 16:38:10.399338-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13261, 932, B'0', 26, '2026-06-09 16:38:10.39977-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13262, 1146, B'0', 26, '2026-06-09 16:38:10.400206-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13263, 930, B'0', 26, '2026-06-09 16:38:10.400626-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13264, 987, B'0', 26, '2026-06-09 16:38:10.401095-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13265, 945, B'0', 26, '2026-06-09 16:38:10.401755-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13266, 1173, B'0', 26, '2026-06-09 16:38:10.402133-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13267, 1163, B'0', 26, '2026-06-09 16:38:10.402463-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13268, 1181, B'0', 26, '2026-06-09 16:38:10.402892-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13269, 899, B'0', 26, '2026-06-09 16:38:10.403407-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13270, 934, B'0', 26, '2026-06-09 16:38:10.403825-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13271, 1125, B'0', 26, '2026-06-09 16:38:10.404196-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13272, 1059, B'0', 26, '2026-06-09 16:38:10.404586-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13273, 1076, B'0', 26, '2026-06-09 16:38:10.404959-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13274, 1046, B'0', 26, '2026-06-09 16:38:10.405286-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13275, 1056, B'0', 26, '2026-06-09 16:38:10.405675-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13276, 1057, B'0', 26, '2026-06-09 16:38:10.406027-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13277, 999, B'0', 26, '2026-06-09 16:38:10.406349-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13278, 878, B'0', 26, '2026-06-09 16:38:10.406668-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13279, 853, B'0', 26, '2026-06-09 16:38:10.407159-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13280, 1119, B'0', 26, '2026-06-09 16:38:10.407524-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13281, 1155, B'0', 26, '2026-06-09 16:38:10.407866-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13282, 1145, B'0', 26, '2026-06-09 16:38:10.408239-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13283, 1152, B'0', 26, '2026-06-09 16:38:10.408622-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13284, 1067, B'0', 26, '2026-06-09 16:38:10.408951-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13285, 861, B'0', 26, '2026-06-09 16:38:10.409335-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13286, 1062, B'0', 26, '2026-06-09 16:38:10.410273-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13287, 940, B'0', 26, '2026-06-09 16:38:10.410972-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13288, 939, B'0', 26, '2026-06-09 16:38:10.41166-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13289, 909, B'0', 26, '2026-06-09 16:38:10.412131-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13290, 964, B'0', 26, '2026-06-09 16:38:10.41255-06', 3, 41, 0.57960, '32', 0.200, 0.76400),
	(13291, 890, B'0', 26, '2026-06-09 16:38:10.412967-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13292, 1038, B'0', 26, '2026-06-09 16:38:10.413336-06', 3, 41, 0.57960, '32', 0.200, 0.76400),
	(13293, 955, B'0', 26, '2026-06-09 16:38:10.413736-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13294, 863, B'0', 26, '2026-06-09 16:38:10.414138-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13295, 1185, B'0', 26, '2026-06-09 16:38:10.414483-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13296, 1045, B'0', 26, '2026-06-09 16:38:10.414886-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13297, 1134, B'0', 26, '2026-06-09 16:38:10.415234-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13298, 1170, B'0', 26, '2026-06-09 16:38:10.415568-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13299, 963, B'0', 26, '2026-06-09 16:38:10.416019-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13300, 925, B'0', 26, '2026-06-09 16:38:10.416568-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13301, 1068, B'0', 26, '2026-06-09 16:38:10.416986-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13302, 959, B'0', 26, '2026-06-09 16:38:10.417496-06', 3, 41, 0.57960, '32', 0.200, 0.76400),
	(13303, 823, B'0', 26, '2026-06-09 16:38:10.417867-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13304, 841, B'0', 26, '2026-06-09 16:38:10.418195-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13305, 1126, B'0', 26, '2026-06-09 16:38:10.418539-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13306, 1204, B'0', 26, '2026-06-09 16:38:10.418922-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13307, 1200, B'0', 26, '2026-06-09 16:38:10.419326-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13308, 1193, B'0', 26, '2026-06-09 16:38:10.4197-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13309, 1218, B'0', 26, '2026-06-09 16:38:10.420214-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13310, 1203, B'0', 26, '2026-06-09 16:38:10.420846-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13311, 951, B'0', 26, '2026-06-09 16:38:10.421305-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13312, 1205, B'0', 26, '2026-06-09 16:38:10.42166-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13313, 1088, B'0', 26, '2026-06-09 16:38:10.422015-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13314, 1094, B'0', 26, '2026-06-09 16:38:10.42239-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13315, 926, B'0', 26, '2026-06-09 16:38:10.423031-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13316, 1049, B'0', 26, '2026-06-09 16:38:10.423469-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13317, 1050, B'0', 26, '2026-06-09 16:38:10.423875-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13318, 1123, B'0', 26, '2026-06-09 16:38:10.42433-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13319, 933, B'0', 26, '2026-06-09 16:38:10.424774-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13320, 826, B'0', 26, '2026-06-09 16:38:10.425113-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13321, 911, B'0', 26, '2026-06-09 16:38:10.425453-06', 3, 41, 0.57960, '32', 0.200, 0.76400),
	(13322, 1051, B'0', 26, '2026-06-09 16:38:10.426052-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13323, 1019, B'0', 26, '2026-06-09 16:38:10.426561-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13324, 942, B'0', 26, '2026-06-09 16:38:10.427281-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13325, 921, B'0', 26, '2026-06-09 16:38:10.427967-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13326, 1143, B'0', 26, '2026-06-09 16:38:10.428524-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13327, 1217, B'0', 26, '2026-06-09 16:38:10.428944-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13328, 1081, B'0', 26, '2026-06-09 16:38:10.429316-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13329, 1082, B'0', 26, '2026-06-09 16:38:10.429698-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13330, 837, B'0', 26, '2026-06-09 16:38:10.430165-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13331, 1025, B'0', 26, '2026-06-09 16:38:10.430598-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13332, 1052, B'0', 26, '2026-06-09 16:38:10.430957-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13333, 1053, B'0', 26, '2026-06-09 16:38:10.431299-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13334, 1075, B'0', 26, '2026-06-09 16:38:10.431664-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13335, 920, B'0', 26, '2026-06-09 16:38:10.432065-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13336, 960, B'0', 26, '2026-06-09 16:38:10.432475-06', 3, 41, 0.57960, '32', 0.200, 0.76400),
	(13337, 952, B'0', 26, '2026-06-09 16:38:10.432943-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13338, 949, B'0', 26, '2026-06-09 16:38:10.433364-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13339, 817, B'0', 26, '2026-06-09 16:38:10.433744-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13340, 1112, B'0', 26, '2026-06-09 16:38:10.434156-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13341, 1160, B'0', 26, '2026-06-09 16:38:10.435425-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13342, 830, B'0', 26, '2026-06-09 16:38:10.435887-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13343, 831, B'0', 26, '2026-06-09 16:38:10.43626-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13344, 873, B'0', 26, '2026-06-09 16:38:10.436599-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13345, 1048, B'0', 26, '2026-06-09 16:38:10.437018-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13346, 931, B'0', 26, '2026-06-09 16:38:10.437465-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13347, 1209, B'0', 26, '2026-06-09 16:38:10.437794-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13348, 888, B'0', 26, '2026-06-09 16:38:10.438112-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13349, 917, B'0', 26, '2026-06-09 16:38:10.438432-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13350, 1005, B'0', 26, '2026-06-09 16:38:10.438909-06', 3, 41, 0.57960, '32', 0.200, 0.76400),
	(13351, 862, B'0', 26, '2026-06-09 16:38:10.439257-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13352, 927, B'0', 26, '2026-06-09 16:38:10.43958-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13353, 1027, B'0', 26, '2026-06-09 16:38:10.439894-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13354, 962, B'0', 26, '2026-06-09 16:38:10.440256-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13355, 958, B'0', 26, '2026-06-09 16:38:10.440591-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13356, 876, B'0', 26, '2026-06-09 16:38:10.440959-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13357, 1131, B'0', 26, '2026-06-09 16:38:10.441482-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13358, 1074, B'0', 26, '2026-06-09 16:38:10.441848-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13359, 1071, B'0', 26, '2026-06-09 16:38:10.44227-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13360, 966, B'0', 26, '2026-06-09 16:38:10.442828-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13361, 856, B'0', 26, '2026-06-09 16:38:10.443231-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13362, 1101, B'0', 26, '2026-06-09 16:38:10.443649-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13363, 870, B'0', 26, '2026-06-09 16:38:10.444064-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13364, 846, B'0', 26, '2026-06-09 16:38:10.444539-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13365, 1158, B'0', 26, '2026-06-09 16:38:10.444922-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13366, 1197, B'0', 26, '2026-06-09 16:38:10.445245-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13367, 1214, B'0', 26, '2026-06-09 16:38:10.445699-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13368, 1099, B'0', 26, '2026-06-09 16:38:10.446389-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13369, 996, B'0', 26, '2026-06-09 16:38:10.446921-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13370, 822, B'0', 26, '2026-06-09 16:38:10.44744-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13371, 1118, B'0', 26, '2026-06-09 16:38:10.44788-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13372, 1121, B'0', 26, '2026-06-09 16:38:10.448444-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13373, 1141, B'0', 26, '2026-06-09 16:38:10.448838-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13374, 1156, B'0', 26, '2026-06-09 16:38:10.449397-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13375, 847, B'0', 26, '2026-06-09 16:38:10.449724-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13376, 852, B'0', 26, '2026-06-09 16:38:10.450157-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13377, 1178, B'0', 26, '2026-06-09 16:38:10.45068-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13378, 843, B'0', 26, '2026-06-09 16:38:10.451193-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13379, 892, B'0', 26, '2026-06-09 16:38:10.451544-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13380, 859, B'0', 26, '2026-06-09 16:38:10.451941-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13381, 1104, B'0', 26, '2026-06-09 16:38:10.452419-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13382, 881, B'0', 26, '2026-06-09 16:38:10.452786-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13383, 1060, B'0', 26, '2026-06-09 16:38:10.453174-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13384, 1061, B'0', 26, '2026-06-09 16:38:10.45357-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13385, 1103, B'0', 26, '2026-06-09 16:38:10.453978-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13386, 1013, B'0', 26, '2026-06-09 16:38:10.454371-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13387, 1115, B'0', 26, '2026-06-09 16:38:10.454862-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13388, 972, B'0', 26, '2026-06-09 16:38:10.455247-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13389, 821, B'0', 26, '2026-06-09 16:38:10.455693-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13390, 896, B'0', 26, '2026-06-09 16:38:10.456159-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13391, 1097, B'0', 26, '2026-06-09 16:38:10.456515-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13392, 989, B'0', 26, '2026-06-09 16:38:10.456905-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13393, 992, B'0', 26, '2026-06-09 16:38:10.45749-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13394, 1084, B'0', 26, '2026-06-09 16:38:10.457902-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13395, 1113, B'0', 26, '2026-06-09 16:38:10.458426-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13396, 1010, B'0', 26, '2026-06-09 16:38:10.459041-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13397, 1120, B'0', 26, '2026-06-09 16:38:10.459543-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13398, 1073, B'0', 26, '2026-06-09 16:38:10.459905-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13399, 1111, B'0', 26, '2026-06-09 16:38:10.460322-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13400, 1144, B'0', 26, '2026-06-09 16:38:10.460749-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13401, 1154, B'0', 26, '2026-06-09 16:38:10.461335-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13402, 1169, B'0', 26, '2026-06-09 16:38:10.461945-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13403, 1072, B'0', 26, '2026-06-09 16:38:10.462426-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13404, 820, B'0', 26, '2026-06-09 16:38:10.462775-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13405, 1047, B'0', 26, '2026-06-09 16:38:10.463119-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13406, 1110, B'0', 26, '2026-06-09 16:38:10.463517-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13407, 954, B'0', 26, '2026-06-09 16:38:10.463989-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13408, 1070, B'0', 26, '2026-06-09 16:38:10.464711-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13409, 868, B'0', 26, '2026-06-09 16:38:10.465219-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13410, 1124, B'0', 26, '2026-06-09 16:38:10.465658-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13411, 1007, B'0', 26, '2026-06-09 16:38:10.466261-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13412, 819, B'0', 26, '2026-06-09 16:38:10.466701-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13413, 849, B'0', 26, '2026-06-09 16:38:10.467058-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13414, 1066, B'0', 26, '2026-06-09 16:38:10.467404-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13415, 973, B'0', 26, '2026-06-09 16:38:10.467758-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13416, 1109, B'0', 26, '2026-06-09 16:38:10.468283-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13417, 907, B'0', 26, '2026-06-09 16:38:10.46874-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13418, 900, B'0', 26, '2026-06-09 16:38:10.469334-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13419, 994, B'0', 26, '2026-06-09 16:38:10.46974-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13420, 950, B'0', 26, '2026-06-09 16:38:10.470178-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13421, 978, B'0', 26, '2026-06-09 16:38:10.47061-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13422, 986, B'0', 26, '2026-06-09 16:38:10.471054-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13423, 1006, B'0', 26, '2026-06-09 16:38:10.471475-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13424, 980, B'0', 26, '2026-06-09 16:38:10.471917-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13425, 976, B'0', 26, '2026-06-09 16:38:10.472554-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13426, 827, B'0', 26, '2026-06-09 16:38:10.4731-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13427, 1219, B'0', 26, '2026-06-09 16:38:10.473592-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13428, 967, B'0', 26, '2026-06-09 16:38:10.474076-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13429, 816, B'0', 26, '2026-06-09 16:38:10.47453-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13430, 1024, B'0', 26, '2026-06-09 16:38:10.474936-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13431, 904, B'0', 26, '2026-06-09 16:38:10.475349-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13432, 825, B'0', 26, '2026-06-09 16:38:10.475798-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13433, 1129, B'0', 26, '2026-06-09 16:38:10.476213-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13434, 1128, B'0', 26, '2026-06-09 16:38:10.476665-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13435, 1114, B'0', 26, '2026-06-09 16:38:10.477096-06', 3, 41, 0.57960, '32', 0.200, 0.76400),
	(13436, 865, B'0', 26, '2026-06-09 16:38:10.477466-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13437, 1086, B'0', 26, '2026-06-09 16:38:10.4778-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13438, 1080, B'0', 26, '2026-06-09 16:38:10.478219-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13439, 1089, B'0', 26, '2026-06-09 16:38:10.478631-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13440, 828, B'0', 26, '2026-06-09 16:38:10.478965-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13441, 1033, B'0', 26, '2026-06-09 16:38:10.479315-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13442, 1030, B'0', 26, '2026-06-09 16:38:10.479686-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13443, 995, B'0', 26, '2026-06-09 16:38:10.480159-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13444, 824, B'0', 26, '2026-06-09 16:38:10.480547-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13445, 851, B'0', 26, '2026-06-09 16:38:10.481044-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13446, 1035, B'0', 26, '2026-06-09 16:38:10.482331-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13447, 1079, B'0', 26, '2026-06-09 16:38:10.482713-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13448, 1044, B'0', 26, '2026-06-09 16:38:10.483068-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13449, 916, B'0', 26, '2026-06-09 16:38:10.483439-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13450, 1014, B'0', 26, '2026-06-09 16:38:10.483816-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13451, 818, B'0', 26, '2026-06-09 16:38:10.484273-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13452, 935, B'0', 26, '2026-06-09 16:38:10.484709-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13453, 953, B'0', 26, '2026-06-09 16:38:10.485079-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13454, 1132, B'0', 26, '2026-06-09 16:38:10.485456-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13455, 1210, B'0', 26, '2026-06-09 16:38:10.48579-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13456, 928, B'0', 26, '2026-06-09 16:38:10.486118-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13457, 887, B'0', 26, '2026-06-09 16:38:10.486458-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13458, 915, B'0', 26, '2026-06-09 16:38:10.486835-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13459, 1085, B'0', 26, '2026-06-09 16:38:10.48723-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13460, 834, B'0', 26, '2026-06-09 16:38:10.487642-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13461, 1096, B'0', 26, '2026-06-09 16:38:10.488048-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13462, 968, B'0', 26, '2026-06-09 16:38:10.488504-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13463, 969, B'0', 26, '2026-06-09 16:38:10.489307-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13464, 855, B'0', 26, '2026-06-09 16:38:10.489692-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13465, 1090, B'0', 26, '2026-06-09 16:38:10.490045-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13466, 922, B'0', 26, '2026-06-09 16:38:10.490363-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13467, 1223, B'0', 26, '2026-06-09 16:38:10.490675-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13468, 871, B'0', 26, '2026-06-09 16:38:10.490996-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13469, 914, B'0', 26, '2026-06-09 16:38:10.491542-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13470, 1043, B'0', 26, '2026-06-09 16:38:10.491887-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13471, 866, B'0', 26, '2026-06-09 16:38:10.492256-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13472, 1054, B'0', 26, '2026-06-09 16:38:10.492675-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13473, 1003, B'0', 26, '2026-06-09 16:38:10.493027-06', 3, 41, 0.57960, '32', 0.200, 0.76400),
	(13474, 891, B'0', 26, '2026-06-09 16:38:10.493345-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13475, 977, B'0', 26, '2026-06-09 16:38:10.493836-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13476, 1216, B'0', 26, '2026-06-09 16:38:10.494188-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13477, 1034, B'0', 26, '2026-06-09 16:38:10.494526-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13478, 1021, B'0', 26, '2026-06-09 16:38:10.494863-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13479, 905, B'0', 26, '2026-06-09 16:38:10.495212-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13480, 1018, B'0', 26, '2026-06-09 16:38:10.495522-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13481, 1036, B'0', 26, '2026-06-09 16:38:10.495859-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13482, 884, B'0', 26, '2026-06-09 16:38:10.496225-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13483, 1069, B'0', 26, '2026-06-09 16:38:10.496554-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13484, 910, B'0', 26, '2026-06-09 16:38:10.496861-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13485, 1020, B'0', 26, '2026-06-09 16:38:10.497168-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13486, 1151, B'0', 26, '2026-06-09 16:38:10.497535-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13487, 1165, B'0', 26, '2026-06-09 16:38:10.497926-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13488, 971, B'0', 26, '2026-06-09 16:38:10.498333-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13489, 1001, B'0', 26, '2026-06-09 16:38:10.498919-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13490, 1002, B'0', 26, '2026-06-09 16:38:10.499271-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13491, 983, B'0', 26, '2026-06-09 16:38:10.499598-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13492, 894, B'0', 26, '2026-06-09 16:38:10.500071-06', 3, 41, 0.57960, '32', 0.200, 0.76400),
	(13493, 981, B'0', 26, '2026-06-09 16:38:10.500488-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13494, 1012, B'0', 26, '2026-06-09 16:38:10.500893-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13495, 1022, B'0', 26, '2026-06-09 16:38:10.501267-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13496, 982, B'0', 26, '2026-06-09 16:38:10.501581-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13497, 836, B'0', 26, '2026-06-09 16:38:10.501896-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13498, 993, B'0', 26, '2026-06-09 16:38:10.502307-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13499, 1102, B'0', 26, '2026-06-09 16:38:10.502885-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13500, 1161, B'0', 26, '2026-06-09 16:38:10.503302-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13501, 1000, B'0', 26, '2026-06-09 16:38:10.503873-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13502, 1023, B'0', 26, '2026-06-09 16:38:10.504358-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13503, 893, B'0', 26, '2026-06-09 16:38:10.505086-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13504, 956, B'0', 26, '2026-06-09 16:38:10.505512-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13505, 923, B'0', 26, '2026-06-09 16:38:10.505864-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13506, 965, B'0', 26, '2026-06-09 16:38:10.506198-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13507, 1162, B'0', 26, '2026-06-09 16:38:10.506646-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13508, 1164, B'0', 26, '2026-06-09 16:38:10.507044-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13509, 1037, B'0', 26, '2026-06-09 16:38:10.507517-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13510, 1016, B'0', 26, '2026-06-09 16:38:10.508231-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13511, 1136, B'0', 26, '2026-06-09 16:38:10.50877-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13512, 990, B'0', 26, '2026-06-09 16:38:10.509164-06', 3, 41, 0.57960, '32', 0.200, 0.76400),
	(13513, 1116, B'0', 26, '2026-06-09 16:38:10.509482-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13514, 1135, B'0', 26, '2026-06-09 16:38:10.509836-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13515, 1137, B'0', 26, '2026-06-09 16:38:10.510181-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13516, 1095, B'0', 26, '2026-06-09 16:38:10.510505-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13517, 1058, B'0', 26, '2026-06-09 16:38:10.510903-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13518, 1083, B'0', 26, '2026-06-09 16:38:10.511299-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13519, 1087, B'0', 26, '2026-06-09 16:38:10.5119-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13520, 829, B'0', 26, '2026-06-09 16:38:10.512392-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13521, 1008, B'0', 26, '2026-06-09 16:38:10.512868-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13522, 860, B'0', 26, '2026-06-09 16:38:10.513349-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13523, 919, B'0', 26, '2026-06-09 16:38:10.513714-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13524, 938, B'0', 26, '2026-06-09 16:38:10.51406-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13525, 918, B'0', 26, '2026-06-09 16:38:10.514395-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13526, 1029, B'0', 26, '2026-06-09 16:38:10.514807-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13527, 912, B'0', 26, '2026-06-09 16:38:10.515127-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13528, 937, B'0', 26, '2026-06-09 16:38:10.515586-06', 3, 41, 0.57960, '32', 0.200, 0.76400),
	(13529, 882, B'0', 26, '2026-06-09 16:38:10.515968-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13530, 867, B'0', 26, '2026-06-09 16:38:10.516285-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13531, 886, B'0', 26, '2026-06-09 16:38:10.516653-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13532, 961, B'0', 26, '2026-06-09 16:38:10.517026-06', 3, 41, 0.57960, '32', 0.200, 0.76400),
	(13533, 1127, B'0', 26, '2026-06-09 16:38:10.51735-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13534, 1139, B'0', 26, '2026-06-09 16:38:10.517733-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13535, 1009, B'0', 26, '2026-06-09 16:38:10.518089-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13536, 936, B'0', 26, '2026-06-09 16:38:10.51842-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13537, 957, B'0', 26, '2026-06-09 16:38:10.518757-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13538, 902, B'0', 26, '2026-06-09 16:38:10.519164-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13539, 898, B'0', 26, '2026-06-09 16:38:10.519533-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13540, 998, B'0', 26, '2026-06-09 16:38:10.519847-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13541, 1040, B'0', 26, '2026-06-09 16:38:10.520377-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13542, 815, B'0', 26, '2026-06-09 16:38:10.5208-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13543, 1042, B'0', 26, '2026-06-09 16:38:10.521221-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13544, 1039, B'0', 26, '2026-06-09 16:38:10.521566-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13545, 974, B'0', 26, '2026-06-09 16:38:10.521937-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13546, 906, B'0', 26, '2026-06-09 16:38:10.522426-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13547, 1011, B'0', 26, '2026-06-09 16:38:10.522926-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13548, 913, B'0', 26, '2026-06-09 16:38:10.523382-06', 2, 41, 0.57960, '32', 0.200, 0.76400),
	(13549, 943, B'0', 26, '2026-06-09 16:38:10.523798-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13550, 975, B'0', 26, '2026-06-09 16:38:10.524211-06', 3, 41, 0.57960, '32', 0.200, 0.76400),
	(13551, 944, B'0', 26, '2026-06-09 16:38:10.525499-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13552, 1190, B'0', 26, '2026-06-09 16:38:10.52584-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13553, 1227, B'0', 26, '2026-06-09 16:38:10.526219-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13554, 1224, B'0', 26, '2026-06-09 16:38:10.52656-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13555, 1015, B'0', 26, '2026-06-09 16:38:10.5269-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13556, 880, B'0', 26, '2026-06-09 16:38:10.527247-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13557, 850, B'0', 26, '2026-06-09 16:38:10.527586-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13558, 948, B'0', 26, '2026-06-09 16:38:10.527911-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13559, 1149, B'0', 26, '2026-06-09 16:38:10.528258-06', 1, 41, 0.57960, '32', 0.200, 0.76400),
	(13560, 1055, B'0', 26, '2026-06-09 16:38:10.528613-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13561, 885, B'0', 26, '2026-06-09 16:38:10.529011-06', 0, 41, 0.57960, '32', 0.200, 0.76400),
	(13562, 1199, B'1', 26, '2026-06-09 16:56:01.430342-06', 0, 5, 0.77201, '32', 0.000, 0.73000),
	(13563, 1199, B'1', 26, '2026-06-09 16:57:33.242836-06', 0, 5, 0.68385, '32', 0.000, 0.74000),
	(13564, 1199, B'1', 26, '2026-06-09 16:57:55.716244-06', 0, 5, 0.69301, '32', 0.000, 0.74500),
	(13565, 1155, B'1', 26, '2026-06-09 16:57:59.017519-06', 0, 5, 0.72257, '32', 0.000, 0.72200),
	(13566, 1155, B'1', 26, '2026-06-09 16:58:00.678938-06', 0, 5, 0.71797, '32', 0.000, 0.73800),
	(13567, 1155, B'1', 26, '2026-06-09 16:58:01.827975-06', 0, 5, 0.71699, '32', 0.000, 0.72900),
	(13568, 1155, B'1', 26, '2026-06-09 16:58:02.962627-06', 0, 5, 0.69357, '32', 0.000, 0.75300),
	(13569, 1199, B'1', 26, '2026-06-09 16:58:16.502321-06', 0, 5, 0.61076, '32', 0.000, 0.76000),
	(13570, 975, B'1', 26, '2026-06-09 17:31:23.197138-06', 3, 5, 0.54070, '32', 0.000, 0.79400),
	(13571, 937, B'1', 26, '2026-06-09 17:54:55.734985-06', 3, 5, 0.48637, '32', 0.000, 0.82961),
	(13572, 1175, B'1', 26, '2026-06-09 17:56:28.702238-06', 0, 5, 0.52633, '32', 0.000, 0.81924),
	(13573, 1055, B'1', 26, '2026-06-09 17:56:56.792574-06', 0, 5, 0.46886, '32', 0.000, 0.82777);


--
-- Data for Name: playlists; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.playlists OVERRIDING SYSTEM VALUE VALUES
	(2, 'Prueba', NULL, '2026-03-04 21:49:46.413684-06', B'1', B'0', NULL),
	(1, 'Favoritos', 26, '2026-02-22 18:57:37.569194-06', B'1', B'1', NULL);


--
-- Data for Name: predicciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.predicciones OVERRIDING SYSTEM VALUE VALUES
	(13428, 1150, 26, '2026-06-09 16:55:22.232704-06', 0.67620, 0, 77.460, 13197),
	(13429, 857, 26, '2026-06-09 16:55:22.232704-06', 1.40552, 0, 53.149, 13198),
	(13430, 832, 26, '2026-06-09 16:55:22.232704-06', 0.12534, 0, 95.822, 13199),
	(13431, 947, 26, '2026-06-09 16:55:22.232704-06', 1.21966, 1, 92.678, 13200),
	(13432, 848, 26, '2026-06-09 16:55:22.232704-06', 0.29862, 0, 90.046, 13201),
	(13433, 858, 26, '2026-06-09 16:55:22.232704-06', 1.12838, 0, 62.387, 13202),
	(13434, 1098, 26, '2026-06-09 16:55:22.232704-06', 0.26832, 0, 91.056, 13203),
	(13435, 984, 26, '2026-06-09 16:55:22.232704-06', 0.53582, 1, 84.527, 13204),
	(13436, 1041, 26, '2026-06-09 16:55:22.232704-06', 1.93114, 2, 97.705, 13205),
	(13437, 991, 26, '2026-06-09 16:55:22.232704-06', 0.44190, 1, 81.397, 13206),
	(13438, 874, 26, '2026-06-09 16:55:22.232704-06', 0.72218, 0, 75.927, 13207),
	(13439, 988, 26, '2026-06-09 16:55:22.232704-06', 2.97378, 3, 99.126, 13208),
	(13440, 840, 26, '2026-06-09 16:55:22.232704-06', 1.69161, 0, 43.613, 13209),
	(13441, 997, 26, '2026-06-09 16:55:22.232704-06', 1.78327, 2, 92.776, 13210),
	(13442, 1026, 26, '2026-06-09 16:55:22.232704-06', 1.87652, 2, 95.884, 13211),
	(13443, 1032, 26, '2026-06-09 16:55:22.232704-06', 1.45299, 2, 81.766, 13212),
	(13444, 1078, 26, '2026-06-09 16:55:22.232704-06', 0.66839, 0, 77.720, 13213),
	(13445, 842, 26, '2026-06-09 16:55:22.232704-06', 1.03026, 0, 65.658, 13214),
	(13446, 1107, 26, '2026-06-09 16:55:22.232704-06', 0.45254, 0, 84.915, 13215),
	(13447, 1108, 26, '2026-06-09 16:55:22.232704-06', 0.11086, 0, 96.305, 13216),
	(13448, 895, 26, '2026-06-09 16:55:22.232704-06', 1.76421, 1, 74.526, 13217),
	(13449, 901, 26, '2026-06-09 16:55:22.232704-06', 1.73258, 2, 91.086, 13218),
	(13450, 889, 26, '2026-06-09 16:55:22.232704-06', 1.61508, 1, 79.497, 13219),
	(13451, 838, 26, '2026-06-09 16:55:22.232704-06', 0.79124, 0, 73.625, 13220),
	(13452, 864, 26, '2026-06-09 16:55:22.232704-06', 1.24297, 0, 58.568, 13221),
	(13453, 839, 26, '2026-06-09 16:55:22.232704-06', 0.50145, 0, 83.285, 13222),
	(13454, 1122, 26, '2026-06-09 16:55:22.232704-06', 1.21278, 0, 59.574, 13223),
	(13455, 1093, 26, '2026-06-09 16:55:22.232704-06', 0.42260, 0, 85.913, 13224),
	(13456, 872, 26, '2026-06-09 16:55:22.232704-06', 0.36358, 0, 87.881, 13225),
	(13457, 941, 26, '2026-06-09 16:55:22.232704-06', 1.19816, 1, 93.395, 13226),
	(13458, 869, 26, '2026-06-09 16:55:22.232704-06', 0.56068, 0, 81.311, 13227),
	(13459, 897, 26, '2026-06-09 16:55:22.232704-06', 1.97754, 2, 99.251, 13228),
	(13460, 970, 26, '2026-06-09 16:55:22.232704-06', 1.71259, 2, 90.420, 13229),
	(13461, 1091, 26, '2026-06-09 16:55:22.232704-06', 0.42899, 0, 85.700, 13230),
	(13462, 1092, 26, '2026-06-09 16:55:22.232704-06', 0.27369, 0, 90.877, 13231),
	(13463, 1187, 26, '2026-06-09 16:55:22.232704-06', 0.94522, 0, 68.493, 13232),
	(13464, 1028, 26, '2026-06-09 16:55:22.232704-06', 1.82217, 1, 72.594, 13233),
	(13465, 1106, 26, '2026-06-09 16:55:22.232704-06', 0.45951, 0, 84.683, 13234),
	(13466, 985, 26, '2026-06-09 16:55:22.232704-06', 0.75565, 1, 91.855, 13235),
	(13467, 879, 26, '2026-06-09 16:55:22.232704-06', 1.00723, 0, 66.426, 13260),
	(13468, 932, 26, '2026-06-09 16:55:22.232704-06', 1.89141, 2, 96.380, 13261),
	(13469, 1146, 26, '2026-06-09 16:55:22.232704-06', 1.54228, 1, 81.924, 13262),
	(13470, 854, 26, '2026-06-09 16:55:22.232704-06', 0.83764, 0, 72.079, 13236),
	(13471, 924, 26, '2026-06-09 16:55:22.232704-06', 1.90361, 2, 96.787, 13237),
	(13472, 1100, 26, '2026-06-09 16:55:22.232704-06', 1.30629, 0, 56.457, 13238),
	(13473, 1105, 26, '2026-06-09 16:55:22.232704-06', 0.20879, 0, 93.040, 13239),
	(13474, 1175, 26, '2026-06-09 16:55:22.232704-06', 2.24461, 0, 25.180, 13240),
	(13475, 1166, 26, '2026-06-09 16:55:22.232704-06', 1.78292, 1, 73.903, 13241),
	(13476, 1017, 26, '2026-06-09 16:55:22.232704-06', 1.68097, 2, 89.366, 13242),
	(13477, 835, 26, '2026-06-09 16:55:22.232704-06', 1.77329, 2, 92.443, 13243),
	(13478, 929, 26, '2026-06-09 16:55:22.232704-06', 1.10149, 1, 96.617, 13244),
	(13479, 1065, 26, '2026-06-09 16:55:22.232704-06', 1.30937, 0, 56.354, 13245),
	(13480, 1031, 26, '2026-06-09 16:55:22.232704-06', 1.16482, 1, 94.506, 13246),
	(13481, 833, 26, '2026-06-09 16:55:22.232704-06', 1.34707, 0, 55.098, 13247),
	(13482, 1004, 26, '2026-06-09 16:55:22.232704-06', 1.56690, 1, 81.103, 13248),
	(13483, 1077, 26, '2026-06-09 16:55:22.232704-06', 1.78972, 0, 40.343, 13249),
	(13484, 814, 26, '2026-06-09 16:55:22.232704-06', 1.22629, 0, 59.124, 13250),
	(13485, 1191, 26, '2026-06-09 16:55:22.232704-06', 1.20572, 0, 59.809, 13251),
	(13486, 1199, 26, '2026-06-09 16:55:22.232704-06', 2.60807, 0, 13.064, 13252),
	(13487, 979, 26, '2026-06-09 16:55:22.232704-06', 2.96959, 3, 98.986, 13253),
	(13488, 946, 26, '2026-06-09 16:55:22.232704-06', 1.56893, 1, 81.036, 13254),
	(13489, 877, 26, '2026-06-09 16:55:22.232704-06', 0.82103, 0, 72.632, 13255),
	(13490, 1063, 26, '2026-06-09 16:55:22.232704-06', 0.74552, 0, 75.149, 13256),
	(13491, 1064, 26, '2026-06-09 16:55:22.232704-06', 0.08046, 0, 97.318, 13257),
	(13492, 903, 26, '2026-06-09 16:55:22.232704-06', 2.96273, 3, 98.758, 13258),
	(13493, 875, 26, '2026-06-09 16:55:22.232704-06', 1.14052, 0, 61.983, 13259),
	(13494, 930, 26, '2026-06-09 16:55:22.232704-06', 2.54759, 1, 48.414, 13263),
	(13495, 939, 26, '2026-06-09 16:55:22.232704-06', 1.31113, 1, 89.629, 13288),
	(13496, 909, 26, '2026-06-09 16:55:22.232704-06', 2.55290, 2, 81.570, 13289),
	(13497, 964, 26, '2026-06-09 16:55:22.232704-06', 2.97284, 3, 99.095, 13290),
	(13498, 890, 26, '2026-06-09 16:55:22.232704-06', 1.68788, 2, 89.596, 13291),
	(13499, 987, 26, '2026-06-09 16:55:22.232704-06', 1.86779, 2, 95.593, 13264),
	(13500, 945, 26, '2026-06-09 16:55:22.232704-06', 1.88547, 2, 96.182, 13265),
	(13501, 1173, 26, '2026-06-09 16:55:22.232704-06', 0.22481, 0, 92.506, 13266),
	(13502, 1163, 26, '2026-06-09 16:55:22.232704-06', 1.81680, 0, 39.440, 13267),
	(13503, 1181, 26, '2026-06-09 16:55:22.232704-06', 1.34225, 0, 55.258, 13268),
	(13504, 899, 26, '2026-06-09 16:55:22.232704-06', 1.78673, 2, 92.891, 13269),
	(13505, 934, 26, '2026-06-09 16:55:22.232704-06', 1.94244, 2, 98.081, 13270),
	(13506, 1125, 26, '2026-06-09 16:55:22.232704-06', 1.40431, 0, 53.190, 13271),
	(13507, 1059, 26, '2026-06-09 16:55:22.232704-06', 0.70139, 0, 76.620, 13272),
	(13508, 1076, 26, '2026-06-09 16:55:22.232704-06', 0.65172, 0, 78.276, 13273),
	(13509, 1046, 26, '2026-06-09 16:55:22.232704-06', 0.16509, 0, 94.497, 13274),
	(13510, 1056, 26, '2026-06-09 16:55:22.232704-06', 1.26934, 1, 91.022, 13275),
	(13511, 1057, 26, '2026-06-09 16:55:22.232704-06', 0.79810, 0, 73.397, 13276),
	(13512, 999, 26, '2026-06-09 16:55:22.232704-06', 0.55452, 1, 85.151, 13277),
	(13513, 878, 26, '2026-06-09 16:55:22.232704-06', 0.27133, 0, 90.956, 13278),
	(13514, 853, 26, '2026-06-09 16:55:22.232704-06', 1.80057, 0, 39.981, 13279),
	(13515, 1119, 26, '2026-06-09 16:55:22.232704-06', 0.29009, 0, 90.330, 13280),
	(13516, 1155, 26, '2026-06-09 16:55:22.232704-06', 2.51551, 0, 16.150, 13281),
	(13517, 1145, 26, '2026-06-09 16:55:22.232704-06', 1.81603, 0, 39.466, 13282),
	(13518, 1152, 26, '2026-06-09 16:55:22.232704-06', 2.01203, 2, 99.599, 13283),
	(13519, 1067, 26, '2026-06-09 16:55:22.232704-06', 0.32268, 0, 89.244, 13284),
	(13520, 861, 26, '2026-06-09 16:55:22.232704-06', 0.47343, 0, 84.219, 13285),
	(13521, 1062, 26, '2026-06-09 16:55:22.232704-06', 0.60208, 0, 79.931, 13286),
	(13522, 940, 26, '2026-06-09 16:55:22.232704-06', 1.56854, 1, 81.049, 13287),
	(13523, 1038, 26, '2026-06-09 16:55:22.232704-06', 2.95745, 3, 98.582, 13292),
	(13524, 955, 26, '2026-06-09 16:55:22.232704-06', 1.58428, 1, 80.524, 13293),
	(13525, 863, 26, '2026-06-09 16:55:22.232704-06', 1.61838, 0, 46.054, 13294),
	(13526, 1185, 26, '2026-06-09 16:55:22.232704-06', 0.85546, 0, 71.485, 13295),
	(13527, 1045, 26, '2026-06-09 16:55:22.232704-06', 0.33447, 0, 88.851, 13296),
	(13528, 1134, 26, '2026-06-09 16:55:22.232704-06', 1.19646, 0, 60.118, 13297),
	(13529, 1170, 26, '2026-06-09 16:55:22.232704-06', 1.57061, 0, 47.646, 13298),
	(13530, 963, 26, '2026-06-09 16:55:22.232704-06', 2.46567, 1, 51.144, 13299),
	(13531, 925, 26, '2026-06-09 16:55:22.232704-06', 1.83849, 1, 72.050, 13300),
	(13532, 1068, 26, '2026-06-09 16:55:22.232704-06', 0.26911, 0, 91.030, 13301),
	(13533, 959, 26, '2026-06-09 16:55:22.232704-06', 2.97992, 3, 99.331, 13302),
	(13534, 823, 26, '2026-06-09 16:55:22.232704-06', 1.38819, 0, 53.727, 13303),
	(13535, 841, 26, '2026-06-09 16:55:22.232704-06', 0.69148, 0, 76.951, 13304),
	(13536, 1126, 26, '2026-06-09 16:55:22.232704-06', 1.93198, 0, 35.601, 13305),
	(13537, 1204, 26, '2026-06-09 16:55:22.232704-06', 0.95703, 0, 68.099, 13306),
	(13538, 1200, 26, '2026-06-09 16:55:22.232704-06', 1.32337, 0, 55.888, 13307),
	(13539, 1193, 26, '2026-06-09 16:55:22.232704-06', 1.50816, 0, 49.728, 13308),
	(13540, 1218, 26, '2026-06-09 16:55:22.232704-06', 1.86951, 0, 37.683, 13309),
	(13541, 1203, 26, '2026-06-09 16:55:22.232704-06', 1.62521, 0, 45.826, 13310),
	(13542, 951, 26, '2026-06-09 16:55:22.232704-06', 1.43141, 2, 81.047, 13311),
	(13543, 1205, 26, '2026-06-09 16:55:22.232704-06', 2.55523, 1, 48.159, 13312),
	(13544, 1088, 26, '2026-06-09 16:55:22.232704-06', 0.31654, 0, 89.449, 13313),
	(13545, 1094, 26, '2026-06-09 16:55:22.232704-06', 0.42260, 0, 85.913, 13314),
	(13546, 926, 26, '2026-06-09 16:55:22.232704-06', 1.79027, 2, 93.009, 13315),
	(13547, 1049, 26, '2026-06-09 16:55:22.232704-06', 0.78462, 0, 73.846, 13316),
	(13548, 1050, 26, '2026-06-09 16:55:22.232704-06', 0.88078, 0, 70.641, 13317),
	(13549, 1123, 26, '2026-06-09 16:55:22.232704-06', 1.49028, 0, 50.324, 13318),
	(13550, 933, 26, '2026-06-09 16:55:22.232704-06', 1.40149, 1, 86.617, 13319),
	(13551, 826, 26, '2026-06-09 16:55:22.232704-06', 0.75373, 0, 74.876, 13320),
	(13552, 911, 26, '2026-06-09 16:55:22.232704-06', 2.94839, 3, 98.280, 13321),
	(13553, 1051, 26, '2026-06-09 16:55:22.232704-06', 0.89326, 1, 96.442, 13322),
	(13554, 1019, 26, '2026-06-09 16:55:22.232704-06', 1.80736, 2, 93.579, 13323),
	(13555, 942, 26, '2026-06-09 16:55:22.232704-06', 1.26415, 1, 91.195, 13324),
	(13556, 921, 26, '2026-06-09 16:55:22.232704-06', 2.13926, 1, 62.025, 13325),
	(13557, 1143, 26, '2026-06-09 16:55:22.232704-06', 0.71096, 0, 76.301, 13326),
	(13558, 1217, 26, '2026-06-09 16:55:22.232704-06', 0.92262, 0, 69.246, 13327),
	(13559, 1081, 26, '2026-06-09 16:55:22.232704-06', 1.53388, 0, 48.871, 13328),
	(13560, 1082, 26, '2026-06-09 16:55:22.232704-06', 1.70284, 2, 90.095, 13329),
	(13561, 837, 26, '2026-06-09 16:55:22.232704-06', 0.52699, 1, 84.233, 13330),
	(13562, 1025, 26, '2026-06-09 16:55:22.232704-06', 1.10073, 1, 96.642, 13331),
	(13563, 1052, 26, '2026-06-09 16:55:22.232704-06', 1.09908, 0, 63.364, 13332),
	(13564, 1053, 26, '2026-06-09 16:55:22.232704-06', 0.27471, 0, 90.843, 13333),
	(13565, 1075, 26, '2026-06-09 16:55:22.232704-06', 1.54757, 0, 48.414, 13334),
	(13566, 920, 26, '2026-06-09 16:55:22.232704-06', 1.85109, 2, 95.036, 13335),
	(13567, 960, 26, '2026-06-09 16:55:22.232704-06', 2.95483, 3, 98.494, 13336),
	(13568, 952, 26, '2026-06-09 16:55:22.232704-06', 1.54866, 1, 81.711, 13337),
	(13569, 949, 26, '2026-06-09 16:55:22.232704-06', 1.71405, 2, 90.468, 13338),
	(13570, 817, 26, '2026-06-09 16:55:22.232704-06', 1.38806, 0, 53.731, 13339),
	(13571, 1112, 26, '2026-06-09 16:55:22.232704-06', 1.28130, 0, 57.290, 13340),
	(13572, 1160, 26, '2026-06-09 16:55:22.232704-06', 0.20881, 0, 93.040, 13341),
	(13573, 830, 26, '2026-06-09 16:55:22.232704-06', 0.59672, 0, 80.109, 13342),
	(13574, 831, 26, '2026-06-09 16:55:22.232704-06', 1.77473, 0, 40.842, 13343),
	(13575, 873, 26, '2026-06-09 16:55:22.232704-06', 1.13107, 0, 62.298, 13344),
	(13576, 1048, 26, '2026-06-09 16:55:22.232704-06', 0.35644, 0, 88.119, 13345),
	(13577, 931, 26, '2026-06-09 16:55:22.232704-06', 1.39045, 1, 86.985, 13346),
	(13578, 1209, 26, '2026-06-09 16:55:22.232704-06', 1.91187, 0, 36.271, 13347),
	(13579, 888, 26, '2026-06-09 16:55:22.232704-06', 0.42832, 0, 85.723, 13348),
	(13580, 917, 26, '2026-06-09 16:55:22.232704-06', 0.84907, 1, 94.969, 13349),
	(13581, 1005, 26, '2026-06-09 16:55:22.232704-06', 2.97203, 3, 99.068, 13350),
	(13582, 862, 26, '2026-06-09 16:55:22.232704-06', 0.71080, 0, 76.307, 13351),
	(13583, 927, 26, '2026-06-09 16:55:22.232704-06', 2.13386, 2, 95.538, 13352),
	(13584, 1027, 26, '2026-06-09 16:55:22.232704-06', 1.52388, 1, 82.537, 13353),
	(13585, 962, 26, '2026-06-09 16:55:22.232704-06', 1.02501, 1, 99.166, 13354),
	(13586, 958, 26, '2026-06-09 16:55:22.232704-06', 0.88681, 1, 96.227, 13355),
	(13587, 876, 26, '2026-06-09 16:55:22.232704-06', 1.23665, 0, 58.778, 13356),
	(13588, 1131, 26, '2026-06-09 16:55:22.232704-06', 1.03864, 0, 65.379, 13357),
	(13589, 1074, 26, '2026-06-09 16:55:22.232704-06', 1.08998, 0, 63.667, 13358),
	(13590, 1071, 26, '2026-06-09 16:55:22.232704-06', 1.14634, 1, 95.122, 13359),
	(13591, 966, 26, '2026-06-09 16:55:22.232704-06', 1.89470, 1, 70.177, 13360),
	(13592, 856, 26, '2026-06-09 16:55:22.232704-06', 1.12211, 0, 62.596, 13361),
	(13593, 1101, 26, '2026-06-09 16:55:22.232704-06', 0.66080, 0, 77.973, 13362),
	(13594, 870, 26, '2026-06-09 16:55:22.232704-06', 1.57788, 0, 47.404, 13363),
	(13595, 846, 26, '2026-06-09 16:55:22.232704-06', 1.05279, 0, 64.907, 13364),
	(13596, 1158, 26, '2026-06-09 16:55:22.232704-06', 0.60882, 0, 79.706, 13365),
	(13597, 1197, 26, '2026-06-09 16:55:22.232704-06', 1.60769, 0, 46.410, 13366),
	(13598, 1214, 26, '2026-06-09 16:55:22.232704-06', 0.83699, 0, 72.100, 13367),
	(13599, 1099, 26, '2026-06-09 16:55:22.232704-06', 0.44256, 0, 85.248, 13368),
	(13600, 996, 26, '2026-06-09 16:55:22.232704-06', 1.66738, 1, 77.754, 13369),
	(13601, 822, 26, '2026-06-09 16:55:22.232704-06', 1.18478, 0, 60.507, 13370),
	(13602, 1118, 26, '2026-06-09 16:55:22.232704-06', 1.24711, 0, 58.430, 13371),
	(13603, 1121, 26, '2026-06-09 16:55:22.232704-06', 1.23474, 2, 74.491, 13372),
	(13604, 1141, 26, '2026-06-09 16:55:22.232704-06', 1.46181, 0, 51.273, 13373),
	(13605, 1156, 26, '2026-06-09 16:55:22.232704-06', 1.03864, 0, 65.379, 13374),
	(13606, 847, 26, '2026-06-09 16:55:22.232704-06', 0.59956, 0, 80.015, 13375),
	(13607, 852, 26, '2026-06-09 16:55:22.232704-06', 1.11591, 0, 62.803, 13376),
	(13608, 1178, 26, '2026-06-09 16:55:22.232704-06', 0.98574, 0, 67.142, 13377),
	(13609, 843, 26, '2026-06-09 16:55:22.232704-06', 0.73712, 0, 75.429, 13378),
	(13610, 892, 26, '2026-06-09 16:55:22.232704-06', 1.52920, 2, 84.307, 13379),
	(13611, 859, 26, '2026-06-09 16:55:22.232704-06', 1.70763, 1, 76.412, 13380),
	(13612, 1104, 26, '2026-06-09 16:55:22.232704-06', 0.58744, 1, 86.248, 13381),
	(13613, 881, 26, '2026-06-09 16:55:22.232704-06', 1.88292, 1, 70.569, 13382),
	(13614, 1060, 26, '2026-06-09 16:55:22.232704-06', 0.11344, 0, 96.219, 13383),
	(13615, 1061, 26, '2026-06-09 16:55:22.232704-06', 0.38722, 0, 87.093, 13384),
	(13616, 1103, 26, '2026-06-09 16:55:22.232704-06', 1.19003, 0, 60.332, 13385),
	(13617, 1013, 26, '2026-06-09 16:55:22.232704-06', 1.96340, 2, 98.780, 13386),
	(13618, 1115, 26, '2026-06-09 16:55:22.232704-06', 1.13390, 0, 62.203, 13387),
	(13619, 972, 26, '2026-06-09 16:55:22.232704-06', 1.79136, 1, 73.621, 13388),
	(13620, 821, 26, '2026-06-09 16:55:22.232704-06', 1.19187, 0, 60.271, 13389),
	(13621, 896, 26, '2026-06-09 16:55:22.232704-06', 1.59079, 1, 80.307, 13390),
	(13622, 1097, 26, '2026-06-09 16:55:22.232704-06', 0.62188, 0, 79.271, 13391),
	(13623, 989, 26, '2026-06-09 16:55:22.232704-06', 1.39755, 1, 86.748, 13392),
	(13624, 992, 26, '2026-06-09 16:55:22.232704-06', 1.64905, 1, 78.365, 13393),
	(13625, 1084, 26, '2026-06-09 16:55:22.232704-06', 0.61564, 1, 87.188, 13394),
	(13626, 1113, 26, '2026-06-09 16:55:22.232704-06', 1.39377, 0, 53.541, 13395),
	(13627, 1010, 26, '2026-06-09 16:55:22.232704-06', 0.59197, 1, 86.399, 13396),
	(13628, 1120, 26, '2026-06-09 16:55:22.232704-06', 1.51165, 0, 49.612, 13397),
	(13629, 1073, 26, '2026-06-09 16:55:22.232704-06', 1.27848, 0, 57.384, 13398),
	(13630, 1111, 26, '2026-06-09 16:55:22.232704-06', 1.56093, 0, 47.969, 13399),
	(13631, 1144, 26, '2026-06-09 16:55:22.232704-06', 0.97345, 0, 67.552, 13400),
	(13632, 1154, 26, '2026-06-09 16:55:22.232704-06', 1.12564, 0, 62.479, 13401),
	(13633, 1169, 26, '2026-06-09 16:55:22.232704-06', 0.57559, 0, 80.814, 13402),
	(13634, 1072, 26, '2026-06-09 16:55:22.232704-06', 0.70234, 0, 76.589, 13403),
	(13635, 820, 26, '2026-06-09 16:55:22.232704-06', 0.38586, 0, 87.138, 13404),
	(13636, 1047, 26, '2026-06-09 16:55:22.232704-06', 0.35465, 0, 88.178, 13405),
	(13637, 1110, 26, '2026-06-09 16:55:22.232704-06', 0.50175, 0, 83.275, 13406),
	(13638, 954, 26, '2026-06-09 16:55:22.232704-06', 1.58192, 2, 86.064, 13407),
	(13639, 1070, 26, '2026-06-09 16:55:22.232704-06', 0.27773, 0, 90.742, 13408),
	(13640, 976, 26, '2026-06-09 16:55:22.232704-06', 2.42352, 2, 85.883, 13425),
	(13641, 827, 26, '2026-06-09 16:55:22.232704-06', 1.02182, 0, 65.939, 13426),
	(13642, 1219, 26, '2026-06-09 16:55:22.232704-06', 1.73471, 0, 42.176, 13427),
	(13643, 967, 26, '2026-06-09 16:55:22.232704-06', 1.83010, 2, 94.337, 13428),
	(13644, 816, 26, '2026-06-09 16:55:22.232704-06', 1.40290, 0, 53.237, 13429),
	(13645, 1024, 26, '2026-06-09 16:55:22.232704-06', 2.22416, 1, 59.195, 13430),
	(13646, 904, 26, '2026-06-09 16:55:22.232704-06', 1.86758, 1, 71.081, 13431),
	(13647, 868, 26, '2026-06-09 16:55:22.232704-06', 0.28577, 0, 90.474, 13409),
	(13648, 1124, 26, '2026-06-09 16:55:22.232704-06', 0.73488, 0, 75.504, 13410),
	(13649, 1007, 26, '2026-06-09 16:55:22.232704-06', 2.06090, 1, 64.637, 13411),
	(13650, 819, 26, '2026-06-09 16:55:22.232704-06', 0.35435, 0, 88.188, 13412),
	(13651, 849, 26, '2026-06-09 16:55:22.232704-06', 1.54910, 0, 48.363, 13413),
	(13652, 1066, 26, '2026-06-09 16:55:22.232704-06', 1.30937, 0, 56.354, 13414),
	(13653, 973, 26, '2026-06-09 16:55:22.232704-06', 1.33836, 1, 88.721, 13415),
	(13654, 1109, 26, '2026-06-09 16:55:22.232704-06', 0.21787, 0, 92.738, 13416),
	(13655, 907, 26, '2026-06-09 16:55:22.232704-06', 1.89780, 2, 96.593, 13417),
	(13656, 900, 26, '2026-06-09 16:55:22.232704-06', 1.81217, 2, 93.739, 13418),
	(13657, 994, 26, '2026-06-09 16:55:22.232704-06', 1.76902, 1, 74.366, 13419),
	(13658, 950, 26, '2026-06-09 16:55:22.232704-06', 1.58772, 1, 80.409, 13420),
	(13659, 978, 26, '2026-06-09 16:55:22.232704-06', 0.79494, 1, 93.165, 13421),
	(13660, 825, 26, '2026-06-09 16:55:22.232704-06', 1.77784, 0, 40.739, 13432),
	(13661, 1129, 26, '2026-06-09 16:55:22.232704-06', 1.89071, 0, 36.976, 13433),
	(13662, 1128, 26, '2026-06-09 16:55:22.232704-06', 1.70692, 0, 43.103, 13434),
	(13663, 1114, 26, '2026-06-09 16:55:22.232704-06', 2.97160, 3, 99.053, 13435),
	(13664, 865, 26, '2026-06-09 16:55:22.232704-06', 0.97449, 0, 67.517, 13436),
	(13665, 1086, 26, '2026-06-09 16:55:22.232704-06', 1.03814, 0, 65.395, 13437),
	(13666, 986, 26, '2026-06-09 16:55:22.232704-06', 1.77209, 1, 74.264, 13422),
	(13667, 1006, 26, '2026-06-09 16:55:22.232704-06', 1.89499, 1, 70.167, 13423),
	(13668, 980, 26, '2026-06-09 16:55:22.232704-06', 0.77997, 1, 92.666, 13424),
	(13669, 1080, 26, '2026-06-09 16:55:22.232704-06', 1.72207, 0, 42.598, 13438),
	(13670, 1089, 26, '2026-06-09 16:55:22.232704-06', 0.38302, 1, 79.434, 13439),
	(13671, 828, 26, '2026-06-09 16:55:22.232704-06', 0.85365, 0, 71.545, 13440),
	(13672, 1033, 26, '2026-06-09 16:55:22.232704-06', 1.19671, 1, 93.443, 13441),
	(13673, 1030, 26, '2026-06-09 16:55:22.232704-06', 1.65197, 1, 78.268, 13442),
	(13674, 995, 26, '2026-06-09 16:55:22.232704-06', 1.62620, 0, 45.793, 13443),
	(13675, 824, 26, '2026-06-09 16:55:22.232704-06', 0.29468, 0, 90.177, 13444),
	(13676, 851, 26, '2026-06-09 16:55:22.232704-06', 0.30978, 0, 89.674, 13445),
	(13677, 1035, 26, '2026-06-09 16:55:22.232704-06', 0.88028, 1, 96.009, 13446),
	(13678, 1079, 26, '2026-06-09 16:55:22.232704-06', 1.00384, 1, 99.872, 13447),
	(13679, 1044, 26, '2026-06-09 16:55:22.232704-06', 0.79968, 0, 73.344, 13448),
	(13680, 916, 26, '2026-06-09 16:55:22.232704-06', 0.38470, 1, 79.490, 13449),
	(13681, 1014, 26, '2026-06-09 16:55:22.232704-06', 1.95368, 2, 98.456, 13450),
	(13682, 818, 26, '2026-06-09 16:55:22.232704-06', 0.41689, 0, 86.104, 13451),
	(13683, 935, 26, '2026-06-09 16:55:22.232704-06', 1.09053, 1, 96.982, 13452),
	(13684, 953, 26, '2026-06-09 16:55:22.232704-06', 1.97485, 2, 99.162, 13453),
	(13685, 1132, 26, '2026-06-09 16:55:22.232704-06', 1.91018, 2, 97.006, 13454),
	(13686, 1210, 26, '2026-06-09 16:55:22.232704-06', 1.92051, 2, 97.350, 13455),
	(13687, 928, 26, '2026-06-09 16:55:22.232704-06', 2.13419, 1, 62.194, 13456),
	(13688, 887, 26, '2026-06-09 16:55:22.232704-06', 0.42832, 0, 85.723, 13457),
	(13689, 915, 26, '2026-06-09 16:55:22.232704-06', 1.70540, 1, 76.487, 13458),
	(13690, 1085, 26, '2026-06-09 16:55:22.232704-06', 0.19519, 0, 93.494, 13459),
	(13691, 834, 26, '2026-06-09 16:55:22.232704-06', 0.85456, 0, 71.515, 13460),
	(13692, 1096, 26, '2026-06-09 16:55:22.232704-06', 0.62188, 0, 79.271, 13461),
	(13693, 968, 26, '2026-06-09 16:55:22.232704-06', 1.88994, 2, 96.331, 13462),
	(13694, 969, 26, '2026-06-09 16:55:22.232704-06', 1.74093, 1, 75.302, 13463),
	(13695, 855, 26, '2026-06-09 16:55:22.232704-06', 0.64884, 0, 78.372, 13464),
	(13696, 1090, 26, '2026-06-09 16:55:22.232704-06', 0.87785, 0, 70.738, 13465),
	(13697, 922, 26, '2026-06-09 16:55:22.232704-06', 1.42258, 1, 85.914, 13466),
	(13698, 1223, 26, '2026-06-09 16:55:22.232704-06', 1.94745, 2, 98.248, 13467),
	(13699, 871, 26, '2026-06-09 16:55:22.232704-06', 0.37848, 0, 87.384, 13468),
	(13700, 914, 26, '2026-06-09 16:55:22.232704-06', 1.99028, 1, 66.991, 13469),
	(13701, 1043, 26, '2026-06-09 16:55:22.232704-06', 1.12174, 1, 95.942, 13470),
	(13702, 866, 26, '2026-06-09 16:55:22.232704-06', 1.35212, 0, 54.929, 13471),
	(13703, 1054, 26, '2026-06-09 16:55:22.232704-06', 0.71120, 1, 90.373, 13472),
	(13704, 1003, 26, '2026-06-09 16:55:22.232704-06', 2.98177, 3, 99.392, 13473),
	(13705, 891, 26, '2026-06-09 16:55:22.232704-06', 1.68797, 2, 89.599, 13474),
	(13706, 977, 26, '2026-06-09 16:55:22.232704-06', 0.63128, 1, 87.709, 13475),
	(13707, 1216, 26, '2026-06-09 16:55:22.232704-06', 0.53255, 0, 82.248, 13476),
	(13708, 1034, 26, '2026-06-09 16:55:22.232704-06', 2.37201, 1, 54.266, 13477),
	(13709, 1021, 26, '2026-06-09 16:55:22.232704-06', 2.75588, 1, 41.471, 13478),
	(13710, 905, 26, '2026-06-09 16:55:22.232704-06', 0.39622, 1, 79.874, 13479),
	(13711, 1018, 26, '2026-06-09 16:55:22.232704-06', 0.85859, 0, 71.380, 13480),
	(13712, 1036, 26, '2026-06-09 16:55:22.232704-06', 0.23398, 0, 92.201, 13481),
	(13713, 884, 26, '2026-06-09 16:55:22.232704-06', 1.31965, 0, 56.012, 13482),
	(13714, 1069, 26, '2026-06-09 16:55:22.232704-06', 0.50570, 0, 83.143, 13483),
	(13715, 910, 26, '2026-06-09 16:55:22.232704-06', 2.08661, 2, 97.113, 13484),
	(13716, 1020, 26, '2026-06-09 16:55:22.232704-06', 2.16874, 1, 61.042, 13485),
	(13717, 1151, 26, '2026-06-09 16:55:22.232704-06', 1.26492, 0, 57.836, 13486),
	(13718, 1165, 26, '2026-06-09 16:55:22.232704-06', 0.97294, 0, 67.569, 13487),
	(13719, 971, 26, '2026-06-09 16:55:22.232704-06', 1.66117, 1, 77.961, 13488),
	(13720, 1001, 26, '2026-06-09 16:55:22.232704-06', 1.37569, 1, 87.477, 13489),
	(13721, 1002, 26, '2026-06-09 16:55:22.232704-06', 1.69139, 1, 76.954, 13490),
	(13722, 983, 26, '2026-06-09 16:55:22.232704-06', 1.98816, 1, 67.061, 13491),
	(13723, 894, 26, '2026-06-09 16:55:22.232704-06', 2.97513, 3, 99.171, 13492),
	(13724, 981, 26, '2026-06-09 16:55:22.232704-06', 1.90771, 1, 69.743, 13493),
	(13725, 1012, 26, '2026-06-09 16:55:22.232704-06', 0.98454, 1, 99.485, 13494),
	(13726, 1022, 26, '2026-06-09 16:55:22.232704-06', 0.93249, 1, 97.750, 13495),
	(13727, 982, 26, '2026-06-09 16:55:22.232704-06', 0.45500, 1, 81.833, 13496),
	(13728, 836, 26, '2026-06-09 16:55:22.232704-06', 0.20664, 0, 93.112, 13497),
	(13729, 993, 26, '2026-06-09 16:55:22.232704-06', 2.88493, 1, 37.169, 13498),
	(13730, 1102, 26, '2026-06-09 16:55:22.232704-06', 0.43970, 0, 85.343, 13499),
	(13731, 1161, 26, '2026-06-09 16:55:22.232704-06', 0.96194, 0, 67.935, 13500),
	(13732, 1162, 26, '2026-06-09 16:55:22.232704-06', 0.54710, 0, 81.763, 13507),
	(13733, 1000, 26, '2026-06-09 16:55:22.232704-06', 0.90593, 1, 96.864, 13501),
	(13734, 1023, 26, '2026-06-09 16:55:22.232704-06', 2.28272, 1, 57.243, 13502),
	(13735, 893, 26, '2026-06-09 16:55:22.232704-06', 1.25100, 1, 91.633, 13503),
	(13736, 956, 26, '2026-06-09 16:55:22.232704-06', 2.22212, 1, 59.263, 13504),
	(13737, 923, 26, '2026-06-09 16:55:22.232704-06', 1.71288, 1, 76.237, 13505),
	(13738, 965, 26, '2026-06-09 16:55:22.232704-06', 1.29779, 2, 76.593, 13506),
	(13739, 1164, 26, '2026-06-09 16:55:22.232704-06', 1.91916, 0, 36.028, 13508),
	(13740, 1037, 26, '2026-06-09 16:55:22.232704-06', 1.65513, 1, 78.162, 13509),
	(13741, 1016, 26, '2026-06-09 16:55:22.232704-06', 2.07175, 1, 64.275, 13510),
	(13742, 1136, 26, '2026-06-09 16:55:22.232704-06', 1.66135, 0, 44.622, 13511),
	(13743, 990, 26, '2026-06-09 16:55:22.232704-06', 0.82077, 3, 27.359, 13512),
	(13744, 1116, 26, '2026-06-09 16:55:22.232704-06', 1.35413, 0, 54.862, 13513),
	(13745, 1135, 26, '2026-06-09 16:55:22.232704-06', 1.61313, 0, 46.229, 13514),
	(13746, 1137, 26, '2026-06-09 16:55:22.232704-06', 2.08924, 0, 30.359, 13515),
	(13747, 1095, 26, '2026-06-09 16:55:22.232704-06', 1.28761, 0, 57.080, 13516),
	(13748, 1058, 26, '2026-06-09 16:55:22.232704-06', 0.21573, 0, 92.809, 13517),
	(13749, 1083, 26, '2026-06-09 16:55:22.232704-06', 0.64376, 0, 78.541, 13518),
	(13750, 1087, 26, '2026-06-09 16:55:22.232704-06', 0.15975, 0, 94.675, 13519),
	(13751, 829, 26, '2026-06-09 16:55:22.232704-06', 1.62377, 0, 45.874, 13520),
	(13752, 1008, 26, '2026-06-09 16:55:22.232704-06', 2.82452, 1, 39.183, 13521),
	(13753, 860, 26, '2026-06-09 16:55:22.232704-06', 0.65297, 0, 78.234, 13522),
	(13754, 919, 26, '2026-06-09 16:55:22.232704-06', 0.77399, 0, 74.200, 13523),
	(13755, 938, 26, '2026-06-09 16:55:22.232704-06', 1.91774, 2, 97.258, 13524),
	(13756, 918, 26, '2026-06-09 16:55:22.232704-06', 0.83780, 1, 94.593, 13525),
	(13757, 1029, 26, '2026-06-09 16:55:22.232704-06', 1.83997, 1, 72.001, 13526),
	(13758, 912, 26, '2026-06-09 16:55:22.232704-06', 2.72442, 2, 75.853, 13527),
	(13759, 937, 26, '2026-06-09 16:55:22.232704-06', 0.69302, 3, 23.101, 13528),
	(13760, 882, 26, '2026-06-09 16:55:22.232704-06', 0.65911, 0, 78.030, 13529),
	(13761, 867, 26, '2026-06-09 16:55:22.232704-06', 0.58840, 0, 80.387, 13530),
	(13762, 886, 26, '2026-06-09 16:55:22.232704-06', 0.68610, 0, 77.130, 13531),
	(13763, 961, 26, '2026-06-09 16:55:22.232704-06', 1.71561, 3, 57.187, 13532),
	(13764, 1127, 26, '2026-06-09 16:55:22.232704-06', 1.55796, 0, 48.068, 13533),
	(13765, 1139, 26, '2026-06-09 16:55:22.232704-06', 1.07203, 0, 64.266, 13534),
	(13766, 1009, 26, '2026-06-09 16:55:22.232704-06', 1.91568, 1, 69.477, 13535),
	(13767, 936, 26, '2026-06-09 16:55:22.232704-06', 1.51496, 1, 82.835, 13536),
	(13768, 957, 26, '2026-06-09 16:55:22.232704-06', 1.78427, 1, 73.858, 13537),
	(13769, 902, 26, '2026-06-09 16:55:22.232704-06', 1.61992, 1, 79.336, 13538),
	(13770, 898, 26, '2026-06-09 16:55:22.232704-06', 1.83745, 2, 94.582, 13539),
	(13771, 998, 26, '2026-06-09 16:55:22.232704-06', 2.58172, 1, 47.276, 13540),
	(13772, 1040, 26, '2026-06-09 16:55:22.232704-06', 2.83881, 1, 38.706, 13541),
	(13773, 815, 26, '2026-06-09 16:55:22.232704-06', 0.37879, 0, 87.374, 13542),
	(13774, 1042, 26, '2026-06-09 16:55:22.232704-06', 1.70489, 1, 76.504, 13543),
	(13775, 1039, 26, '2026-06-09 16:55:22.232704-06', 1.39471, 1, 86.843, 13544),
	(13776, 974, 26, '2026-06-09 16:55:22.232704-06', 1.13802, 1, 95.399, 13545),
	(13777, 906, 26, '2026-06-09 16:55:22.232704-06', 1.31668, 2, 77.223, 13546),
	(13778, 1011, 26, '2026-06-09 16:55:22.232704-06', 2.05414, 1, 64.862, 13547),
	(13779, 913, 26, '2026-06-09 16:55:22.232704-06', 2.86678, 2, 71.107, 13548),
	(13780, 943, 26, '2026-06-09 16:55:22.232704-06', 1.83111, 1, 72.296, 13549),
	(13781, 975, 26, '2026-06-09 16:55:22.232704-06', 0.48685, 3, 16.228, 13550),
	(13782, 944, 26, '2026-06-09 16:55:22.232704-06', 1.97522, 1, 67.493, 13551),
	(13783, 1190, 26, '2026-06-09 16:55:22.232704-06', 2.05850, 0, 31.383, 13552),
	(13784, 1227, 26, '2026-06-09 16:55:22.232704-06', 0.70672, 0, 76.443, 13553),
	(13785, 1224, 26, '2026-06-09 16:55:22.232704-06', 1.67152, 0, 44.283, 13554),
	(13786, 1015, 26, '2026-06-09 16:55:22.232704-06', 1.50399, 1, 83.200, 13555),
	(13787, 880, 26, '2026-06-09 16:55:22.232704-06', 1.65431, 1, 78.190, 13556),
	(13788, 850, 26, '2026-06-09 16:55:22.232704-06', 0.61369, 0, 79.544, 13557),
	(13789, 948, 26, '2026-06-09 16:55:22.232704-06', 2.81487, 1, 39.504, 13558),
	(13790, 1149, 26, '2026-06-09 16:55:22.232704-06', 1.26415, 1, 91.195, 13559),
	(13791, 1055, 26, '2026-06-09 16:55:22.232704-06', 2.18424, 0, 27.192, 13560),
	(13792, 885, 26, '2026-06-09 16:55:22.232704-06', 1.30166, 0, 56.611, 13561),
	(13793, 1199, 26, '2026-06-09 16:56:01.489106-06', 0.85659, 0, 71.447, 13562),
	(13794, 1199, 26, '2026-06-09 16:57:36.104012-06', 0.57119, 0, 80.960, 13563),
	(13795, 1199, 26, '2026-06-09 16:57:57.7627-06', 0.60699, 0, 79.767, 13564),
	(13796, 1155, 26, '2026-06-09 16:58:00.176147-06', 0.95080, 0, 68.307, 13565),
	(13797, 1155, 26, '2026-06-09 16:58:01.380972-06', 1.00408, 0, 66.531, 13566),
	(13798, 1155, 26, '2026-06-09 16:58:02.821525-06', 0.82008, 0, 72.664, 13567),
	(13799, 1155, 26, '2026-06-09 16:58:04.235065-06', 0.96639, 0, 67.787, 13568),
	(13800, 1199, 26, '2026-06-09 16:58:16.507606-06', 0.55525, 0, 81.492, 13569),
	(13801, 975, 26, '2026-06-09 17:31:23.21532-06', 2.52343, 3, 84.114, 13570),
	(13802, 937, 26, '2026-06-09 17:54:55.775299-06', 2.56075, 3, 85.358, 13571),
	(13803, 1175, 26, '2026-06-09 17:56:28.745021-06', 0.62028, 0, 79.324, 13572),
	(13804, 1055, 26, '2026-06-09 17:56:56.831623-06', 0.44144, 0, 85.285, 13573);


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
	(230, 1043, 1, '2026-02-24 19:04:35.863572-06'),
	(229, 1042, 1, '2026-02-24 19:04:35.863091-06'),
	(228, 1041, 1, '2026-02-24 19:04:35.862441-06'),
	(227, 1040, 1, '2026-02-24 19:04:35.862-06'),
	(226, 1039, 1, '2026-02-24 19:04:35.861602-06'),
	(225, 1038, 1, '2026-02-24 19:04:35.861204-06'),
	(224, 1037, 1, '2026-02-24 19:04:35.860789-06'),
	(223, 1036, 1, '2026-02-24 19:04:35.860357-06'),
	(222, 1035, 1, '2026-02-24 19:04:35.859912-06'),
	(221, 1034, 1, '2026-02-24 19:04:35.859488-06'),
	(220, 1033, 1, '2026-02-24 19:04:35.859072-06'),
	(219, 1032, 1, '2026-02-24 19:04:35.858464-06'),
	(218, 1031, 1, '2026-02-24 19:04:35.857879-06'),
	(217, 1030, 1, '2026-02-24 19:04:35.857407-06'),
	(216, 1029, 1, '2026-02-24 19:04:35.856997-06'),
	(215, 1028, 1, '2026-02-24 19:04:35.856577-06'),
	(214, 1027, 1, '2026-02-24 19:04:35.856125-06'),
	(213, 1026, 1, '2026-02-24 19:04:35.855617-06'),
	(212, 1025, 1, '2026-02-24 19:04:35.855122-06'),
	(211, 1024, 1, '2026-02-24 19:04:35.854684-06'),
	(210, 1023, 1, '2026-02-24 19:04:35.854028-06'),
	(209, 1022, 1, '2026-02-24 19:04:35.853433-06'),
	(208, 1021, 1, '2026-02-24 19:04:35.852923-06'),
	(207, 1020, 1, '2026-02-24 19:04:35.852498-06'),
	(206, 1019, 1, '2026-02-24 19:04:35.851878-06'),
	(205, 1018, 1, '2026-02-24 19:04:35.851472-06'),
	(204, 1017, 1, '2026-02-24 19:04:35.851058-06'),
	(203, 1016, 1, '2026-02-24 19:04:35.850657-06'),
	(202, 1015, 1, '2026-02-24 19:04:35.850236-06'),
	(201, 1014, 1, '2026-02-24 19:04:35.84981-06'),
	(231, 830, 2, '2026-03-04 21:54:04.761008-06'),
	(232, 831, 2, '2026-03-04 21:54:04.761008-06'),
	(233, 832, 2, '2026-03-04 21:54:04.761008-06'),
	(234, 833, 2, '2026-03-04 21:54:04.761008-06'),
	(235, 836, 2, '2026-03-04 21:54:04.761008-06'),
	(236, 837, 2, '2026-03-04 21:54:04.761008-06'),
	(237, 817, 2, '2026-03-04 21:54:04.761008-06'),
	(238, 834, 2, '2026-03-04 21:54:04.761008-06'),
	(239, 839, 2, '2026-03-04 21:54:04.761008-06'),
	(240, 841, 2, '2026-03-04 21:54:04.761008-06'),
	(241, 842, 2, '2026-03-04 21:54:04.761008-06'),
	(242, 843, 2, '2026-03-04 21:54:04.761008-06'),
	(243, 844, 2, '2026-03-04 21:54:04.761008-06'),
	(244, 845, 2, '2026-03-04 21:54:04.761008-06'),
	(245, 846, 2, '2026-03-04 21:54:04.761008-06'),
	(246, 848, 2, '2026-03-04 21:54:04.761008-06'),
	(247, 849, 2, '2026-03-04 21:54:04.761008-06'),
	(248, 850, 2, '2026-03-04 21:54:04.761008-06'),
	(249, 851, 2, '2026-03-04 21:54:04.761008-06'),
	(250, 853, 2, '2026-03-04 21:54:04.761008-06'),
	(251, 873, 2, '2026-03-04 21:54:04.761008-06'),
	(252, 857, 2, '2026-03-04 21:54:04.761008-06'),
	(253, 858, 2, '2026-03-04 21:54:04.761008-06'),
	(254, 859, 2, '2026-03-04 21:54:04.761008-06'),
	(255, 860, 2, '2026-03-04 21:54:04.761008-06'),
	(256, 868, 2, '2026-03-04 21:54:04.761008-06'),
	(257, 864, 2, '2026-03-04 21:54:04.761008-06'),
	(258, 862, 2, '2026-03-04 21:54:04.761008-06'),
	(259, 835, 2, '2026-03-04 21:54:04.761008-06'),
	(260, 854, 2, '2026-03-04 21:54:04.761008-06'),
	(261, 855, 2, '2026-03-04 21:54:04.761008-06'),
	(262, 856, 2, '2026-03-04 21:54:04.761008-06'),
	(263, 861, 2, '2026-03-04 21:54:04.761008-06'),
	(264, 865, 2, '2026-03-04 21:54:04.761008-06'),
	(265, 819, 2, '2026-03-04 21:54:04.761008-06'),
	(266, 818, 2, '2026-03-04 21:54:04.761008-06'),
	(267, 820, 2, '2026-03-04 21:54:04.761008-06'),
	(268, 824, 2, '2026-03-04 21:54:04.761008-06'),
	(269, 822, 2, '2026-03-04 21:54:04.761008-06'),
	(270, 821, 2, '2026-03-04 21:54:04.761008-06'),
	(271, 815, 2, '2026-03-04 21:54:04.761008-06'),
	(272, 825, 2, '2026-03-04 21:54:04.761008-06'),
	(273, 827, 2, '2026-03-04 21:54:04.761008-06'),
	(274, 866, 2, '2026-03-04 21:54:04.761008-06'),
	(275, 840, 2, '2026-03-04 21:54:04.761008-06'),
	(276, 891, 2, '2026-03-04 21:54:04.761008-06'),
	(277, 894, 2, '2026-03-04 21:54:04.761008-06'),
	(278, 895, 2, '2026-03-04 21:54:04.761008-06'),
	(279, 896, 2, '2026-03-04 21:54:04.761008-06'),
	(280, 897, 2, '2026-03-04 21:54:04.761008-06'),
	(281, 898, 2, '2026-03-04 21:54:04.761008-06'),
	(282, 899, 2, '2026-03-04 21:54:04.761008-06'),
	(283, 901, 2, '2026-03-04 21:54:04.761008-06'),
	(284, 900, 2, '2026-03-04 21:54:04.761008-06'),
	(285, 903, 2, '2026-03-04 21:54:04.761008-06'),
	(286, 904, 2, '2026-03-04 21:54:04.761008-06'),
	(287, 905, 2, '2026-03-04 21:54:04.761008-06'),
	(288, 907, 2, '2026-03-04 21:54:04.761008-06'),
	(289, 908, 2, '2026-03-04 21:54:04.761008-06'),
	(290, 909, 2, '2026-03-04 21:54:04.761008-06'),
	(291, 910, 2, '2026-03-04 21:54:04.761008-06'),
	(292, 911, 2, '2026-03-04 21:54:04.761008-06'),
	(293, 913, 2, '2026-03-04 21:54:04.761008-06'),
	(294, 915, 2, '2026-03-04 21:54:04.761008-06'),
	(295, 916, 2, '2026-03-04 21:54:04.761008-06'),
	(296, 917, 2, '2026-03-04 21:54:04.761008-06'),
	(297, 920, 2, '2026-03-04 21:54:04.761008-06'),
	(298, 919, 2, '2026-03-04 21:54:04.761008-06'),
	(299, 921, 2, '2026-03-04 21:54:04.761008-06'),
	(300, 922, 2, '2026-03-04 21:54:04.761008-06'),
	(301, 923, 2, '2026-03-04 21:54:04.761008-06'),
	(302, 927, 2, '2026-03-04 21:54:04.761008-06'),
	(303, 925, 2, '2026-03-04 21:54:04.761008-06'),
	(304, 926, 2, '2026-03-04 21:54:04.761008-06'),
	(305, 929, 2, '2026-03-04 21:54:04.761008-06'),
	(306, 930, 2, '2026-03-04 21:54:04.761008-06'),
	(307, 931, 2, '2026-03-04 21:54:04.761008-06'),
	(308, 932, 2, '2026-03-04 21:54:04.761008-06'),
	(309, 934, 2, '2026-03-04 21:54:04.761008-06'),
	(310, 935, 2, '2026-03-04 21:54:04.761008-06'),
	(311, 936, 2, '2026-03-04 21:54:04.761008-06'),
	(312, 889, 2, '2026-03-04 21:54:04.761008-06'),
	(313, 872, 2, '2026-03-04 21:54:04.761008-06'),
	(314, 875, 2, '2026-03-04 21:54:04.761008-06'),
	(315, 869, 2, '2026-03-04 21:54:04.761008-06'),
	(316, 876, 2, '2026-03-04 21:54:04.761008-06'),
	(317, 870, 2, '2026-03-04 21:54:04.761008-06'),
	(318, 890, 2, '2026-03-04 21:54:04.761008-06'),
	(319, 814, 2, '2026-03-04 21:54:04.761008-06'),
	(320, 877, 2, '2026-03-04 21:54:04.761008-06'),
	(321, 878, 2, '2026-03-04 21:54:04.761008-06'),
	(322, 880, 2, '2026-03-04 21:54:04.761008-06'),
	(323, 881, 2, '2026-03-04 21:54:04.761008-06'),
	(324, 883, 2, '2026-03-04 21:54:04.761008-06'),
	(325, 816, 2, '2026-03-04 21:54:04.761008-06'),
	(326, 884, 2, '2026-03-04 21:54:04.761008-06'),
	(327, 885, 2, '2026-03-04 21:54:04.761008-06'),
	(328, 826, 2, '2026-03-04 21:54:04.761008-06'),
	(329, 893, 2, '2026-03-04 21:54:04.761008-06'),
	(330, 886, 2, '2026-03-04 21:54:04.761008-06'),
	(331, 887, 2, '2026-03-04 21:54:04.761008-06'),
	(332, 888, 2, '2026-03-04 21:54:04.761008-06'),
	(333, 983, 2, '2026-03-04 21:54:04.761008-06'),
	(334, 981, 2, '2026-03-04 21:54:04.761008-06'),
	(335, 939, 2, '2026-03-04 21:54:04.761008-06'),
	(336, 940, 2, '2026-03-04 21:54:04.761008-06'),
	(337, 941, 2, '2026-03-04 21:54:04.761008-06'),
	(338, 974, 2, '2026-03-04 21:54:04.761008-06'),
	(339, 942, 2, '2026-03-04 21:54:04.761008-06'),
	(340, 943, 2, '2026-03-04 21:54:04.761008-06'),
	(341, 944, 2, '2026-03-04 21:54:04.761008-06'),
	(342, 945, 2, '2026-03-04 21:54:04.761008-06'),
	(343, 946, 2, '2026-03-04 21:54:04.761008-06'),
	(344, 947, 2, '2026-03-04 21:54:04.761008-06'),
	(345, 948, 2, '2026-03-04 21:54:04.761008-06'),
	(346, 950, 2, '2026-03-04 21:54:04.761008-06'),
	(347, 951, 2, '2026-03-04 21:54:04.761008-06'),
	(348, 952, 2, '2026-03-04 21:54:04.761008-06'),
	(349, 953, 2, '2026-03-04 21:54:04.761008-06'),
	(350, 976, 2, '2026-03-04 21:54:04.761008-06'),
	(351, 977, 2, '2026-03-04 21:54:04.761008-06'),
	(352, 955, 2, '2026-03-04 21:54:04.761008-06'),
	(353, 956, 2, '2026-03-04 21:54:04.761008-06'),
	(354, 957, 2, '2026-03-04 21:54:04.761008-06'),
	(355, 958, 2, '2026-03-04 21:54:04.761008-06'),
	(356, 960, 2, '2026-03-04 21:54:04.761008-06'),
	(357, 962, 2, '2026-03-04 21:54:04.761008-06'),
	(358, 985, 2, '2026-03-04 21:54:04.761008-06'),
	(359, 963, 2, '2026-03-04 21:54:04.761008-06'),
	(360, 964, 2, '2026-03-04 21:54:04.761008-06'),
	(361, 965, 2, '2026-03-04 21:54:04.761008-06'),
	(362, 978, 2, '2026-03-04 21:54:04.761008-06'),
	(363, 968, 2, '2026-03-04 21:54:04.761008-06'),
	(364, 967, 2, '2026-03-04 21:54:04.761008-06'),
	(365, 979, 2, '2026-03-04 21:54:04.761008-06'),
	(366, 980, 2, '2026-03-04 21:54:04.761008-06'),
	(367, 969, 2, '2026-03-04 21:54:04.761008-06'),
	(368, 971, 2, '2026-03-04 21:54:04.761008-06'),
	(369, 972, 2, '2026-03-04 21:54:04.761008-06'),
	(370, 973, 2, '2026-03-04 21:54:04.761008-06'),
	(371, 986, 2, '2026-03-04 21:54:04.761008-06'),
	(372, 987, 2, '2026-03-04 21:54:04.761008-06'),
	(373, 1000, 2, '2026-03-04 21:54:04.761008-06'),
	(374, 993, 2, '2026-03-04 21:54:04.761008-06'),
	(375, 990, 2, '2026-03-04 21:54:04.761008-06'),
	(376, 999, 2, '2026-03-04 21:54:04.761008-06'),
	(377, 994, 2, '2026-03-04 21:54:04.761008-06'),
	(378, 995, 2, '2026-03-04 21:54:04.761008-06'),
	(379, 989, 2, '2026-03-04 21:54:04.761008-06'),
	(380, 996, 2, '2026-03-04 21:54:04.761008-06'),
	(381, 997, 2, '2026-03-04 21:54:04.761008-06'),
	(382, 991, 2, '2026-03-04 21:54:04.761008-06'),
	(383, 975, 2, '2026-03-04 21:54:04.761008-06'),
	(384, 998, 2, '2026-03-04 21:54:04.761008-06'),
	(385, 949, 2, '2026-03-04 21:54:04.761008-06'),
	(386, 959, 2, '2026-03-04 21:54:04.761008-06'),
	(387, 1015, 2, '2026-03-04 21:54:04.761008-06'),
	(388, 1020, 2, '2026-03-04 21:54:04.761008-06'),
	(389, 1014, 2, '2026-03-04 21:54:04.761008-06'),
	(390, 1021, 2, '2026-03-04 21:54:04.761008-06'),
	(391, 871, 2, '2026-03-04 21:54:04.761008-06'),
	(392, 1019, 2, '2026-03-04 21:54:04.761008-06'),
	(393, 1022, 2, '2026-03-04 21:54:04.761008-06'),
	(394, 1017, 2, '2026-03-04 21:54:04.761008-06'),
	(395, 1018, 2, '2026-03-04 21:54:04.761008-06'),
	(396, 1023, 2, '2026-03-04 21:54:04.761008-06'),
	(397, 1024, 2, '2026-03-04 21:54:04.761008-06'),
	(398, 1001, 2, '2026-03-04 21:54:04.761008-06'),
	(399, 1002, 2, '2026-03-04 21:54:04.761008-06'),
	(400, 1003, 2, '2026-03-04 21:54:04.761008-06'),
	(401, 1005, 2, '2026-03-04 21:54:04.761008-06'),
	(402, 1006, 2, '2026-03-04 21:54:04.761008-06'),
	(403, 1025, 2, '2026-03-04 21:54:04.761008-06'),
	(404, 1026, 2, '2026-03-04 21:54:04.761008-06'),
	(405, 1007, 2, '2026-03-04 21:54:04.761008-06'),
	(406, 1029, 2, '2026-03-04 21:54:04.761008-06'),
	(407, 1030, 2, '2026-03-04 21:54:04.761008-06'),
	(408, 1028, 2, '2026-03-04 21:54:04.761008-06'),
	(409, 1031, 2, '2026-03-04 21:54:04.761008-06'),
	(410, 1027, 2, '2026-03-04 21:54:04.761008-06'),
	(411, 1032, 2, '2026-03-04 21:54:04.761008-06'),
	(412, 1009, 2, '2026-03-04 21:54:04.761008-06'),
	(413, 1004, 2, '2026-03-04 21:54:04.761008-06'),
	(414, 1010, 2, '2026-03-04 21:54:04.761008-06'),
	(415, 1012, 2, '2026-03-04 21:54:04.761008-06'),
	(416, 823, 2, '2026-03-04 21:54:04.761008-06'),
	(417, 829, 2, '2026-03-04 21:54:04.761008-06'),
	(418, 838, 2, '2026-03-04 21:54:04.761008-06'),
	(419, 852, 2, '2026-03-04 21:54:04.761008-06'),
	(420, 982, 2, '2026-03-04 21:54:04.761008-06'),
	(421, 892, 2, '2026-03-04 21:54:04.761008-06'),
	(422, 902, 2, '2026-03-04 21:54:04.761008-06'),
	(423, 914, 2, '2026-03-04 21:54:04.761008-06'),
	(424, 928, 2, '2026-03-04 21:54:04.761008-06'),
	(425, 1013, 2, '2026-03-04 21:54:04.761008-06'),
	(426, 1016, 2, '2026-03-04 21:54:04.761008-06'),
	(427, 1033, 2, '2026-03-04 21:54:04.761008-06'),
	(428, 1034, 2, '2026-03-04 21:54:04.761008-06'),
	(429, 1036, 2, '2026-03-04 21:54:04.761008-06'),
	(430, 1037, 2, '2026-03-04 21:54:04.761008-06'),
	(431, 1038, 2, '2026-03-04 21:54:04.761008-06'),
	(432, 1039, 2, '2026-03-04 21:54:04.761008-06'),
	(433, 1040, 2, '2026-03-04 21:54:04.761008-06'),
	(434, 1042, 2, '2026-03-04 21:54:04.761008-06'),
	(435, 1043, 2, '2026-03-04 21:54:04.761008-06'),
	(436, 863, 2, '2026-03-04 21:54:04.761008-06'),
	(437, 828, 2, '2026-03-04 21:54:04.761008-06'),
	(438, 906, 2, '2026-03-04 21:54:04.761008-06'),
	(439, 912, 2, '2026-03-04 21:54:04.761008-06'),
	(440, 918, 2, '2026-03-04 21:54:04.761008-06'),
	(441, 924, 2, '2026-03-04 21:54:04.761008-06'),
	(442, 933, 2, '2026-03-04 21:54:04.761008-06'),
	(443, 874, 2, '2026-03-04 21:54:04.761008-06'),
	(444, 937, 2, '2026-03-04 21:54:04.761008-06'),
	(445, 984, 2, '2026-03-04 21:54:04.761008-06'),
	(446, 954, 2, '2026-03-04 21:54:04.761008-06'),
	(447, 961, 2, '2026-03-04 21:54:04.761008-06'),
	(448, 966, 2, '2026-03-04 21:54:04.761008-06'),
	(449, 970, 2, '2026-03-04 21:54:04.761008-06'),
	(450, 992, 2, '2026-03-04 21:54:04.761008-06'),
	(451, 847, 2, '2026-03-04 21:54:04.761008-06'),
	(452, 938, 2, '2026-03-04 21:54:04.761008-06'),
	(453, 988, 2, '2026-03-04 21:54:04.761008-06'),
	(454, 1011, 2, '2026-03-04 21:54:04.761008-06'),
	(455, 1008, 2, '2026-03-04 21:54:04.761008-06'),
	(456, 867, 2, '2026-03-04 21:54:04.761008-06'),
	(457, 879, 2, '2026-03-04 21:54:04.761008-06'),
	(458, 1035, 2, '2026-03-04 21:54:04.761008-06'),
	(459, 1041, 2, '2026-03-04 21:54:04.761008-06'),
	(460, 882, 2, '2026-03-04 21:54:04.761008-06'),
	(461, 1044, 1, '2026-03-14 19:10:41.230033-06'),
	(462, 1045, 1, '2026-04-14 21:31:32.859931-06'),
	(463, 1046, 1, '2026-04-14 21:31:32.868546-06'),
	(464, 1047, 1, '2026-04-14 21:31:32.869559-06'),
	(465, 1048, 1, '2026-04-14 21:31:32.870366-06'),
	(466, 1049, 1, '2026-04-14 21:31:32.871052-06'),
	(467, 1050, 1, '2026-04-14 21:31:32.871609-06'),
	(468, 1051, 1, '2026-04-14 21:31:32.872103-06'),
	(469, 1052, 1, '2026-04-14 21:31:32.872595-06'),
	(470, 1053, 1, '2026-04-14 21:31:32.873127-06'),
	(471, 1054, 1, '2026-04-14 21:31:32.873615-06'),
	(472, 1055, 1, '2026-04-14 21:31:32.874155-06'),
	(473, 1056, 1, '2026-04-14 21:31:32.87467-06'),
	(474, 1057, 1, '2026-04-14 21:31:32.87522-06'),
	(475, 1058, 1, '2026-04-14 21:31:32.875696-06'),
	(476, 1059, 1, '2026-04-14 21:31:32.876186-06'),
	(477, 1060, 1, '2026-04-14 21:31:32.876638-06'),
	(478, 1061, 1, '2026-04-14 21:31:32.877187-06'),
	(479, 1062, 1, '2026-04-14 21:31:32.877667-06'),
	(480, 1063, 1, '2026-04-14 21:31:32.878207-06'),
	(481, 1064, 1, '2026-04-14 21:31:32.878644-06'),
	(482, 1065, 1, '2026-04-14 21:31:32.879091-06'),
	(483, 1066, 1, '2026-04-14 21:31:32.879738-06'),
	(484, 1067, 1, '2026-04-14 21:31:32.880266-06'),
	(485, 1068, 1, '2026-04-14 21:31:32.88116-06'),
	(486, 1069, 1, '2026-04-14 21:31:32.881767-06'),
	(487, 1070, 1, '2026-04-14 21:31:32.88225-06'),
	(488, 1071, 1, '2026-04-14 21:31:32.882672-06'),
	(489, 1072, 1, '2026-04-14 21:31:32.883077-06'),
	(490, 1073, 1, '2026-04-14 21:31:32.883804-06'),
	(491, 1074, 1, '2026-04-14 21:31:32.884321-06'),
	(492, 1075, 1, '2026-04-14 21:31:32.884766-06'),
	(493, 1076, 1, '2026-04-14 21:31:32.885258-06'),
	(494, 1077, 1, '2026-04-14 21:31:32.885839-06'),
	(495, 1078, 1, '2026-04-14 21:31:32.886344-06'),
	(496, 1079, 1, '2026-04-14 21:31:32.886765-06'),
	(497, 1080, 1, '2026-04-14 21:31:32.887313-06'),
	(498, 1081, 1, '2026-04-14 21:31:32.887824-06'),
	(499, 1082, 1, '2026-04-14 21:31:32.888344-06'),
	(500, 1083, 1, '2026-04-14 21:31:32.888849-06');
INSERT INTO public.rel_playlists_canciones OVERRIDING SYSTEM VALUE VALUES
	(501, 1084, 1, '2026-04-14 21:31:32.889387-06'),
	(502, 1085, 1, '2026-04-14 21:31:32.889926-06'),
	(503, 1086, 1, '2026-04-14 21:31:32.890663-06'),
	(504, 1087, 1, '2026-04-14 21:31:32.891365-06'),
	(505, 1088, 1, '2026-04-14 21:31:32.891882-06'),
	(506, 1089, 1, '2026-04-14 21:31:32.892364-06'),
	(507, 1090, 1, '2026-04-14 21:31:32.892807-06'),
	(508, 1091, 1, '2026-04-14 21:31:32.893505-06'),
	(509, 1092, 1, '2026-04-14 21:31:32.893955-06'),
	(510, 1093, 1, '2026-04-14 21:31:32.894394-06'),
	(511, 1094, 1, '2026-04-14 21:31:32.895016-06'),
	(512, 1095, 1, '2026-04-14 21:31:32.895595-06'),
	(513, 1096, 1, '2026-04-14 21:31:32.898489-06'),
	(514, 1097, 1, '2026-04-14 21:31:32.899329-06'),
	(515, 1098, 1, '2026-04-14 21:31:32.899866-06'),
	(516, 1099, 1, '2026-04-14 21:31:32.900423-06'),
	(517, 1100, 1, '2026-04-14 21:31:32.901352-06'),
	(518, 1101, 1, '2026-04-14 21:31:32.901909-06'),
	(519, 1102, 1, '2026-04-14 21:31:32.902539-06'),
	(520, 1103, 1, '2026-04-14 21:31:32.903233-06'),
	(521, 1104, 1, '2026-04-14 21:31:32.903939-06'),
	(522, 1105, 1, '2026-04-14 21:31:32.904702-06'),
	(523, 1106, 1, '2026-04-14 21:31:32.905309-06'),
	(524, 1107, 1, '2026-04-14 21:31:32.905844-06'),
	(525, 1108, 1, '2026-04-14 21:31:32.906316-06'),
	(526, 1109, 1, '2026-04-14 21:31:32.906851-06'),
	(527, 1110, 1, '2026-04-14 21:31:32.907286-06'),
	(528, 1111, 1, '2026-04-14 21:31:32.907775-06'),
	(529, 1112, 1, '2026-04-14 21:31:32.908216-06'),
	(530, 1113, 1, '2026-04-14 21:31:32.90903-06'),
	(531, 1114, 1, '2026-04-23 19:22:26.224054-06'),
	(532, 1115, 1, '2026-05-08 18:27:49.998052-06'),
	(533, 1116, 1, '2026-05-08 18:27:50.005903-06'),
	(534, 1117, 1, '2026-05-08 18:27:50.006541-06'),
	(535, 1118, 1, '2026-05-08 18:27:50.007217-06'),
	(536, 1119, 1, '2026-05-08 18:27:50.007763-06'),
	(537, 1120, 1, '2026-05-08 18:27:50.008447-06'),
	(538, 1121, 1, '2026-05-08 18:27:50.009121-06'),
	(539, 1122, 1, '2026-05-08 18:27:50.009678-06'),
	(540, 1123, 1, '2026-05-08 18:27:50.010265-06'),
	(541, 1124, 1, '2026-05-08 18:27:50.010747-06'),
	(542, 1125, 1, '2026-05-08 18:27:50.011172-06'),
	(543, 1126, 1, '2026-05-08 18:27:50.011588-06'),
	(544, 1127, 1, '2026-05-08 18:52:30.276392-06'),
	(545, 1128, 1, '2026-05-08 18:52:30.277758-06'),
	(546, 1129, 1, '2026-05-08 18:52:30.278703-06'),
	(547, 1130, 1, '2026-05-08 18:52:30.2796-06'),
	(548, 1131, 1, '2026-05-08 18:52:30.280442-06'),
	(549, 1132, 1, '2026-05-08 18:52:30.281243-06'),
	(550, 1133, 1, '2026-05-08 18:52:30.281933-06'),
	(551, 1134, 1, '2026-05-08 18:52:30.282416-06'),
	(552, 1135, 1, '2026-05-08 18:52:30.282911-06'),
	(553, 1136, 1, '2026-05-08 18:52:30.283431-06'),
	(554, 1137, 1, '2026-05-08 18:52:30.284132-06'),
	(555, 1138, 1, '2026-05-08 18:52:30.284687-06'),
	(556, 1139, 1, '2026-05-08 18:52:30.285213-06'),
	(557, 1140, 1, '2026-05-08 18:52:30.285759-06'),
	(558, 1141, 1, '2026-05-08 18:52:30.286383-06'),
	(559, 1142, 1, '2026-05-08 18:52:30.286941-06'),
	(560, 1143, 1, '2026-05-08 18:52:30.287666-06'),
	(561, 1144, 1, '2026-05-08 18:52:30.288433-06'),
	(562, 1145, 1, '2026-05-08 18:52:30.289355-06'),
	(563, 1146, 1, '2026-05-08 18:52:30.290239-06'),
	(564, 1147, 1, '2026-05-08 18:52:30.29104-06'),
	(565, 1148, 1, '2026-05-08 18:52:30.291845-06'),
	(566, 1149, 1, '2026-05-08 18:52:30.292456-06'),
	(567, 1150, 1, '2026-05-08 18:52:30.292897-06'),
	(568, 1151, 1, '2026-05-08 18:52:30.293327-06'),
	(569, 1152, 1, '2026-05-08 18:52:30.293914-06'),
	(570, 1153, 1, '2026-05-08 18:52:30.294417-06'),
	(571, 1154, 1, '2026-05-08 18:52:30.297722-06'),
	(572, 1155, 1, '2026-05-08 18:52:30.29831-06'),
	(573, 1156, 1, '2026-05-08 18:52:30.298803-06'),
	(574, 1157, 1, '2026-05-08 18:52:30.299247-06'),
	(575, 1158, 1, '2026-05-08 18:52:30.299676-06'),
	(576, 1159, 1, '2026-05-08 18:52:30.300108-06'),
	(577, 1160, 1, '2026-05-08 18:52:30.300512-06'),
	(578, 1161, 1, '2026-05-08 18:52:30.300986-06'),
	(579, 1162, 1, '2026-05-08 18:52:30.301404-06'),
	(580, 1163, 1, '2026-05-08 18:52:30.301862-06'),
	(581, 1164, 1, '2026-05-08 18:52:30.302298-06'),
	(582, 1165, 1, '2026-05-08 18:52:30.302753-06'),
	(583, 1166, 1, '2026-05-08 18:52:30.303274-06'),
	(584, 1167, 1, '2026-05-08 18:52:30.303844-06'),
	(585, 1168, 1, '2026-05-08 18:52:30.304403-06'),
	(586, 1169, 1, '2026-05-08 18:52:30.304954-06'),
	(587, 1170, 1, '2026-05-08 18:52:30.30551-06'),
	(588, 1171, 1, '2026-05-08 18:52:30.306037-06'),
	(589, 1172, 1, '2026-05-08 18:52:30.306472-06'),
	(590, 1173, 1, '2026-05-08 18:52:30.306902-06'),
	(591, 1174, 1, '2026-05-08 18:52:30.307424-06'),
	(592, 1175, 1, '2026-05-08 18:52:30.30796-06'),
	(593, 1176, 1, '2026-05-08 18:52:30.308481-06'),
	(594, 1177, 1, '2026-05-08 18:52:30.309008-06'),
	(595, 1178, 1, '2026-05-08 18:52:30.309514-06'),
	(596, 1179, 1, '2026-05-08 18:52:30.310176-06'),
	(597, 1180, 1, '2026-05-08 18:52:30.310695-06'),
	(598, 1181, 1, '2026-05-08 18:52:30.311208-06'),
	(599, 1182, 1, '2026-05-08 18:52:30.311689-06'),
	(600, 1183, 1, '2026-05-08 18:52:30.312134-06'),
	(601, 1184, 1, '2026-05-08 18:52:30.312579-06'),
	(602, 1185, 1, '2026-05-08 18:52:30.313059-06'),
	(603, 1186, 1, '2026-05-08 18:52:30.313649-06'),
	(604, 1187, 1, '2026-05-08 18:52:30.314232-06'),
	(605, 1188, 1, '2026-05-08 18:52:30.314845-06'),
	(606, 1189, 1, '2026-05-08 18:52:30.315614-06'),
	(607, 1190, 1, '2026-05-08 18:52:30.316331-06'),
	(608, 1191, 1, '2026-05-08 18:52:30.316926-06'),
	(609, 1192, 1, '2026-05-08 18:52:30.317491-06'),
	(610, 1193, 1, '2026-05-08 18:52:30.318104-06'),
	(611, 1194, 1, '2026-05-08 18:52:30.318615-06'),
	(612, 1195, 1, '2026-05-08 18:52:30.319052-06'),
	(613, 1196, 1, '2026-05-08 18:52:30.31946-06'),
	(614, 1197, 1, '2026-05-08 18:52:30.320007-06'),
	(615, 1198, 1, '2026-05-08 18:52:30.320528-06'),
	(616, 1199, 1, '2026-05-08 18:52:30.321096-06'),
	(617, 1200, 1, '2026-05-08 18:52:30.321657-06'),
	(618, 1201, 1, '2026-05-08 18:52:30.322114-06'),
	(619, 1202, 1, '2026-05-08 18:52:30.322518-06'),
	(620, 1203, 1, '2026-05-08 18:52:30.322939-06'),
	(621, 1204, 1, '2026-05-08 18:52:30.323345-06'),
	(622, 1205, 1, '2026-05-08 18:52:30.32382-06'),
	(623, 1206, 1, '2026-05-08 18:52:30.324367-06'),
	(624, 1207, 1, '2026-05-08 18:52:30.324803-06'),
	(625, 1208, 1, '2026-05-08 18:52:30.325278-06'),
	(626, 1209, 1, '2026-05-08 18:52:30.325681-06'),
	(627, 1210, 1, '2026-05-08 18:52:30.326097-06'),
	(628, 1211, 1, '2026-05-08 18:52:30.326723-06'),
	(629, 1212, 1, '2026-05-08 18:52:30.327174-06'),
	(630, 1213, 1, '2026-05-08 18:52:30.327582-06'),
	(631, 1214, 1, '2026-05-08 18:52:30.32801-06'),
	(632, 1215, 1, '2026-05-08 18:52:30.328444-06'),
	(633, 1216, 1, '2026-05-08 18:52:30.328842-06'),
	(634, 1217, 1, '2026-05-08 18:52:30.329249-06'),
	(635, 1218, 1, '2026-05-08 18:52:30.329696-06'),
	(636, 1219, 1, '2026-05-08 18:52:30.330145-06'),
	(637, 1220, 1, '2026-05-08 18:52:30.330668-06'),
	(638, 1221, 1, '2026-05-08 18:52:30.331123-06'),
	(639, 1222, 1, '2026-05-08 18:52:30.331575-06'),
	(640, 1223, 1, '2026-05-08 18:52:30.33197-06'),
	(641, 1224, 1, '2026-05-08 18:52:30.332359-06'),
	(642, 1225, 1, '2026-05-08 18:52:30.332847-06'),
	(643, 1226, 1, '2026-05-08 18:52:30.333241-06'),
	(644, 1227, 1, '2026-05-08 18:52:30.33367-06'),
	(645, 1228, 1, '2026-05-08 18:52:30.334096-06'),
	(646, 1229, 1, '2026-05-08 18:52:30.334491-06'),
	(647, 1230, 1, '2026-05-08 18:52:30.334888-06');


--
-- Data for Name: tipos_datos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tipos_datos OVERRIDING SYSTEM VALUE VALUES
	(1, 'archivo', 'file', 'archivos que se guardan en disco con formato .mp3 (primeras pruebas)'),
	(2, 'enlace', 'link', 'enlaces extraidos de otros sitios (por definir)');


--
-- Data for Name: ts_modelos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ts_modelos OVERRIDING SYSTEM VALUE VALUES
	(26, B'1', 365, 76, '2026-06-09 16:36:59.886099-06', 'model_global', 0.468855, 0.7644, 9, B'1', 0.00100000, 32, 4, 304, '{"type":"sequential","layers":[{"type":"dense","units":256,"activation":"relu","init":"heNormal"},{"type":"dropout","rate":0.2},{"type":"dense","units":128,"activation":"relu","init":"heNormal"},{"type":"dropout","rate":0.2},{"type":"dense","units":4,"activation":"softmax","note":"clasificación 4 clases"}]}');


--
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Name: canciones_evaluadas_ce_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.canciones_evaluadas_ce_id_seq', 1230, true);


--
-- Name: entrenamientos_en_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.entrenamientos_en_id_seq', 13573, true);


--
-- Name: playlists_pl_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.playlists_pl_id_seq', 2, true);


--
-- Name: predicciones_pd_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.predicciones_pd_id_seq', 13804, true);


--
-- Name: rel_playlists_canciones_pc_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rel_playlists_canciones_pc_id_seq', 647, true);


--
-- Name: tipos_datos_td_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tipos_datos_td_id_seq', 2, true);


--
-- Name: ts_modelos_ts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ts_modelos_ts_id_seq', 26, true);


--
-- Name: usuarios_us_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuarios_us_id_seq', 1, false);


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
-- Name: entrenamientos unique_entrenamientos_en_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entrenamientos
    ADD CONSTRAINT unique_entrenamientos_en_id UNIQUE (en_id);


--
-- Name: playlists unique_playlists_pl_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlists
    ADD CONSTRAINT unique_playlists_pl_id UNIQUE (pl_id);


--
-- Name: predicciones unique_predicciones_pd_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.predicciones
    ADD CONSTRAINT unique_predicciones_pd_id UNIQUE (pd_id);


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
-- Name: usuarios unique_usuarios_us_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT unique_usuarios_us_id UNIQUE (us_id);


--
-- Name: index_ca_us_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_ca_us_id ON public.canciones USING btree (ca_us_id);


--
-- Name: index_en_id_cancion; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_en_id_cancion ON public.entrenamientos USING btree (en_id_cancion);


--
-- Name: index_en_id_modelo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_en_id_modelo ON public.entrenamientos USING btree (en_id_modelo);


--
-- Name: index_pd_id_cancion; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_pd_id_cancion ON public.predicciones USING btree (pd_id_cancion);


--
-- Name: index_pd_id_modelo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_pd_id_modelo ON public.predicciones USING btree (pd_id_modelo);


--
-- Name: index_pl_us_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_pl_us_id ON public.playlists USING btree (pl_us_id);


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
-- Name: entrenamientos link_canciones_entrenamientos; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entrenamientos
    ADD CONSTRAINT link_canciones_entrenamientos FOREIGN KEY (en_id_cancion) REFERENCES public.canciones(ca_id) MATCH FULL ON UPDATE CASCADE;


--
-- Name: predicciones link_canciones_predicciones; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.predicciones
    ADD CONSTRAINT link_canciones_predicciones FOREIGN KEY (pd_id_cancion) REFERENCES public.canciones(ca_id) MATCH FULL ON UPDATE CASCADE;


--
-- Name: rel_playlists_canciones link_canciones_rel_playlists_canciones; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rel_playlists_canciones
    ADD CONSTRAINT link_canciones_rel_playlists_canciones FOREIGN KEY (pr_ca_id) REFERENCES public.canciones(ca_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: predicciones link_entrenamientos_predicciones; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.predicciones
    ADD CONSTRAINT link_entrenamientos_predicciones FOREIGN KEY (pd_id_last_fit) REFERENCES public.entrenamientos(en_id) MATCH FULL ON UPDATE CASCADE;


--
-- Name: rel_playlists_canciones link_playlists_rel_playlists_canciones; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rel_playlists_canciones
    ADD CONSTRAINT link_playlists_rel_playlists_canciones FOREIGN KEY (pr_pl_id) REFERENCES public.playlists(pl_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: entrenamientos link_ts_modelos_entrenamientos; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entrenamientos
    ADD CONSTRAINT link_ts_modelos_entrenamientos FOREIGN KEY (en_id_modelo) REFERENCES public.ts_modelos(ts_id) MATCH FULL ON UPDATE CASCADE;


--
-- Name: playlists link_ts_modelos_playlists; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlists
    ADD CONSTRAINT link_ts_modelos_playlists FOREIGN KEY (pl_id_ts_modelo) REFERENCES public.ts_modelos(ts_id) MATCH FULL ON UPDATE CASCADE;


--
-- Name: predicciones link_ts_modelos_predicciones; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.predicciones
    ADD CONSTRAINT link_ts_modelos_predicciones FOREIGN KEY (pd_id_modelo) REFERENCES public.ts_modelos(ts_id) MATCH FULL ON UPDATE CASCADE;


--
-- Name: canciones link_usuarios_canciones; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.canciones
    ADD CONSTRAINT link_usuarios_canciones FOREIGN KEY (ca_us_id) REFERENCES public.usuarios(us_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: playlists link_usuarios_playlists; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlists
    ADD CONSTRAINT link_usuarios_playlists FOREIGN KEY (pl_us_id) REFERENCES public.usuarios(us_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--


-- Admin User
INSERT INTO public.usuarios (us_username, us_password, us_activo) VALUES ('admin', '$Mmyh9k6cWb5EIOpzIby2IeMyy1xQNUDHwZbP4z8JJUAosjnomVosO', B'1');
