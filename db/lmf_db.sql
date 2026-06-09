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
    ca_youtube_link text
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
    en_ts_loss numeric(6,5) NOT NULL,
    en_ts_batch_size text NOT NULL,
    en_ts_validation_split numeric(6,3) NOT NULL,
    en_ts_mae numeric(6,3) NOT NULL
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
-- Data for Name: canciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.canciones OVERRIDING SYSTEM VALUE VALUES
	(1150, 0, 8218889, 'Taisetsunakoto (feat. Hatsune Miku, Kagamine Rin, Kagamine Len, Megurine Luka, KAITO, MEIKO &... (128kbit_AAC).mp3', 1, B'1', NULL, 1.43780, 1, 'features_1150.npy', NULL),
	(857, 0, 5568544, '【初音ミク】Calla Soiled - 虚構の光【オリジナル曲】 [FiukeDh9WKo].mp3', 1, B'1', NULL, 1.08168, 1, 'features_857.npy', NULL),
	(832, 0, 2959411, '【2013-05-01 _ Carlos Hakamada(debut)】 タイムトラベラー！(Time traveller_)- MIKU(original)_カルロス袴田(music) [udobYRGEeNg].mp3', 1, B'1', NULL, 0.67473, 1, 'features_832.npy', NULL),
	(947, 1, 6458068, 'livetune   never ende.mp3', 1, B'1', NULL, 1.32920, 1, 'features_947.npy', NULL),
	(848, 0, 4205575, '【初音ミク - Hatsune Miku】心の片隅に - Kokoro no Katasumi ni【subs】 [p6cQU2bQitU].mp3', 1, B'1', NULL, 0.76163, 1, 'features_848.npy', NULL),
	(858, 0, 3899541, '【初音ミク】Oriental Cybernetic QT Girl【SUB ENG_ITA】 [mCPH4OGATq8].mp3', 1, B'1', NULL, 1.44691, 1, 'features_858.npy', NULL),
	(1098, 0, 4091869, '初音ミクキマシメ少女のアカルイ未来計画オリジナルMV付き.mp3', 1, B'1', NULL, 0.88006, 1, 'features_1098.npy', NULL),
	(984, 1, 5286947, '【Kagamine Rin V4X】 Hop! Step! Instant Death! A Happiness Dance Death Trap 【VOCALOID Cover�.mp3', 1, B'1', NULL, 1.30938, 1, 'features_984.npy', NULL),
	(1041, 2, 4048736, '空海月 - -STL001- MIKUHOP LP - 08 チョコレートサンデー [nt8RupYeHlc].mp3', 1, B'1', NULL, 1.88134, 1, 'features_1041.npy', NULL),
	(991, 1, 3551772, '【初音ミクSweet】街路灯を横切って English and romaji subs [CKqpXsny5W0].mp3', 1, B'1', NULL, 1.49566, 1, 'features_991.npy', NULL),
	(874, 0, 4771135, 'ピノキオピー - ゲームスペクター2 feat. 初音ミク _ Game Specter 2 [OfXUHMYccu4].mp3', 1, B'1', NULL, 1.00662, 1, 'features_874.npy', NULL),
	(988, 3, 5142658, '【公式】アイシテ  とあ feat 初音ミク　  LOVE ME  toa feat Hatsune Miku.mp3', 1, B'1', NULL, 2.25591, 1, 'features_988.npy', NULL),
	(838, 0, 2871204, '【MV】現代ササクレ概論／なすP feat. 初音ミク (Modern Hangnail Outline／Nasu feat. Miku Hatsune) [OEXZ5Ml4vKk].mp3', 1, B'1', NULL, 1.19957, 1, 'features_838.npy', NULL),
	(864, 0, 3072887, '【初音ミク】ムラサキ【オリジナル曲PV付】 [omYEruBpSM8].mp3', 1, B'1', NULL, 1.76434, 1, 'features_864.npy', NULL),
	(839, 0, 2495759, '【MV】絶望の砂漠／なすP feat. 初音ミク (Desert of Despair／Nasu feat. Miku Hatsune) [rDL6huvbJM0].mp3', 1, B'1', NULL, 1.22350, 1, 'features_839.npy', NULL),
	(1122, 0, 3219681, '【公式】 テレストテレス／かいりきベア feat.初音ミク (128kbit_AAC).mp3', 1, B'1', NULL, 1.38690, 1, 'features_1122.npy', NULL),
	(1158, 0, 5191600, '【初音ミク⁄鏡音レン】クレイジー・ビート【#コンパス】 (128kbit_AAC).mp3', 1, B'1', NULL, 1.10787, 1, 'features_1158.npy', NULL),
	(1197, 0, 6594463, 'ティアードクライシス … GUMI｜Tieredcrisis (128kbit_AAC).mp3', 1, B'1', NULL, 1.31593, 1, 'features_1197.npy', NULL),
	(1214, 0, 4473102, '八王子P 「バイオレンストリガー feat. 初音ミク」(#コンパス メグメグテーマソング） (128kbit_AAC).mp3', 1, B'1', NULL, 1.09039, 1, 'features_1214.npy', NULL),
	(1099, 0, 5089065, '初音ミクキミとボクまわるセカイオリジナル曲PV.mp3', 1, B'1', NULL, 0.93351, 1, 'features_1099.npy', NULL),
	(996, 1, 3347864, '【初音ミク】 Lap Tap Love 【オリジナル】_[Hatsune Miku] Lap Tap Love [Original] [yhBQfbvHmdw].mp3', 1, B'1', NULL, 2.01519, 1, 'features_996.npy', NULL),
	(822, 0, 4173522, 'Kikuo feat. Hatsune Miku - Shimizu Curry Song [English Subbed] [Q2P76nOpeDs].mp3', 1, B'1', NULL, 1.45583, 1, 'features_822.npy', NULL),
	(1118, 0, 3465855, '【Inaba Cumori ft. Kaai Yuki】Floating Moonlight City (浮遊月光街) - English Subtitles (128kbit_AAC).mp3', 1, B'1', NULL, 1.20341, 1, 'features_1118.npy', NULL),
	(1121, 2, 3411934, '【Police Piccadilly ft. Hatsune Miku】Separate «English sub» [TheBlackCero Hazuki No Yume] (128kbit_AAC).mp3', 1, B'1', NULL, 1.36525, 1, 'features_1121.npy', NULL),
	(1141, 0, 5056245, 'Don''t Return to Being a Drowned Corpse ⁄ Iyowa feat. V Flower & Hatsune Miku (English Subs) (128kbit_AAC).mp3', 1, B'1', NULL, 1.51339, 1, 'features_1141.npy', NULL),
	(1156, 0, 5527225, '∴煮ル果実「アイアルの勘違い」with Flower【Official】- A Mistaken Belief of Love (128kbit_AAC).mp3', 1, B'1', NULL, 1.15210, 1, 'features_1156.npy', NULL),
	(1115, 0, 2625772, '(FLASHING LIGHTS) Mercy Killing - iyowa ft. Hatsune Miku, flower (English Subtitles Remastered ;D) (128kbit_AAC).mp3', 1, B'1', NULL, 1.73472, 1, 'features_1115.npy', NULL),
	(1093, 0, 4588623, '初音ミクTearsオリジナルMV (1).mp3', 1, B'1', NULL, 1.06004, 1, 'features_1093.npy', NULL),
	(1194, NULL, 4900280, 'セブンティーナ ⁄ はるまきごはん feat.初音ミク アニメMV - Seventina (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(972, 1, 4904932, 'yt1s.com - Far Away.mp3', 1, B'1', NULL, 2.23748, 1, 'features_972.npy', NULL),
	(821, 0, 5228556, 'float (feat. 初音ミク) [gKWxuB14zOQ].mp3', 1, B'1', NULL, 1.49200, 1, 'features_821.npy', NULL),
	(896, 1, 6794009, '04 CALL ME CALL ME.mp3', 1, B'1', NULL, 1.78718, 1, 'features_896.npy', NULL),
	(1097, 0, 4572457, '初音ミクさとうささら 君キライ Reupload.mp3', 1, B'1', NULL, 1.41775, 1, 'features_1097.npy', NULL),
	(877, 0, 3956089, '唸る刃と群青正義 [aSp3DvQS7BI].mp3', 1, B'1', NULL, 1.32457, 1, 'features_877.npy', NULL),
	(1063, 0, 4290415, 'Vivid Wave feat. Hatsune Miku.mp3', 1, B'1', NULL, 0.93526, 1, 'features_1063.npy', NULL),
	(1064, 0, 2707053, 'VOCALOIDBox of MadenMETALDUBSTEP.mp3', 1, B'1', NULL, 0.57102, 1, 'features_1064.npy', NULL),
	(903, 3, 9631379, '09 ツユメロ.mp3', 1, B'1', NULL, 2.23182, 1, 'features_903.npy', NULL),
	(875, 0, 4298997, 'ミルキーオンザクレープ [hdoG6pvGxA0].mp3', 1, B'1', NULL, 2.02998, 1, 'features_875.npy', NULL),
	(879, 0, 7472180, '微熱の微笑み、微少女は微かに微睡ーム [FYTsVgSO-ms].mp3', 1, B'1', NULL, 0.94595, 1, 'features_879.npy', NULL),
	(932, 2, 4239123, 'Equation.mp3', 1, B'1', NULL, 1.46245, 1, 'features_932.npy', NULL),
	(1146, 1, 3877755, 'MASA WORKS DESIGN ft.初音ミク&GUMI - BRASS NOISE FLAMENCO (128kbit_AAC).mp3', 1, B'1', NULL, 2.04595, 1, 'features_1146.npy', NULL),
	(930, 1, 6799123, 'DreamerTeary Planet feat. 初音ミク.mp3', 1, B'1', NULL, 2.28210, 1, 'features_930.npy', NULL),
	(989, 1, 4176877, '【初音ミク - Hatsune Miku】Electro Saturator -Starry electro mix-【MMD-PV】 [UX4II4sy1IQ].mp3', 1, B'1', NULL, 1.55942, 1, 'features_989.npy', NULL),
	(1046, 0, 3912413, 'ATOLS - EYE feat. Hatsune Miku  アイ feat. 初音ミク.mp3', 1, B'1', NULL, 0.76069, 1, 'features_1046.npy', NULL),
	(1056, 1, 6417551, 'MIKUHeliosphere.mp3', 1, B'1', NULL, 1.00335, 1, 'features_1056.npy', NULL),
	(1057, 0, 3554454, 'muship - 変な子ね [Official Audio].mp3', 1, B'1', NULL, 0.87013, 1, 'features_1057.npy', NULL),
	(999, 1, 6521296, '【初音ミク】a tail of the wind【Cazオリジナル】.mp3', 1, B'1', NULL, 1.56387, 1, 'features_999.npy', NULL),
	(878, 0, 3749064, '徒花満ちて _ ふる feat. 初音ミク [LRCKlcAECQ4].mp3', 1, B'1', NULL, 0.94312, 1, 'features_878.npy', NULL),
	(853, 0, 4837996, '【初音ミクDark】ループ・ループ・ループ【オリジナル】 [wpV2EbPYnrY].mp3', 1, B'1', NULL, 1.22752, 1, 'features_853.npy', NULL),
	(1119, 0, 6162518, '【Kanzaki Iori】 That Summer is Saturating 【Kagamine Rin ・ Len】(English Sub) (128kbit_AAC).mp3', 1, B'1', NULL, 0.94888, 1, 'features_1119.npy', NULL),
	(1155, 0, 4841742, 'Yin Yang Relationship (128kbit_AAC).mp3', 1, B'1', NULL, 1.72046, 1, 'features_1155.npy', NULL),
	(1145, 0, 5466451, 'Last Dance (128kbit_AAC).mp3', 1, B'1', NULL, 2.27433, 1, 'features_1145.npy', NULL),
	(1152, 2, 5652228, 'TsunTsun (128kbit_AAC).mp3', 1, B'1', NULL, 2.08877, 1, 'features_1152.npy', NULL),
	(1067, 0, 4443069, 'VocaloidIROHADrumstepDubstep.mp3', 1, B'1', NULL, 0.83230, 1, 'features_1067.npy', NULL),
	(861, 0, 3559505, '【初音ミク】　曇りのち腐乱臭　【オリジナルPV】 [kKtLt901HDw].mp3', 1, B'1', NULL, 0.88181, 1, 'features_861.npy', NULL),
	(1062, 0, 5427546, 'Utsu-P - Poster Girl''s Prank  看板娘の悪巫山戯.mp3', 1, B'1', NULL, 1.37178, 1, 'features_1062.npy', NULL),
	(940, 1, 6601010, 'Hatsune Miku Original Song.mp3', 1, B'1', NULL, 1.72507, 1, 'features_940.npy', NULL),
	(939, 1, 6269360, 'Hatsune Miku Original Song Bright City.mp3', 1, B'1', NULL, 2.00903, 1, 'features_939.npy', NULL),
	(909, 2, 6483666, '16 ローリンガール.mp3', 1, B'1', NULL, 2.29757, 1, 'features_909.npy', NULL),
	(964, 3, 5262496, 'sasakureUK x DECO27   39 feat Hatsune Miku.mp3', 1, B'1', NULL, 2.34618, 1, 'features_964.npy', NULL),
	(890, 2, 3762650, '- 初音ミクねこみみスイッチオリジナル.mp3', 1, B'1', NULL, 1.79792, 1, 'features_890.npy', NULL),
	(987, 2, 5669379, '【ミク・MAYU・がくぽ】「Ib」 forever 【オリジナルPV】.mp3', 1, B'1', NULL, 1.79984, 1, 'features_987.npy', NULL),
	(945, 2, 4775365, 'Lamaze P ft 初音ミク.mp3', 1, B'1', NULL, 1.39165, 1, 'features_945.npy', NULL),
	(1173, 0, 5321468, 'ゆよゆっぺ feat.巡音ルカ-Draw(Draw) (128kbit_AAC).mp3', 1, B'1', NULL, 1.14648, 1, 'features_1173.npy', NULL),
	(1163, 0, 5119165, '【巡音ルカ】Misery【オリジナル】 (128kbit_AAC).mp3', 1, B'1', NULL, 1.57637, 1, 'features_1163.npy', NULL),
	(1181, 0, 4711085, 'ウシノヒ☆アブダクション (128kbit_AAC).mp3', 1, B'1', NULL, 1.63744, 1, 'features_1181.npy', NULL),
	(899, 2, 6143816, '08 雨のちSweet-Drops.mp3', 1, B'1', NULL, 2.02885, 1, 'features_899.npy', NULL),
	(934, 2, 7662709, 'Hand in Hand.mp3', 1, B'1', NULL, 2.01850, 1, 'features_934.npy', NULL),
	(1125, 0, 7258330, '疑神暗鬼-⁄-しーくん-feat.-flower【Official】-_128kbit_AAC_.mp3', 1, B'1', NULL, 1.68194, 1, 'features_1125.npy', NULL),
	(1059, 0, 3407566, 'Q [Mu-fullauto].mp3', 1, B'1', NULL, 0.89080, 1, 'features_1059.npy', NULL),
	(1076, 0, 3803791, 'ナレ入り君ガ空コソカナシケレHoneyWorks feat.兎眠りおん初音ミク.mp3', 1, B'1', NULL, 1.18479, 1, 'features_1076.npy', NULL),
	(1111, 0, 3915751, '未来アタラシズム (feat. 初音ミク).mp3', 1, B'1', NULL, 1.79406, 1, 'features_1111.npy', NULL),
	(1038, 3, 6117641, '神のまにまに - れるりりfeat.ミク&リン&GUMI  At God''s Mercy - rerulili feat.Vocaloids.mp3', 1, B'1', NULL, 2.24938, 1, 'features_1038.npy', NULL),
	(1144, 0, 2900725, 'HikkieP - できるできない万里の長城 [VOCALOID Kagamine Rin] (128kbit_AAC).mp3', 1, B'1', NULL, 0.92150, 1, 'features_1144.npy', NULL),
	(1154, 0, 1639737, 'Utsu-P - 自爆⁄Self-Destruct [Greatest Shits Ver.] (128kbit_AAC).mp3', 1, B'1', NULL, 1.34925, 1, 'features_1154.npy', NULL),
	(1169, 0, 5755031, 'ねぇ、どろどろさん YASUHIRO(康寛) feat.鏡音リン (128kbit_AAC).mp3', 1, B'1', NULL, 1.08644, 1, 'features_1169.npy', NULL),
	(1072, 0, 3011068, 'さよならワンダーノイズ.mp3', 1, B'1', NULL, 1.08282, 1, 'features_1072.npy', NULL),
	(820, 0, 4548609, 'EXLIUM - EXLIUM feat. Miku [06KskCU_d-M].mp3', 1, B'1', NULL, 0.92712, 1, 'features_820.npy', NULL),
	(1074, 0, 5643594, 'とあ - HALO - ft.初音ミク ( Toa - HALO -  ft.Hatsune Miku ).mp3', 1, B'1', NULL, 1.05077, 1, 'features_1074.npy', NULL),
	(1047, 0, 3615157, 'Audio-onlyえすぴあるWaroki  Hatsune Miku.mp3', 1, B'1', NULL, 0.85174, 1, 'features_1047.npy', NULL),
	(844, 0, 5812731, '【初音ミク - Hatsune Miku】your anniversary【PV subs】 [rUd8zvq63Ro] (1).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(845, 0, 5812731, '【初音ミク - Hatsune Miku】your anniversary【PV subs】 [rUd8zvq63Ro] (2).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1167, NULL, 5908882, 'どぅーまいべすと！／キノシタ(kinoshita) feat.音街ウナ／Do my best! (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1130, 0, 4204303, 'ATOLS - MINT feat. Hatsune Miku ⁄ ミント feat. 初音ミク (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1110, 0, 3634609, '晴れのちメアリーシェーンにて (feat. 初音ミク).mp3', 1, B'1', NULL, 1.01397, 1, 'features_1110.npy', NULL),
	(954, 2, 4251662, 'Musunde Hiraite Rasetsu to Mukuro ORIGINAL.mp3', 1, B'1', NULL, 1.72243, 1, 'features_954.npy', NULL),
	(868, 0, 5434338, '【初音ミクオリジナル】リダクト [A9JripMnIMc].mp3', 1, B'1', NULL, 0.94948, 1, 'features_868.npy', NULL),
	(1124, 0, 794639, '【初音ミク】 トゥール 【オリジナル】 (128kbit_AAC).mp3', 1, B'1', NULL, 1.03409, 1, 'features_1124.npy', NULL),
	(1007, 1, 6113159, '【初音ミク】アポロ【オリジナルMMD PV】.mp3', 1, B'1', NULL, 2.28010, 1, 'features_1007.npy', NULL),
	(819, 0, 6655813, 'Calla Soiled - 亜 [tqI5vcYYQY0].mp3', 1, B'1', NULL, 0.85852, 1, 'features_819.npy', NULL),
	(849, 0, 4790748, '【初音ミクAppend】miss you【中文字幕】 [MrVuRQHJhYs].mp3', 1, B'1', NULL, 1.13225, 1, 'features_849.npy', NULL),
	(1066, 0, 4244644, 'VOCALOIDflower of sorrow初音ミク.mp3', 1, B'1', NULL, 1.18604, 1, 'features_1066.npy', NULL),
	(965, 2, 4354178, 'spica- hatsune miku.mp3', 1, B'1', NULL, 1.39063, 1, 'features_965.npy', NULL),
	(1026, 2, 4160129, '初音ミク Project Diva f 2nd  nanou  Hatsune Miku  Glory 3usi9  Best of nanou (high volume).mp3', 1, B'1', NULL, 2.06328, 1, 'features_1026.npy', NULL),
	(1071, 1, 3869657, '[附中譯]初音ミクハートフルメッセージオリジナル曲PV.mp3', 1, B'1', NULL, 1.92437, 1, 'features_1071.npy', NULL),
	(1054, 1, 4814456, 'JimmyThumbP - Crossroad feat. Hatsune Miku.mp3', 1, B'1', NULL, 1.36183, 1, 'features_1054.npy', NULL),
	(966, 1, 6155257, 'SushiP ft 初音ミク ''Align'' アライン (English Subtitles).mp3', 1, B'1', NULL, 2.29348, 1, 'features_966.npy', NULL),
	(856, 0, 4083751, '【初音ミク】 心音 【オリジナル曲】 [EztEXXCheSk].mp3', 1, B'1', NULL, 1.99561, 1, 'features_856.npy', NULL),
	(1101, 0, 2117076, '初音ミク人間失格オリジナル曲.mp3', 1, B'1', NULL, 1.52492, 1, 'features_1101.npy', NULL),
	(870, 0, 4765562, '【初音ミク（ぐにょ）】福寿草【作曲してみた】 [15HNvDg0Gq4].mp3', 1, B'1', NULL, 1.67453, 1, 'features_870.npy', NULL),
	(846, 0, 5812731, '【初音ミク - Hatsune Miku】your anniversary【PV subs】 [rUd8zvq63Ro].mp3', 1, B'1', NULL, 0.94995, 1, 'features_846.npy', NULL),
	(854, 0, 3566009, '【初音ミク】 名無しの詩 【オリジナル曲】 [2ZayXb8YfyY].mp3', 1, B'1', NULL, 1.69688, 1, 'features_854.npy', NULL),
	(924, 2, 5743358, 'DECO27   ハートアラモード feat 初音ミ�.mp3', 1, B'1', NULL, 2.23243, 1, 'features_924.npy', NULL),
	(1102, 0, 3790109, '初音ミク愛に奇術師オリジナル1.mp3', 1, B'1', NULL, 1.16014, 1, 'features_1102.npy', NULL),
	(1100, 0, 4370093, '初音ミクホシゾラレインオリジナルMV付き.mp3', 1, B'1', NULL, 1.73118, 1, 'features_1100.npy', NULL),
	(1105, 0, 2331126, '初音ロックンロールアイラヴド [Mu-fullauto].mp3', 1, B'1', NULL, 0.97355, 1, 'features_1105.npy', NULL),
	(1175, 0, 7347601, 'ゆらゆら／音街ウナ (128kbit_AAC).mp3', 1, B'1', NULL, 2.20539, 1, 'features_1175.npy', NULL),
	(1166, 1, 5916732, 'どぅーまいべすと！ (feat. 音街ウナ) (128kbit_AAC).mp3', 1, B'1', NULL, 1.75729, 1, 'features_1166.npy', NULL),
	(955, 1, 5485059, 'Neo.mp3', 1, B'1', NULL, 1.73492, 1, 'features_955.npy', NULL),
	(1017, 2, 5887554, 'みきとP Hoi MV.mp3', 1, B'1', NULL, 1.76582, 1, 'features_1017.npy', NULL),
	(835, 2, 4006520, '【Hatsune Miku】Lost My Love【Original Song】 [Hg0xobCxaI8].mp3', 1, B'1', NULL, 1.20815, 1, 'features_835.npy', NULL),
	(1126, 0, 6474143, '稲葉曇『浮遊月光街』Vo.-歌愛ユキ-_128kbit_AAC_.mp3', 1, B'1', NULL, 1.70765, 1, 'features_1126.npy', NULL),
	(1204, 0, 4428116, 'バイオレンストリガー (128kbit_AAC).mp3', 1, B'1', NULL, 1.34199, 1, 'features_1204.npy', NULL),
	(1200, 0, 4265978, 'デレレレ (feat. Hatsune Miku) (128kbit_AAC).mp3', 1, B'1', NULL, 1.35892, 1, 'features_1200.npy', NULL),
	(1193, 0, 4968558, 'セブンティーナ (128kbit_AAC).mp3', 1, B'1', NULL, 1.33014, 1, 'features_1193.npy', NULL),
	(1218, 0, 4587699, '天泣 (128kbit_AAC).mp3', 1, B'1', NULL, 1.86813, 1, 'features_1218.npy', NULL),
	(1203, 0, 4860360, 'ニビイロドロウレ ⁄ nibiiro dolore - rin [オリジナル] (128kbit_AAC).mp3', 1, B'1', NULL, 1.41439, 1, 'features_1203.npy', NULL),
	(951, 2, 5197294, 'Melancholic  Junky ft Rin Kagamine.mp3', 1, B'1', NULL, 1.68160, 1, 'features_951.npy', NULL),
	(1205, 1, 5199971, 'ビューティフルなフィクション (128kbit_AAC).mp3', 1, B'1', NULL, 2.15502, 1, 'features_1205.npy', NULL),
	(1088, 0, 6740940, '初音ミクArigatoオリジナル.mp3', 1, B'1', NULL, 0.82334, 1, 'features_1088.npy', NULL),
	(1065, 0, 4244644, 'VOCALOIDflower of sorrow初音ミク (1).mp3', 1, B'1', NULL, 1.18604, 1, 'features_1065.npy', NULL),
	(1031, 1, 5332086, '初音ミクメイウェンティーオリジナルPV.mp3', 1, B'1', NULL, 1.74920, 1, 'features_1031.npy', NULL),
	(833, 0, 4179634, '【Hatsune Miku】 【L】ucy【Eve】【Original MV】 [49c4aO99Etg].mp3', 1, B'1', NULL, 1.60266, 1, 'features_833.npy', NULL),
	(1004, 1, 5194160, '【初音ミク】　表面張力　【オリジナル�.mp3', 1, B'1', NULL, 2.18704, 1, 'features_1004.npy', NULL),
	(1077, 0, 3845987, 'ニカソヒテキ 初音ミク.mp3', 1, B'1', NULL, 1.94868, 1, 'features_1077.npy', NULL),
	(814, 0, 3658842, '(Reprint) 初音ミク『アンダー・プリテンダー』オリジナル [A2zTCOY-uPI].mp3', 1, B'1', NULL, 1.39643, 1, 'features_814.npy', NULL),
	(1191, 0, 5286623, 'スチールワンダー (128kbit_AAC).mp3', 1, B'1', NULL, 1.32729, 1, 'features_1191.npy', NULL),
	(1199, 0, 5174992, 'ディザーチューン ／ DIVELA feat.初音ミク (128kbit_AAC).mp3', 1, B'1', NULL, 2.13949, 1, 'features_1199.npy', NULL),
	(979, 3, 5737281, '[VnSharing] Umi Yuri Kaiteitan   Hatsune Miku   Vocaloid vietsub.mp3', 1, B'1', NULL, 2.18292, 1, 'features_979.npy', NULL),
	(1032, 2, 5216312, '初音ミクリンレンルカ夢の続きオリジナル中文字幕.mp3', 1, B'1', NULL, 1.03849, 1, 'features_1032.npy', NULL),
	(1219, 0, 6649463, '幾望の月 (128kbit_AAC).mp3', 1, B'1', NULL, 1.81893, 1, 'features_1219.npy', NULL),
	(908, 3, 5303487, '16 スイートマジック.mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(883, 0, 4643130, '洗濯　（初音ミクAppend） [yargFkG0q0o] (1).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1195, 0, 5543388, 'センシティブサマー (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1140, NULL, 5474779, 'DECO#27 - 愛言葉Ⅲ feat. 初音ミク (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(863, 0, 5612525, '【初音ミク】ゲーセン上のアリア【オリジナル曲】 [PEHddBaJyUA].mp3', 1, B'1', NULL, 1.26121, 1, 'features_863.npy', NULL),
	(1220, NULL, 6568280, '幾望の月 feat. 結月ゆかり ⁄ Kibou no tsuki - Nakyamurya (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1185, 0, 5385328, 'カタストロフ (feat. 初音ミク & KAITO) (128kbit_AAC).mp3', 1, B'1', NULL, 1.09336, 1, 'features_1185.npy', NULL),
	(1045, 0, 4210080, '(Reprint) 初音ミクファーストセラピー(初投稿)オリジナル.mp3', 1, B'1', NULL, 0.83494, 1, 'features_1045.npy', NULL),
	(1134, 0, 5880397, 'Circus-P - ''I Am Here (with Mo Qingxian)'' [Vocaloid Original Song] (128kbit_AAC).mp3', 1, B'1', NULL, 1.73328, 1, 'features_1134.npy', NULL),
	(1170, 0, 4619758, 'はらぺこのルベル (128kbit_AAC).mp3', 1, B'1', NULL, 1.59825, 1, 'features_1170.npy', NULL),
	(963, 1, 5964668, 'ryuryu   Flowers featHatsune Miku 初音ミ�.mp3', 1, B'1', NULL, 2.38296, 1, 'features_963.npy', NULL),
	(925, 1, 5708877, 'DECO27   夜行性ハイズ feat 初音ミ�.mp3', 1, B'1', NULL, 2.11343, 1, 'features_925.npy', NULL),
	(1068, 0, 7352616, 'VocaloidYADA!!Moombahton.mp3', 1, B'1', NULL, 0.91891, 1, 'features_1068.npy', NULL),
	(1070, 0, 4338308, 'YARUSE NAKIO - UFOが飛んでいる.mp3', 1, B'1', NULL, 1.51238, 1, 'features_1070.npy', NULL),
	(959, 3, 6144599, 'Ordinary   ポリスピカデリー feat 初音ミク  Ordinary   Police Piccadilly feat Hatsune Mik.mp3', 1, B'1', NULL, 2.40697, 1, 'features_959.npy', NULL),
	(823, 0, 4163060, 'Koi wa Maboroshi de Ai wa Karamawari _ Nashimoto Ui (恋は幻で愛は空回り_梨本うい) [CfUZYBL6pr0].mp3', 1, B'1', NULL, 2.06782, 1, 'features_823.npy', NULL),
	(992, 1, 4831162, '【初音ミク×アルクロ】センセーションはおわらない！ フルver【コラボオリジナル楽曲�.mp3', 1, B'1', NULL, 1.56624, 1, 'features_992.npy', NULL),
	(841, 0, 5422033, '【VOCALOID_IA】_ 午前４時の金星 _ AM4 Venus _ by Ashin Kuroda [Zhc9onqv-QM].mp3', 1, B'1', NULL, 1.04105, 1, 'features_841.npy', NULL),
	(1084, 1, 3837517, '初音ミク A.I.210 オリジナル [Hatsune miku] A.I.210 [Official video].mp3', 1, B'1', NULL, 1.29497, 1, 'features_1084.npy', NULL),
	(1113, 0, 3802207, '花のない部屋 (feat. 初音ミク).mp3', 1, B'1', NULL, 1.35708, 1, 'features_1113.npy', NULL),
	(1010, 1, 5141020, '【初音ミク】空に花束を【オリジナル】 [4OLuVzAyYZ0].mp3', 1, B'1', NULL, 1.19734, 1, 'features_1010.npy', NULL),
	(1120, 0, 4246618, '【MV】Music Like Magic! feat. Hatsune Miku ⁄ 魔法みたいなミュージック！ feat. 初音ミク (128kbit_AAC).mp3', 1, B'1', NULL, 2.09653, 1, 'features_1120.npy', NULL),
	(1073, 0, 3736111, 'ただのCo 初音ミクアルカリ成人.mp3', 1, B'1', NULL, 1.53584, 1, 'features_1073.npy', NULL),
	(1016, 1, 6318888, 'ひとりぼっちとココロの本と - PIPPO feat. 初音ミク.mp3', 1, B'1', NULL, 2.25169, 1, 'features_1016.npy', NULL),
	(893, 1, 5372012, '01 アンドロイド Voc@loid ～I am not a robot～.mp3', 1, B'1', NULL, 1.30696, 1, 'features_893.npy', NULL),
	(1171, NULL, 4578462, 'はらぺこのルベル ⁄ 初音ミク (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1174, NULL, 4802378, 'ゆよゆっぺ feat.巡音ルカ-Fake(Draw) (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1180, NULL, 4804883, 'インヤンカンケイ - 和田たけあき (VOCALOID ver.) (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1157, 0, 2845306, '【HikkieP feat. 鏡音リン】できるできない万里の長城 (The Do''s and Don''t''s of the Great Wall)【ENGLISH SUBTITLES】 (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1182, NULL, 4725388, 'ウシノヒ☆アブダクション - cosMo＠暴走P feat. 音街ウナ (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1183, NULL, 1365555, 'エゴロック／ すりぃ feat.鏡音レン【OFFICIAL】 (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1184, NULL, 3532684, 'エロルヤ光線P ⁄ 門松円化 - 骨  (Eroruya Kousenp ⁄ Madoka Kadomatsu - Bone) (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1186, NULL, 5277779, 'カタストロフ（Catastrophe） feat.初音ミク KAITO - Dios⁄シグナルP (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1189, NULL, 5404121, 'クーロンズ・ホテル (feat. 鏡音リン & 鏡音レン) (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1117, 0, 2070747, '【HikkieP feat. 鏡音リン】できるできない万里の長城 (The Dos and Donts of the Great Wall)【ENGLISH SUBTITLES】 (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1159, NULL, 1125374, '【初音ミク】　トゥール　【オリジナル】 (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1019, 2, 5233030, 'みきとP『 だいあもんど 』M.mp3', 1, B'1', NULL, 2.04443, 1, 'features_1019.npy', NULL),
	(942, 1, 8056042, 'Heavenz   アルファ.mp3', 1, B'1', NULL, 1.84310, 1, 'features_942.npy', NULL),
	(921, 1, 5121435, 'Child   初音ミク.mp3', 1, B'1', NULL, 2.16577, 1, 'features_921.npy', NULL),
	(1143, 0, 6035166, 'Haruno Sora-sensei Will Praise You Endlessly (English subs for 無限にホメてくれる桜乃そら先生) (128kbit_AAC).mp3', 1, B'1', NULL, 1.10633, 1, 'features_1143.npy', NULL),
	(1217, 0, 4330334, '唯一、愛ノ詠 ⁄ ルカミクグミIAリン (128kbit_AAC).mp3', 1, B'1', NULL, 1.21753, 1, 'features_1217.npy', NULL),
	(1081, 0, 4083676, '八王子PGAME OVER feat. 初音ミクMusic Video.mp3', 1, B'1', NULL, 1.91022, 1, 'features_1081.npy', NULL),
	(1082, 2, 4693133, '八王子PHORIZON feat. 初音ミクMusic Video.mp3', 1, B'1', NULL, 1.91481, 1, 'features_1082.npy', NULL),
	(837, 1, 6215701, '【MIKU】Bianca [8a3lVn8rzmA].mp3', 1, B'1', NULL, 0.79905, 1, 'features_837.npy', NULL),
	(926, 2, 3934431, 'DECO27  愛言葉Ⅲ feat 初音ミク.mp3', 1, B'1', NULL, 2.26925, 1, 'features_926.npy', NULL),
	(1049, 0, 4634971, 'Cryogenic (feat. 初音ミク).mp3', 1, B'1', NULL, 0.93774, 1, 'features_1049.npy', NULL),
	(1050, 0, 3877272, 'Desires-はるまきごはんfeat. 初音ミク.mp3', 1, B'1', NULL, 0.95637, 1, 'features_1050.npy', NULL),
	(1123, 0, 3937292, '【公式】撥条少女時計 feat.初音ミク【オリジナル曲】 (128kbit_AAC).mp3', 1, B'1', NULL, 1.34899, 1, 'features_1123.npy', NULL),
	(933, 1, 4128127, 'Find Me feat. Hatsune Miku [P7UJeX6WE4Q].mp3', 1, B'1', NULL, 1.69787, 1, 'features_933.npy', NULL),
	(826, 0, 3322812, '[Hatsune Miku] That Rich Guy is a Tetromino - tadanoco English subs [Ik8DHj5zcrs].mp3', 1, B'1', NULL, 1.08099, 1, 'features_826.npy', NULL),
	(911, 3, 8411420, '17 Yellow.mp3', 1, B'1', NULL, 2.26478, 1, 'features_911.npy', NULL),
	(1051, 1, 4387844, 'Hatsune Miku - World on Color [Original].mp3', 1, B'1', NULL, 1.85321, 1, 'features_1051.npy', NULL),
	(1052, 0, 3227552, 'Hatsune Miku, GUMI - M.S.S.Planet (Sub Eng).mp3', 1, B'1', NULL, 1.08806, 1, 'features_1052.npy', NULL),
	(1053, 0, 8530381, 'Inverse Relation (feat. 初音ミク).mp3', 1, B'1', NULL, 0.79202, 1, 'features_1053.npy', NULL),
	(1075, 0, 3927340, 'スノウドライヴ  Omoi feat. 初音ミク.mp3', 1, B'1', NULL, 1.94443, 1, 'features_1075.npy', NULL),
	(920, 2, 6536436, 'CATS RULE THE WORLD   daniwell feat Hatsune Miku  Momone Momo.mp3', 1, B'1', NULL, 1.45424, 1, 'features_920.npy', NULL),
	(960, 3, 4362839, 'PinocchioP (feat Hatsune Miku and Yukkuri)   Proliferation of Imamur.mp3', 1, B'1', NULL, 2.11783, 1, 'features_960.npy', NULL),
	(952, 1, 4345285, 'METEOR  DIVELA feat初音ミク.mp3', 1, B'1', NULL, 1.81493, 1, 'features_952.npy', NULL),
	(949, 2, 4201412, 'lumo - ネットチルナノグ feat. 初音ミク [fSOK6pGHI5Q].mp3', 1, B'1', NULL, 1.35606, 1, 'features_949.npy', NULL),
	(904, 1, 5874858, '11 396.mp3', 1, B'1', NULL, 2.37328, 1, 'features_904.npy', NULL),
	(840, 0, 6059129, '【SKEW】カノジョの選択肢と独りぼっちの北の空【PSGOZ】 [Ei22xcvPXy8].mp3', 1, B'1', NULL, 1.41270, 1, 'features_840.npy', NULL),
	(825, 0, 6771075, 'sasakure.UK - Spider Thread Monopoly feat. Hatsune Miku  蜘蛛糸モノポリー.mp3', 1, B'1', NULL, 1.55357, 1, 'features_825.npy', NULL),
	(1129, 0, 5543992, 'ATOLS - Don Gara Shan feat. Hatsune Miku ⁄ ドンガラシャン feat. 初音ミク (128kbit_AAC).mp3', 1, B'1', NULL, 2.01883, 1, 'features_1129.npy', NULL),
	(1128, 0, 4198554, '404：虚像■初音ミク_オリジナル (128kbit_AAC).mp3', 1, B'1', NULL, 1.90912, 1, 'features_1128.npy', NULL),
	(1114, 3, 5132257, '[1080P Full] Sweet Magic スイートマジック - Kagamine Rin 鏡音リン Project DIVA English Romaji PDA FT.mp3', 1, B'1', NULL, 2.30801, 1, 'features_1114.npy', NULL),
	(865, 0, 3016114, '【初音ミク】夢で逢いましょう【オリジナル】 [YI492W4Qb3g].mp3', 1, B'1', NULL, 1.15938, 1, 'features_865.npy', NULL),
	(1086, 0, 5875460, '初音ミク もう やめちゃってもいい かなァ 人生オリジナル.mp3', 1, B'1', NULL, 1.99323, 1, 'features_1086.npy', NULL),
	(1094, 0, 4588623, '初音ミクTearsオリジナルMV.mp3', 1, B'1', NULL, 1.06004, 1, 'features_1094.npy', NULL),
	(1080, 0, 4731644, '一触即発禅ガール - れるりりfeat.初音ミク&GUMI  Simmering ZEN Girl - rerulili feat.miku&gumi.mp3', 1, B'1', NULL, 1.87697, 1, 'features_1080.npy', NULL),
	(1089, 1, 3798990, '初音ミクGUMI(40) コトバのうた オリジナルPV.mp3', 1, B'1', NULL, 0.84035, 1, 'features_1089.npy', NULL),
	(828, 0, 3612810, '┗_∵_┓ヤキモチの答え-another story-／HoneyWorks feat.初音ミク [Qlkezcz3tt4].mp3', 1, B'1', NULL, 1.64789, 1, 'features_828.npy', NULL),
	(1033, 1, 5628001, '初音ミク灯火syudou_192kbps.mp3', 1, B'1', NULL, 1.88942, 1, 'features_1033.npy', NULL),
	(1030, 1, 6067486, '初音ミクオリジナル曲「Singularity�.mp3', 1, B'1', NULL, 1.97095, 1, 'features_1030.npy', NULL),
	(995, 0, 7854795, '【初音ミク】 children 【オリジナル曲】.mp3', 1, B'1', NULL, 1.86445, 1, 'features_995.npy', NULL),
	(1168, NULL, 6493837, 'ぬゆり - ロンリーダンス ⁄ flower ; Lonely Dance (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(824, 0, 5785319, 'Reality _ Dog tails feat. Miku [MMDPV] [UPhsMAdDGfM].mp3', 1, B'1', NULL, 1.00778, 1, 'features_824.npy', NULL),
	(851, 0, 5377606, '【初音ミクDark】ゆらゆら English and romaji subs [04fGKdznrkw].mp3', 1, B'1', NULL, 1.69637, 1, 'features_851.npy', NULL),
	(1035, 1, 7311959, '大嫌いなはずだったHoneyWorks feat.GUMI初音ミク.mp3', 1, B'1', NULL, 1.10363, 1, 'features_1035.npy', NULL),
	(1078, 0, 3481810, 'ピノキオピー - ストレンジアニマル feat. 初音ミク鏡音リン  Strange Animal.mp3', 1, B'1', NULL, 0.91241, 1, 'features_1078.npy', NULL),
	(1079, 1, 4707801, 'リンレンGUMIルカミクcLick cRackオリジナル.mp3', 1, B'1', NULL, 1.44651, 1, 'features_1079.npy', NULL),
	(1044, 0, 3954545, '【初音ミク】SEAHOLLY【オリジナルMV】 [LkCHlsJyV7Y].mp3', 1, B'1', NULL, 0.92193, 1, 'features_1044.npy', NULL),
	(916, 1, 3662996, 'Anti Selector_初音ミク [ShTbgwaKkiQ].mp3', 1, B'1', NULL, 0.92259, 1, 'features_916.npy', NULL),
	(967, 2, 9821039, 'triple baka - miku hatsune.mp3', 1, B'1', NULL, 1.54312, 1, 'features_967.npy', NULL),
	(1014, 2, 3723988, 'えいえんがみつからない - daniwell feat. Hatsune Miku & Momone Momo.mp3', 1, B'1', NULL, 2.22965, 1, 'features_1014.npy', NULL),
	(818, 0, 4057727, 'Blindness (feat. 初音ミク) [nlLGzmErKWE].mp3', 1, B'1', NULL, 0.98219, 1, 'features_818.npy', NULL),
	(935, 1, 3791071, 'Hatsune Miku   Akeomeakeomeakeomeakeome (Happy New Year).mp3', 1, B'1', NULL, 1.77102, 1, 'features_935.npy', NULL),
	(953, 2, 3980123, 'miku hatsune - po pi po356.mp3', 1, B'1', NULL, 1.64037, 1, 'features_953.npy', NULL),
	(1132, 2, 4020657, 'Booo! - TOKOTOKO（西沢さんP） feat.音街ウナ (128kbit_AAC).mp3', 1, B'1', NULL, 1.93084, 1, 'features_1132.npy', NULL),
	(1210, 2, 4410293, '僕が夢を捨てて大人になるまで (128kbit_AAC).mp3', 1, B'1', NULL, 1.35424, 1, 'features_1210.npy', NULL),
	(928, 1, 2889533, 'DokiDokiBeat 初音ミク for Lamaze.mp3', 1, B'1', NULL, 1.52491, 1, 'features_928.npy', NULL),
	(887, 0, 3885563, '霞む森 _ 初音ミク＆GUMI [5UIfTqACqJ8] (1).mp3', 1, B'1', NULL, 0.93890, 1, 'features_887.npy', NULL),
	(915, 1, 7015417, 'An ／ DECO＊27 feat初音ミク.mp3', 1, B'1', NULL, 2.31885, 1, 'features_915.npy', NULL),
	(1085, 0, 3459565, '初音ミク White Prism 蝶々P.mp3', 1, B'1', NULL, 0.61273, 1, 'features_1085.npy', NULL),
	(834, 0, 3150189, '【Hatsune Miku】 たのしい逃避行 [5Tef_SSOe40].mp3', 1, B'1', NULL, 0.98043, 1, 'features_834.npy', NULL),
	(1096, 0, 4572457, '初音ミクさとうささら 君キライ Reupload (1).mp3', 1, B'1', NULL, 1.41775, 1, 'features_1096.npy', NULL),
	(968, 2, 5999149, 'TsunTsun  ftHatsune Miku_192kbps.mp3', 1, B'1', NULL, 1.92741, 1, 'features_968.npy', NULL),
	(969, 1, 5117066, 'Weekender Girl   Hatsune Miku Project Diva F (HD).mp3', 1, B'1', NULL, 2.11352, 1, 'features_969.npy', NULL),
	(855, 0, 3899633, '【初音ミク】 幻奏サティスファクション 【オリジナル曲】 [RHqTWidK9DE].mp3', 1, B'1', NULL, 1.35269, 1, 'features_855.npy', NULL),
	(929, 1, 5673768, 'Dream Chase.mp3', 1, B'1', NULL, 1.45712, 1, 'features_929.npy', NULL),
	(1090, 0, 8880650, '初音ミクHatsune Miku - Shining Love.mp3', 1, B'1', NULL, 1.26607, 1, 'features_1090.npy', NULL),
	(1069, 0, 4404652, 'We Wait for Morning on the Last Train risou feat. Hatsune Miku (English sub).mp3', 1, B'1', NULL, 1.31984, 1, 'features_1069.npy', NULL),
	(847, 0, 5063310, '【初音ミク - Hatsune Miku】ウタヲウタエ - Uta o Utae - Sing a Song【PV subs】 [j_AtIAPeIsU].mp3', 1, B'1', NULL, 1.24698, 1, 'features_847.npy', NULL),
	(852, 0, 5016696, '【初音ミクdark】シロツメクサの花冠 【オリジナル】 [rwXpIeZm-Sc].mp3', 1, B'1', NULL, 1.63427, 1, 'features_852.npy', NULL),
	(1178, 0, 5891229, 'アンチ・デジタリズム (feat. Hatsune Miku) (128kbit_AAC).mp3', 1, B'1', NULL, 1.58870, 1, 'features_1178.npy', NULL),
	(843, 0, 5339349, '【ミクAPPENDsolid】僕の一部【オリジナルPV】 [Po-oRnoT-ts].mp3', 1, B'1', NULL, 1.52759, 1, 'features_843.npy', NULL),
	(892, 2, 5561339, '01 EARTH DAY.mp3', 1, B'1', NULL, 1.60129, 1, 'features_892.npy', NULL),
	(859, 1, 4809098, '【初音ミク】Twinkle Days【オリジナル曲PV】 [m9DTGxCT5-0].mp3', 1, B'1', NULL, 1.71959, 1, 'features_859.npy', NULL),
	(1104, 1, 2527156, '初音ミク桃音モモ鏡音リンレンとてたてとてたオリジナル.mp3', 1, B'1', NULL, 0.97301, 1, 'features_1104.npy', NULL),
	(881, 1, 5130954, '明日も良い日になるでしょう (feat. IA＆初音ミク) [fHhV6tz2_Rs].mp3', 1, B'1', NULL, 2.07687, 1, 'features_881.npy', NULL),
	(1060, 0, 3550458, 'Starduster (Orchestral Ver.) - Hatsune Miku.mp3', 1, B'1', NULL, 0.74281, 1, 'features_1060.npy', NULL),
	(1179, 0, 4892148, 'インヤンカンケイ (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1061, 0, 8219614, 'TEN feat. Hatsune Miku & Kasane Teto TEN初音ミク&重音テト.mp3', 1, B'1', NULL, 0.85147, 1, 'features_1061.npy', NULL),
	(1103, 0, 3838955, '初音ミク東京レトロオリジナル曲PV付.mp3', 1, B'1', NULL, 1.75674, 1, 'features_1103.npy', NULL),
	(1013, 2, 4874421, 'あいまいクエスチョン／yamada feat初音ミク   The Quizmaste.mp3', 1, B'1', NULL, 1.81119, 1, 'features_1013.npy', NULL),
	(910, 2, 4558903, '17 Ievan Polkka.mp3', 1, B'1', NULL, 2.18259, 1, 'features_910.npy', NULL),
	(1020, 1, 4399108, 'アンドロメダアンドロメダ   ナユタン星人 feat 初音ミク.mp3', 1, B'1', NULL, 2.38344, 1, 'features_1020.npy', NULL),
	(1151, 0, 6477311, 'TieredCrisis ⁄ youman feat. GUMI (English Subs) (128kbit_AAC).mp3', 1, B'1', NULL, 1.19940, 1, 'features_1151.npy', NULL),
	(997, 2, 3340929, '【初音ミク】 だんだん早くなる Getting Faster and Faster【オリジナル�.mp3', 1, B'1', NULL, 1.96327, 1, 'features_997.npy', NULL),
	(1165, 0, 5902699, 'とがびとごろし ⁄ 歌愛ユキ、音街ウナ (128kbit_AAC).mp3', 1, B'1', NULL, 1.49484, 1, 'features_1165.npy', NULL),
	(1161, 0, 4649780, '【巡音ルカ】Canvas【オリジナル】 (128kbit_AAC).mp3', 1, B'1', NULL, 1.36467, 1, 'features_1161.npy', NULL),
	(1138, NULL, 5284440, 'DADARUMA／flower (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(889, 1, 3250232, '- Ranaエレクトロサチュレイタ ElectrosaturatorVSQx.mp3', 1, B'1', NULL, 2.07984, 1, 'features_889.npy', NULL),
	(936, 1, 5667499, 'Hatsune Miku   Calc (English  Romaji Subs).mp3', 1, B'1', NULL, 1.95657, 1, 'features_936.npy', NULL),
	(1025, 1, 6081645, '初音ミク poppin'' jumpin まらしぃ kors k.mp3', 1, B'1', NULL, 1.71764, 1, 'features_1025.npy', NULL),
	(957, 1, 5964041, 'night  (t)rain  初音ミ�.mp3', 1, B'1', NULL, 1.60551, 1, 'features_957.npy', NULL),
	(1000, 1, 7950183, '【初音ミク】Another Mine【オリジナル21】[HD720p].mp3', 1, B'1', NULL, 1.85314, 1, 'features_1000.npy', NULL),
	(1023, 1, 5891316, 'モノクロブルースカイ  のぼる feat 初音ミク  MonochromeBlueSky.mp3', 1, B'1', NULL, 1.99444, 1, 'features_1023.npy', NULL),
	(850, 0, 4513925, '【初音ミクAppend】Quiet【オリジナル曲】 [fihI7EuO0eA].mp3', 1, B'1', NULL, 1.48633, 1, 'features_850.npy', NULL),
	(948, 1, 6385343, 'LOST NOTE  No85 feat初音ミ�.mp3', 1, B'1', NULL, 1.81143, 1, 'features_948.npy', NULL),
	(1149, 1, 5012316, 'Sleeping Awake ⁄ Aqu3ra feat.初音ミク (128kbit_AAC).mp3', 1, B'1', NULL, 1.09340, 1, 'features_1149.npy', NULL),
	(1055, 0, 5957309, 'MASA WORKS DESIGN ft.初音ミク&GUMI - 狐の嫁入り.mp3', 1, B'1', NULL, 1.59604, 1, 'features_1055.npy', NULL),
	(885, 0, 2156993, '第1話　予測の先にカノジョは走馬灯を見るか PSGO-Z【SKEW PV】 [Ih6NBS9OcPo].mp3', 1, B'1', NULL, 0.94531, 1, 'features_885.npy', NULL),
	(872, 0, 4753744, 'キャラメルティアドロップ_初音ミク [d4qecYvfWgw].mp3', 1, B'1', NULL, 1.03465, 1, 'features_872.npy', NULL),
	(941, 1, 4503295, 'Hatsune Miku Two Faced Lovers.mp3', 1, B'1', NULL, 1.67738, 1, 'features_941.npy', NULL),
	(869, 0, 4647758, '【初音ミク・VY1V3】PROGRAM BREAKER【オリジナルPV】 [NIDa7HqGqc4].mp3', 1, B'1', NULL, 0.88831, 1, 'features_869.npy', NULL),
	(897, 2, 9410964, '04 彼方まで虹を架けて.mp3', 1, B'1', NULL, 2.21625, 1, 'features_897.npy', NULL),
	(970, 2, 6314499, 'White Dove with English  Romaji Sub  Hatsune Miku  ハト  sm2583719  HQ.mp3', 1, B'1', NULL, 1.86842, 1, 'features_970.npy', NULL),
	(1091, 0, 7071877, '初音ミクidiolectオリシナル.mp3', 1, B'1', NULL, 0.91005, 1, 'features_1091.npy', NULL),
	(1092, 0, 4024965, '初音ミクLast Time to Sayオリジナル.mp3', 1, B'1', NULL, 1.39357, 1, 'features_1092.npy', NULL),
	(1187, 0, 5175796, 'クレイジー・ビート (128kbit_AAC).mp3', 1, B'1', NULL, 1.32553, 1, 'features_1187.npy', NULL),
	(1107, 0, 2860890, '四ツ谷さんによろしく.mp3', 1, B'1', NULL, 1.00335, 1, 'features_1107.npy', NULL),
	(1108, 0, 2518572, '天音サクラAlien初音ミク.mp3', 1, B'1', NULL, 0.64249, 1, 'features_1108.npy', NULL),
	(1109, 0, 3770361, '少年Aと妄想少女.mp3', 1, B'1', NULL, 0.73101, 1, 'features_1109.npy', NULL),
	(907, 2, 6677916, '13 アンダンテ.mp3', 1, B'1', NULL, 2.16550, 1, 'features_907.npy', NULL),
	(900, 2, 7637962, '09 GIFT.mp3', 1, B'1', NULL, 2.25806, 1, 'features_900.npy', NULL),
	(994, 1, 6394121, '【初音ミク】 Baby Steps 【オリジナル�.mp3', 1, B'1', NULL, 2.03217, 1, 'features_994.npy', NULL),
	(950, 1, 4374124, 'MASA WORKS DESIGN ft初音ミクu0026GUMI   BRASS NOISE FLAMENC.mp3', 1, B'1', NULL, 2.06171, 1, 'features_950.npy', NULL),
	(978, 1, 4346243, '[Subs+Lyrics] Contrast [Hatsune Miku] [O6FrUaQVqlQ].mp3', 1, B'1', NULL, 1.36867, 1, 'features_978.npy', NULL),
	(986, 1, 6716994, '【オリジナルMV】ユメノアメ feat初音ミク  ドッシ�.mp3', 1, B'1', NULL, 2.27947, 1, 'features_986.npy', NULL),
	(1006, 1, 8406594, '【初音ミク】アネモネ【オリジナル】.mp3', 1, B'1', NULL, 2.06410, 1, 'features_1006.npy', NULL),
	(980, 1, 7771505, '[VOCALOID] Sailing  初音ミク [公式.mp3', 1, B'1', NULL, 1.70634, 1, 'features_980.npy', NULL),
	(976, 2, 6832978, '[Music] Livetune (feat Hatsune Miku)   Redia.mp3', 1, B'1', NULL, 2.24412, 1, 'features_976.npy', NULL),
	(827, 0, 4347135, '[Rin Kagamine and Miku Hatsune] Cold Back (English Subs) [HGtUmG1v9no].mp3', 1, B'1', NULL, 2.01009, 1, 'features_827.npy', NULL),
	(973, 1, 3014503, 'yt1s.com - Mizusano feat 初音ミク Universe.mp3', 1, B'1', NULL, 1.23216, 1, 'features_973.npy', NULL),
	(895, 1, 8460849, '03 ワールズエンド・ダンスホール.mp3', 1, B'1', NULL, 2.14919, 1, 'features_895.npy', NULL),
	(901, 2, 8783761, '09 ☆Fighting Pose☆.mp3', 1, B'1', NULL, 2.12568, 1, 'features_901.npy', NULL),
	(946, 1, 4629288, 'Landscape  初音ミク   歩く人×春�.mp3', 1, B'1', NULL, 1.78949, 1, 'features_946.npy', NULL),
	(1106, 0, 3442266, '君が君がfeat. 初音ミク.mp3', 1, B'1', NULL, 1.48977, 1, 'features_1106.npy', NULL),
	(985, 1, 5549634, '【Robo feat 初音ミク】 SKY HIGHWAY【オリジナル曲�.mp3', 1, B'1', NULL, 1.06076, 1, 'features_985.npy', NULL),
	(842, 0, 4147173, '【_years_ 5_12】May【初音ミクDarkオリジナルPV】 [wxXQJBMeW94].mp3', 1, B'1', NULL, 1.96065, 1, 'features_842.npy', NULL),
	(817, 0, 3024424, 'ATOLS - LAST SIGNAL feat. Hatsune Miku _ ラストシグナル feat. 初音ミク [d2M3z797sQ8].mp3', 1, B'1', NULL, 1.03353, 1, 'features_817.npy', NULL),
	(1112, 0, 3831653, '潔癖K毒滅グリモア.mp3', 1, B'1', NULL, 1.03320, 1, 'features_1112.npy', NULL),
	(1160, 0, 3507879, '【初音ミク】骨【エロルヤ光線P】2018⁄10⁄31 (128kbit_AAC).mp3', 1, B'1', NULL, 0.84573, 1, 'features_1160.npy', NULL),
	(830, 0, 1945642, '┗_∵_┓第三次プリン戦争　／　HoneyWorks feat.初音ミク、GUMI [A_zZ4SY0kp0].mp3', 1, B'1', NULL, 1.39084, 1, 'features_830.npy', NULL),
	(831, 0, 4103244, '「キズ」 - KEI feat.初音ミク [D9UFIFujRyo].mp3', 1, B'1', NULL, 2.05603, 1, 'features_831.npy', NULL),
	(873, 0, 5009650, 'サテライト [h3bNut-SVpg].mp3', 1, B'1', NULL, 1.47043, 1, 'features_873.npy', NULL),
	(1048, 0, 3935156, 'Brownie (feat. 初音ミク).mp3', 1, B'1', NULL, 0.89444, 1, 'features_1048.npy', NULL),
	(931, 1, 4121259, 'east end and bocci  feat初音ミク.mp3', 1, B'1', NULL, 1.83119, 1, 'features_931.npy', NULL),
	(1209, 0, 4978460, 'メアメア (128kbit_AAC).mp3', 1, B'1', NULL, 2.13039, 1, 'features_1209.npy', NULL),
	(888, 0, 3885563, '霞む森 _ 初音ミク＆GUMI [5UIfTqACqJ8].mp3', 1, B'1', NULL, 0.93890, 1, 'features_888.npy', NULL),
	(917, 1, 6067327, 'AOHARU.mp3', 1, B'1', NULL, 1.24717, 1, 'features_917.npy', NULL),
	(1028, 1, 3597881, '初音ミク　オリジナル曲　『アンダワ』.mp3', 1, B'1', NULL, 2.16143, 1, 'features_1028.npy', NULL),
	(1005, 3, 5042348, '【初音ミク】アクリルスター【オリジナル】.mp3', 1, B'1', NULL, 2.07449, 1, 'features_1005.npy', NULL),
	(862, 0, 5609899, '【初音ミク】わたしと君とを繋ぐもの【オリジナル】 [IKOookjqXhU].mp3', 1, B'1', NULL, 1.21878, 1, 'features_862.npy', NULL),
	(927, 2, 6410421, 'Deco27 ft 初音ミク.mp3', 1, B'1', NULL, 2.27958, 1, 'features_927.npy', NULL),
	(1027, 1, 4944011, '初音ミク ラストペインター オリジナルMIKULast painteroriginal.mp3', 1, B'1', NULL, 1.77074, 1, 'features_1027.npy', NULL),
	(962, 1, 7012282, 'Robo feat. Hatsune Miku SPACERUN オリジナル曲.mp3', 1, B'1', NULL, 1.49153, 1, 'features_962.npy', NULL),
	(958, 1, 2856514, 'Onesided Love Samba  Hatsune Miku Traduccion.mp3', 1, B'1', NULL, 0.96737, 1, 'features_958.npy', NULL),
	(876, 0, 3853027, '初音ミクオリジナル曲 「PYX」中日字幕 [36UirlGT-iY].mp3', 1, B'1', NULL, 1.92340, 1, 'features_876.npy', NULL),
	(1131, 0, 4817976, 'bin - 音街ウナ (128kbit_AAC).mp3', 1, B'1', NULL, 1.24400, 1, 'features_1131.npy', NULL),
	(1162, 0, 5188554, '【巡音ルカ】Gerbera【オリジナル】 (128kbit_AAC).mp3', 1, B'1', NULL, 1.52354, 1, 'features_1162.npy', NULL),
	(1164, 0, 5616197, '【巡音ルカ】Reon - Remind【オリジナル】 (128kbit_AAC).mp3', 1, B'1', NULL, 1.41786, 1, 'features_1164.npy', NULL),
	(1037, 1, 6647404, '手�.mp3', 1, B'1', NULL, 1.43373, 1, 'features_1037.npy', NULL),
	(1188, 0, 5409690, 'クーロンズ・ホテル(Kowloon''s HOTEL)／鏡音リン・てにをは (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1176, 0, 5307886, 'わいふぁい暴想ボーイ- れるりり feat 鏡音レン& Fukase ⁄ Wi-Fi Imagination Wild Boy - rerulili feat LEN &VOCALOID Fukase (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1172, 0, 3565028, 'ぼかろころしあむ (feat. Kagamine Rin) (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1225, NULL, 6217782, '泥中に咲く ⁄ HarryP ft. 初音ミク (Official Music Video) (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1136, 0, 6487236, 'Clean Tears - Flying Away feat.初音ミク (128kbit_AAC).mp3', 1, B'1', NULL, 1.91636, 1, 'features_1136.npy', NULL),
	(990, 3, 6693704, '【初音ミクAppend DARK】Carbuncle【オリジナル曲】.mp3', 1, B'1', NULL, 2.00896, 1, 'features_990.npy', NULL),
	(1116, 0, 3725369, 'Luna - アルティメット (Ultimate) feat.Kagamine Len (128kbit_AAC).mp3', 1, B'1', NULL, 1.54287, 1, 'features_1116.npy', NULL),
	(1135, 0, 5097935, 'Circus-P - ''See (with AZUKI)'' [Original Vocaloid Song] (128kbit_AAC).mp3', 1, B'1', NULL, 1.31535, 1, 'features_1135.npy', NULL),
	(1137, 0, 5284901, 'DADARUMA (128kbit_AAC).mp3', 1, B'1', NULL, 2.11540, 1, 'features_1137.npy', NULL),
	(1095, 0, 5176143, '初音ミクが声優のようにしゃべってラップする曲ビバハピ Mitchie M.mp3', 1, B'1', NULL, 1.31959, 1, 'features_1095.npy', NULL),
	(1058, 0, 4028008, 'Psychokinesis (feat. Hatsune Miku) 2020 Version  Utsu-P.mp3', 1, B'1', NULL, 0.98765, 1, 'features_1058.npy', NULL),
	(1083, 0, 5693459, '初音ミク - Hatsune Miku AppendAllgatherOriginal.mp3', 1, B'1', NULL, 1.19511, 1, 'features_1083.npy', NULL),
	(1087, 0, 2861385, '初音ミク ｿﾄﾞﾑSodom Hatsune MikuOriginal.mp3', 1, B'1', NULL, 0.94000, 1, 'features_1087.npy', NULL),
	(829, 0, 3862228, '┗_∵_┓吉田、家出するってよ／HoneyWorks feat.初音ミク [fd0uHUAy6TU].mp3', 1, B'1', NULL, 1.87201, 1, 'features_829.npy', NULL),
	(1008, 1, 6742072, '【初音ミク】スターナイトスノウ【オリジナルMV�.mp3', 1, B'1', NULL, 2.03918, 1, 'features_1008.npy', NULL),
	(860, 0, 3683148, '【初音ミク】　 オトシメセルフ 　【オリジナル曲】 [hTQKJQWMQ-4].mp3', 1, B'1', NULL, 1.36762, 1, 'features_860.npy', NULL),
	(919, 0, 4315585, 'Bright future Ein schritt.mp3', 1, B'1', NULL, 0.86613, 1, 'features_919.npy', NULL),
	(816, 0, 3851200, 'After that feat. Hatsune Miku [xRoF-MAJ5O8].mp3', 1, B'1', NULL, 1.02931, 1, 'features_816.npy', NULL),
	(1024, 1, 6525151, '八王子Pデスクトップシンデレラ feat. 初音ミクMusic Video.mp3', 1, B'1', NULL, 2.25406, 1, 'features_1024.npy', NULL),
	(956, 1, 5234911, 'Neru - ロストワンの号哭(Lost One''s Weeping) feat. Kagamine Rin.mp3', 1, B'1', NULL, 2.19216, 1, 'features_956.npy', NULL),
	(922, 1, 5852446, 'cloudway (feat Hatsune Miku)   keisei.mp3', 1, B'1', NULL, 1.74074, 1, 'features_922.npy', NULL),
	(923, 1, 4043380, 'Cressida   ftHatsune Miku 【english subtitles】.mp3', 1, B'1', NULL, 1.34674, 1, 'features_923.npy', NULL),
	(1153, NULL, 5080856, 'Ultimate (feat. Kagamine Len) (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1147, 0, 5616472, 'Off-Album Volume 7; Track 6-Reply to Gerbera (Okame-P) (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1142, NULL, 6635780, 'Flying away (feat. 初音ミク) (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1177, NULL, 5604621, 'アイアルの勘違い (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1230, NULL, 4936776, '稲葉曇『浮遊月光街』Vo. 歌愛ユキ (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1226, NULL, 5001056, '浮遊月光街 (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1229, NULL, 5424243, '疑神暗鬼 ⁄ しーくん feat. flower【Official】 (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1192, NULL, 5144318, 'スチールワンダー ⁄ はるまきごはん feat.初音ミク アニメMV - Steel Wonder (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1196, NULL, 5516370, 'センシティブサマー(SENSITIVE SUMMER) ⁄ ZLMS feat.初音ミク (ジグ・ルワン・はるまきごはん・雄之助） (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1003, 3, 4929612, '【初音ミク】Hatsune Miku「DECORATOR」MP3 High Quality![8].mp3', 1, B'1', NULL, 2.23802, 1, 'features_1003.npy', NULL),
	(891, 2, 4129298, '01 - Tell Your World.mp3', 1, B'1', NULL, 1.20073, 1, 'features_891.npy', NULL),
	(977, 1, 5640540, '[MV]さよならカンパニュラ  mehikari feat 初音ミ�.mp3', 1, B'1', NULL, 1.04227, 1, 'features_977.npy', NULL),
	(1216, 0, 6767001, '初音ミクの激唱(2018Remake) - cosMo＠暴走P (128kbit_AAC).mp3', 1, B'1', NULL, 0.99931, 1, 'features_1216.npy', NULL),
	(1034, 1, 6625461, '夏至の踊り子 ／初音ミ�.mp3', 1, B'1', NULL, 2.34286, 1, 'features_1034.npy', NULL),
	(1021, 1, 6313246, 'シネマセレク�.mp3', 1, B'1', NULL, 2.33310, 1, 'features_1021.npy', NULL),
	(905, 1, 6123034, '11 Anti X''mas Superstar.mp3', 1, B'1', NULL, 0.92820, 1, 'features_905.npy', NULL),
	(1018, 0, 4653386, 'みきとP『 kiss 』MV [9tjA9S281wg].mp3', 1, B'1', NULL, 1.69295, 1, 'features_1018.npy', NULL),
	(1036, 0, 1661360, '小説3こちら幸福安心委員会です女王様とハピネスサマーゲーム.mp3', 1, B'1', NULL, 1.00403, 1, 'features_1036.npy', NULL),
	(884, 0, 4643130, '洗濯　（初音ミクAppend） [yargFkG0q0o].mp3', 1, B'1', NULL, 1.44526, 1, 'features_884.npy', NULL),
	(1223, 2, 7029300, '未来 (いつか) [feat. 初音ミク & 闇音レンリ] (128kbit_AAC).mp3', 1, B'1', NULL, 2.31584, 1, 'features_1223.npy', NULL),
	(871, 0, 4586189, 'とあ - 飛行機雲 - ft.初音ミク ( Toa - Contrail - ft.Hatsune Miku ) [RHCoZroZySA].mp3', 1, B'1', NULL, 0.89075, 1, 'features_871.npy', NULL),
	(914, 1, 6109320, 'Amaotopetrichor (feat. Hatsune Miku).mp3', 1, B'1', NULL, 2.24249, 1, 'features_914.npy', NULL),
	(1043, 1, 2568958, '鏡音レン唐傘さんが通るオリジナルPV.mp3', 1, B'1', NULL, 1.76151, 1, 'features_1043.npy', NULL),
	(866, 0, 3491991, '【初音ミク】天空の六分儀【オリジナルMV】 [x0_e0yQZibY].mp3', 1, B'1', NULL, 1.39460, 1, 'features_866.npy', NULL),
	(971, 1, 3495156, 'yt1s.com - ElectronicMizusano ft Hatsune Miku  Smile Walker.mp3', 1, B'1', NULL, 1.71742, 1, 'features_971.npy', NULL),
	(1133, NULL, 3608383, 'BRASS NOISE FLAMENCO (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1148, NULL, 4792269, 'Sleeping Awake  Aqu3ra feat 初音ミク (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1206, NULL, 5208086, 'ピノキオピー - ビューティフルなフィクション feat. 初音ミク ⁄ Beautiful Fiction (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1207, NULL, 3706535, 'マーシーキリング (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1211, NULL, 4764333, '僕が夢を捨てて大人になるまで (152kbit_Opus).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1212, NULL, 4355916, '僕が夢を捨てて大人になるまで (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1213, NULL, 4987245, '僕が夢を捨てて大人になるまで　⁄  feat. 初音ミク (152kbit_Opus).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1001, 1, 5260371, '【初音ミク】aria【オリジナル曲PV付】.mp3', 1, B'1', NULL, 2.36556, 1, 'features_1001.npy', NULL),
	(1002, 1, 5931974, '【初音ミク】bpm full ver 【PV】.mp3', 1, B'1', NULL, 1.91656, 1, 'features_1002.npy', NULL),
	(983, 1, 4738909, '【Hatsune Miku】Body Music【Original Song】.mp3', 1, B'1', NULL, 2.24513, 1, 'features_983.npy', NULL),
	(894, 3, 8224103, '03 Palette.mp3', 1, B'1', NULL, 1.12672, 1, 'features_894.npy', NULL),
	(981, 1, 5384749, '‪【Hatsune Miku】‬Cerita SMU【Original】‬.mp3', 1, B'1', NULL, 1.46932, 1, 'features_981.npy', NULL),
	(1012, 1, 7576434, '【水野大輔 feat 初音ミく】 Brilliance.mp3', 1, B'1', NULL, 1.55239, 1, 'features_1012.npy', NULL),
	(1022, 1, 4102032, 'プリエ  初音ミク  Hatsune Miku.mp3', 1, B'1', NULL, 1.66201, 1, 'features_1022.npy', NULL),
	(982, 1, 5817964, '┗ ∵ ┓夢ファンファーレ／HoneyWorks feat初音ミクu0026GUM.mp3', 1, B'1', NULL, 1.31772, 1, 'features_982.npy', NULL),
	(836, 0, 4427473, '【Miku·GUMI·Lily·Iroha】「Violet Blue Fantasy ～Fantasy of Iolite～」【Sub Español】 [d86r3_HR5kw].mp3', 1, B'1', NULL, 0.70448, 1, 'features_836.npy', NULL),
	(993, 1, 2801668, '【初音ミク】 Anata no Utahime (8ch arr) 【休闲の1月曲】.mp3', 1, B'1', NULL, 2.33710, 1, 'features_993.npy', NULL),
	(1215, NULL, 6842640, '初音ミク⁄そらをおよぐ (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1221, NULL, 5544129, '愛言葉III (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1222, NULL, 5646561, '撥条少女時計 (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1208, 0, 5068462, 'ミライゲイザー ／ DIVELA feat.初音ミク (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1198, NULL, 4658052, 'テレストテレス (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1228, 0, 6702060, '無限にホメてくれる桜乃そら先生 (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1201, NULL, 4305016, 'デレレレ ／ DIVELA feat.初音ミク (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1202, NULL, 5533589, 'ドンガラシャン (feat. 初音ミク) (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1040, 1, 5408573, '私は足りないでいっぱい_192kbps.mp3', 1, B'1', NULL, 2.34678, 1, 'features_1040.npy', NULL),
	(815, 0, 3325418, '(Reprint) 小悪魔笑顔とワガママボディー【初音ﾐｸﾀﾞﾖｰ オリジナルPV】 [ErksldUjSUI].mp3', 1, B'1', NULL, 0.98961, 1, 'features_815.npy', NULL),
	(1042, 1, 7087515, '膵臓  Luna feat 初音ミク ガールズコレクション.mp3', 1, B'1', NULL, 1.76603, 1, 'features_1042.npy', NULL),
	(1039, 1, 7278104, '神経衰弱  初音ミク 【 Nervous Breakdown  Hatsune Miku �.mp3', 1, B'1', NULL, 2.21752, 1, 'features_1039.npy', NULL),
	(974, 1, 4184609, '[Eng Sub] To the Lonely You and the Lone Me [Suzumu ft. Hatsune Miku] [EHxFEHPBDP8].mp3', 1, B'1', NULL, 1.84546, 1, 'features_974.npy', NULL),
	(906, 2, 8975210, '11 ハロー、プラネット.mp3', 1, B'1', NULL, 1.10850, 1, 'features_906.npy', NULL),
	(1011, 1, 6175226, '【初音ミク・GUMI】あの日、描いたDIARY【オリジナル曲PV】OFFICIAL　MV.mp3', 1, B'1', NULL, 1.82704, 1, 'features_1011.npy', NULL),
	(913, 2, 5785263, '20 どういうことなの! (Game Version).mp3', 1, B'1', NULL, 2.21027, 1, 'features_913.npy', NULL),
	(943, 1, 6782196, 'irucaice   White Step feat Hatsune Mik.mp3', 1, B'1', NULL, 1.92482, 1, 'features_943.npy', NULL),
	(902, 1, 15100066, '09 キューティージェリー (feat. 初音ミク).mp3', 1, B'1', NULL, 2.14838, 1, 'features_902.npy', NULL),
	(898, 2, 3675539, '05 Night Glitter (Featuring Hatsune Miku).mp3', 1, B'1', NULL, 2.13128, 1, 'features_898.npy', NULL),
	(998, 1, 6366535, '【初音ミク】 紫陽花が咲く頃に、君と恋をする 【nk】.mp3', 1, B'1', NULL, 2.37305, 1, 'features_998.npy', NULL),
	(975, 3, 6084413, '[Hatsune Miku] Sayonara Arpeggio [VOSTFR].mp3', 1, B'1', NULL, 1.01987, 1, 'features_975.npy', NULL),
	(944, 1, 5845549, 'kiRakiLa  gaogao feat初音ミ�.mp3', 1, B'1', NULL, 1.42584, 1, 'features_944.npy', NULL),
	(1190, 0, 5591923, 'コロナ (feat. Kagamine Rin) (128kbit_AAC).mp3', 1, B'1', NULL, 1.28129, 1, 'features_1190.npy', NULL),
	(1227, 0, 6121514, '無限にホメてくれる桜乃そら先生 (128kbit_AAC).mp3', 1, B'1', NULL, 1.06681, 1, 'features_1227.npy', NULL),
	(1224, 0, 6143344, '泥中に咲く (feat. 初音ミク) (128kbit_AAC).mp3', 1, B'1', NULL, 1.78373, 1, 'features_1224.npy', NULL),
	(1015, 1, 5372210, 'くるくるついんてーる_192kbps.mp3', 1, B'1', NULL, 1.75843, 1, 'features_1015.npy', NULL),
	(880, 1, 4468974, '恋人一首 _ 初音ミク [f7vloBZBp6c].mp3', 1, B'1', NULL, 1.21595, 1, 'features_880.npy', NULL),
	(938, 2, 5052472, 'Hatsune Miku   Torinoko City  (トリノコシティ)(Left Behind City) Sub Esp (+mp3 + romaji.mp3', 1, B'1', NULL, 2.24183, 1, 'features_938.npy', NULL),
	(918, 1, 7372052, 'Breath of Urban   keisei feat Hatsune Miku.mp3', 1, B'1', NULL, 1.87185, 1, 'features_918.npy', NULL),
	(1029, 1, 6602171, '初音ミクオリジナル曲 「Breath of mechanical」.mp3', 1, B'1', NULL, 1.83361, 1, 'features_1029.npy', NULL),
	(912, 2, 8169778, '18 リンリンシグナル.mp3', 1, B'1', NULL, 2.28309, 1, 'features_912.npy', NULL),
	(937, 3, 4216042, 'Hatsune Miku   Sayonara·Good bye [English Sub].mp3', 1, B'1', NULL, 1.01904, 1, 'features_937.npy', NULL),
	(882, 0, 3489005, '最憂間で君は [fmbOTo1t1dk].mp3', 1, B'1', NULL, 1.42761, 1, 'features_882.npy', NULL),
	(867, 0, 4512043, '【初音ミク】祝祭と流転 English and romaji subs [ieEk2hXFkOw].mp3', 1, B'1', NULL, 0.87030, 1, 'features_867.npy', NULL),
	(886, 0, 4240510, '雀色コンデンサ [Rh3XRrvzl50].mp3', 1, B'1', NULL, 1.11462, 1, 'features_886.npy', NULL),
	(961, 3, 6713232, 'Rainbow Palace feat Hatsune Miku   Jonathan Parecki 【Vocaloid Original�.mp3', 1, B'1', NULL, 1.82972, 1, 'features_961.npy', NULL),
	(1127, 0, 4979425, '#Luna - アルティメット (Ultimate) feat.Kagamine Len (128kbit_AAC).mp3', 1, B'1', NULL, 1.81587, 1, 'features_1127.npy', NULL),
	(1139, 0, 4162121, 'Dasu - Cur Ergo ft. IA & Kagamine Rin (Original) (128kbit_AAC).mp3', 1, B'1', NULL, 1.16632, 1, 'features_1139.npy', NULL),
	(1009, 1, 6236759, '【初音ミク】名前のない誰か【オリジナル�.mp3', 1, B'1', NULL, 2.10696, 1, 'features_1009.npy', NULL);


--
-- Data for Name: entrenamientos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.entrenamientos OVERRIDING SYSTEM VALUE VALUES
	(12467, 832, B'0', 24, '2026-06-08 20:43:58.558583-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12468, 874, B'0', 24, '2026-06-08 20:43:58.568104-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12469, 988, B'0', 24, '2026-06-08 20:43:58.568685-06', 3, 28, 1.12773, '32', 0.200, 0.502),
	(12470, 838, B'0', 24, '2026-06-08 20:43:58.569098-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12471, 864, B'0', 24, '2026-06-08 20:43:58.569504-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12472, 839, B'0', 24, '2026-06-08 20:43:58.569819-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12473, 1122, B'0', 24, '2026-06-08 20:43:58.570125-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12474, 1158, B'0', 24, '2026-06-08 20:43:58.570549-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12475, 1197, B'0', 24, '2026-06-08 20:43:58.57095-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12476, 1214, B'0', 24, '2026-06-08 20:43:58.571746-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12477, 1099, B'0', 24, '2026-06-08 20:43:58.572123-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12478, 996, B'0', 24, '2026-06-08 20:43:58.572555-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12479, 822, B'0', 24, '2026-06-08 20:43:58.572974-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12480, 1118, B'0', 24, '2026-06-08 20:43:58.573278-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12481, 1121, B'0', 24, '2026-06-08 20:43:58.573662-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12482, 1141, B'0', 24, '2026-06-08 20:43:58.574157-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12483, 1156, B'0', 24, '2026-06-08 20:43:58.574638-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12484, 1150, B'0', 24, '2026-06-08 20:43:58.574992-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12485, 947, B'0', 24, '2026-06-08 20:43:58.575444-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12486, 857, B'0', 24, '2026-06-08 20:43:58.575945-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12487, 1093, B'0', 24, '2026-06-08 20:43:58.57638-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12488, 972, B'0', 24, '2026-06-08 20:43:58.577248-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12489, 821, B'0', 24, '2026-06-08 20:43:58.577582-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12490, 896, B'0', 24, '2026-06-08 20:43:58.577884-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12491, 1097, B'0', 24, '2026-06-08 20:43:58.578714-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12492, 820, B'0', 24, '2026-06-08 20:43:58.57906-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12493, 1115, B'0', 24, '2026-06-08 20:43:58.57938-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12494, 848, B'0', 24, '2026-06-08 20:43:58.579765-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12495, 877, B'0', 24, '2026-06-08 20:43:58.580214-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12496, 1063, B'0', 24, '2026-06-08 20:43:58.580627-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12497, 1064, B'0', 24, '2026-06-08 20:43:58.581026-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12498, 903, B'0', 24, '2026-06-08 20:43:58.581429-06', 3, 28, 1.12773, '32', 0.200, 0.502),
	(12499, 875, B'0', 24, '2026-06-08 20:43:58.581777-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12500, 879, B'0', 24, '2026-06-08 20:43:58.582277-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12501, 932, B'0', 24, '2026-06-08 20:43:58.582644-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12502, 1146, B'0', 24, '2026-06-08 20:43:58.583033-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12503, 930, B'0', 24, '2026-06-08 20:43:58.583393-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12504, 989, B'0', 24, '2026-06-08 20:43:58.583741-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12505, 1046, B'0', 24, '2026-06-08 20:43:58.58417-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12506, 1056, B'0', 24, '2026-06-08 20:43:58.584664-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12507, 1057, B'0', 24, '2026-06-08 20:43:58.585077-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12508, 999, B'0', 24, '2026-06-08 20:43:58.585499-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12509, 878, B'0', 24, '2026-06-08 20:43:58.585972-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12510, 853, B'0', 24, '2026-06-08 20:43:58.586357-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12511, 1119, B'0', 24, '2026-06-08 20:43:58.586728-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12512, 1155, B'0', 24, '2026-06-08 20:43:58.587025-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12513, 1145, B'0', 24, '2026-06-08 20:43:58.587421-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12514, 1152, B'0', 24, '2026-06-08 20:43:58.587803-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12515, 1067, B'0', 24, '2026-06-08 20:43:58.588223-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12516, 861, B'0', 24, '2026-06-08 20:43:58.588668-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12517, 1062, B'0', 24, '2026-06-08 20:43:58.589791-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12518, 940, B'0', 24, '2026-06-08 20:43:58.590512-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12519, 858, B'0', 24, '2026-06-08 20:43:58.590828-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12520, 939, B'0', 24, '2026-06-08 20:43:58.591178-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12521, 909, B'0', 24, '2026-06-08 20:43:58.591451-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12522, 964, B'0', 24, '2026-06-08 20:43:58.591738-06', 3, 28, 1.12773, '32', 0.200, 0.502),
	(12523, 890, B'0', 24, '2026-06-08 20:43:58.59204-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12524, 987, B'0', 24, '2026-06-08 20:43:58.592307-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12525, 945, B'0', 24, '2026-06-08 20:43:58.592574-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12526, 1173, B'0', 24, '2026-06-08 20:43:58.592981-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12527, 1163, B'0', 24, '2026-06-08 20:43:58.593293-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12528, 1181, B'0', 24, '2026-06-08 20:43:58.593567-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12529, 899, B'0', 24, '2026-06-08 20:43:58.59403-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12530, 934, B'0', 24, '2026-06-08 20:43:58.59438-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12531, 1125, B'0', 24, '2026-06-08 20:43:58.594698-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12532, 1059, B'0', 24, '2026-06-08 20:43:58.595033-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12533, 1076, B'0', 24, '2026-06-08 20:43:58.595343-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12534, 1111, B'0', 24, '2026-06-08 20:43:58.595648-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12535, 1038, B'0', 24, '2026-06-08 20:43:58.596014-06', 3, 28, 1.12773, '32', 0.200, 0.502),
	(12536, 1144, B'0', 24, '2026-06-08 20:43:58.596295-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12537, 1154, B'0', 24, '2026-06-08 20:43:58.596592-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12538, 1169, B'0', 24, '2026-06-08 20:43:58.597029-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12539, 1072, B'0', 24, '2026-06-08 20:43:58.597296-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12540, 1047, B'0', 24, '2026-06-08 20:43:58.597604-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12541, 979, B'0', 24, '2026-06-08 20:43:58.597939-06', 3, 28, 1.12773, '32', 0.200, 0.502),
	(12542, 1074, B'0', 24, '2026-06-08 20:43:58.598334-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12543, 1098, B'0', 24, '2026-06-08 20:43:58.598623-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12544, 1110, B'0', 24, '2026-06-08 20:43:58.598939-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12545, 954, B'0', 24, '2026-06-08 20:43:58.599204-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12546, 868, B'0', 24, '2026-06-08 20:43:58.599465-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12547, 1124, B'0', 24, '2026-06-08 20:43:58.599729-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12548, 1007, B'0', 24, '2026-06-08 20:43:58.599987-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12549, 819, B'0', 24, '2026-06-08 20:43:58.600312-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12550, 849, B'0', 24, '2026-06-08 20:43:58.600712-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12551, 1066, B'0', 24, '2026-06-08 20:43:58.600996-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12552, 965, B'0', 24, '2026-06-08 20:43:58.601262-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12553, 1026, B'0', 24, '2026-06-08 20:43:58.601602-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12554, 1071, B'0', 24, '2026-06-08 20:43:58.602085-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12555, 1054, B'0', 24, '2026-06-08 20:43:58.6024-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12556, 966, B'0', 24, '2026-06-08 20:43:58.602995-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12557, 856, B'0', 24, '2026-06-08 20:43:58.603315-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12558, 1101, B'0', 24, '2026-06-08 20:43:58.603606-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12559, 870, B'0', 24, '2026-06-08 20:43:58.603915-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12560, 846, B'0', 24, '2026-06-08 20:43:58.604313-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12561, 854, B'0', 24, '2026-06-08 20:43:58.604586-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12562, 984, B'0', 24, '2026-06-08 20:43:58.604858-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12563, 924, B'0', 24, '2026-06-08 20:43:58.606172-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12564, 1102, B'0', 24, '2026-06-08 20:43:58.606589-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12565, 1100, B'0', 24, '2026-06-08 20:43:58.606945-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12566, 1105, B'0', 24, '2026-06-08 20:43:58.607263-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12567, 1175, B'0', 24, '2026-06-08 20:43:58.607551-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12568, 1166, B'0', 24, '2026-06-08 20:43:58.607852-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12569, 955, B'0', 24, '2026-06-08 20:43:58.608156-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12570, 1017, B'0', 24, '2026-06-08 20:43:58.608433-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12571, 835, B'0', 24, '2026-06-08 20:43:58.608752-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12572, 1126, B'0', 24, '2026-06-08 20:43:58.609147-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12573, 1204, B'0', 24, '2026-06-08 20:43:58.60947-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12574, 1200, B'0', 24, '2026-06-08 20:43:58.609795-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12575, 1193, B'0', 24, '2026-06-08 20:43:58.610258-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12576, 1218, B'0', 24, '2026-06-08 20:43:58.610655-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12577, 1203, B'0', 24, '2026-06-08 20:43:58.610965-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12578, 951, B'0', 24, '2026-06-08 20:43:58.61124-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12579, 1205, B'0', 24, '2026-06-08 20:43:58.611534-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12580, 1088, B'0', 24, '2026-06-08 20:43:58.611831-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12581, 1065, B'0', 24, '2026-06-08 20:43:58.612164-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12582, 1031, B'0', 24, '2026-06-08 20:43:58.612442-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12583, 833, B'0', 24, '2026-06-08 20:43:58.612865-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12584, 1004, B'0', 24, '2026-06-08 20:43:58.613191-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12585, 1077, B'0', 24, '2026-06-08 20:43:58.613541-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12586, 814, B'0', 24, '2026-06-08 20:43:58.613854-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12587, 1191, B'0', 24, '2026-06-08 20:43:58.614139-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12588, 1199, B'0', 24, '2026-06-08 20:43:58.614441-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12589, 1032, B'0', 24, '2026-06-08 20:43:58.614713-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12590, 1219, B'0', 24, '2026-06-08 20:43:58.615007-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12591, 863, B'0', 24, '2026-06-08 20:43:58.615304-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12592, 1185, B'0', 24, '2026-06-08 20:43:58.615745-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12593, 1045, B'0', 24, '2026-06-08 20:43:58.616443-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12594, 1134, B'0', 24, '2026-06-08 20:43:58.616743-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12595, 1170, B'0', 24, '2026-06-08 20:43:58.617318-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12596, 963, B'0', 24, '2026-06-08 20:43:58.61765-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12597, 925, B'0', 24, '2026-06-08 20:43:58.617958-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12598, 1068, B'0', 24, '2026-06-08 20:43:58.618273-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12599, 1070, B'0', 24, '2026-06-08 20:43:58.618577-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12600, 959, B'0', 24, '2026-06-08 20:43:58.61886-06', 3, 28, 1.12773, '32', 0.200, 0.502),
	(12601, 823, B'0', 24, '2026-06-08 20:43:58.619177-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12602, 992, B'0', 24, '2026-06-08 20:43:58.619514-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12603, 841, B'0', 24, '2026-06-08 20:43:58.619956-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12604, 1084, B'0', 24, '2026-06-08 20:43:58.620228-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12605, 1113, B'0', 24, '2026-06-08 20:43:58.620561-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12606, 1010, B'0', 24, '2026-06-08 20:43:58.62085-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12607, 1120, B'0', 24, '2026-06-08 20:43:58.621206-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12608, 1073, B'0', 24, '2026-06-08 20:43:58.621504-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12609, 1016, B'0', 24, '2026-06-08 20:43:58.621771-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12610, 1033, B'0', 24, '2026-06-08 20:43:58.622104-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12611, 893, B'0', 24, '2026-06-08 20:43:58.62241-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12612, 1019, B'0', 24, '2026-06-08 20:43:58.622682-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12613, 942, B'0', 24, '2026-06-08 20:43:58.622944-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12614, 1041, B'0', 24, '2026-06-08 20:43:58.624336-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12615, 921, B'0', 24, '2026-06-08 20:43:58.624702-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12616, 1143, B'0', 24, '2026-06-08 20:43:58.625027-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12617, 1217, B'0', 24, '2026-06-08 20:43:58.625327-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12618, 1081, B'0', 24, '2026-06-08 20:43:58.625591-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12619, 1082, B'0', 24, '2026-06-08 20:43:58.62595-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12620, 837, B'0', 24, '2026-06-08 20:43:58.626254-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12621, 926, B'0', 24, '2026-06-08 20:43:58.626584-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12622, 1049, B'0', 24, '2026-06-08 20:43:58.626979-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12623, 1050, B'0', 24, '2026-06-08 20:43:58.627337-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12624, 1123, B'0', 24, '2026-06-08 20:43:58.627629-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12625, 933, B'0', 24, '2026-06-08 20:43:58.627898-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12626, 826, B'0', 24, '2026-06-08 20:43:58.628161-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12627, 911, B'0', 24, '2026-06-08 20:43:58.628441-06', 3, 28, 1.12773, '32', 0.200, 0.502),
	(12628, 1051, B'0', 24, '2026-06-08 20:43:58.62875-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12629, 1052, B'0', 24, '2026-06-08 20:43:58.629021-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12630, 1053, B'0', 24, '2026-06-08 20:43:58.629366-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12631, 1075, B'0', 24, '2026-06-08 20:43:58.629733-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12632, 920, B'0', 24, '2026-06-08 20:43:58.630019-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12633, 960, B'0', 24, '2026-06-08 20:43:58.630334-06', 3, 28, 1.12773, '32', 0.200, 0.502),
	(12634, 952, B'0', 24, '2026-06-08 20:43:58.630633-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12635, 949, B'0', 24, '2026-06-08 20:43:58.630936-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12636, 904, B'0', 24, '2026-06-08 20:43:58.631247-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12637, 991, B'0', 24, '2026-06-08 20:43:58.631517-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12638, 840, B'0', 24, '2026-06-08 20:43:58.631778-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12639, 825, B'0', 24, '2026-06-08 20:43:58.632037-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12640, 1129, B'0', 24, '2026-06-08 20:43:58.632596-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12641, 1128, B'0', 24, '2026-06-08 20:43:58.632863-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12642, 1114, B'0', 24, '2026-06-08 20:43:58.633126-06', 3, 28, 1.12773, '32', 0.200, 0.502),
	(12643, 865, B'0', 24, '2026-06-08 20:43:58.633396-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12644, 1086, B'0', 24, '2026-06-08 20:43:58.633811-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12645, 1094, B'0', 24, '2026-06-08 20:43:58.634311-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12646, 1080, B'0', 24, '2026-06-08 20:43:58.634585-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12647, 1089, B'0', 24, '2026-06-08 20:43:58.634849-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12648, 828, B'0', 24, '2026-06-08 20:43:58.635158-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12649, 1078, B'0', 24, '2026-06-08 20:43:58.635482-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12650, 1079, B'0', 24, '2026-06-08 20:43:58.6366-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12651, 1044, B'0', 24, '2026-06-08 20:43:58.636931-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12652, 916, B'0', 24, '2026-06-08 20:43:58.637218-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12653, 967, B'0', 24, '2026-06-08 20:43:58.637523-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12654, 1014, B'0', 24, '2026-06-08 20:43:58.637846-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12655, 818, B'0', 24, '2026-06-08 20:43:58.638182-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12656, 935, B'0', 24, '2026-06-08 20:43:58.638545-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12657, 953, B'0', 24, '2026-06-08 20:43:58.638853-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12658, 1132, B'0', 24, '2026-06-08 20:43:58.63915-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12659, 1210, B'0', 24, '2026-06-08 20:43:58.63942-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12660, 928, B'0', 24, '2026-06-08 20:43:58.639721-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12661, 887, B'0', 24, '2026-06-08 20:43:58.640017-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12662, 915, B'0', 24, '2026-06-08 20:43:58.640307-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12663, 1085, B'0', 24, '2026-06-08 20:43:58.640595-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12664, 834, B'0', 24, '2026-06-08 20:43:58.640862-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12665, 1096, B'0', 24, '2026-06-08 20:43:58.641188-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12666, 968, B'0', 24, '2026-06-08 20:43:58.641488-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12667, 969, B'0', 24, '2026-06-08 20:43:58.641755-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12668, 855, B'0', 24, '2026-06-08 20:43:58.64204-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12669, 1030, B'0', 24, '2026-06-08 20:43:58.642424-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12670, 995, B'0', 24, '2026-06-08 20:43:58.642724-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12671, 851, B'0', 24, '2026-06-08 20:43:58.642992-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12672, 1035, B'0', 24, '2026-06-08 20:43:58.643259-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12673, 824, B'0', 24, '2026-06-08 20:43:58.643551-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12674, 929, B'0', 24, '2026-06-08 20:43:58.643817-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12675, 1090, B'0', 24, '2026-06-08 20:43:58.644076-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12676, 1069, B'0', 24, '2026-06-08 20:43:58.644344-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12677, 847, B'0', 24, '2026-06-08 20:43:58.644665-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12678, 852, B'0', 24, '2026-06-08 20:43:58.645038-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12679, 1178, B'0', 24, '2026-06-08 20:43:58.645336-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12680, 843, B'0', 24, '2026-06-08 20:43:58.645667-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12681, 892, B'0', 24, '2026-06-08 20:43:58.646096-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12682, 859, B'0', 24, '2026-06-08 20:43:58.646492-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12683, 1104, B'0', 24, '2026-06-08 20:43:58.646821-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12684, 881, B'0', 24, '2026-06-08 20:43:58.647166-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12685, 1060, B'0', 24, '2026-06-08 20:43:58.647577-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12686, 1061, B'0', 24, '2026-06-08 20:43:58.648037-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12687, 1103, B'0', 24, '2026-06-08 20:43:58.648371-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12688, 1013, B'0', 24, '2026-06-08 20:43:58.648668-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12689, 910, B'0', 24, '2026-06-08 20:43:58.648968-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12690, 1020, B'0', 24, '2026-06-08 20:43:58.649348-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12691, 1151, B'0', 24, '2026-06-08 20:43:58.649789-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12692, 997, B'0', 24, '2026-06-08 20:43:58.650198-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12693, 1165, B'0', 24, '2026-06-08 20:43:58.65049-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12694, 1161, B'0', 24, '2026-06-08 20:43:58.650774-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12695, 1149, B'0', 24, '2026-06-08 20:43:58.651044-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12696, 1055, B'0', 24, '2026-06-08 20:43:58.651339-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12697, 885, B'0', 24, '2026-06-08 20:43:58.651766-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12698, 872, B'0', 24, '2026-06-08 20:43:58.652649-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12699, 941, B'0', 24, '2026-06-08 20:43:58.652959-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12700, 869, B'0', 24, '2026-06-08 20:43:58.653271-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12701, 897, B'0', 24, '2026-06-08 20:43:58.653683-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12702, 970, B'0', 24, '2026-06-08 20:43:58.654057-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12703, 1091, B'0', 24, '2026-06-08 20:43:58.654501-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12704, 1092, B'0', 24, '2026-06-08 20:43:58.654856-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12705, 1187, B'0', 24, '2026-06-08 20:43:58.655189-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12706, 1107, B'0', 24, '2026-06-08 20:43:58.6555-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12707, 1108, B'0', 24, '2026-06-08 20:43:58.6558-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12708, 1109, B'0', 24, '2026-06-08 20:43:58.656137-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12709, 907, B'0', 24, '2026-06-08 20:43:58.656506-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12710, 900, B'0', 24, '2026-06-08 20:43:58.656874-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12711, 994, B'0', 24, '2026-06-08 20:43:58.657302-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12712, 950, B'0', 24, '2026-06-08 20:43:58.65766-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12713, 889, B'0', 24, '2026-06-08 20:43:58.657924-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12714, 936, B'0', 24, '2026-06-08 20:43:58.658287-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12715, 1025, B'0', 24, '2026-06-08 20:43:58.658739-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12716, 957, B'0', 24, '2026-06-08 20:43:58.659132-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12717, 978, B'0', 24, '2026-06-08 20:43:58.659478-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12718, 986, B'0', 24, '2026-06-08 20:43:58.659809-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12719, 1000, B'0', 24, '2026-06-08 20:43:58.66007-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12720, 1023, B'0', 24, '2026-06-08 20:43:58.660391-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12721, 850, B'0', 24, '2026-06-08 20:43:58.660698-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12722, 948, B'0', 24, '2026-06-08 20:43:58.661006-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12723, 1006, B'0', 24, '2026-06-08 20:43:58.661306-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12724, 980, B'0', 24, '2026-06-08 20:43:58.661598-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12725, 976, B'0', 24, '2026-06-08 20:43:58.661992-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12726, 827, B'0', 24, '2026-06-08 20:43:58.662286-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12727, 973, B'0', 24, '2026-06-08 20:43:58.662588-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12728, 895, B'0', 24, '2026-06-08 20:43:58.662879-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12729, 901, B'0', 24, '2026-06-08 20:43:58.663169-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12730, 946, B'0', 24, '2026-06-08 20:43:58.663566-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12731, 1106, B'0', 24, '2026-06-08 20:43:58.663849-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12732, 985, B'0', 24, '2026-06-08 20:43:58.66436-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12733, 842, B'0', 24, '2026-06-08 20:43:58.664692-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12734, 817, B'0', 24, '2026-06-08 20:43:58.665012-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12735, 1112, B'0', 24, '2026-06-08 20:43:58.665327-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12736, 1160, B'0', 24, '2026-06-08 20:43:58.665695-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12737, 830, B'0', 24, '2026-06-08 20:43:58.66607-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12738, 831, B'0', 24, '2026-06-08 20:43:58.666422-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12739, 873, B'0', 24, '2026-06-08 20:43:58.667611-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12740, 1048, B'0', 24, '2026-06-08 20:43:58.668071-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12741, 931, B'0', 24, '2026-06-08 20:43:58.668366-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12742, 1209, B'0', 24, '2026-06-08 20:43:58.668735-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12743, 888, B'0', 24, '2026-06-08 20:43:58.669152-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12744, 917, B'0', 24, '2026-06-08 20:43:58.669427-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12745, 1028, B'0', 24, '2026-06-08 20:43:58.670165-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12746, 1005, B'0', 24, '2026-06-08 20:43:58.670508-06', 3, 28, 1.12773, '32', 0.200, 0.502),
	(12747, 862, B'0', 24, '2026-06-08 20:43:58.670885-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12748, 927, B'0', 24, '2026-06-08 20:43:58.671191-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12749, 1027, B'0', 24, '2026-06-08 20:43:58.671487-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12750, 962, B'0', 24, '2026-06-08 20:43:58.671792-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12751, 958, B'0', 24, '2026-06-08 20:43:58.672085-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12752, 876, B'0', 24, '2026-06-08 20:43:58.672505-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12753, 1131, B'0', 24, '2026-06-08 20:43:58.672859-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12754, 1162, B'0', 24, '2026-06-08 20:43:58.673173-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12755, 1164, B'0', 24, '2026-06-08 20:43:58.673492-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12756, 1037, B'0', 24, '2026-06-08 20:43:58.673959-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12757, 1136, B'0', 24, '2026-06-08 20:43:58.674263-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12758, 990, B'0', 24, '2026-06-08 20:43:58.674602-06', 3, 28, 1.12773, '32', 0.200, 0.502),
	(12759, 1116, B'0', 24, '2026-06-08 20:43:58.675062-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12760, 1135, B'0', 24, '2026-06-08 20:43:58.675413-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12761, 1137, B'0', 24, '2026-06-08 20:43:58.675783-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12762, 1095, B'0', 24, '2026-06-08 20:43:58.676073-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12763, 1058, B'0', 24, '2026-06-08 20:43:58.676344-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12764, 1083, B'0', 24, '2026-06-08 20:43:58.676623-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12765, 1087, B'0', 24, '2026-06-08 20:43:58.676891-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12766, 829, B'0', 24, '2026-06-08 20:43:58.677151-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12767, 1008, B'0', 24, '2026-06-08 20:43:58.677453-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12768, 860, B'0', 24, '2026-06-08 20:43:58.677748-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12769, 919, B'0', 24, '2026-06-08 20:43:58.678011-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12770, 816, B'0', 24, '2026-06-08 20:43:58.678272-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12771, 1024, B'0', 24, '2026-06-08 20:43:58.678546-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12772, 956, B'0', 24, '2026-06-08 20:43:58.678986-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12773, 922, B'0', 24, '2026-06-08 20:43:58.679499-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12774, 923, B'0', 24, '2026-06-08 20:43:58.679988-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12775, 914, B'0', 24, '2026-06-08 20:43:58.680268-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12776, 1043, B'0', 24, '2026-06-08 20:43:58.680548-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12777, 866, B'0', 24, '2026-06-08 20:43:58.680814-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12778, 1003, B'0', 24, '2026-06-08 20:43:58.681088-06', 3, 28, 1.12773, '32', 0.200, 0.502),
	(12779, 891, B'0', 24, '2026-06-08 20:43:58.681362-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12780, 977, B'0', 24, '2026-06-08 20:43:58.681632-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12781, 1216, B'0', 24, '2026-06-08 20:43:58.681898-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12782, 1034, B'0', 24, '2026-06-08 20:43:58.682167-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12783, 1021, B'0', 24, '2026-06-08 20:43:58.682534-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12784, 905, B'0', 24, '2026-06-08 20:43:58.682882-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12785, 1018, B'0', 24, '2026-06-08 20:43:58.683202-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12786, 1036, B'0', 24, '2026-06-08 20:43:58.6835-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12787, 884, B'0', 24, '2026-06-08 20:43:58.683819-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12788, 1223, B'0', 24, '2026-06-08 20:43:58.684092-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12789, 871, B'0', 24, '2026-06-08 20:43:58.684391-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12790, 981, B'0', 24, '2026-06-08 20:43:58.684716-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12791, 1012, B'0', 24, '2026-06-08 20:43:58.685013-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12792, 1022, B'0', 24, '2026-06-08 20:43:58.685311-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12793, 982, B'0', 24, '2026-06-08 20:43:58.685638-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12794, 836, B'0', 24, '2026-06-08 20:43:58.685915-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12795, 993, B'0', 24, '2026-06-08 20:43:58.686275-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12796, 971, B'0', 24, '2026-06-08 20:43:58.686625-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12797, 1001, B'0', 24, '2026-06-08 20:43:58.68695-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12798, 1002, B'0', 24, '2026-06-08 20:43:58.687265-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12799, 983, B'0', 24, '2026-06-08 20:43:58.687599-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12800, 894, B'0', 24, '2026-06-08 20:43:58.687887-06', 3, 28, 1.12773, '32', 0.200, 0.502),
	(12801, 1040, B'0', 24, '2026-06-08 20:43:58.688156-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12802, 815, B'0', 24, '2026-06-08 20:43:58.68842-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12803, 1042, B'0', 24, '2026-06-08 20:43:58.689341-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12804, 1039, B'0', 24, '2026-06-08 20:43:58.689669-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12805, 974, B'0', 24, '2026-06-08 20:43:58.69-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12806, 906, B'0', 24, '2026-06-08 20:43:58.690305-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12807, 1011, B'0', 24, '2026-06-08 20:43:58.690749-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12808, 913, B'0', 24, '2026-06-08 20:43:58.691027-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12809, 943, B'0', 24, '2026-06-08 20:43:58.691295-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12810, 882, B'0', 24, '2026-06-08 20:43:58.691564-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12811, 867, B'0', 24, '2026-06-08 20:43:58.691866-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12812, 886, B'0', 24, '2026-06-08 20:43:58.692152-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12813, 961, B'0', 24, '2026-06-08 20:43:58.69242-06', 3, 28, 1.12773, '32', 0.200, 0.502),
	(12814, 1127, B'0', 24, '2026-06-08 20:43:58.692691-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12815, 1139, B'0', 24, '2026-06-08 20:43:58.692951-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12816, 1009, B'0', 24, '2026-06-08 20:43:58.693364-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12817, 902, B'0', 24, '2026-06-08 20:43:58.693738-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12818, 898, B'0', 24, '2026-06-08 20:43:58.694096-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12819, 998, B'0', 24, '2026-06-08 20:43:58.694468-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12820, 975, B'0', 24, '2026-06-08 20:43:58.694841-06', 3, 28, 1.12773, '32', 0.200, 0.502),
	(12821, 944, B'0', 24, '2026-06-08 20:43:58.695171-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12822, 1190, B'0', 24, '2026-06-08 20:43:58.695464-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12823, 1227, B'0', 24, '2026-06-08 20:43:58.695739-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12824, 1224, B'0', 24, '2026-06-08 20:43:58.696006-06', 0, 28, 1.12773, '32', 0.200, 0.502),
	(12825, 1015, B'0', 24, '2026-06-08 20:43:58.696306-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12826, 880, B'0', 24, '2026-06-08 20:43:58.696599-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12827, 938, B'0', 24, '2026-06-08 20:43:58.696888-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12828, 918, B'0', 24, '2026-06-08 20:43:58.697155-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12829, 1029, B'0', 24, '2026-06-08 20:43:58.697456-06', 1, 28, 1.12773, '32', 0.200, 0.502),
	(12830, 912, B'0', 24, '2026-06-08 20:43:58.697736-06', 2, 28, 1.12773, '32', 0.200, 0.502),
	(12831, 937, B'0', 24, '2026-06-08 20:43:58.698014-06', 3, 28, 1.12773, '32', 0.200, 0.502);


--
-- Data for Name: playlists; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.playlists OVERRIDING SYSTEM VALUE VALUES
	(2, 'Prueba', NULL, '2026-03-04 21:49:46.413684-06', B'1', B'0'),
	(1, 'Favoritos', 24, '2026-02-22 18:57:37.569194-06', B'1', B'1');


--
-- Data for Name: predicciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.predicciones OVERRIDING SYSTEM VALUE VALUES
	(12698, 857, 24, '2026-06-08 20:44:14.479617-06', 1.08168, 0, 63.944, 12486),
	(12699, 832, 24, '2026-06-08 20:44:14.479617-06', 0.67473, 0, 77.509, 12467),
	(12700, 874, 24, '2026-06-08 20:44:14.479617-06', 1.00662, 0, 66.446, 12468),
	(12701, 988, 24, '2026-06-08 20:44:14.479617-06', 2.25591, 3, 75.197, 12469),
	(12702, 838, 24, '2026-06-08 20:44:14.479617-06', 1.19957, 0, 60.014, 12470),
	(12703, 864, 24, '2026-06-08 20:44:14.479617-06', 1.76434, 0, 41.189, 12471),
	(12704, 839, 24, '2026-06-08 20:44:14.479617-06', 1.22350, 0, 59.217, 12472),
	(12705, 1122, 24, '2026-06-08 20:44:14.479617-06', 1.38690, 0, 53.770, 12473),
	(12706, 1158, 24, '2026-06-08 20:44:14.479617-06', 1.10787, 0, 63.071, 12474),
	(12707, 1197, 24, '2026-06-08 20:44:14.479617-06', 1.31593, 0, 56.136, 12475),
	(12708, 1214, 24, '2026-06-08 20:44:14.479617-06', 1.09039, 0, 63.654, 12476),
	(12709, 1099, 24, '2026-06-08 20:44:14.479617-06', 0.93351, 0, 68.883, 12477),
	(12710, 996, 24, '2026-06-08 20:44:14.479617-06', 2.01519, 1, 66.160, 12478),
	(12711, 822, 24, '2026-06-08 20:44:14.479617-06', 1.45583, 0, 51.472, 12479),
	(12712, 1118, 24, '2026-06-08 20:44:14.479617-06', 1.20341, 0, 59.886, 12480),
	(12713, 1121, 24, '2026-06-08 20:44:14.479617-06', 1.36525, 2, 78.842, 12481),
	(12714, 1141, 24, '2026-06-08 20:44:14.479617-06', 1.51339, 0, 49.554, 12482),
	(12715, 1156, 24, '2026-06-08 20:44:14.479617-06', 1.15210, 0, 61.597, 12483),
	(12716, 1150, 24, '2026-06-08 20:44:14.479617-06', 1.43780, 0, 52.073, 12484),
	(12717, 947, 24, '2026-06-08 20:44:14.479617-06', 1.32920, 1, 89.027, 12485),
	(12718, 820, 24, '2026-06-08 20:44:14.479617-06', 0.92712, 0, 69.096, 12492),
	(12719, 1115, 24, '2026-06-08 20:44:14.479617-06', 1.73472, 0, 42.176, 12493),
	(12720, 1093, 24, '2026-06-08 20:44:14.479617-06', 1.06004, 0, 64.665, 12487),
	(12721, 972, 24, '2026-06-08 20:44:14.479617-06', 2.23748, 1, 58.751, 12488),
	(12722, 821, 24, '2026-06-08 20:44:14.479617-06', 1.49200, 0, 50.267, 12489),
	(12723, 896, 24, '2026-06-08 20:44:14.479617-06', 1.78718, 1, 73.761, 12490),
	(12724, 1097, 24, '2026-06-08 20:44:14.479617-06', 1.41775, 0, 52.742, 12491),
	(12725, 848, 24, '2026-06-08 20:44:14.479617-06', 0.76163, 0, 74.612, 12494),
	(12726, 877, 24, '2026-06-08 20:44:14.479617-06', 1.32457, 0, 55.848, 12495),
	(12727, 1063, 24, '2026-06-08 20:44:14.479617-06', 0.93526, 0, 68.825, 12496),
	(12728, 1064, 24, '2026-06-08 20:44:14.479617-06', 0.57102, 0, 80.966, 12497),
	(12729, 903, 24, '2026-06-08 20:44:14.479617-06', 2.23182, 3, 74.394, 12498),
	(12730, 875, 24, '2026-06-08 20:44:14.479617-06', 2.02998, 0, 32.334, 12499),
	(12731, 879, 24, '2026-06-08 20:44:14.479617-06', 0.94595, 0, 68.468, 12500),
	(12732, 932, 24, '2026-06-08 20:44:14.479617-06', 1.46245, 2, 82.082, 12501),
	(12733, 1146, 24, '2026-06-08 20:44:14.479617-06', 2.04595, 1, 65.135, 12502),
	(12734, 930, 24, '2026-06-08 20:44:14.479617-06', 2.28210, 1, 57.263, 12503),
	(12735, 989, 24, '2026-06-08 20:44:14.479617-06', 1.55942, 1, 81.353, 12504),
	(12736, 1046, 24, '2026-06-08 20:44:14.479617-06', 0.76069, 0, 74.644, 12505),
	(12737, 1056, 24, '2026-06-08 20:44:14.479617-06', 1.00335, 1, 99.888, 12506),
	(12738, 1057, 24, '2026-06-08 20:44:14.479617-06', 0.87013, 0, 70.996, 12507),
	(12739, 999, 24, '2026-06-08 20:44:14.479617-06', 1.56387, 1, 81.204, 12508),
	(12740, 878, 24, '2026-06-08 20:44:14.479617-06', 0.94312, 0, 68.563, 12509),
	(12741, 853, 24, '2026-06-08 20:44:14.479617-06', 1.22752, 0, 59.083, 12510),
	(12742, 1119, 24, '2026-06-08 20:44:14.479617-06', 0.94888, 0, 68.371, 12511),
	(12743, 1155, 24, '2026-06-08 20:44:14.479617-06', 1.72046, 0, 42.651, 12512),
	(12744, 1145, 24, '2026-06-08 20:44:14.479617-06', 2.27433, 0, 24.189, 12513),
	(12745, 1152, 24, '2026-06-08 20:44:14.479617-06', 2.08877, 2, 97.041, 12514),
	(12746, 1067, 24, '2026-06-08 20:44:14.479617-06', 0.83230, 0, 72.257, 12515),
	(12747, 861, 24, '2026-06-08 20:44:14.479617-06', 0.88181, 0, 70.606, 12516),
	(12748, 1062, 24, '2026-06-08 20:44:14.479617-06', 1.37178, 0, 54.274, 12517),
	(12749, 940, 24, '2026-06-08 20:44:14.479617-06', 1.72507, 1, 75.831, 12518),
	(12750, 858, 24, '2026-06-08 20:44:14.479617-06', 1.44691, 0, 51.770, 12519),
	(12751, 939, 24, '2026-06-08 20:44:14.479617-06', 2.00903, 1, 66.366, 12520),
	(12752, 909, 24, '2026-06-08 20:44:14.479617-06', 2.29757, 2, 90.081, 12521),
	(12753, 964, 24, '2026-06-08 20:44:14.479617-06', 2.34618, 3, 78.206, 12522),
	(12754, 890, 24, '2026-06-08 20:44:14.479617-06', 1.79792, 2, 93.264, 12523),
	(12755, 987, 24, '2026-06-08 20:44:14.479617-06', 1.79984, 2, 93.328, 12524),
	(12756, 945, 24, '2026-06-08 20:44:14.479617-06', 1.39165, 2, 79.722, 12525),
	(12757, 1173, 24, '2026-06-08 20:44:14.479617-06', 1.14648, 0, 61.784, 12526),
	(12758, 1163, 24, '2026-06-08 20:44:14.479617-06', 1.57637, 0, 47.454, 12527),
	(12759, 1181, 24, '2026-06-08 20:44:14.479617-06', 1.63744, 0, 45.419, 12528),
	(12760, 899, 24, '2026-06-08 20:44:14.479617-06', 2.02885, 2, 99.038, 12529),
	(12761, 934, 24, '2026-06-08 20:44:14.479617-06', 2.01850, 2, 99.383, 12530),
	(12762, 1125, 24, '2026-06-08 20:44:14.479617-06', 1.68194, 0, 43.935, 12531),
	(12763, 1059, 24, '2026-06-08 20:44:14.479617-06', 0.89080, 0, 70.307, 12532),
	(12764, 1076, 24, '2026-06-08 20:44:14.479617-06', 1.18479, 0, 60.507, 12533),
	(12765, 1111, 24, '2026-06-08 20:44:14.479617-06', 1.79406, 0, 40.198, 12534),
	(12766, 1038, 24, '2026-06-08 20:44:14.479617-06', 2.24938, 3, 74.979, 12535),
	(12767, 1144, 24, '2026-06-08 20:44:14.479617-06', 0.92150, 0, 69.283, 12536),
	(12768, 1154, 24, '2026-06-08 20:44:14.479617-06', 1.34925, 0, 55.025, 12537),
	(12769, 1169, 24, '2026-06-08 20:44:14.479617-06', 1.08644, 0, 63.785, 12538),
	(12770, 1072, 24, '2026-06-08 20:44:14.479617-06', 1.08282, 0, 63.906, 12539),
	(12771, 979, 24, '2026-06-08 20:44:14.479617-06', 2.18292, 3, 72.764, 12541),
	(12772, 1074, 24, '2026-06-08 20:44:14.479617-06', 1.05077, 0, 64.974, 12542),
	(12773, 1047, 24, '2026-06-08 20:44:14.479617-06', 0.85174, 0, 71.609, 12540),
	(12774, 1098, 24, '2026-06-08 20:44:14.479617-06', 0.88006, 0, 70.665, 12543),
	(12775, 1110, 24, '2026-06-08 20:44:14.479617-06', 1.01397, 0, 66.201, 12544),
	(12776, 954, 24, '2026-06-08 20:44:14.479617-06', 1.72243, 2, 90.748, 12545),
	(12777, 868, 24, '2026-06-08 20:44:14.479617-06', 0.94948, 0, 68.351, 12546),
	(12778, 1124, 24, '2026-06-08 20:44:14.479617-06', 1.03409, 0, 65.530, 12547),
	(12779, 1007, 24, '2026-06-08 20:44:14.479617-06', 2.28010, 1, 57.330, 12548),
	(12780, 819, 24, '2026-06-08 20:44:14.479617-06', 0.85852, 0, 71.383, 12549),
	(12781, 849, 24, '2026-06-08 20:44:14.479617-06', 1.13225, 0, 62.258, 12550),
	(12782, 1066, 24, '2026-06-08 20:44:14.479617-06', 1.18604, 0, 60.465, 12551),
	(12783, 965, 24, '2026-06-08 20:44:14.479617-06', 1.39063, 2, 79.688, 12552),
	(12784, 1026, 24, '2026-06-08 20:44:14.479617-06', 2.06328, 2, 97.891, 12553),
	(12785, 1071, 24, '2026-06-08 20:44:14.479617-06', 1.92437, 1, 69.188, 12554),
	(12786, 1054, 24, '2026-06-08 20:44:14.479617-06', 1.36183, 1, 87.939, 12555),
	(12787, 966, 24, '2026-06-08 20:44:14.479617-06', 2.29348, 1, 56.884, 12556),
	(12788, 856, 24, '2026-06-08 20:44:14.479617-06', 1.99561, 0, 33.480, 12557),
	(12789, 1101, 24, '2026-06-08 20:44:14.479617-06', 1.52492, 0, 49.169, 12558),
	(12790, 870, 24, '2026-06-08 20:44:14.479617-06', 1.67453, 0, 44.182, 12559),
	(12791, 846, 24, '2026-06-08 20:44:14.479617-06', 0.94995, 0, 68.335, 12560),
	(12792, 854, 24, '2026-06-08 20:44:14.479617-06', 1.69688, 0, 43.437, 12561),
	(12793, 984, 24, '2026-06-08 20:44:14.479617-06', 1.30938, 1, 89.687, 12562),
	(12794, 924, 24, '2026-06-08 20:44:14.479617-06', 2.23243, 2, 92.252, 12563),
	(12795, 1102, 24, '2026-06-08 20:44:14.479617-06', 1.16014, 0, 61.329, 12564),
	(12796, 1100, 24, '2026-06-08 20:44:14.479617-06', 1.73118, 0, 42.294, 12565),
	(12797, 1105, 24, '2026-06-08 20:44:14.479617-06', 0.97355, 0, 67.548, 12566),
	(12798, 1175, 24, '2026-06-08 20:44:14.479617-06', 2.20539, 0, 26.487, 12567),
	(12799, 1166, 24, '2026-06-08 20:44:14.479617-06', 1.75729, 1, 74.757, 12568),
	(12800, 955, 24, '2026-06-08 20:44:14.479617-06', 1.73492, 1, 75.503, 12569),
	(12801, 1017, 24, '2026-06-08 20:44:14.479617-06', 1.76582, 2, 92.194, 12570),
	(12802, 835, 24, '2026-06-08 20:44:14.479617-06', 1.20815, 2, 73.605, 12571),
	(12803, 1126, 24, '2026-06-08 20:44:14.479617-06', 1.70765, 0, 43.078, 12572),
	(12804, 1204, 24, '2026-06-08 20:44:14.479617-06', 1.34199, 0, 55.267, 12573),
	(12805, 1200, 24, '2026-06-08 20:44:14.479617-06', 1.35892, 0, 54.703, 12574),
	(12806, 1193, 24, '2026-06-08 20:44:14.479617-06', 1.33014, 0, 55.662, 12575),
	(12807, 1218, 24, '2026-06-08 20:44:14.479617-06', 1.86813, 0, 37.729, 12576),
	(12808, 1203, 24, '2026-06-08 20:44:14.479617-06', 1.41439, 0, 52.854, 12577),
	(12809, 951, 24, '2026-06-08 20:44:14.479617-06', 1.68160, 2, 89.387, 12578),
	(12810, 1205, 24, '2026-06-08 20:44:14.479617-06', 2.15502, 1, 61.499, 12579),
	(12811, 1088, 24, '2026-06-08 20:44:14.479617-06', 0.82334, 0, 72.555, 12580),
	(12812, 1065, 24, '2026-06-08 20:44:14.479617-06', 1.18604, 0, 60.465, 12581),
	(12813, 1031, 24, '2026-06-08 20:44:14.479617-06', 1.74920, 1, 75.027, 12582),
	(12814, 833, 24, '2026-06-08 20:44:14.479617-06', 1.60266, 0, 46.578, 12583),
	(12815, 1004, 24, '2026-06-08 20:44:14.479617-06', 2.18704, 1, 60.432, 12584),
	(12816, 1077, 24, '2026-06-08 20:44:14.479617-06', 1.94868, 0, 35.044, 12585),
	(12817, 814, 24, '2026-06-08 20:44:14.479617-06', 1.39643, 0, 53.452, 12586),
	(12818, 1191, 24, '2026-06-08 20:44:14.479617-06', 1.32729, 0, 55.757, 12587),
	(12819, 1199, 24, '2026-06-08 20:44:14.479617-06', 2.13949, 0, 28.684, 12588),
	(12820, 1032, 24, '2026-06-08 20:44:14.479617-06', 1.03849, 2, 67.950, 12589),
	(12821, 1219, 24, '2026-06-08 20:44:14.479617-06', 1.81893, 0, 39.369, 12590),
	(12822, 863, 24, '2026-06-08 20:44:14.479617-06', 1.26121, 0, 57.960, 12591),
	(12823, 1185, 24, '2026-06-08 20:44:14.479617-06', 1.09336, 0, 63.555, 12592),
	(12824, 1045, 24, '2026-06-08 20:44:14.479617-06', 0.83494, 0, 72.169, 12593),
	(12825, 1134, 24, '2026-06-08 20:44:14.479617-06', 1.73328, 0, 42.224, 12594),
	(12826, 1170, 24, '2026-06-08 20:44:14.479617-06', 1.59825, 0, 46.725, 12595),
	(12827, 963, 24, '2026-06-08 20:44:14.479617-06', 2.38296, 1, 53.901, 12596),
	(12828, 925, 24, '2026-06-08 20:44:14.479617-06', 2.11343, 1, 62.886, 12597),
	(12829, 1068, 24, '2026-06-08 20:44:14.479617-06', 0.91891, 0, 69.370, 12598),
	(12830, 1070, 24, '2026-06-08 20:44:14.479617-06', 1.51238, 0, 49.587, 12599),
	(12831, 959, 24, '2026-06-08 20:44:14.479617-06', 2.40697, 3, 80.232, 12600),
	(12832, 823, 24, '2026-06-08 20:44:14.479617-06', 2.06782, 0, 31.073, 12601),
	(12833, 992, 24, '2026-06-08 20:44:14.479617-06', 1.56624, 1, 81.125, 12602),
	(12834, 841, 24, '2026-06-08 20:44:14.479617-06', 1.04105, 0, 65.298, 12603),
	(12835, 1084, 24, '2026-06-08 20:44:14.479617-06', 1.29497, 1, 90.168, 12604),
	(12836, 1113, 24, '2026-06-08 20:44:14.479617-06', 1.35708, 0, 54.764, 12605),
	(12837, 1010, 24, '2026-06-08 20:44:14.479617-06', 1.19734, 1, 93.422, 12606),
	(12838, 1120, 24, '2026-06-08 20:44:14.479617-06', 2.09653, 0, 30.116, 12607),
	(12839, 1073, 24, '2026-06-08 20:44:14.479617-06', 1.53584, 0, 48.805, 12608),
	(12840, 1033, 24, '2026-06-08 20:44:14.479617-06', 1.88942, 1, 70.353, 12610),
	(12841, 1016, 24, '2026-06-08 20:44:14.479617-06', 2.25169, 1, 58.277, 12609),
	(12842, 893, 24, '2026-06-08 20:44:14.479617-06', 1.30696, 1, 89.768, 12611),
	(12843, 1019, 24, '2026-06-08 20:44:14.479617-06', 2.04443, 2, 98.519, 12612),
	(12844, 942, 24, '2026-06-08 20:44:14.479617-06', 1.84310, 1, 71.897, 12613),
	(12845, 1041, 24, '2026-06-08 20:44:14.479617-06', 1.88134, 2, 96.045, 12614),
	(12846, 921, 24, '2026-06-08 20:44:14.479617-06', 2.16577, 1, 61.141, 12615),
	(12847, 1143, 24, '2026-06-08 20:44:14.479617-06', 1.10633, 0, 63.122, 12616),
	(12848, 1217, 24, '2026-06-08 20:44:14.479617-06', 1.21753, 0, 59.416, 12617),
	(12849, 1081, 24, '2026-06-08 20:44:14.479617-06', 1.91022, 0, 36.326, 12618),
	(12850, 1082, 24, '2026-06-08 20:44:14.479617-06', 1.91481, 2, 97.160, 12619),
	(12851, 837, 24, '2026-06-08 20:44:14.479617-06', 0.79905, 1, 93.302, 12620),
	(12852, 926, 24, '2026-06-08 20:44:14.479617-06', 2.26925, 2, 91.025, 12621),
	(12853, 1049, 24, '2026-06-08 20:44:14.479617-06', 0.93774, 0, 68.742, 12622),
	(12854, 1050, 24, '2026-06-08 20:44:14.479617-06', 0.95637, 0, 68.121, 12623),
	(12855, 1123, 24, '2026-06-08 20:44:14.479617-06', 1.34899, 0, 55.034, 12624),
	(12856, 933, 24, '2026-06-08 20:44:14.479617-06', 1.69787, 1, 76.738, 12625),
	(12857, 826, 24, '2026-06-08 20:44:14.479617-06', 1.08099, 0, 63.967, 12626),
	(12858, 911, 24, '2026-06-08 20:44:14.479617-06', 2.26478, 3, 75.493, 12627),
	(12859, 1051, 24, '2026-06-08 20:44:14.479617-06', 1.85321, 1, 71.560, 12628),
	(12860, 1052, 24, '2026-06-08 20:44:14.479617-06', 1.08806, 0, 63.731, 12629),
	(12861, 1053, 24, '2026-06-08 20:44:14.479617-06', 0.79202, 0, 73.599, 12630),
	(12862, 1075, 24, '2026-06-08 20:44:14.479617-06', 1.94443, 0, 35.186, 12631),
	(12863, 920, 24, '2026-06-08 20:44:14.479617-06', 1.45424, 2, 81.808, 12632),
	(12864, 960, 24, '2026-06-08 20:44:14.479617-06', 2.11783, 3, 70.594, 12633),
	(12865, 952, 24, '2026-06-08 20:44:14.479617-06', 1.81493, 1, 72.836, 12634),
	(12866, 949, 24, '2026-06-08 20:44:14.479617-06', 1.35606, 2, 78.535, 12635),
	(12867, 904, 24, '2026-06-08 20:44:14.479617-06', 2.37328, 1, 54.224, 12636),
	(12868, 991, 24, '2026-06-08 20:44:14.479617-06', 1.49566, 1, 83.478, 12637),
	(12869, 840, 24, '2026-06-08 20:44:14.479617-06', 1.41270, 0, 52.910, 12638),
	(12870, 825, 24, '2026-06-08 20:44:14.479617-06', 1.55357, 0, 48.214, 12639),
	(12871, 1129, 24, '2026-06-08 20:44:14.479617-06', 2.01883, 0, 32.706, 12640),
	(12872, 1128, 24, '2026-06-08 20:44:14.479617-06', 1.90912, 0, 36.363, 12641),
	(12873, 1114, 24, '2026-06-08 20:44:14.479617-06', 2.30801, 3, 76.934, 12642),
	(12874, 865, 24, '2026-06-08 20:44:14.479617-06', 1.15938, 0, 61.354, 12643),
	(12875, 1086, 24, '2026-06-08 20:44:14.479617-06', 1.99323, 0, 33.559, 12644),
	(12876, 1094, 24, '2026-06-08 20:44:14.479617-06', 1.06004, 0, 64.665, 12645),
	(12877, 1080, 24, '2026-06-08 20:44:14.479617-06', 1.87697, 0, 37.434, 12646),
	(12878, 1089, 24, '2026-06-08 20:44:14.479617-06', 0.84035, 1, 94.678, 12647),
	(12879, 828, 24, '2026-06-08 20:44:14.479617-06', 1.64789, 0, 45.070, 12648),
	(12880, 851, 24, '2026-06-08 20:44:14.479617-06', 1.69637, 0, 43.454, 12671),
	(12881, 1035, 24, '2026-06-08 20:44:14.479617-06', 1.10363, 1, 96.546, 12672),
	(12882, 1078, 24, '2026-06-08 20:44:14.479617-06', 0.91241, 0, 69.586, 12649),
	(12883, 1079, 24, '2026-06-08 20:44:14.479617-06', 1.44651, 1, 85.116, 12650),
	(12884, 1044, 24, '2026-06-08 20:44:14.479617-06', 0.92193, 0, 69.269, 12651),
	(12885, 916, 24, '2026-06-08 20:44:14.479617-06', 0.92259, 1, 97.420, 12652),
	(12886, 967, 24, '2026-06-08 20:44:14.479617-06', 1.54312, 2, 84.771, 12653),
	(12887, 1014, 24, '2026-06-08 20:44:14.479617-06', 2.22965, 2, 92.345, 12654),
	(12888, 818, 24, '2026-06-08 20:44:14.479617-06', 0.98219, 0, 67.260, 12655),
	(12889, 935, 24, '2026-06-08 20:44:14.479617-06', 1.77102, 1, 74.299, 12656),
	(12890, 953, 24, '2026-06-08 20:44:14.479617-06', 1.64037, 2, 88.012, 12657),
	(12891, 1132, 24, '2026-06-08 20:44:14.479617-06', 1.93084, 2, 97.695, 12658),
	(12892, 1210, 24, '2026-06-08 20:44:14.479617-06', 1.35424, 2, 78.475, 12659),
	(12893, 928, 24, '2026-06-08 20:44:14.479617-06', 1.52491, 1, 82.503, 12660),
	(12894, 887, 24, '2026-06-08 20:44:14.479617-06', 0.93890, 0, 68.703, 12661),
	(12895, 915, 24, '2026-06-08 20:44:14.479617-06', 2.31885, 1, 56.038, 12662),
	(12896, 1085, 24, '2026-06-08 20:44:14.479617-06', 0.61273, 0, 79.576, 12663),
	(12897, 834, 24, '2026-06-08 20:44:14.479617-06', 0.98043, 0, 67.319, 12664),
	(12898, 1096, 24, '2026-06-08 20:44:14.479617-06', 1.41775, 0, 52.742, 12665),
	(12899, 968, 24, '2026-06-08 20:44:14.479617-06', 1.92741, 2, 97.580, 12666),
	(12900, 969, 24, '2026-06-08 20:44:14.479617-06', 2.11352, 1, 62.883, 12667),
	(12901, 855, 24, '2026-06-08 20:44:14.479617-06', 1.35269, 0, 54.910, 12668),
	(12902, 1030, 24, '2026-06-08 20:44:14.479617-06', 1.97095, 1, 67.635, 12669),
	(12903, 995, 24, '2026-06-08 20:44:14.479617-06', 1.86445, 0, 37.852, 12670),
	(12904, 824, 24, '2026-06-08 20:44:14.479617-06', 1.00778, 0, 66.407, 12673),
	(12905, 929, 24, '2026-06-08 20:44:14.479617-06', 1.45712, 1, 84.763, 12674),
	(12906, 1090, 24, '2026-06-08 20:44:14.479617-06', 1.26607, 0, 57.798, 12675),
	(12907, 1069, 24, '2026-06-08 20:44:14.479617-06', 1.31984, 0, 56.005, 12676),
	(12908, 847, 24, '2026-06-08 20:44:14.479617-06', 1.24698, 0, 58.434, 12677),
	(12909, 852, 24, '2026-06-08 20:44:14.479617-06', 1.63427, 0, 45.524, 12678),
	(12910, 1178, 24, '2026-06-08 20:44:14.479617-06', 1.58870, 0, 47.043, 12679),
	(12911, 843, 24, '2026-06-08 20:44:14.479617-06', 1.52759, 0, 49.080, 12680),
	(12912, 892, 24, '2026-06-08 20:44:14.479617-06', 1.60129, 2, 86.710, 12681),
	(12913, 859, 24, '2026-06-08 20:44:14.479617-06', 1.71959, 1, 76.014, 12682),
	(12914, 1104, 24, '2026-06-08 20:44:14.479617-06', 0.97301, 1, 99.100, 12683),
	(12915, 881, 24, '2026-06-08 20:44:14.479617-06', 2.07687, 1, 64.104, 12684),
	(12916, 1060, 24, '2026-06-08 20:44:14.479617-06', 0.74281, 0, 75.240, 12685),
	(12917, 1061, 24, '2026-06-08 20:44:14.479617-06', 0.85147, 0, 71.618, 12686),
	(12918, 1103, 24, '2026-06-08 20:44:14.479617-06', 1.75674, 0, 41.442, 12687),
	(12919, 1013, 24, '2026-06-08 20:44:14.479617-06', 1.81119, 2, 93.706, 12688),
	(12920, 910, 24, '2026-06-08 20:44:14.479617-06', 2.18259, 2, 93.914, 12689),
	(12921, 1020, 24, '2026-06-08 20:44:14.479617-06', 2.38344, 1, 53.885, 12690),
	(12922, 1151, 24, '2026-06-08 20:44:14.479617-06', 1.19940, 0, 60.020, 12691),
	(12923, 997, 24, '2026-06-08 20:44:14.479617-06', 1.96327, 2, 98.776, 12692),
	(12924, 1165, 24, '2026-06-08 20:44:14.479617-06', 1.49484, 0, 50.172, 12693),
	(12925, 1161, 24, '2026-06-08 20:44:14.479617-06', 1.36467, 0, 54.511, 12694),
	(12926, 1000, 24, '2026-06-08 20:44:14.479617-06', 1.85314, 1, 71.562, 12719),
	(12927, 1023, 24, '2026-06-08 20:44:14.479617-06', 1.99444, 1, 66.852, 12720),
	(12928, 850, 24, '2026-06-08 20:44:14.479617-06', 1.48633, 0, 50.456, 12721),
	(12929, 948, 24, '2026-06-08 20:44:14.479617-06', 1.81143, 1, 72.952, 12722),
	(12930, 1149, 24, '2026-06-08 20:44:14.479617-06', 1.09340, 1, 96.887, 12695),
	(12931, 1055, 24, '2026-06-08 20:44:14.479617-06', 1.59604, 0, 46.799, 12696),
	(12932, 885, 24, '2026-06-08 20:44:14.479617-06', 0.94531, 0, 68.490, 12697),
	(12933, 872, 24, '2026-06-08 20:44:14.479617-06', 1.03465, 0, 65.512, 12698),
	(12934, 941, 24, '2026-06-08 20:44:14.479617-06', 1.67738, 1, 77.421, 12699),
	(12935, 869, 24, '2026-06-08 20:44:14.479617-06', 0.88831, 0, 70.390, 12700),
	(12936, 897, 24, '2026-06-08 20:44:14.479617-06', 2.21625, 2, 92.792, 12701),
	(12937, 970, 24, '2026-06-08 20:44:14.479617-06', 1.86842, 2, 95.614, 12702),
	(12938, 1091, 24, '2026-06-08 20:44:14.479617-06', 0.91005, 0, 69.665, 12703),
	(12939, 1092, 24, '2026-06-08 20:44:14.479617-06', 1.39357, 0, 53.548, 12704),
	(12940, 1187, 24, '2026-06-08 20:44:14.479617-06', 1.32553, 0, 55.816, 12705),
	(12941, 1107, 24, '2026-06-08 20:44:14.479617-06', 1.00335, 0, 66.555, 12706),
	(12942, 1108, 24, '2026-06-08 20:44:14.479617-06', 0.64249, 0, 78.584, 12707),
	(12943, 1109, 24, '2026-06-08 20:44:14.479617-06', 0.73101, 0, 75.633, 12708),
	(12944, 907, 24, '2026-06-08 20:44:14.479617-06', 2.16550, 2, 94.483, 12709),
	(12945, 900, 24, '2026-06-08 20:44:14.479617-06', 2.25806, 2, 91.398, 12710),
	(12946, 994, 24, '2026-06-08 20:44:14.479617-06', 2.03217, 1, 65.594, 12711),
	(12947, 950, 24, '2026-06-08 20:44:14.479617-06', 2.06171, 1, 64.610, 12712),
	(12948, 889, 24, '2026-06-08 20:44:14.479617-06', 2.07984, 1, 64.005, 12713),
	(12949, 936, 24, '2026-06-08 20:44:14.479617-06', 1.95657, 1, 68.114, 12714),
	(12950, 1025, 24, '2026-06-08 20:44:14.479617-06', 1.71764, 1, 76.079, 12715),
	(12951, 957, 24, '2026-06-08 20:44:14.479617-06', 1.60551, 1, 79.816, 12716),
	(12952, 978, 24, '2026-06-08 20:44:14.479617-06', 1.36867, 1, 87.711, 12717),
	(12953, 986, 24, '2026-06-08 20:44:14.479617-06', 2.27947, 1, 57.351, 12718),
	(12954, 1006, 24, '2026-06-08 20:44:14.479617-06', 2.06410, 1, 64.530, 12723),
	(12955, 980, 24, '2026-06-08 20:44:14.479617-06', 1.70634, 1, 76.455, 12724),
	(12956, 976, 24, '2026-06-08 20:44:14.479617-06', 2.24412, 2, 91.863, 12725),
	(12957, 827, 24, '2026-06-08 20:44:14.479617-06', 2.01009, 0, 32.997, 12726),
	(12958, 973, 24, '2026-06-08 20:44:14.479617-06', 1.23216, 1, 92.261, 12727),
	(12959, 895, 24, '2026-06-08 20:44:14.479617-06', 2.14919, 1, 61.694, 12728),
	(12960, 901, 24, '2026-06-08 20:44:14.479617-06', 2.12568, 2, 95.811, 12729),
	(12961, 946, 24, '2026-06-08 20:44:14.479617-06', 1.78949, 1, 73.684, 12730),
	(12962, 1106, 24, '2026-06-08 20:44:14.479617-06', 1.48977, 0, 50.341, 12731),
	(12963, 985, 24, '2026-06-08 20:44:14.479617-06', 1.06076, 1, 97.975, 12732),
	(12964, 842, 24, '2026-06-08 20:44:14.479617-06', 1.96065, 0, 34.645, 12733),
	(12965, 817, 24, '2026-06-08 20:44:14.479617-06', 1.03353, 0, 65.549, 12734),
	(12966, 1112, 24, '2026-06-08 20:44:14.479617-06', 1.03320, 0, 65.560, 12735),
	(12967, 1160, 24, '2026-06-08 20:44:14.479617-06', 0.84573, 0, 71.809, 12736),
	(12968, 830, 24, '2026-06-08 20:44:14.479617-06', 1.39084, 0, 53.639, 12737),
	(12969, 831, 24, '2026-06-08 20:44:14.479617-06', 2.05603, 0, 31.466, 12738),
	(12970, 873, 24, '2026-06-08 20:44:14.479617-06', 1.47043, 0, 50.986, 12739),
	(12971, 1048, 24, '2026-06-08 20:44:14.479617-06', 0.89444, 0, 70.185, 12740),
	(12972, 931, 24, '2026-06-08 20:44:14.479617-06', 1.83119, 1, 72.294, 12741),
	(12973, 1209, 24, '2026-06-08 20:44:14.479617-06', 2.13039, 0, 28.987, 12742),
	(12974, 888, 24, '2026-06-08 20:44:14.479617-06', 0.93890, 0, 68.703, 12743),
	(12975, 917, 24, '2026-06-08 20:44:14.479617-06', 1.24717, 1, 91.761, 12744),
	(12976, 1028, 24, '2026-06-08 20:44:14.479617-06', 2.16143, 1, 61.286, 12745),
	(12977, 1005, 24, '2026-06-08 20:44:14.479617-06', 2.07449, 3, 69.150, 12746),
	(12978, 862, 24, '2026-06-08 20:44:14.479617-06', 1.21878, 0, 59.374, 12747),
	(12979, 927, 24, '2026-06-08 20:44:14.479617-06', 2.27958, 2, 90.681, 12748),
	(12980, 1027, 24, '2026-06-08 20:44:14.479617-06', 1.77074, 1, 74.309, 12749),
	(12981, 962, 24, '2026-06-08 20:44:14.479617-06', 1.49153, 1, 83.616, 12750),
	(12982, 958, 24, '2026-06-08 20:44:14.479617-06', 0.96737, 1, 98.912, 12751),
	(12983, 876, 24, '2026-06-08 20:44:14.479617-06', 1.92340, 0, 35.887, 12752),
	(12984, 1131, 24, '2026-06-08 20:44:14.479617-06', 1.24400, 0, 58.533, 12753),
	(12985, 1162, 24, '2026-06-08 20:44:14.479617-06', 1.52354, 0, 49.215, 12754),
	(12986, 1164, 24, '2026-06-08 20:44:14.479617-06', 1.41786, 0, 52.738, 12755),
	(12987, 1037, 24, '2026-06-08 20:44:14.479617-06', 1.43373, 1, 85.542, 12756),
	(12988, 1136, 24, '2026-06-08 20:44:14.479617-06', 1.91636, 0, 36.121, 12757),
	(12989, 990, 24, '2026-06-08 20:44:14.479617-06', 2.00896, 3, 66.965, 12758),
	(12990, 1116, 24, '2026-06-08 20:44:14.479617-06', 1.54287, 0, 48.571, 12759),
	(12991, 1135, 24, '2026-06-08 20:44:14.479617-06', 1.31535, 0, 56.155, 12760),
	(12992, 1137, 24, '2026-06-08 20:44:14.479617-06', 2.11540, 0, 29.487, 12761),
	(12993, 1095, 24, '2026-06-08 20:44:14.479617-06', 1.31959, 0, 56.014, 12762),
	(12994, 1058, 24, '2026-06-08 20:44:14.479617-06', 0.98765, 0, 67.078, 12763),
	(12995, 1083, 24, '2026-06-08 20:44:14.479617-06', 1.19511, 0, 60.163, 12764),
	(12996, 1087, 24, '2026-06-08 20:44:14.479617-06', 0.94000, 0, 68.667, 12765),
	(12997, 829, 24, '2026-06-08 20:44:14.479617-06', 1.87201, 0, 37.600, 12766),
	(12998, 1008, 24, '2026-06-08 20:44:14.479617-06', 2.03918, 1, 65.361, 12767),
	(12999, 860, 24, '2026-06-08 20:44:14.479617-06', 1.36762, 0, 54.413, 12768),
	(13000, 919, 24, '2026-06-08 20:44:14.479617-06', 0.86613, 0, 71.129, 12769),
	(13001, 816, 24, '2026-06-08 20:44:14.479617-06', 1.02931, 0, 65.690, 12770),
	(13002, 1024, 24, '2026-06-08 20:44:14.479617-06', 2.25406, 1, 58.198, 12771),
	(13003, 956, 24, '2026-06-08 20:44:14.479617-06', 2.19216, 1, 60.261, 12772),
	(13004, 922, 24, '2026-06-08 20:44:14.479617-06', 1.74074, 1, 75.309, 12773),
	(13005, 923, 24, '2026-06-08 20:44:14.479617-06', 1.34674, 1, 88.442, 12774),
	(13006, 1003, 24, '2026-06-08 20:44:14.479617-06', 2.23802, 3, 74.601, 12778),
	(13007, 891, 24, '2026-06-08 20:44:14.479617-06', 1.20073, 2, 73.358, 12779),
	(13008, 977, 24, '2026-06-08 20:44:14.479617-06', 1.04227, 1, 98.591, 12780),
	(13009, 1216, 24, '2026-06-08 20:44:14.479617-06', 0.99931, 0, 66.690, 12781),
	(13010, 1034, 24, '2026-06-08 20:44:14.479617-06', 2.34286, 1, 55.238, 12782),
	(13011, 1021, 24, '2026-06-08 20:44:14.479617-06', 2.33310, 1, 55.563, 12783),
	(13012, 905, 24, '2026-06-08 20:44:14.479617-06', 0.92820, 1, 97.607, 12784),
	(13013, 1018, 24, '2026-06-08 20:44:14.479617-06', 1.69295, 0, 43.568, 12785),
	(13014, 1036, 24, '2026-06-08 20:44:14.479617-06', 1.00403, 0, 66.532, 12786),
	(13015, 884, 24, '2026-06-08 20:44:14.479617-06', 1.44526, 0, 51.825, 12787),
	(13016, 1223, 24, '2026-06-08 20:44:14.479617-06', 2.31584, 2, 89.472, 12788),
	(13017, 871, 24, '2026-06-08 20:44:14.479617-06', 0.89075, 0, 70.308, 12789),
	(13018, 914, 24, '2026-06-08 20:44:14.479617-06', 2.24249, 1, 58.584, 12775),
	(13019, 1043, 24, '2026-06-08 20:44:14.479617-06', 1.76151, 1, 74.616, 12776),
	(13020, 866, 24, '2026-06-08 20:44:14.479617-06', 1.39460, 0, 53.513, 12777),
	(13021, 971, 24, '2026-06-08 20:44:14.479617-06', 1.71742, 1, 76.086, 12796),
	(13022, 1001, 24, '2026-06-08 20:44:14.479617-06', 2.36556, 1, 54.481, 12797),
	(13023, 1002, 24, '2026-06-08 20:44:14.479617-06', 1.91656, 1, 69.448, 12798),
	(13024, 983, 24, '2026-06-08 20:44:14.479617-06', 2.24513, 1, 58.496, 12799),
	(13025, 894, 24, '2026-06-08 20:44:14.479617-06', 1.12672, 3, 37.557, 12800),
	(13026, 981, 24, '2026-06-08 20:44:14.479617-06', 1.46932, 1, 84.356, 12790),
	(13027, 1012, 24, '2026-06-08 20:44:14.479617-06', 1.55239, 1, 81.587, 12791),
	(13028, 1022, 24, '2026-06-08 20:44:14.479617-06', 1.66201, 1, 77.933, 12792),
	(13029, 982, 24, '2026-06-08 20:44:14.479617-06', 1.31772, 1, 89.409, 12793),
	(13030, 836, 24, '2026-06-08 20:44:14.479617-06', 0.70448, 0, 76.517, 12794),
	(13031, 993, 24, '2026-06-08 20:44:14.479617-06', 2.33710, 1, 55.430, 12795),
	(13032, 1040, 24, '2026-06-08 20:44:14.479617-06', 2.34678, 1, 55.107, 12801),
	(13033, 815, 24, '2026-06-08 20:44:14.479617-06', 0.98961, 0, 67.013, 12802),
	(13034, 1042, 24, '2026-06-08 20:44:14.479617-06', 1.76603, 1, 74.466, 12803),
	(13035, 1039, 24, '2026-06-08 20:44:14.479617-06', 2.21752, 1, 59.416, 12804),
	(13036, 974, 24, '2026-06-08 20:44:14.479617-06', 1.84546, 1, 71.818, 12805),
	(13037, 906, 24, '2026-06-08 20:44:14.479617-06', 1.10850, 2, 70.283, 12806),
	(13038, 1011, 24, '2026-06-08 20:44:14.479617-06', 1.82704, 1, 72.432, 12807),
	(13039, 913, 24, '2026-06-08 20:44:14.479617-06', 2.21027, 2, 92.991, 12808),
	(13040, 943, 24, '2026-06-08 20:44:14.479617-06', 1.92482, 1, 69.173, 12809),
	(13041, 902, 24, '2026-06-08 20:44:14.479617-06', 2.14838, 1, 61.721, 12817),
	(13042, 898, 24, '2026-06-08 20:44:14.479617-06', 2.13128, 2, 95.624, 12818),
	(13043, 998, 24, '2026-06-08 20:44:14.479617-06', 2.37305, 1, 54.232, 12819),
	(13044, 975, 24, '2026-06-08 20:44:14.479617-06', 1.01987, 3, 33.996, 12820),
	(13045, 944, 24, '2026-06-08 20:44:14.479617-06', 1.42584, 1, 85.805, 12821),
	(13046, 1190, 24, '2026-06-08 20:44:14.479617-06', 1.28129, 0, 57.290, 12822),
	(13047, 1227, 24, '2026-06-08 20:44:14.479617-06', 1.06681, 0, 64.440, 12823),
	(13048, 1224, 24, '2026-06-08 20:44:14.479617-06', 1.78373, 0, 40.542, 12824),
	(13049, 1015, 24, '2026-06-08 20:44:14.479617-06', 1.75843, 1, 74.719, 12825),
	(13050, 880, 24, '2026-06-08 20:44:14.479617-06', 1.21595, 1, 92.802, 12826),
	(13051, 938, 24, '2026-06-08 20:44:14.479617-06', 2.24183, 2, 91.939, 12827),
	(13052, 918, 24, '2026-06-08 20:44:14.479617-06', 1.87185, 1, 70.938, 12828),
	(13053, 1029, 24, '2026-06-08 20:44:14.479617-06', 1.83361, 1, 72.213, 12829),
	(13054, 912, 24, '2026-06-08 20:44:14.479617-06', 2.28309, 2, 90.564, 12830),
	(13055, 937, 24, '2026-06-08 20:44:14.479617-06', 1.01904, 3, 33.968, 12831),
	(13056, 882, 24, '2026-06-08 20:44:14.479617-06', 1.42761, 0, 52.413, 12810),
	(13057, 867, 24, '2026-06-08 20:44:14.479617-06', 0.87030, 0, 70.990, 12811),
	(13058, 886, 24, '2026-06-08 20:44:14.479617-06', 1.11462, 0, 62.846, 12812),
	(13059, 961, 24, '2026-06-08 20:44:14.479617-06', 1.82972, 3, 60.991, 12813),
	(13060, 1127, 24, '2026-06-08 20:44:14.479617-06', 1.81587, 0, 39.471, 12814),
	(13061, 1139, 24, '2026-06-08 20:44:14.479617-06', 1.16632, 0, 61.123, 12815),
	(13062, 1009, 24, '2026-06-08 20:44:14.479617-06', 2.10696, 1, 63.101, 12816);


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
	(24, B'1', 365, 28, '2026-06-08 20:43:47.751415-06', 'model_global', 1.127733, 0.5021, 2, B'1', 0.00100000, 32, 4, 304, '{"type":"sequential","layers":[{"type":"dense","units":64,"activation":"relu","init":"heNormal"},{"type":"dropout","rate":0.3},{"type":"dense","units":32,"activation":"relu","init":"heNormal"},{"type":"dropout","rate":0.3},{"type":"dense","units":4,"activation":"softmax","note":"clasificación 4 clases"}]}');


--
-- Name: canciones_evaluadas_ce_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.canciones_evaluadas_ce_id_seq', 1230, true);


--
-- Name: entrenamientos_en_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.entrenamientos_en_id_seq', 12831, true);


--
-- Name: playlists_pl_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.playlists_pl_id_seq', 2, true);


--
-- Name: predicciones_pd_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.predicciones_pd_id_seq', 13062, true);


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

SELECT pg_catalog.setval('public.ts_modelos_ts_id_seq', 24, true);


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
-- PostgreSQL database dump complete
--

