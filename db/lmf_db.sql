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
	(1150, 0, 8218889, 'Taisetsunakoto (feat. Hatsune Miku, Kagamine Rin, Kagamine Len, Megurine Luka, KAITO, MEIKO &... (128kbit_AAC).mp3', 1, B'1', NULL, 0.37842, 1, 'features_1150.npy', NULL),
	(857, 0, 5568544, '【初音ミク】Calla Soiled - 虚構の光【オリジナル曲】 [FiukeDh9WKo].mp3', 1, B'1', NULL, 1.55926, 1, 'features_857.npy', NULL),
	(832, 0, 2959411, '【2013-05-01 _ Carlos Hakamada(debut)】 タイムトラベラー！(Time traveller_)- MIKU(original)_カルロス袴田(music) [udobYRGEeNg].mp3', 1, B'1', NULL, 0.07501, 1, 'features_832.npy', NULL),
	(947, 1, 6458068, 'livetune   never ende.mp3', 1, B'1', NULL, 0.88860, 1, 'features_947.npy', NULL),
	(848, 0, 4205575, '【初音ミク - Hatsune Miku】心の片隅に - Kokoro no Katasumi ni【subs】 [p6cQU2bQitU].mp3', 1, B'1', NULL, 0.23991, 1, 'features_848.npy', NULL),
	(858, 0, 3899541, '【初音ミク】Oriental Cybernetic QT Girl【SUB ENG_ITA】 [mCPH4OGATq8].mp3', 1, B'1', NULL, 0.72461, 1, 'features_858.npy', NULL),
	(1098, 0, 4091869, '初音ミクキマシメ少女のアカルイ未来計画オリジナルMV付き.mp3', 1, B'1', NULL, 0.16670, 1, 'features_1098.npy', NULL),
	(984, 1, 5286947, '【Kagamine Rin V4X】 Hop! Step! Instant Death! A Happiness Dance Death Trap 【VOCALOID Cover�.mp3', 1, B'1', NULL, 0.29987, 1, 'features_984.npy', NULL),
	(1041, 2, 4048736, '空海月 - -STL001- MIKUHOP LP - 08 チョコレートサンデー [nt8RupYeHlc].mp3', 1, B'1', NULL, 1.87485, 1, 'features_1041.npy', NULL),
	(991, 1, 3551772, '【初音ミクSweet】街路灯を横切って English and romaji subs [CKqpXsny5W0].mp3', 1, B'1', NULL, 0.44298, 1, 'features_991.npy', NULL),
	(874, 0, 4771135, 'ピノキオピー - ゲームスペクター2 feat. 初音ミク _ Game Specter 2 [OfXUHMYccu4].mp3', 1, B'1', NULL, 0.93723, 1, 'features_874.npy', NULL),
	(988, 3, 5142658, '【公式】アイシテ  とあ feat 初音ミク　  LOVE ME  toa feat Hatsune Miku.mp3', 1, B'1', NULL, 2.91918, 1, 'features_988.npy', NULL),
	(840, 0, 6059129, '【SKEW】カノジョの選択肢と独りぼっちの北の空【PSGOZ】 [Ei22xcvPXy8].mp3', 1, B'1', NULL, 1.65997, 1, 'features_840.npy', NULL),
	(997, 2, 3340929, '【初音ミク】 だんだん早くなる Getting Faster and Faster【オリジナル�.mp3', 1, B'1', NULL, 1.53621, 1, 'features_997.npy', NULL),
	(1026, 2, 4160129, '初音ミク Project Diva f 2nd  nanou  Hatsune Miku  Glory 3usi9  Best of nanou (high volume).mp3', 1, B'1', NULL, 1.59338, 1, 'features_1026.npy', NULL),
	(1032, 2, 5216312, '初音ミクリンレンルカ夢の続きオリジナル中文字幕.mp3', 1, B'1', NULL, 1.27594, 1, 'features_1032.npy', NULL),
	(1078, 0, 3481810, 'ピノキオピー - ストレンジアニマル feat. 初音ミク鏡音リン  Strange Animal.mp3', 1, B'1', NULL, 0.21714, 1, 'features_1078.npy', NULL),
	(1107, 0, 2860890, '四ツ谷さんによろしく.mp3', 1, B'1', NULL, 0.30097, 1, 'features_1107.npy', NULL),
	(1108, 0, 2518572, '天音サクラAlien初音ミク.mp3', 1, B'1', NULL, 0.02398, 1, 'features_1108.npy', NULL),
	(895, 1, 8460849, '03 ワールズエンド・ダンスホール.mp3', 1, B'1', NULL, 1.15979, 1, 'features_895.npy', NULL),
	(901, 2, 8783761, '09 ☆Fighting Pose☆.mp3', 1, B'1', NULL, 1.66023, 1, 'features_901.npy', NULL),
	(889, 1, 3250232, '- Ranaエレクトロサチュレイタ ElectrosaturatorVSQx.mp3', 1, B'1', NULL, 1.40802, 1, 'features_889.npy', NULL),
	(838, 0, 2871204, '【MV】現代ササクレ概論／なすP feat. 初音ミク (Modern Hangnail Outline／Nasu feat. Miku Hatsune) [OEXZ5Ml4vKk].mp3', 1, B'1', NULL, 0.52451, 1, 'features_838.npy', NULL),
	(864, 0, 3072887, '【初音ミク】ムラサキ【オリジナル曲PV付】 [omYEruBpSM8].mp3', 1, B'1', NULL, 0.71559, 1, 'features_864.npy', NULL),
	(839, 0, 2495759, '【MV】絶望の砂漠／なすP feat. 初音ミク (Desert of Despair／Nasu feat. Miku Hatsune) [rDL6huvbJM0].mp3', 1, B'1', NULL, 0.32416, 1, 'features_839.npy', NULL),
	(1122, 0, 3219681, '【公式】 テレストテレス／かいりきベア feat.初音ミク (128kbit_AAC).mp3', 1, B'1', NULL, 0.53943, 1, 'features_1122.npy', NULL),
	(1093, 0, 4588623, '初音ミクTearsオリジナルMV (1).mp3', 1, B'1', NULL, 0.32556, 1, 'features_1093.npy', NULL),
	(872, 0, 4753744, 'キャラメルティアドロップ_初音ミク [d4qecYvfWgw].mp3', 1, B'1', NULL, 0.38336, 1, 'features_872.npy', NULL),
	(941, 1, 4503295, 'Hatsune Miku Two Faced Lovers.mp3', 1, B'1', NULL, 0.99650, 1, 'features_941.npy', NULL),
	(869, 0, 4647758, '【初音ミク・VY1V3】PROGRAM BREAKER【オリジナルPV】 [NIDa7HqGqc4].mp3', 1, B'1', NULL, 0.23820, 1, 'features_869.npy', NULL),
	(897, 2, 9410964, '04 彼方まで虹を架けて.mp3', 1, B'1', NULL, 1.85975, 1, 'features_897.npy', NULL),
	(970, 2, 6314499, 'White Dove with English  Romaji Sub  Hatsune Miku  ハト  sm2583719  HQ.mp3', 1, B'1', NULL, 1.71103, 1, 'features_970.npy', NULL),
	(1091, 0, 7071877, '初音ミクidiolectオリシナル.mp3', 1, B'1', NULL, 0.25092, 1, 'features_1091.npy', NULL),
	(1092, 0, 4024965, '初音ミクLast Time to Sayオリジナル.mp3', 1, B'1', NULL, 0.36774, 1, 'features_1092.npy', NULL),
	(1187, 0, 5175796, 'クレイジー・ビート (128kbit_AAC).mp3', 1, B'1', NULL, 0.32343, 1, 'features_1187.npy', NULL),
	(1106, 0, 3442266, '君が君がfeat. 初音ミク.mp3', 1, B'1', NULL, 0.48382, 1, 'features_1106.npy', NULL),
	(985, 1, 5549634, '【Robo feat 初音ミク】 SKY HIGHWAY【オリジナル曲�.mp3', 1, B'1', NULL, 0.54023, 1, 'features_985.npy', NULL),
	(842, 0, 4147173, '【_years_ 5_12】May【初音ミクDarkオリジナルPV】 [wxXQJBMeW94].mp3', 1, B'1', NULL, 0.94627, 1, 'features_842.npy', NULL),
	(817, 0, 3024424, 'ATOLS - LAST SIGNAL feat. Hatsune Miku _ ラストシグナル feat. 初音ミク [d2M3z797sQ8].mp3', 1, B'1', NULL, 0.59359, 1, 'features_817.npy', NULL),
	(1112, 0, 3831653, '潔癖K毒滅グリモア.mp3', 1, B'1', NULL, 0.51894, 1, 'features_1112.npy', NULL),
	(1160, 0, 3507879, '【初音ミク】骨【エロルヤ光線P】2018⁄10⁄31 (128kbit_AAC).mp3', 1, B'1', NULL, 0.06235, 1, 'features_1160.npy', NULL),
	(830, 0, 1945642, '┗_∵_┓第三次プリン戦争　／　HoneyWorks feat.初音ミク、GUMI [A_zZ4SY0kp0].mp3', 1, B'1', NULL, 0.28927, 1, 'features_830.npy', NULL),
	(831, 0, 4103244, '「キズ」 - KEI feat.初音ミク [D9UFIFujRyo].mp3', 1, B'1', NULL, 1.00436, 1, 'features_831.npy', NULL),
	(873, 0, 5009650, 'サテライト [h3bNut-SVpg].mp3', 1, B'1', NULL, 0.96979, 1, 'features_873.npy', NULL),
	(1048, 0, 3935156, 'Brownie (feat. 初音ミク).mp3', 1, B'1', NULL, 0.14318, 1, 'features_1048.npy', NULL),
	(931, 1, 4121259, 'east end and bocci  feat初音ミク.mp3', 1, B'1', NULL, 1.09127, 1, 'features_931.npy', NULL),
	(1209, 0, 4978460, 'メアメア (128kbit_AAC).mp3', 1, B'1', NULL, 1.38747, 1, 'features_1209.npy', NULL),
	(888, 0, 3885563, '霞む森 _ 初音ミク＆GUMI [5UIfTqACqJ8].mp3', 1, B'1', NULL, 0.31204, 1, 'features_888.npy', NULL),
	(917, 1, 6067327, 'AOHARU.mp3', 1, B'1', NULL, 0.49127, 1, 'features_917.npy', NULL),
	(1028, 1, 3597881, '初音ミク　オリジナル曲　『アンダワ』.mp3', 1, B'1', NULL, 1.64963, 1, 'features_1028.npy', NULL),
	(1005, 3, 5042348, '【初音ミク】アクリルスター【オリジナル】.mp3', 1, B'1', NULL, 2.91791, 1, 'features_1005.npy', NULL),
	(862, 0, 5609899, '【初音ミク】わたしと君とを繋ぐもの【オリジナル】 [IKOookjqXhU].mp3', 1, B'1', NULL, 0.21156, 1, 'features_862.npy', NULL),
	(927, 2, 6410421, 'Deco27 ft 初音ミク.mp3', 1, B'1', NULL, 1.66785, 1, 'features_927.npy', NULL),
	(1027, 1, 4944011, '初音ミク ラストペインター オリジナルMIKULast painteroriginal.mp3', 1, B'1', NULL, 1.30702, 1, 'features_1027.npy', NULL),
	(962, 1, 7012282, 'Robo feat. Hatsune Miku SPACERUN オリジナル曲.mp3', 1, B'1', NULL, 1.03898, 1, 'features_962.npy', NULL),
	(958, 1, 2856514, 'Onesided Love Samba  Hatsune Miku Traduccion.mp3', 1, B'1', NULL, 0.64839, 1, 'features_958.npy', NULL),
	(876, 0, 3853027, '初音ミクオリジナル曲 「PYX」中日字幕 [36UirlGT-iY].mp3', 1, B'1', NULL, 0.65171, 1, 'features_876.npy', NULL),
	(1131, 0, 4817976, 'bin - 音街ウナ (128kbit_AAC).mp3', 1, B'1', NULL, 0.33403, 1, 'features_1131.npy', NULL),
	(1074, 0, 5643594, 'とあ - HALO - ft.初音ミク ( Toa - HALO -  ft.Hatsune Miku ).mp3', 1, B'1', NULL, 0.85076, 1, 'features_1074.npy', NULL),
	(1071, 1, 3869657, '[附中譯]初音ミクハートフルメッセージオリジナル曲PV.mp3', 1, B'1', NULL, 0.89153, 1, 'features_1071.npy', NULL),
	(966, 1, 6155257, 'SushiP ft 初音ミク ''Align'' アライン (English Subtitles).mp3', 1, B'1', NULL, 1.37386, 1, 'features_966.npy', NULL),
	(856, 0, 4083751, '【初音ミク】 心音 【オリジナル曲】 [EztEXXCheSk].mp3', 1, B'1', NULL, 0.87395, 1, 'features_856.npy', NULL),
	(1101, 0, 2117076, '初音ミク人間失格オリジナル曲.mp3', 1, B'1', NULL, 0.54460, 1, 'features_1101.npy', NULL),
	(870, 0, 4765562, '【初音ミク（ぐにょ）】福寿草【作曲してみた】 [15HNvDg0Gq4].mp3', 1, B'1', NULL, 1.28472, 1, 'features_870.npy', NULL),
	(846, 0, 5812731, '【初音ミク - Hatsune Miku】your anniversary【PV subs】 [rUd8zvq63Ro].mp3', 1, B'1', NULL, 0.57707, 1, 'features_846.npy', NULL),
	(854, 0, 3566009, '【初音ミク】 名無しの詩 【オリジナル曲】 [2ZayXb8YfyY].mp3', 1, B'1', NULL, 0.55252, 1, 'features_854.npy', NULL),
	(924, 2, 5743358, 'DECO27   ハートアラモード feat 初音ミ�.mp3', 1, B'1', NULL, 1.78177, 1, 'features_924.npy', NULL),
	(1100, 0, 4370093, '初音ミクホシゾラレインオリジナルMV付き.mp3', 1, B'1', NULL, 0.69684, 1, 'features_1100.npy', NULL),
	(1105, 0, 2331126, '初音ロックンロールアイラヴド [Mu-fullauto].mp3', 1, B'1', NULL, 0.23858, 1, 'features_1105.npy', NULL),
	(1175, 0, 7347601, 'ゆらゆら／音街ウナ (128kbit_AAC).mp3', 1, B'1', NULL, 1.13611, 1, 'features_1175.npy', NULL),
	(1166, 1, 5916732, 'どぅーまいべすと！ (feat. 音街ウナ) (128kbit_AAC).mp3', 1, B'1', NULL, 1.23733, 1, 'features_1166.npy', NULL),
	(1017, 2, 5887554, 'みきとP Hoi MV.mp3', 1, B'1', NULL, 1.24007, 1, 'features_1017.npy', NULL),
	(835, 2, 4006520, '【Hatsune Miku】Lost My Love【Original Song】 [Hg0xobCxaI8].mp3', 1, B'1', NULL, 1.46126, 1, 'features_835.npy', NULL),
	(929, 1, 5673768, 'Dream Chase.mp3', 1, B'1', NULL, 0.76881, 1, 'features_929.npy', NULL),
	(1065, 0, 4244644, 'VOCALOIDflower of sorrow初音ミク (1).mp3', 1, B'1', NULL, 0.52004, 1, 'features_1065.npy', NULL),
	(1031, 1, 5332086, '初音ミクメイウェンティーオリジナルPV.mp3', 1, B'1', NULL, 0.60666, 1, 'features_1031.npy', NULL),
	(833, 0, 4179634, '【Hatsune Miku】 【L】ucy【Eve】【Original MV】 [49c4aO99Etg].mp3', 1, B'1', NULL, 0.42125, 1, 'features_833.npy', NULL),
	(1004, 1, 5194160, '【初音ミク】　表面張力　【オリジナル�.mp3', 1, B'1', NULL, 1.04509, 1, 'features_1004.npy', NULL),
	(1077, 0, 3845987, 'ニカソヒテキ 初音ミク.mp3', 1, B'1', NULL, 2.13529, 1, 'features_1077.npy', NULL),
	(814, 0, 3658842, '(Reprint) 初音ミク『アンダー・プリテンダー』オリジナル [A2zTCOY-uPI].mp3', 1, B'1', NULL, 1.55782, 1, 'features_814.npy', NULL),
	(1191, 0, 5286623, 'スチールワンダー (128kbit_AAC).mp3', 1, B'1', NULL, 0.51126, 1, 'features_1191.npy', NULL),
	(1199, 0, 5174992, 'ディザーチューン ／ DIVELA feat.初音ミク (128kbit_AAC).mp3', 1, B'1', NULL, 1.34503, 1, 'features_1199.npy', NULL),
	(979, 3, 5737281, '[VnSharing] Umi Yuri Kaiteitan   Hatsune Miku   Vocaloid vietsub.mp3', 1, B'1', NULL, 2.90474, 1, 'features_979.npy', NULL),
	(946, 1, 4629288, 'Landscape  初音ミク   歩く人×春�.mp3', 1, B'1', NULL, 0.93289, 1, 'features_946.npy', NULL),
	(908, 3, 5303487, '16 スイートマジック.mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(877, 0, 3956089, '唸る刃と群青正義 [aSp3DvQS7BI].mp3', 1, B'1', NULL, 0.53130, 1, 'features_877.npy', NULL),
	(1063, 0, 4290415, 'Vivid Wave feat. Hatsune Miku.mp3', 1, B'1', NULL, 0.38680, 1, 'features_1063.npy', NULL),
	(1064, 0, 2707053, 'VOCALOIDBox of MadenMETALDUBSTEP.mp3', 1, B'1', NULL, 0.03301, 1, 'features_1064.npy', NULL),
	(903, 3, 9631379, '09 ツユメロ.mp3', 1, B'1', NULL, 2.88692, 1, 'features_903.npy', NULL),
	(875, 0, 4298997, 'ミルキーオンザクレープ [hdoG6pvGxA0].mp3', 1, B'1', NULL, 0.91977, 1, 'features_875.npy', NULL),
	(879, 0, 7472180, '微熱の微笑み、微少女は微かに微睡ーム [FYTsVgSO-ms].mp3', 1, B'1', NULL, 0.68266, 1, 'features_879.npy', NULL),
	(932, 2, 4239123, 'Equation.mp3', 1, B'1', NULL, 1.86930, 1, 'features_932.npy', NULL),
	(1146, 1, 3877755, 'MASA WORKS DESIGN ft.初音ミク&GUMI - BRASS NOISE FLAMENCO (128kbit_AAC).mp3', 1, B'1', NULL, 1.07000, 1, 'features_1146.npy', NULL),
	(930, 1, 6799123, 'DreamerTeary Planet feat. 初音ミク.mp3', 1, B'1', NULL, 1.74310, 1, 'features_930.npy', NULL),
	(1158, 0, 5191600, '【初音ミク⁄鏡音レン】クレイジー・ビート【#コンパス】 (128kbit_AAC).mp3', 1, B'1', NULL, 0.14600, 1, 'features_1158.npy', NULL),
	(1197, 0, 6594463, 'ティアードクライシス … GUMI｜Tieredcrisis (128kbit_AAC).mp3', 1, B'1', NULL, 1.24703, 1, 'features_1197.npy', NULL),
	(1214, 0, 4473102, '八王子P 「バイオレンストリガー feat. 初音ミク」(#コンパス メグメグテーマソング） (128kbit_AAC).mp3', 1, B'1', NULL, 0.49610, 1, 'features_1214.npy', NULL),
	(1099, 0, 5089065, '初音ミクキミとボクまわるセカイオリジナル曲PV.mp3', 1, B'1', NULL, 0.37007, 1, 'features_1099.npy', NULL),
	(996, 1, 3347864, '【初音ミク】 Lap Tap Love 【オリジナル】_[Hatsune Miku] Lap Tap Love [Original] [yhBQfbvHmdw].mp3', 1, B'1', NULL, 1.63201, 1, 'features_996.npy', NULL),
	(822, 0, 4173522, 'Kikuo feat. Hatsune Miku - Shimizu Curry Song [English Subbed] [Q2P76nOpeDs].mp3', 1, B'1', NULL, 0.38119, 1, 'features_822.npy', NULL),
	(1118, 0, 3465855, '【Inaba Cumori ft. Kaai Yuki】Floating Moonlight City (浮遊月光街) - English Subtitles (128kbit_AAC).mp3', 1, B'1', NULL, 1.14387, 1, 'features_1118.npy', NULL),
	(1121, 2, 3411934, '【Police Piccadilly ft. Hatsune Miku】Separate «English sub» [TheBlackCero Hazuki No Yume] (128kbit_AAC).mp3', 1, B'1', NULL, 0.70386, 1, 'features_1121.npy', NULL),
	(1141, 0, 5056245, 'Don''t Return to Being a Drowned Corpse ⁄ Iyowa feat. V Flower & Hatsune Miku (English Subs) (128kbit_AAC).mp3', 1, B'1', NULL, 0.91468, 1, 'features_1141.npy', NULL),
	(1156, 0, 5527225, '∴煮ル果実「アイアルの勘違い」with Flower【Official】- A Mistaken Belief of Love (128kbit_AAC).mp3', 1, B'1', NULL, 0.25608, 1, 'features_1156.npy', NULL),
	(1115, 0, 2625772, '(FLASHING LIGHTS) Mercy Killing - iyowa ft. Hatsune Miku, flower (English Subtitles Remastered ;D) (128kbit_AAC).mp3', 1, B'1', NULL, 0.89367, 1, 'features_1115.npy', NULL),
	(972, 1, 4904932, 'yt1s.com - Far Away.mp3', 1, B'1', NULL, 1.57482, 1, 'features_972.npy', NULL),
	(821, 0, 5228556, 'float (feat. 初音ミク) [gKWxuB14zOQ].mp3', 1, B'1', NULL, 1.03863, 1, 'features_821.npy', NULL),
	(896, 1, 6794009, '04 CALL ME CALL ME.mp3', 1, B'1', NULL, 1.45533, 1, 'features_896.npy', NULL),
	(1097, 0, 4572457, '初音ミクさとうささら 君キライ Reupload.mp3', 1, B'1', NULL, 0.97262, 1, 'features_1097.npy', NULL),
	(1194, NULL, 4900280, 'セブンティーナ ⁄ はるまきごはん feat.初音ミク アニメMV - Seventina (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(989, 1, 4176877, '【初音ミク - Hatsune Miku】Electro Saturator -Starry electro mix-【MMD-PV】 [UX4II4sy1IQ].mp3', 1, B'1', NULL, 1.04591, 1, 'features_989.npy', NULL),
	(987, 2, 5669379, '【ミク・MAYU・がくぽ】「Ib」 forever 【オリジナルPV】.mp3', 1, B'1', NULL, 1.74792, 1, 'features_987.npy', NULL),
	(945, 2, 4775365, 'Lamaze P ft 初音ミク.mp3', 1, B'1', NULL, 1.74667, 1, 'features_945.npy', NULL),
	(1173, 0, 5321468, 'ゆよゆっぺ feat.巡音ルカ-Draw(Draw) (128kbit_AAC).mp3', 1, B'1', NULL, 0.10599, 1, 'features_1173.npy', NULL),
	(1163, 0, 5119165, '【巡音ルカ】Misery【オリジナル】 (128kbit_AAC).mp3', 1, B'1', NULL, 0.72709, 1, 'features_1163.npy', NULL),
	(1181, 0, 4711085, 'ウシノヒ☆アブダクション (128kbit_AAC).mp3', 1, B'1', NULL, 0.87994, 1, 'features_1181.npy', NULL),
	(899, 2, 6143816, '08 雨のちSweet-Drops.mp3', 1, B'1', NULL, 1.74910, 1, 'features_899.npy', NULL),
	(934, 2, 7662709, 'Hand in Hand.mp3', 1, B'1', NULL, 1.89108, 1, 'features_934.npy', NULL),
	(1125, 0, 7258330, '疑神暗鬼-⁄-しーくん-feat.-flower【Official】-_128kbit_AAC_.mp3', 1, B'1', NULL, 0.67091, 1, 'features_1125.npy', NULL),
	(1059, 0, 3407566, 'Q [Mu-fullauto].mp3', 1, B'1', NULL, 0.22825, 1, 'features_1059.npy', NULL),
	(1076, 0, 3803791, 'ナレ入り君ガ空コソカナシケレHoneyWorks feat.兎眠りおん初音ミク.mp3', 1, B'1', NULL, 0.46717, 1, 'features_1076.npy', NULL),
	(1046, 0, 3912413, 'ATOLS - EYE feat. Hatsune Miku  アイ feat. 初音ミク.mp3', 1, B'1', NULL, 0.18062, 1, 'features_1046.npy', NULL),
	(1056, 1, 6417551, 'MIKUHeliosphere.mp3', 1, B'1', NULL, 0.67199, 1, 'features_1056.npy', NULL),
	(1057, 0, 3554454, 'muship - 変な子ね [Official Audio].mp3', 1, B'1', NULL, 0.23981, 1, 'features_1057.npy', NULL),
	(999, 1, 6521296, '【初音ミク】a tail of the wind【Cazオリジナル】.mp3', 1, B'1', NULL, 0.50970, 1, 'features_999.npy', NULL),
	(878, 0, 3749064, '徒花満ちて _ ふる feat. 初音ミク [LRCKlcAECQ4].mp3', 1, B'1', NULL, 0.17551, 1, 'features_878.npy', NULL),
	(853, 0, 4837996, '【初音ミクDark】ループ・ループ・ループ【オリジナル】 [wpV2EbPYnrY].mp3', 1, B'1', NULL, 1.91250, 1, 'features_853.npy', NULL),
	(1119, 0, 6162518, '【Kanzaki Iori】 That Summer is Saturating 【Kagamine Rin ・ Len】(English Sub) (128kbit_AAC).mp3', 1, B'1', NULL, 0.11890, 1, 'features_1119.npy', NULL),
	(1155, 0, 4841742, 'Yin Yang Relationship (128kbit_AAC).mp3', 1, B'1', NULL, 2.34281, 1, 'features_1155.npy', NULL),
	(1145, 0, 5466451, 'Last Dance (128kbit_AAC).mp3', 1, B'1', NULL, 1.48452, 1, 'features_1145.npy', NULL),
	(1152, 2, 5652228, 'TsunTsun (128kbit_AAC).mp3', 1, B'1', NULL, 1.96913, 1, 'features_1152.npy', NULL),
	(1067, 0, 4443069, 'VocaloidIROHADrumstepDubstep.mp3', 1, B'1', NULL, 0.31415, 1, 'features_1067.npy', NULL),
	(861, 0, 3559505, '【初音ミク】　曇りのち腐乱臭　【オリジナルPV】 [kKtLt901HDw].mp3', 1, B'1', NULL, 0.38679, 1, 'features_861.npy', NULL),
	(1062, 0, 5427546, 'Utsu-P - Poster Girl''s Prank  看板娘の悪巫山戯.mp3', 1, B'1', NULL, 0.23171, 1, 'features_1062.npy', NULL),
	(940, 1, 6601010, 'Hatsune Miku Original Song.mp3', 1, B'1', NULL, 1.32702, 1, 'features_940.npy', NULL),
	(939, 1, 6269360, 'Hatsune Miku Original Song Bright City.mp3', 1, B'1', NULL, 1.27042, 1, 'features_939.npy', NULL),
	(909, 2, 6483666, '16 ローリンガール.mp3', 1, B'1', NULL, 1.91551, 1, 'features_909.npy', NULL),
	(964, 3, 5262496, 'sasakureUK x DECO27   39 feat Hatsune Miku.mp3', 1, B'1', NULL, 2.92978, 1, 'features_964.npy', NULL),
	(890, 2, 3762650, '- 初音ミクねこみみスイッチオリジナル.mp3', 1, B'1', NULL, 1.59062, 1, 'features_890.npy', NULL),
	(1038, 3, 6117641, '神のまにまに - れるりりfeat.ミク&リン&GUMI  At God''s Mercy - rerulili feat.Vocaloids.mp3', 1, B'1', NULL, 2.90132, 1, 'features_1038.npy', NULL),
	(955, 1, 5485059, 'Neo.mp3', 1, B'1', NULL, 1.04346, 1, 'features_955.npy', NULL),
	(863, 0, 5612525, '【初音ミク】ゲーセン上のアリア【オリジナル曲】 [PEHddBaJyUA].mp3', 1, B'1', NULL, 1.86591, 1, 'features_863.npy', NULL),
	(1185, 0, 5385328, 'カタストロフ (feat. 初音ミク & KAITO) (128kbit_AAC).mp3', 1, B'1', NULL, 0.46337, 1, 'features_1185.npy', NULL),
	(1045, 0, 4210080, '(Reprint) 初音ミクファーストセラピー(初投稿)オリジナル.mp3', 1, B'1', NULL, 0.23924, 1, 'features_1045.npy', NULL),
	(1134, 0, 5880397, 'Circus-P - ''I Am Here (with Mo Qingxian)'' [Vocaloid Original Song] (128kbit_AAC).mp3', 1, B'1', NULL, 0.84727, 1, 'features_1134.npy', NULL),
	(1170, 0, 4619758, 'はらぺこのルベル (128kbit_AAC).mp3', 1, B'1', NULL, 1.02863, 1, 'features_1170.npy', NULL),
	(963, 1, 5964668, 'ryuryu   Flowers featHatsune Miku 初音ミ�.mp3', 1, B'1', NULL, 1.62141, 1, 'features_963.npy', NULL),
	(925, 1, 5708877, 'DECO27   夜行性ハイズ feat 初音ミ�.mp3', 1, B'1', NULL, 1.37862, 1, 'features_925.npy', NULL),
	(1068, 0, 7352616, 'VocaloidYADA!!Moombahton.mp3', 1, B'1', NULL, 0.09751, 1, 'features_1068.npy', NULL),
	(959, 3, 6144599, 'Ordinary   ポリスピカデリー feat 初音ミク  Ordinary   Police Piccadilly feat Hatsune Mik.mp3', 1, B'1', NULL, 2.92191, 1, 'features_959.npy', NULL),
	(823, 0, 4163060, 'Koi wa Maboroshi de Ai wa Karamawari _ Nashimoto Ui (恋は幻で愛は空回り_梨本うい) [CfUZYBL6pr0].mp3', 1, B'1', NULL, 0.65247, 1, 'features_823.npy', NULL),
	(992, 1, 4831162, '【初音ミク×アルクロ】センセーションはおわらない！ フルver【コラボオリジナル楽曲�.mp3', 1, B'1', NULL, 1.34310, 1, 'features_992.npy', NULL),
	(841, 0, 5422033, '【VOCALOID_IA】_ 午前４時の金星 _ AM4 Venus _ by Ashin Kuroda [Zhc9onqv-QM].mp3', 1, B'1', NULL, 0.22620, 1, 'features_841.npy', NULL),
	(1084, 1, 3837517, '初音ミク A.I.210 オリジナル [Hatsune miku] A.I.210 [Official video].mp3', 1, B'1', NULL, 0.62296, 1, 'features_1084.npy', NULL),
	(1113, 0, 3802207, '花のない部屋 (feat. 初音ミク).mp3', 1, B'1', NULL, 0.94025, 1, 'features_1113.npy', NULL),
	(1010, 1, 5141020, '【初音ミク】空に花束を【オリジナル】 [4OLuVzAyYZ0].mp3', 1, B'1', NULL, 0.47833, 1, 'features_1010.npy', NULL),
	(1120, 0, 4246618, '【MV】Music Like Magic! feat. Hatsune Miku ⁄ 魔法みたいなミュージック！ feat. 初音ミク (128kbit_AAC).mp3', 1, B'1', NULL, 0.95958, 1, 'features_1120.npy', NULL),
	(1073, 0, 3736111, 'ただのCo 初音ミクアルカリ成人.mp3', 1, B'1', NULL, 0.92265, 1, 'features_1073.npy', NULL),
	(1111, 0, 3915751, '未来アタラシズム (feat. 初音ミク).mp3', 1, B'1', NULL, 1.73888, 1, 'features_1111.npy', NULL),
	(1144, 0, 2900725, 'HikkieP - できるできない万里の長城 [VOCALOID Kagamine Rin] (128kbit_AAC).mp3', 1, B'1', NULL, 0.27470, 1, 'features_1144.npy', NULL),
	(1154, 0, 1639737, 'Utsu-P - 自爆⁄Self-Destruct [Greatest Shits Ver.] (128kbit_AAC).mp3', 1, B'1', NULL, 0.46577, 1, 'features_1154.npy', NULL),
	(1169, 0, 5755031, 'ねぇ、どろどろさん YASUHIRO(康寛) feat.鏡音リン (128kbit_AAC).mp3', 1, B'1', NULL, 0.30747, 1, 'features_1169.npy', NULL),
	(1072, 0, 3011068, 'さよならワンダーノイズ.mp3', 1, B'1', NULL, 0.65206, 1, 'features_1072.npy', NULL),
	(820, 0, 4548609, 'EXLIUM - EXLIUM feat. Miku [06KskCU_d-M].mp3', 1, B'1', NULL, 0.24587, 1, 'features_820.npy', NULL),
	(1047, 0, 3615157, 'Audio-onlyえすぴあるWaroki  Hatsune Miku.mp3', 1, B'1', NULL, 0.17200, 1, 'features_1047.npy', NULL),
	(1110, 0, 3634609, '晴れのちメアリーシェーンにて (feat. 初音ミク).mp3', 1, B'1', NULL, 0.44886, 1, 'features_1110.npy', NULL),
	(954, 2, 4251662, 'Musunde Hiraite Rasetsu to Mukuro ORIGINAL.mp3', 1, B'1', NULL, 1.53655, 1, 'features_954.npy', NULL),
	(1070, 0, 4338308, 'YARUSE NAKIO - UFOが飛んでいる.mp3', 1, B'1', NULL, 0.39173, 1, 'features_1070.npy', NULL),
	(844, 0, 5812731, '【初音ミク - Hatsune Miku】your anniversary【PV subs】 [rUd8zvq63Ro] (1).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(845, 0, 5812731, '【初音ミク - Hatsune Miku】your anniversary【PV subs】 [rUd8zvq63Ro] (2).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1167, NULL, 5908882, 'どぅーまいべすと！／キノシタ(kinoshita) feat.音街ウナ／Do my best! (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1130, 0, 4204303, 'ATOLS - MINT feat. Hatsune Miku ⁄ ミント feat. 初音ミク (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(883, 0, 4643130, '洗濯　（初音ミクAppend） [yargFkG0q0o] (1).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1195, 0, 5543388, 'センシティブサマー (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1140, NULL, 5474779, 'DECO#27 - 愛言葉Ⅲ feat. 初音ミク (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1220, NULL, 6568280, '幾望の月 feat. 結月ゆかり ⁄ Kibou no tsuki - Nakyamurya (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1126, 0, 6474143, '稲葉曇『浮遊月光街』Vo.-歌愛ユキ-_128kbit_AAC_.mp3', 1, B'1', NULL, 1.69579, 1, 'features_1126.npy', NULL),
	(1204, 0, 4428116, 'バイオレンストリガー (128kbit_AAC).mp3', 1, B'1', NULL, 0.56948, 1, 'features_1204.npy', NULL),
	(1200, 0, 4265978, 'デレレレ (feat. Hatsune Miku) (128kbit_AAC).mp3', 1, B'1', NULL, 0.47718, 1, 'features_1200.npy', NULL),
	(1193, 0, 4968558, 'セブンティーナ (128kbit_AAC).mp3', 1, B'1', NULL, 1.22385, 1, 'features_1193.npy', NULL),
	(1218, 0, 4587699, '天泣 (128kbit_AAC).mp3', 1, B'1', NULL, 1.91666, 1, 'features_1218.npy', NULL),
	(1203, 0, 4860360, 'ニビイロドロウレ ⁄ nibiiro dolore - rin [オリジナル] (128kbit_AAC).mp3', 1, B'1', NULL, 0.82151, 1, 'features_1203.npy', NULL),
	(951, 2, 5197294, 'Melancholic  Junky ft Rin Kagamine.mp3', 1, B'1', NULL, 1.46678, 1, 'features_951.npy', NULL),
	(1205, 1, 5199971, 'ビューティフルなフィクション (128kbit_AAC).mp3', 1, B'1', NULL, 2.29980, 1, 'features_1205.npy', NULL),
	(1088, 0, 6740940, '初音ミクArigatoオリジナル.mp3', 1, B'1', NULL, 0.13561, 1, 'features_1088.npy', NULL),
	(926, 2, 3934431, 'DECO27  愛言葉Ⅲ feat 初音ミク.mp3', 1, B'1', NULL, 1.83043, 1, 'features_926.npy', NULL),
	(1049, 0, 4634971, 'Cryogenic (feat. 初音ミク).mp3', 1, B'1', NULL, 0.36916, 1, 'features_1049.npy', NULL),
	(1050, 0, 3877272, 'Desires-はるまきごはんfeat. 初音ミク.mp3', 1, B'1', NULL, 0.33279, 1, 'features_1050.npy', NULL),
	(1123, 0, 3937292, '【公式】撥条少女時計 feat.初音ミク【オリジナル曲】 (128kbit_AAC).mp3', 1, B'1', NULL, 0.82958, 1, 'features_1123.npy', NULL),
	(933, 1, 4128127, 'Find Me feat. Hatsune Miku [P7UJeX6WE4Q].mp3', 1, B'1', NULL, 1.17212, 1, 'features_933.npy', NULL),
	(826, 0, 3322812, '[Hatsune Miku] That Rich Guy is a Tetromino - tadanoco English subs [Ik8DHj5zcrs].mp3', 1, B'1', NULL, 0.46850, 1, 'features_826.npy', NULL),
	(911, 3, 8411420, '17 Yellow.mp3', 1, B'1', NULL, 2.92757, 1, 'features_911.npy', NULL),
	(1051, 1, 4387844, 'Hatsune Miku - World on Color [Original].mp3', 1, B'1', NULL, 0.76200, 1, 'features_1051.npy', NULL),
	(1019, 2, 5233030, 'みきとP『 だいあもんど 』M.mp3', 1, B'1', NULL, 1.67124, 1, 'features_1019.npy', NULL),
	(942, 1, 8056042, 'Heavenz   アルファ.mp3', 1, B'1', NULL, 1.08147, 1, 'features_942.npy', NULL),
	(921, 1, 5121435, 'Child   初音ミク.mp3', 1, B'1', NULL, 1.12079, 1, 'features_921.npy', NULL),
	(1143, 0, 6035166, 'Haruno Sora-sensei Will Praise You Endlessly (English subs for 無限にホメてくれる桜乃そら先生) (128kbit_AAC).mp3', 1, B'1', NULL, 0.56460, 1, 'features_1143.npy', NULL),
	(1217, 0, 4330334, '唯一、愛ノ詠 ⁄ ルカミクグミIAリン (128kbit_AAC).mp3', 1, B'1', NULL, 0.31047, 1, 'features_1217.npy', NULL),
	(1081, 0, 4083676, '八王子PGAME OVER feat. 初音ミクMusic Video.mp3', 1, B'1', NULL, 1.58084, 1, 'features_1081.npy', NULL),
	(1082, 2, 4693133, '八王子PHORIZON feat. 初音ミクMusic Video.mp3', 1, B'1', NULL, 1.70584, 1, 'features_1082.npy', NULL),
	(837, 1, 6215701, '【MIKU】Bianca [8a3lVn8rzmA].mp3', 1, B'1', NULL, 0.46264, 1, 'features_837.npy', NULL),
	(1180, NULL, 4804883, 'インヤンカンケイ - 和田たけあき (VOCALOID ver.) (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1157, 0, 2845306, '【HikkieP feat. 鏡音リン】できるできない万里の長城 (The Do''s and Don''t''s of the Great Wall)【ENGLISH SUBTITLES】 (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1182, NULL, 4725388, 'ウシノヒ☆アブダクション - cosMo＠暴走P feat. 音街ウナ (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1183, NULL, 1365555, 'エゴロック／ すりぃ feat.鏡音レン【OFFICIAL】 (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1184, NULL, 3532684, 'エロルヤ光線P ⁄ 門松円化 - 骨  (Eroruya Kousenp ⁄ Madoka Kadomatsu - Bone) (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1186, NULL, 5277779, 'カタストロフ（Catastrophe） feat.初音ミク KAITO - Dios⁄シグナルP (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1189, NULL, 5404121, 'クーロンズ・ホテル (feat. 鏡音リン & 鏡音レン) (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1117, 0, 2070747, '【HikkieP feat. 鏡音リン】できるできない万里の長城 (The Dos and Donts of the Great Wall)【ENGLISH SUBTITLES】 (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1159, NULL, 1125374, '【初音ミク】　トゥール　【オリジナル】 (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1052, 0, 3227552, 'Hatsune Miku, GUMI - M.S.S.Planet (Sub Eng).mp3', 1, B'1', NULL, 1.06255, 1, 'features_1052.npy', NULL),
	(1053, 0, 8530381, 'Inverse Relation (feat. 初音ミク).mp3', 1, B'1', NULL, 0.08966, 1, 'features_1053.npy', NULL),
	(1075, 0, 3927340, 'スノウドライヴ  Omoi feat. 初音ミク.mp3', 1, B'1', NULL, 1.24461, 1, 'features_1075.npy', NULL),
	(920, 2, 6536436, 'CATS RULE THE WORLD   daniwell feat Hatsune Miku  Momone Momo.mp3', 1, B'1', NULL, 1.48521, 1, 'features_920.npy', NULL),
	(960, 3, 4362839, 'PinocchioP (feat Hatsune Miku and Yukkuri)   Proliferation of Imamur.mp3', 1, B'1', NULL, 2.96484, 1, 'features_960.npy', NULL),
	(952, 1, 4345285, 'METEOR  DIVELA feat初音ミク.mp3', 1, B'1', NULL, 0.74929, 1, 'features_952.npy', NULL),
	(949, 2, 4201412, 'lumo - ネットチルナノグ feat. 初音ミク [fSOK6pGHI5Q].mp3', 1, B'1', NULL, 1.69331, 1, 'features_949.npy', NULL),
	(847, 0, 5063310, '【初音ミク - Hatsune Miku】ウタヲウタエ - Uta o Utae - Sing a Song【PV subs】 [j_AtIAPeIsU].mp3', 1, B'1', NULL, 0.38024, 1, 'features_847.npy', NULL),
	(852, 0, 5016696, '【初音ミクdark】シロツメクサの花冠 【オリジナル】 [rwXpIeZm-Sc].mp3', 1, B'1', NULL, 0.54231, 1, 'features_852.npy', NULL),
	(1178, 0, 5891229, 'アンチ・デジタリズム (feat. Hatsune Miku) (128kbit_AAC).mp3', 1, B'1', NULL, 0.31073, 1, 'features_1178.npy', NULL),
	(843, 0, 5339349, '【ミクAPPENDsolid】僕の一部【オリジナルPV】 [Po-oRnoT-ts].mp3', 1, B'1', NULL, 0.45793, 1, 'features_843.npy', NULL),
	(892, 2, 5561339, '01 EARTH DAY.mp3', 1, B'1', NULL, 1.20736, 1, 'features_892.npy', NULL),
	(859, 1, 4809098, '【初音ミク】Twinkle Days【オリジナル曲PV】 [m9DTGxCT5-0].mp3', 1, B'1', NULL, 1.51794, 1, 'features_859.npy', NULL),
	(1104, 1, 2527156, '初音ミク桃音モモ鏡音リンレンとてたてとてたオリジナル.mp3', 1, B'1', NULL, 0.46439, 1, 'features_1104.npy', NULL),
	(881, 1, 5130954, '明日も良い日になるでしょう (feat. IA＆初音ミク) [fHhV6tz2_Rs].mp3', 1, B'1', NULL, 1.47730, 1, 'features_881.npy', NULL),
	(1060, 0, 3550458, 'Starduster (Orchestral Ver.) - Hatsune Miku.mp3', 1, B'1', NULL, 0.08723, 1, 'features_1060.npy', NULL),
	(1061, 0, 8219614, 'TEN feat. Hatsune Miku & Kasane Teto TEN初音ミク&重音テト.mp3', 1, B'1', NULL, 0.16629, 1, 'features_1061.npy', NULL),
	(1103, 0, 3838955, '初音ミク東京レトロオリジナル曲PV付.mp3', 1, B'1', NULL, 1.17643, 1, 'features_1103.npy', NULL),
	(1013, 2, 4874421, 'あいまいクエスチョン／yamada feat初音ミク   The Quizmaste.mp3', 1, B'1', NULL, 1.95241, 1, 'features_1013.npy', NULL),
	(1179, 0, 4892148, 'インヤンカンケイ (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(868, 0, 5434338, '【初音ミクオリジナル】リダクト [A9JripMnIMc].mp3', 1, B'1', NULL, 0.33243, 1, 'features_868.npy', NULL),
	(1124, 0, 794639, '【初音ミク】 トゥール 【オリジナル】 (128kbit_AAC).mp3', 1, B'1', NULL, 0.43560, 1, 'features_1124.npy', NULL),
	(1007, 1, 6113159, '【初音ミク】アポロ【オリジナルMMD PV】.mp3', 1, B'1', NULL, 1.61546, 1, 'features_1007.npy', NULL),
	(819, 0, 6655813, 'Calla Soiled - 亜 [tqI5vcYYQY0].mp3', 1, B'1', NULL, 0.32160, 1, 'features_819.npy', NULL),
	(849, 0, 4790748, '【初音ミクAppend】miss you【中文字幕】 [MrVuRQHJhYs].mp3', 1, B'1', NULL, 0.72419, 1, 'features_849.npy', NULL),
	(1066, 0, 4244644, 'VOCALOIDflower of sorrow初音ミク.mp3', 1, B'1', NULL, 0.52004, 1, 'features_1066.npy', NULL),
	(973, 1, 3014503, 'yt1s.com - Mizusano feat 初音ミク Universe.mp3', 1, B'1', NULL, 1.02839, 1, 'features_973.npy', NULL),
	(1109, 0, 3770361, '少年Aと妄想少女.mp3', 1, B'1', NULL, 0.12192, 1, 'features_1109.npy', NULL),
	(907, 2, 6677916, '13 アンダンテ.mp3', 1, B'1', NULL, 1.90726, 1, 'features_907.npy', NULL),
	(900, 2, 7637962, '09 GIFT.mp3', 1, B'1', NULL, 1.76688, 1, 'features_900.npy', NULL),
	(994, 1, 6394121, '【初音ミク】 Baby Steps 【オリジナル�.mp3', 1, B'1', NULL, 1.58704, 1, 'features_994.npy', NULL),
	(950, 1, 4374124, 'MASA WORKS DESIGN ft初音ミクu0026GUMI   BRASS NOISE FLAMENC.mp3', 1, B'1', NULL, 1.09971, 1, 'features_950.npy', NULL),
	(978, 1, 4346243, '[Subs+Lyrics] Contrast [Hatsune Miku] [O6FrUaQVqlQ].mp3', 1, B'1', NULL, 0.68328, 1, 'features_978.npy', NULL),
	(986, 1, 6716994, '【オリジナルMV】ユメノアメ feat初音ミク  ドッシ�.mp3', 1, B'1', NULL, 1.48912, 1, 'features_986.npy', NULL),
	(1006, 1, 8406594, '【初音ミク】アネモネ【オリジナル】.mp3', 1, B'1', NULL, 2.60000, 1, 'features_1006.npy', NULL),
	(980, 1, 7771505, '[VOCALOID] Sailing  初音ミク [公式.mp3', 1, B'1', NULL, 0.51650, 1, 'features_980.npy', NULL),
	(976, 2, 6832978, '[Music] Livetune (feat Hatsune Miku)   Redia.mp3', 1, B'1', NULL, 1.80072, 1, 'features_976.npy', NULL),
	(827, 0, 4347135, '[Rin Kagamine and Miku Hatsune] Cold Back (English Subs) [HGtUmG1v9no].mp3', 1, B'1', NULL, 0.63560, 1, 'features_827.npy', NULL),
	(1219, 0, 6649463, '幾望の月 (128kbit_AAC).mp3', 1, B'1', NULL, 1.18717, 1, 'features_1219.npy', NULL),
	(967, 2, 9821039, 'triple baka - miku hatsune.mp3', 1, B'1', NULL, 1.66442, 1, 'features_967.npy', NULL),
	(956, 1, 5234911, 'Neru - ロストワンの号哭(Lost One''s Weeping) feat. Kagamine Rin.mp3', 1, B'1', NULL, 0.99256, 1, 'features_956.npy', NULL),
	(922, 1, 5852446, 'cloudway (feat Hatsune Miku)   keisei.mp3', 1, B'1', NULL, 1.15822, 1, 'features_922.npy', NULL),
	(923, 1, 4043380, 'Cressida   ftHatsune Miku 【english subtitles】.mp3', 1, B'1', NULL, 1.33355, 1, 'features_923.npy', NULL),
	(965, 2, 4354178, 'spica- hatsune miku.mp3', 1, B'1', NULL, 1.58530, 1, 'features_965.npy', NULL),
	(1162, 0, 5188554, '【巡音ルカ】Gerbera【オリジナル】 (128kbit_AAC).mp3', 1, B'1', NULL, 0.39318, 1, 'features_1162.npy', NULL),
	(1164, 0, 5616197, '【巡音ルカ】Reon - Remind【オリジナル】 (128kbit_AAC).mp3', 1, B'1', NULL, 0.31437, 1, 'features_1164.npy', NULL),
	(1188, 0, 5409690, 'クーロンズ・ホテル(Kowloon''s HOTEL)／鏡音リン・てにをは (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1176, 0, 5307886, 'わいふぁい暴想ボーイ- れるりり feat 鏡音レン& Fukase ⁄ Wi-Fi Imagination Wild Boy - rerulili feat LEN &VOCALOID Fukase (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1172, 0, 3565028, 'ぼかろころしあむ (feat. Kagamine Rin) (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1225, NULL, 6217782, '泥中に咲く ⁄ HarryP ft. 初音ミク (Official Music Video) (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1037, 1, 6647404, '手�.mp3', 1, B'1', NULL, 1.07016, 1, 'features_1037.npy', NULL),
	(1016, 1, 6318888, 'ひとりぼっちとココロの本と - PIPPO feat. 初音ミク.mp3', 1, B'1', NULL, 1.62473, 1, 'features_1016.npy', NULL),
	(1136, 0, 6487236, 'Clean Tears - Flying Away feat.初音ミク (128kbit_AAC).mp3', 1, B'1', NULL, 1.72908, 1, 'features_1136.npy', NULL),
	(990, 3, 6693704, '【初音ミクAppend DARK】Carbuncle【オリジナル曲】.mp3', 1, B'1', NULL, 2.95983, 1, 'features_990.npy', NULL),
	(1116, 0, 3725369, 'Luna - アルティメット (Ultimate) feat.Kagamine Len (128kbit_AAC).mp3', 1, B'1', NULL, 0.63760, 1, 'features_1116.npy', NULL),
	(1135, 0, 5097935, 'Circus-P - ''See (with AZUKI)'' [Original Vocaloid Song] (128kbit_AAC).mp3', 1, B'1', NULL, 0.95679, 1, 'features_1135.npy', NULL),
	(1137, 0, 5284901, 'DADARUMA (128kbit_AAC).mp3', 1, B'1', NULL, 0.84413, 1, 'features_1137.npy', NULL),
	(1095, 0, 5176143, '初音ミクが声優のようにしゃべってラップする曲ビバハピ Mitchie M.mp3', 1, B'1', NULL, 0.46524, 1, 'features_1095.npy', NULL),
	(1058, 0, 4028008, 'Psychokinesis (feat. Hatsune Miku) 2020 Version  Utsu-P.mp3', 1, B'1', NULL, 0.07295, 1, 'features_1058.npy', NULL),
	(1083, 0, 5693459, '初音ミク - Hatsune Miku AppendAllgatherOriginal.mp3', 1, B'1', NULL, 0.28717, 1, 'features_1083.npy', NULL),
	(1087, 0, 2861385, '初音ミク ｿﾄﾞﾑSodom Hatsune MikuOriginal.mp3', 1, B'1', NULL, 0.06310, 1, 'features_1087.npy', NULL),
	(829, 0, 3862228, '┗_∵_┓吉田、家出するってよ／HoneyWorks feat.初音ミク [fd0uHUAy6TU].mp3', 1, B'1', NULL, 0.94690, 1, 'features_829.npy', NULL),
	(1008, 1, 6742072, '【初音ミク】スターナイトスノウ【オリジナルMV�.mp3', 1, B'1', NULL, 0.67859, 1, 'features_1008.npy', NULL),
	(860, 0, 3683148, '【初音ミク】　 オトシメセルフ 　【オリジナル曲】 [hTQKJQWMQ-4].mp3', 1, B'1', NULL, 0.35396, 1, 'features_860.npy', NULL),
	(919, 0, 4315585, 'Bright future Ein schritt.mp3', 1, B'1', NULL, 0.17055, 1, 'features_919.npy', NULL),
	(816, 0, 3851200, 'After that feat. Hatsune Miku [xRoF-MAJ5O8].mp3', 1, B'1', NULL, 0.25196, 1, 'features_816.npy', NULL),
	(1024, 1, 6525151, '八王子Pデスクトップシンデレラ feat. 初音ミクMusic Video.mp3', 1, B'1', NULL, 1.80304, 1, 'features_1024.npy', NULL),
	(1223, 2, 7029300, '未来 (いつか) [feat. 初音ミク & 闇音レンリ] (128kbit_AAC).mp3', 1, B'1', NULL, 1.49296, 1, 'features_1223.npy', NULL),
	(871, 0, 4586189, 'とあ - 飛行機雲 - ft.初音ミク ( Toa - Contrail - ft.Hatsune Miku ) [RHCoZroZySA].mp3', 1, B'1', NULL, 0.20037, 1, 'features_871.npy', NULL),
	(914, 1, 6109320, 'Amaotopetrichor (feat. Hatsune Miku).mp3', 1, B'1', NULL, 1.44000, 1, 'features_914.npy', NULL),
	(1043, 1, 2568958, '鏡音レン唐傘さんが通るオリジナルPV.mp3', 1, B'1', NULL, 1.09214, 1, 'features_1043.npy', NULL),
	(866, 0, 3491991, '【初音ミク】天空の六分儀【オリジナルMV】 [x0_e0yQZibY].mp3', 1, B'1', NULL, 0.63805, 1, 'features_866.npy', NULL),
	(1054, 1, 4814456, 'JimmyThumbP - Crossroad feat. Hatsune Miku.mp3', 1, B'1', NULL, 0.57400, 1, 'features_1054.npy', NULL),
	(1153, NULL, 5080856, 'Ultimate (feat. Kagamine Len) (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1147, 0, 5616472, 'Off-Album Volume 7; Track 6-Reply to Gerbera (Okame-P) (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1142, NULL, 6635780, 'Flying away (feat. 初音ミク) (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1177, NULL, 5604621, 'アイアルの勘違い (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1230, NULL, 4936776, '稲葉曇『浮遊月光街』Vo. 歌愛ユキ (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1226, NULL, 5001056, '浮遊月光街 (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1229, NULL, 5424243, '疑神暗鬼 ⁄ しーくん feat. flower【Official】 (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1192, NULL, 5144318, 'スチールワンダー ⁄ はるまきごはん feat.初音ミク アニメMV - Steel Wonder (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1196, NULL, 5516370, 'センシティブサマー(SENSITIVE SUMMER) ⁄ ZLMS feat.初音ミク (ジグ・ルワン・はるまきごはん・雄之助） (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1003, 3, 4929612, '【初音ミク】Hatsune Miku「DECORATOR」MP3 High Quality![8].mp3', 1, B'1', NULL, 2.94949, 1, 'features_1003.npy', NULL),
	(891, 2, 4129298, '01 - Tell Your World.mp3', 1, B'1', NULL, 1.57992, 1, 'features_891.npy', NULL),
	(977, 1, 5640540, '[MV]さよならカンパニュラ  mehikari feat 初音ミ�.mp3', 1, B'1', NULL, 0.59269, 1, 'features_977.npy', NULL),
	(1216, 0, 6767001, '初音ミクの激唱(2018Remake) - cosMo＠暴走P (128kbit_AAC).mp3', 1, B'1', NULL, 0.45085, 1, 'features_1216.npy', NULL),
	(1034, 1, 6625461, '夏至の踊り子 ／初音ミ�.mp3', 1, B'1', NULL, 1.04685, 1, 'features_1034.npy', NULL),
	(1021, 1, 6313246, 'シネマセレク�.mp3', 1, B'1', NULL, 1.49523, 1, 'features_1021.npy', NULL),
	(905, 1, 6123034, '11 Anti X''mas Superstar.mp3', 1, B'1', NULL, 0.32187, 1, 'features_905.npy', NULL),
	(1018, 0, 4653386, 'みきとP『 kiss 』MV [9tjA9S281wg].mp3', 1, B'1', NULL, 0.78862, 1, 'features_1018.npy', NULL),
	(1036, 0, 1661360, '小説3こちら幸福安心委員会です女王様とハピネスサマーゲーム.mp3', 1, B'1', NULL, 0.09107, 1, 'features_1036.npy', NULL),
	(884, 0, 4643130, '洗濯　（初音ミクAppend） [yargFkG0q0o].mp3', 1, B'1', NULL, 0.66354, 1, 'features_884.npy', NULL),
	(1133, NULL, 3608383, 'BRASS NOISE FLAMENCO (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1148, NULL, 4792269, 'Sleeping Awake  Aqu3ra feat 初音ミク (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1206, NULL, 5208086, 'ピノキオピー - ビューティフルなフィクション feat. 初音ミク ⁄ Beautiful Fiction (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1207, NULL, 3706535, 'マーシーキリング (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(971, 1, 3495156, 'yt1s.com - ElectronicMizusano ft Hatsune Miku  Smile Walker.mp3', 1, B'1', NULL, 1.64238, 1, 'features_971.npy', NULL),
	(1001, 1, 5260371, '【初音ミク】aria【オリジナル曲PV付】.mp3', 1, B'1', NULL, 1.12061, 1, 'features_1001.npy', NULL),
	(1002, 1, 5931974, '【初音ミク】bpm full ver 【PV】.mp3', 1, B'1', NULL, 1.65394, 1, 'features_1002.npy', NULL),
	(983, 1, 4738909, '【Hatsune Miku】Body Music【Original Song】.mp3', 1, B'1', NULL, 1.63032, 1, 'features_983.npy', NULL),
	(894, 3, 8224103, '03 Palette.mp3', 1, B'1', NULL, 2.89793, 1, 'features_894.npy', NULL),
	(981, 1, 5384749, '‪【Hatsune Miku】‬Cerita SMU【Original】‬.mp3', 1, B'1', NULL, 0.49011, 1, 'features_981.npy', NULL),
	(1211, NULL, 4764333, '僕が夢を捨てて大人になるまで (152kbit_Opus).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1212, NULL, 4355916, '僕が夢を捨てて大人になるまで (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1213, NULL, 4987245, '僕が夢を捨てて大人になるまで　⁄  feat. 初音ミク (152kbit_Opus).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1012, 1, 7576434, '【水野大輔 feat 初音ミく】 Brilliance.mp3', 1, B'1', NULL, 0.60385, 1, 'features_1012.npy', NULL),
	(1022, 1, 4102032, 'プリエ  初音ミク  Hatsune Miku.mp3', 1, B'1', NULL, 0.78267, 1, 'features_1022.npy', NULL),
	(982, 1, 5817964, '┗ ∵ ┓夢ファンファーレ／HoneyWorks feat初音ミクu0026GUM.mp3', 1, B'1', NULL, 0.39341, 1, 'features_982.npy', NULL),
	(836, 0, 4427473, '【Miku·GUMI·Lily·Iroha】「Violet Blue Fantasy ～Fantasy of Iolite～」【Sub Español】 [d86r3_HR5kw].mp3', 1, B'1', NULL, 0.21536, 1, 'features_836.npy', NULL),
	(993, 1, 2801668, '【初音ミク】 Anata no Utahime (8ch arr) 【休闲の1月曲】.mp3', 1, B'1', NULL, 1.49838, 1, 'features_993.npy', NULL),
	(1102, 0, 3790109, '初音ミク愛に奇術師オリジナル1.mp3', 1, B'1', NULL, 0.50941, 1, 'features_1102.npy', NULL),
	(1215, NULL, 6842640, '初音ミク⁄そらをおよぐ (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1221, NULL, 5544129, '愛言葉III (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1222, NULL, 5646561, '撥条少女時計 (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1208, 0, 5068462, 'ミライゲイザー ／ DIVELA feat.初音ミク (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1198, NULL, 4658052, 'テレストテレス (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1228, 0, 6702060, '無限にホメてくれる桜乃そら先生 (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1201, NULL, 4305016, 'デレレレ ／ DIVELA feat.初音ミク (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1202, NULL, 5533589, 'ドンガラシャン (feat. 初音ミク) (96kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1040, 1, 5408573, '私は足りないでいっぱい_192kbps.mp3', 1, B'1', NULL, 1.64997, 1, 'features_1040.npy', NULL),
	(815, 0, 3325418, '(Reprint) 小悪魔笑顔とワガママボディー【初音ﾐｸﾀﾞﾖｰ オリジナルPV】 [ErksldUjSUI].mp3', 1, B'1', NULL, 0.19610, 1, 'features_815.npy', NULL),
	(1042, 1, 7087515, '膵臓  Luna feat 初音ミク ガールズコレクション.mp3', 1, B'1', NULL, 1.06463, 1, 'features_1042.npy', NULL),
	(1039, 1, 7278104, '神経衰弱  初音ミク 【 Nervous Breakdown  Hatsune Miku �.mp3', 1, B'1', NULL, 1.25676, 1, 'features_1039.npy', NULL),
	(974, 1, 4184609, '[Eng Sub] To the Lonely You and the Lone Me [Suzumu ft. Hatsune Miku] [EHxFEHPBDP8].mp3', 1, B'1', NULL, 1.05198, 1, 'features_974.npy', NULL),
	(906, 2, 8975210, '11 ハロー、プラネット.mp3', 1, B'1', NULL, 1.87666, 1, 'features_906.npy', NULL),
	(1011, 1, 6175226, '【初音ミク・GUMI】あの日、描いたDIARY【オリジナル曲PV】OFFICIAL　MV.mp3', 1, B'1', NULL, 1.28774, 1, 'features_1011.npy', NULL),
	(913, 2, 5785263, '20 どういうことなの! (Game Version).mp3', 1, B'1', NULL, 1.89792, 1, 'features_913.npy', NULL),
	(943, 1, 6782196, 'irucaice   White Step feat Hatsune Mik.mp3', 1, B'1', NULL, 1.51706, 1, 'features_943.npy', NULL),
	(1138, NULL, 5284440, 'DADARUMA／flower (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(975, 3, 6084413, '[Hatsune Miku] Sayonara Arpeggio [VOSTFR].mp3', 1, B'1', NULL, 2.79313, 1, 'features_975.npy', NULL),
	(944, 1, 5845549, 'kiRakiLa  gaogao feat初音ミ�.mp3', 1, B'1', NULL, 1.68211, 1, 'features_944.npy', NULL),
	(1190, 0, 5591923, 'コロナ (feat. Kagamine Rin) (128kbit_AAC).mp3', 1, B'1', NULL, 0.16630, 1, 'features_1190.npy', NULL),
	(1227, 0, 6121514, '無限にホメてくれる桜乃そら先生 (128kbit_AAC).mp3', 1, B'1', NULL, 0.48739, 1, 'features_1227.npy', NULL),
	(1224, 0, 6143344, '泥中に咲く (feat. 初音ミク) (128kbit_AAC).mp3', 1, B'1', NULL, 0.84964, 1, 'features_1224.npy', NULL),
	(1015, 1, 5372210, 'くるくるついんてーる_192kbps.mp3', 1, B'1', NULL, 1.58501, 1, 'features_1015.npy', NULL),
	(880, 1, 4468974, '恋人一首 _ 初音ミク [f7vloBZBp6c].mp3', 1, B'1', NULL, 1.60059, 1, 'features_880.npy', NULL),
	(938, 2, 5052472, 'Hatsune Miku   Torinoko City  (トリノコシティ)(Left Behind City) Sub Esp (+mp3 + romaji.mp3', 1, B'1', NULL, 1.86332, 1, 'features_938.npy', NULL),
	(918, 1, 7372052, 'Breath of Urban   keisei feat Hatsune Miku.mp3', 1, B'1', NULL, 0.79098, 1, 'features_918.npy', NULL),
	(1029, 1, 6602171, '初音ミクオリジナル曲 「Breath of mechanical」.mp3', 1, B'1', NULL, 1.46053, 1, 'features_1029.npy', NULL),
	(912, 2, 8169778, '18 リンリンシグナル.mp3', 1, B'1', NULL, 1.79221, 1, 'features_912.npy', NULL),
	(937, 3, 4216042, 'Hatsune Miku   Sayonara·Good bye [English Sub].mp3', 1, B'1', NULL, 0.42680, 1, 'features_937.npy', NULL),
	(882, 0, 3489005, '最憂間で君は [fmbOTo1t1dk].mp3', 1, B'1', NULL, 0.57005, 1, 'features_882.npy', NULL),
	(867, 0, 4512043, '【初音ミク】祝祭と流転 English and romaji subs [ieEk2hXFkOw].mp3', 1, B'1', NULL, 0.73766, 1, 'features_867.npy', NULL),
	(886, 0, 4240510, '雀色コンデンサ [Rh3XRrvzl50].mp3', 1, B'1', NULL, 0.77650, 1, 'features_886.npy', NULL),
	(961, 3, 6713232, 'Rainbow Palace feat Hatsune Miku   Jonathan Parecki 【Vocaloid Original�.mp3', 1, B'1', NULL, 0.90548, 1, 'features_961.npy', NULL),
	(1127, 0, 4979425, '#Luna - アルティメット (Ultimate) feat.Kagamine Len (128kbit_AAC).mp3', 1, B'1', NULL, 0.76148, 1, 'features_1127.npy', NULL),
	(1139, 0, 4162121, 'Dasu - Cur Ergo ft. IA & Kagamine Rin (Original) (128kbit_AAC).mp3', 1, B'1', NULL, 0.38503, 1, 'features_1139.npy', NULL),
	(1009, 1, 6236759, '【初音ミク】名前のない誰か【オリジナル�.mp3', 1, B'1', NULL, 2.94505, 1, 'features_1009.npy', NULL),
	(936, 1, 5667499, 'Hatsune Miku   Calc (English  Romaji Subs).mp3', 1, B'1', NULL, 0.86006, 1, 'features_936.npy', NULL),
	(957, 1, 5964041, 'night  (t)rain  初音ミ�.mp3', 1, B'1', NULL, 1.22234, 1, 'features_957.npy', NULL),
	(902, 1, 15100066, '09 キューティージェリー (feat. 初音ミク).mp3', 1, B'1', NULL, 1.67427, 1, 'features_902.npy', NULL),
	(898, 2, 3675539, '05 Night Glitter (Featuring Hatsune Miku).mp3', 1, B'1', NULL, 1.84939, 1, 'features_898.npy', NULL),
	(998, 1, 6366535, '【初音ミク】 紫陽花が咲く頃に、君と恋をする 【nk】.mp3', 1, B'1', NULL, 1.39836, 1, 'features_998.npy', NULL),
	(1171, NULL, 4578462, 'はらぺこのルベル ⁄ 初音ミク (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1174, NULL, 4802378, 'ゆよゆっぺ feat.巡音ルカ-Fake(Draw) (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(1168, NULL, 6493837, 'ぬゆり - ロンリーダンス ⁄ flower ; Lonely Dance (128kbit_AAC).mp3', 1, B'0', NULL, NULL, 0, NULL, NULL),
	(904, 1, 5874858, '11 396.mp3', 1, B'1', NULL, 1.13351, 1, 'features_904.npy', NULL),
	(825, 0, 6771075, 'sasakure.UK - Spider Thread Monopoly feat. Hatsune Miku  蜘蛛糸モノポリー.mp3', 1, B'1', NULL, 1.71691, 1, 'features_825.npy', NULL),
	(1129, 0, 5543992, 'ATOLS - Don Gara Shan feat. Hatsune Miku ⁄ ドンガラシャン feat. 初音ミク (128kbit_AAC).mp3', 1, B'1', NULL, 1.67491, 1, 'features_1129.npy', NULL),
	(1128, 0, 4198554, '404：虚像■初音ミク_オリジナル (128kbit_AAC).mp3', 1, B'1', NULL, 1.71963, 1, 'features_1128.npy', NULL),
	(1114, 3, 5132257, '[1080P Full] Sweet Magic スイートマジック - Kagamine Rin 鏡音リン Project DIVA English Romaji PDA FT.mp3', 1, B'1', NULL, 1.53408, 1, 'features_1114.npy', NULL),
	(865, 0, 3016114, '【初音ミク】夢で逢いましょう【オリジナル】 [YI492W4Qb3g].mp3', 1, B'1', NULL, 0.34434, 1, 'features_865.npy', NULL),
	(1086, 0, 5875460, '初音ミク もう やめちゃってもいい かなァ 人生オリジナル.mp3', 1, B'1', NULL, 0.96336, 1, 'features_1086.npy', NULL),
	(1094, 0, 4588623, '初音ミクTearsオリジナルMV.mp3', 1, B'1', NULL, 0.32556, 1, 'features_1094.npy', NULL),
	(1080, 0, 4731644, '一触即発禅ガール - れるりりfeat.初音ミク&GUMI  Simmering ZEN Girl - rerulili feat.miku&gumi.mp3', 1, B'1', NULL, 0.95489, 1, 'features_1080.npy', NULL),
	(1089, 1, 3798990, '初音ミクGUMI(40) コトバのうた オリジナルPV.mp3', 1, B'1', NULL, 0.16519, 1, 'features_1089.npy', NULL),
	(828, 0, 3612810, '┗_∵_┓ヤキモチの答え-another story-／HoneyWorks feat.初音ミク [Qlkezcz3tt4].mp3', 1, B'1', NULL, 0.73503, 1, 'features_828.npy', NULL),
	(1033, 1, 5628001, '初音ミク灯火syudou_192kbps.mp3', 1, B'1', NULL, 2.00323, 1, 'features_1033.npy', NULL),
	(1030, 1, 6067486, '初音ミクオリジナル曲「Singularity�.mp3', 1, B'1', NULL, 1.86078, 1, 'features_1030.npy', NULL),
	(995, 0, 7854795, '【初音ミク】 children 【オリジナル曲】.mp3', 1, B'1', NULL, 1.20809, 1, 'features_995.npy', NULL),
	(824, 0, 5785319, 'Reality _ Dog tails feat. Miku [MMDPV] [UPhsMAdDGfM].mp3', 1, B'1', NULL, 0.17677, 1, 'features_824.npy', NULL),
	(851, 0, 5377606, '【初音ミクDark】ゆらゆら English and romaji subs [04fGKdznrkw].mp3', 1, B'1', NULL, 0.88840, 1, 'features_851.npy', NULL),
	(1035, 1, 7311959, '大嫌いなはずだったHoneyWorks feat.GUMI初音ミク.mp3', 1, B'1', NULL, 0.85753, 1, 'features_1035.npy', NULL),
	(1079, 1, 4707801, 'リンレンGUMIルカミクcLick cRackオリジナル.mp3', 1, B'1', NULL, 0.25854, 1, 'features_1079.npy', NULL),
	(1044, 0, 3954545, '【初音ミク】SEAHOLLY【オリジナルMV】 [LkCHlsJyV7Y].mp3', 1, B'1', NULL, 0.49823, 1, 'features_1044.npy', NULL),
	(916, 1, 3662996, 'Anti Selector_初音ミク [ShTbgwaKkiQ].mp3', 1, B'1', NULL, 0.24275, 1, 'features_916.npy', NULL),
	(1014, 2, 3723988, 'えいえんがみつからない - daniwell feat. Hatsune Miku & Momone Momo.mp3', 1, B'1', NULL, 2.99540, 1, 'features_1014.npy', NULL),
	(818, 0, 4057727, 'Blindness (feat. 初音ミク) [nlLGzmErKWE].mp3', 1, B'1', NULL, 0.21999, 1, 'features_818.npy', NULL),
	(935, 1, 3791071, 'Hatsune Miku   Akeomeakeomeakeomeakeome (Happy New Year).mp3', 1, B'1', NULL, 0.57583, 1, 'features_935.npy', NULL),
	(953, 2, 3980123, 'miku hatsune - po pi po356.mp3', 1, B'1', NULL, 1.88014, 1, 'features_953.npy', NULL),
	(1132, 2, 4020657, 'Booo! - TOKOTOKO（西沢さんP） feat.音街ウナ (128kbit_AAC).mp3', 1, B'1', NULL, 1.07941, 1, 'features_1132.npy', NULL),
	(1210, 2, 4410293, '僕が夢を捨てて大人になるまで (128kbit_AAC).mp3', 1, B'1', NULL, 0.59668, 1, 'features_1210.npy', NULL),
	(928, 1, 2889533, 'DokiDokiBeat 初音ミク for Lamaze.mp3', 1, B'1', NULL, 2.68639, 1, 'features_928.npy', NULL),
	(887, 0, 3885563, '霞む森 _ 初音ミク＆GUMI [5UIfTqACqJ8] (1).mp3', 1, B'1', NULL, 0.31204, 1, 'features_887.npy', NULL),
	(915, 1, 7015417, 'An ／ DECO＊27 feat初音ミク.mp3', 1, B'1', NULL, 1.03205, 1, 'features_915.npy', NULL),
	(1085, 0, 3459565, '初音ミク White Prism 蝶々P.mp3', 1, B'1', NULL, 0.12476, 1, 'features_1085.npy', NULL),
	(834, 0, 3150189, '【Hatsune Miku】 たのしい逃避行 [5Tef_SSOe40].mp3', 1, B'1', NULL, 0.72420, 1, 'features_834.npy', NULL),
	(1096, 0, 4572457, '初音ミクさとうささら 君キライ Reupload (1).mp3', 1, B'1', NULL, 0.97262, 1, 'features_1096.npy', NULL),
	(968, 2, 5999149, 'TsunTsun  ftHatsune Miku_192kbps.mp3', 1, B'1', NULL, 1.56915, 1, 'features_968.npy', NULL),
	(969, 1, 5117066, 'Weekender Girl   Hatsune Miku Project Diva F (HD).mp3', 1, B'1', NULL, 1.48943, 1, 'features_969.npy', NULL),
	(855, 0, 3899633, '【初音ミク】 幻奏サティスファクション 【オリジナル曲】 [RHqTWidK9DE].mp3', 1, B'1', NULL, 0.51115, 1, 'features_855.npy', NULL),
	(1090, 0, 8880650, '初音ミクHatsune Miku - Shining Love.mp3', 1, B'1', NULL, 0.45682, 1, 'features_1090.npy', NULL),
	(1069, 0, 4404652, 'We Wait for Morning on the Last Train risou feat. Hatsune Miku (English sub).mp3', 1, B'1', NULL, 0.34538, 1, 'features_1069.npy', NULL),
	(910, 2, 4558903, '17 Ievan Polkka.mp3', 1, B'1', NULL, 2.97603, 1, 'features_910.npy', NULL),
	(1020, 1, 4399108, 'アンドロメダアンドロメダ   ナユタン星人 feat 初音ミク.mp3', 1, B'1', NULL, 1.70102, 1, 'features_1020.npy', NULL),
	(1151, 0, 6477311, 'TieredCrisis ⁄ youman feat. GUMI (English Subs) (128kbit_AAC).mp3', 1, B'1', NULL, 0.80923, 1, 'features_1151.npy', NULL),
	(1165, 0, 5902699, 'とがびとごろし ⁄ 歌愛ユキ、音街ウナ (128kbit_AAC).mp3', 1, B'1', NULL, 1.08318, 1, 'features_1165.npy', NULL),
	(1161, 0, 4649780, '【巡音ルカ】Canvas【オリジナル】 (128kbit_AAC).mp3', 1, B'1', NULL, 0.37029, 1, 'features_1161.npy', NULL),
	(1025, 1, 6081645, '初音ミク poppin'' jumpin まらしぃ kors k.mp3', 1, B'1', NULL, 0.86211, 1, 'features_1025.npy', NULL),
	(1000, 1, 7950183, '【初音ミク】Another Mine【オリジナル21】[HD720p].mp3', 1, B'1', NULL, 1.00784, 1, 'features_1000.npy', NULL),
	(1023, 1, 5891316, 'モノクロブルースカイ  のぼる feat 初音ミク  MonochromeBlueSky.mp3', 1, B'1', NULL, 2.33664, 1, 'features_1023.npy', NULL),
	(893, 1, 5372012, '01 アンドロイド Voc@loid ～I am not a robot～.mp3', 1, B'1', NULL, 0.58311, 1, 'features_893.npy', NULL),
	(850, 0, 4513925, '【初音ミクAppend】Quiet【オリジナル曲】 [fihI7EuO0eA].mp3', 1, B'1', NULL, 0.70810, 1, 'features_850.npy', NULL),
	(948, 1, 6385343, 'LOST NOTE  No85 feat初音ミ�.mp3', 1, B'1', NULL, 0.54133, 1, 'features_948.npy', NULL),
	(1149, 1, 5012316, 'Sleeping Awake ⁄ Aqu3ra feat.初音ミク (128kbit_AAC).mp3', 1, B'1', NULL, 0.70058, 1, 'features_1149.npy', NULL),
	(1055, 0, 5957309, 'MASA WORKS DESIGN ft.初音ミク&GUMI - 狐の嫁入り.mp3', 1, B'1', NULL, 2.61482, 1, 'features_1055.npy', NULL),
	(885, 0, 2156993, '第1話　予測の先にカノジョは走馬灯を見るか PSGO-Z【SKEW PV】 [Ih6NBS9OcPo].mp3', 1, B'1', NULL, 0.85624, 1, 'features_885.npy', NULL);


--
-- Data for Name: entrenamientos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.entrenamientos OVERRIDING SYSTEM VALUE VALUES
	(12832, 1150, B'0', 25, '2026-06-08 21:04:19.454789-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12833, 857, B'0', 25, '2026-06-08 21:04:19.456224-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12834, 832, B'0', 25, '2026-06-08 21:04:19.456761-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12835, 947, B'0', 25, '2026-06-08 21:04:19.457203-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12836, 848, B'0', 25, '2026-06-08 21:04:19.457789-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12837, 858, B'0', 25, '2026-06-08 21:04:19.458313-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12838, 1098, B'0', 25, '2026-06-08 21:04:19.45875-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12839, 984, B'0', 25, '2026-06-08 21:04:19.459105-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12840, 1041, B'0', 25, '2026-06-08 21:04:19.459451-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(12841, 991, B'0', 25, '2026-06-08 21:04:19.459757-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12842, 874, B'0', 25, '2026-06-08 21:04:19.460206-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12843, 988, B'0', 25, '2026-06-08 21:04:19.460622-06', 3, 51, 0.50777, '32', 0.200, 0.784),
	(12844, 838, B'0', 25, '2026-06-08 21:04:19.460924-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12845, 864, B'0', 25, '2026-06-08 21:04:19.46136-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12846, 839, B'0', 25, '2026-06-08 21:04:19.461744-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12847, 1122, B'0', 25, '2026-06-08 21:04:19.462057-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12848, 1093, B'0', 25, '2026-06-08 21:04:19.462357-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12849, 872, B'0', 25, '2026-06-08 21:04:19.462679-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12850, 941, B'0', 25, '2026-06-08 21:04:19.463048-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12851, 869, B'0', 25, '2026-06-08 21:04:19.463399-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12852, 897, B'0', 25, '2026-06-08 21:04:19.463723-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(12853, 970, B'0', 25, '2026-06-08 21:04:19.464009-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(12854, 1091, B'0', 25, '2026-06-08 21:04:19.464444-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12855, 1092, B'0', 25, '2026-06-08 21:04:19.464818-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12856, 1187, B'0', 25, '2026-06-08 21:04:19.465203-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12857, 1107, B'0', 25, '2026-06-08 21:04:19.465579-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12858, 1108, B'0', 25, '2026-06-08 21:04:19.465935-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12859, 895, B'0', 25, '2026-06-08 21:04:19.466269-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12860, 901, B'0', 25, '2026-06-08 21:04:19.466654-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(12861, 946, B'0', 25, '2026-06-08 21:04:19.467031-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12862, 1106, B'0', 25, '2026-06-08 21:04:19.467477-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12863, 985, B'0', 25, '2026-06-08 21:04:19.468397-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12864, 842, B'0', 25, '2026-06-08 21:04:19.46871-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12865, 817, B'0', 25, '2026-06-08 21:04:19.469226-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12866, 1112, B'0', 25, '2026-06-08 21:04:19.46968-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12867, 1160, B'0', 25, '2026-06-08 21:04:19.470038-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12868, 830, B'0', 25, '2026-06-08 21:04:19.470387-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12869, 831, B'0', 25, '2026-06-08 21:04:19.470696-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12870, 873, B'0', 25, '2026-06-08 21:04:19.471017-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12871, 1048, B'0', 25, '2026-06-08 21:04:19.471583-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12872, 931, B'0', 25, '2026-06-08 21:04:19.471961-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12873, 1209, B'0', 25, '2026-06-08 21:04:19.472298-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12874, 888, B'0', 25, '2026-06-08 21:04:19.472591-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12875, 917, B'0', 25, '2026-06-08 21:04:19.47294-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12876, 1028, B'0', 25, '2026-06-08 21:04:19.473252-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12877, 1005, B'0', 25, '2026-06-08 21:04:19.473721-06', 3, 51, 0.50777, '32', 0.200, 0.784),
	(12878, 862, B'0', 25, '2026-06-08 21:04:19.474125-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12879, 927, B'0', 25, '2026-06-08 21:04:19.474473-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(12880, 1027, B'0', 25, '2026-06-08 21:04:19.474817-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12881, 962, B'0', 25, '2026-06-08 21:04:19.475269-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12882, 958, B'0', 25, '2026-06-08 21:04:19.475601-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12883, 876, B'0', 25, '2026-06-08 21:04:19.475935-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12884, 1131, B'0', 25, '2026-06-08 21:04:19.47625-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12885, 1074, B'0', 25, '2026-06-08 21:04:19.476547-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12886, 1026, B'0', 25, '2026-06-08 21:04:19.476845-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(12887, 1071, B'0', 25, '2026-06-08 21:04:19.477175-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12888, 966, B'0', 25, '2026-06-08 21:04:19.477623-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12889, 856, B'0', 25, '2026-06-08 21:04:19.477922-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12890, 1101, B'0', 25, '2026-06-08 21:04:19.478202-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12891, 870, B'0', 25, '2026-06-08 21:04:19.478594-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12892, 846, B'0', 25, '2026-06-08 21:04:19.478904-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12893, 854, B'0', 25, '2026-06-08 21:04:19.47925-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12894, 924, B'0', 25, '2026-06-08 21:04:19.479548-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(12895, 1100, B'0', 25, '2026-06-08 21:04:19.47985-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12896, 1105, B'0', 25, '2026-06-08 21:04:19.480154-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12897, 1175, B'0', 25, '2026-06-08 21:04:19.480488-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12898, 1166, B'0', 25, '2026-06-08 21:04:19.481427-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12899, 1017, B'0', 25, '2026-06-08 21:04:19.48177-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(12900, 835, B'0', 25, '2026-06-08 21:04:19.482217-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(12901, 929, B'0', 25, '2026-06-08 21:04:19.482597-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12902, 1065, B'0', 25, '2026-06-08 21:04:19.482973-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12903, 1031, B'0', 25, '2026-06-08 21:04:19.483306-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12904, 833, B'0', 25, '2026-06-08 21:04:19.483664-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12905, 1004, B'0', 25, '2026-06-08 21:04:19.483957-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12906, 1077, B'0', 25, '2026-06-08 21:04:19.484309-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12907, 814, B'0', 25, '2026-06-08 21:04:19.484731-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12908, 1191, B'0', 25, '2026-06-08 21:04:19.485325-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12909, 1199, B'0', 25, '2026-06-08 21:04:19.485702-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12910, 979, B'0', 25, '2026-06-08 21:04:19.486004-06', 3, 51, 0.50777, '32', 0.200, 0.784),
	(12911, 1032, B'0', 25, '2026-06-08 21:04:19.486302-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(12912, 1158, B'0', 25, '2026-06-08 21:04:19.486755-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12913, 1197, B'0', 25, '2026-06-08 21:04:19.4871-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12914, 1214, B'0', 25, '2026-06-08 21:04:19.487408-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12915, 1099, B'0', 25, '2026-06-08 21:04:19.487745-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12916, 996, B'0', 25, '2026-06-08 21:04:19.488044-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12917, 822, B'0', 25, '2026-06-08 21:04:19.48838-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12918, 1118, B'0', 25, '2026-06-08 21:04:19.488746-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12919, 1121, B'0', 25, '2026-06-08 21:04:19.489083-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(12920, 1141, B'0', 25, '2026-06-08 21:04:19.489481-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12921, 1156, B'0', 25, '2026-06-08 21:04:19.490074-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12922, 1115, B'0', 25, '2026-06-08 21:04:19.490521-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12923, 972, B'0', 25, '2026-06-08 21:04:19.49083-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12924, 821, B'0', 25, '2026-06-08 21:04:19.491145-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12925, 896, B'0', 25, '2026-06-08 21:04:19.49146-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12926, 1097, B'0', 25, '2026-06-08 21:04:19.491772-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12927, 877, B'0', 25, '2026-06-08 21:04:19.492117-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12928, 1063, B'0', 25, '2026-06-08 21:04:19.492501-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12929, 1064, B'0', 25, '2026-06-08 21:04:19.492802-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12930, 903, B'0', 25, '2026-06-08 21:04:19.493154-06', 3, 51, 0.50777, '32', 0.200, 0.784),
	(12931, 875, B'0', 25, '2026-06-08 21:04:19.493467-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12932, 879, B'0', 25, '2026-06-08 21:04:19.493751-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12933, 932, B'0', 25, '2026-06-08 21:04:19.494075-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(12934, 1146, B'0', 25, '2026-06-08 21:04:19.494388-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12935, 930, B'0', 25, '2026-06-08 21:04:19.494841-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12936, 989, B'0', 25, '2026-06-08 21:04:19.495194-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12937, 1046, B'0', 25, '2026-06-08 21:04:19.495518-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12938, 1056, B'0', 25, '2026-06-08 21:04:19.495816-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12939, 1057, B'0', 25, '2026-06-08 21:04:19.496127-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12940, 999, B'0', 25, '2026-06-08 21:04:19.496411-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12941, 878, B'0', 25, '2026-06-08 21:04:19.496707-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12942, 853, B'0', 25, '2026-06-08 21:04:19.497011-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12943, 1119, B'0', 25, '2026-06-08 21:04:19.497298-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12944, 1155, B'0', 25, '2026-06-08 21:04:19.497578-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12945, 1145, B'0', 25, '2026-06-08 21:04:19.497875-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12946, 1152, B'0', 25, '2026-06-08 21:04:19.498202-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(12947, 1067, B'0', 25, '2026-06-08 21:04:19.498654-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12948, 861, B'0', 25, '2026-06-08 21:04:19.49901-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12949, 1062, B'0', 25, '2026-06-08 21:04:19.499363-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12950, 940, B'0', 25, '2026-06-08 21:04:19.49969-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12951, 939, B'0', 25, '2026-06-08 21:04:19.500014-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12952, 909, B'0', 25, '2026-06-08 21:04:19.500324-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(12953, 964, B'0', 25, '2026-06-08 21:04:19.500642-06', 3, 51, 0.50777, '32', 0.200, 0.784),
	(12954, 890, B'0', 25, '2026-06-08 21:04:19.500935-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(12955, 987, B'0', 25, '2026-06-08 21:04:19.501249-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(12956, 945, B'0', 25, '2026-06-08 21:04:19.501608-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(12957, 1173, B'0', 25, '2026-06-08 21:04:19.50194-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12958, 1163, B'0', 25, '2026-06-08 21:04:19.502365-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12959, 1181, B'0', 25, '2026-06-08 21:04:19.502795-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12960, 899, B'0', 25, '2026-06-08 21:04:19.503277-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(12961, 934, B'0', 25, '2026-06-08 21:04:19.503665-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(12962, 1125, B'0', 25, '2026-06-08 21:04:19.504041-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12963, 1059, B'0', 25, '2026-06-08 21:04:19.504386-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12964, 1076, B'0', 25, '2026-06-08 21:04:19.504766-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12965, 1111, B'0', 25, '2026-06-08 21:04:19.505198-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12966, 1038, B'0', 25, '2026-06-08 21:04:19.505563-06', 3, 51, 0.50777, '32', 0.200, 0.784),
	(12967, 1144, B'0', 25, '2026-06-08 21:04:19.506095-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12968, 1154, B'0', 25, '2026-06-08 21:04:19.506576-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12969, 1169, B'0', 25, '2026-06-08 21:04:19.506968-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12970, 1072, B'0', 25, '2026-06-08 21:04:19.507296-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12971, 820, B'0', 25, '2026-06-08 21:04:19.507721-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12972, 1047, B'0', 25, '2026-06-08 21:04:19.508031-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12973, 1110, B'0', 25, '2026-06-08 21:04:19.508328-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12974, 954, B'0', 25, '2026-06-08 21:04:19.50863-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(12975, 955, B'0', 25, '2026-06-08 21:04:19.508983-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12976, 863, B'0', 25, '2026-06-08 21:04:19.509375-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12977, 1185, B'0', 25, '2026-06-08 21:04:19.509787-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12978, 1045, B'0', 25, '2026-06-08 21:04:19.51015-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12979, 1134, B'0', 25, '2026-06-08 21:04:19.51048-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12980, 1170, B'0', 25, '2026-06-08 21:04:19.510839-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12981, 963, B'0', 25, '2026-06-08 21:04:19.511183-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12982, 925, B'0', 25, '2026-06-08 21:04:19.511678-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12983, 1068, B'0', 25, '2026-06-08 21:04:19.511981-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12984, 1070, B'0', 25, '2026-06-08 21:04:19.512292-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12985, 959, B'0', 25, '2026-06-08 21:04:19.512653-06', 3, 51, 0.50777, '32', 0.200, 0.784),
	(12986, 823, B'0', 25, '2026-06-08 21:04:19.513127-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12987, 992, B'0', 25, '2026-06-08 21:04:19.513608-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12988, 841, B'0', 25, '2026-06-08 21:04:19.513984-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12989, 1084, B'0', 25, '2026-06-08 21:04:19.514314-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12990, 1113, B'0', 25, '2026-06-08 21:04:19.514658-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12991, 1010, B'0', 25, '2026-06-08 21:04:19.514983-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(12992, 1120, B'0', 25, '2026-06-08 21:04:19.515285-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12993, 1073, B'0', 25, '2026-06-08 21:04:19.515762-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12994, 1126, B'0', 25, '2026-06-08 21:04:19.516067-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12995, 1204, B'0', 25, '2026-06-08 21:04:19.516486-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12996, 1200, B'0', 25, '2026-06-08 21:04:19.516781-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12997, 1193, B'0', 25, '2026-06-08 21:04:19.517096-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12998, 1218, B'0', 25, '2026-06-08 21:04:19.517426-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(12999, 1203, B'0', 25, '2026-06-08 21:04:19.517776-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13000, 951, B'0', 25, '2026-06-08 21:04:19.5181-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(13001, 1205, B'0', 25, '2026-06-08 21:04:19.518407-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13002, 1088, B'0', 25, '2026-06-08 21:04:19.518738-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13003, 1019, B'0', 25, '2026-06-08 21:04:19.519836-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(13004, 942, B'0', 25, '2026-06-08 21:04:19.520179-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13005, 921, B'0', 25, '2026-06-08 21:04:19.520526-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13006, 1143, B'0', 25, '2026-06-08 21:04:19.521006-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13007, 1217, B'0', 25, '2026-06-08 21:04:19.521345-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13008, 1081, B'0', 25, '2026-06-08 21:04:19.521703-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13009, 1082, B'0', 25, '2026-06-08 21:04:19.522057-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(13010, 837, B'0', 25, '2026-06-08 21:04:19.522376-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13011, 926, B'0', 25, '2026-06-08 21:04:19.522725-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(13012, 1049, B'0', 25, '2026-06-08 21:04:19.523058-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13013, 1050, B'0', 25, '2026-06-08 21:04:19.523365-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13014, 1123, B'0', 25, '2026-06-08 21:04:19.523684-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13015, 933, B'0', 25, '2026-06-08 21:04:19.523973-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13016, 826, B'0', 25, '2026-06-08 21:04:19.524332-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13017, 911, B'0', 25, '2026-06-08 21:04:19.524777-06', 3, 51, 0.50777, '32', 0.200, 0.784),
	(13018, 1051, B'0', 25, '2026-06-08 21:04:19.525114-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13019, 1052, B'0', 25, '2026-06-08 21:04:19.525502-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13020, 1053, B'0', 25, '2026-06-08 21:04:19.525912-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13021, 1075, B'0', 25, '2026-06-08 21:04:19.526289-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13022, 920, B'0', 25, '2026-06-08 21:04:19.526623-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(13023, 960, B'0', 25, '2026-06-08 21:04:19.527067-06', 3, 51, 0.50777, '32', 0.200, 0.784),
	(13024, 952, B'0', 25, '2026-06-08 21:04:19.527445-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13025, 949, B'0', 25, '2026-06-08 21:04:19.527792-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(13026, 847, B'0', 25, '2026-06-08 21:04:19.528107-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13027, 852, B'0', 25, '2026-06-08 21:04:19.5284-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13028, 1178, B'0', 25, '2026-06-08 21:04:19.528834-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13029, 843, B'0', 25, '2026-06-08 21:04:19.529134-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13030, 892, B'0', 25, '2026-06-08 21:04:19.529455-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(13031, 859, B'0', 25, '2026-06-08 21:04:19.529773-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13032, 1104, B'0', 25, '2026-06-08 21:04:19.530046-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13033, 881, B'0', 25, '2026-06-08 21:04:19.530333-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13034, 1060, B'0', 25, '2026-06-08 21:04:19.530638-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13035, 1061, B'0', 25, '2026-06-08 21:04:19.530915-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13036, 1103, B'0', 25, '2026-06-08 21:04:19.531215-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13037, 1013, B'0', 25, '2026-06-08 21:04:19.531523-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(13038, 1109, B'0', 25, '2026-06-08 21:04:19.531826-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13039, 907, B'0', 25, '2026-06-08 21:04:19.532102-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(13040, 900, B'0', 25, '2026-06-08 21:04:19.532517-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(13041, 994, B'0', 25, '2026-06-08 21:04:19.532826-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13042, 950, B'0', 25, '2026-06-08 21:04:19.533115-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13043, 978, B'0', 25, '2026-06-08 21:04:19.533397-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13044, 986, B'0', 25, '2026-06-08 21:04:19.533706-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13045, 1006, B'0', 25, '2026-06-08 21:04:19.533991-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13046, 980, B'0', 25, '2026-06-08 21:04:19.534284-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13047, 976, B'0', 25, '2026-06-08 21:04:19.534623-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(13048, 827, B'0', 25, '2026-06-08 21:04:19.534912-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13049, 1219, B'0', 25, '2026-06-08 21:04:19.53527-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13050, 967, B'0', 25, '2026-06-08 21:04:19.535588-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(13051, 868, B'0', 25, '2026-06-08 21:04:19.5359-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13052, 1124, B'0', 25, '2026-06-08 21:04:19.536352-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13053, 1007, B'0', 25, '2026-06-08 21:04:19.536741-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13054, 819, B'0', 25, '2026-06-08 21:04:19.537072-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13055, 849, B'0', 25, '2026-06-08 21:04:19.537404-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13056, 1066, B'0', 25, '2026-06-08 21:04:19.537701-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13057, 973, B'0', 25, '2026-06-08 21:04:19.538027-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13058, 1162, B'0', 25, '2026-06-08 21:04:19.538337-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13059, 1164, B'0', 25, '2026-06-08 21:04:19.538625-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13060, 1037, B'0', 25, '2026-06-08 21:04:19.538925-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13061, 1136, B'0', 25, '2026-06-08 21:04:19.539276-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13062, 990, B'0', 25, '2026-06-08 21:04:19.539633-06', 3, 51, 0.50777, '32', 0.200, 0.784),
	(13063, 1116, B'0', 25, '2026-06-08 21:04:19.539927-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13064, 1135, B'0', 25, '2026-06-08 21:04:19.540381-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13065, 1137, B'0', 25, '2026-06-08 21:04:19.540803-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13066, 1095, B'0', 25, '2026-06-08 21:04:19.541138-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13067, 1058, B'0', 25, '2026-06-08 21:04:19.541434-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13068, 1083, B'0', 25, '2026-06-08 21:04:19.541742-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13069, 1087, B'0', 25, '2026-06-08 21:04:19.542026-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13070, 829, B'0', 25, '2026-06-08 21:04:19.542339-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13071, 1008, B'0', 25, '2026-06-08 21:04:19.542641-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13072, 860, B'0', 25, '2026-06-08 21:04:19.542928-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13073, 919, B'0', 25, '2026-06-08 21:04:19.543298-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13074, 816, B'0', 25, '2026-06-08 21:04:19.543647-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13075, 1024, B'0', 25, '2026-06-08 21:04:19.54395-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13076, 956, B'0', 25, '2026-06-08 21:04:19.544337-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13077, 922, B'0', 25, '2026-06-08 21:04:19.544842-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13078, 923, B'0', 25, '2026-06-08 21:04:19.545153-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13079, 965, B'0', 25, '2026-06-08 21:04:19.545467-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(13080, 1016, B'0', 25, '2026-06-08 21:04:19.545837-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13081, 1003, B'0', 25, '2026-06-08 21:04:19.546201-06', 3, 51, 0.50777, '32', 0.200, 0.784),
	(13082, 891, B'0', 25, '2026-06-08 21:04:19.546576-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(13083, 977, B'0', 25, '2026-06-08 21:04:19.546877-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13084, 1216, B'0', 25, '2026-06-08 21:04:19.547275-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13085, 1034, B'0', 25, '2026-06-08 21:04:19.547651-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13086, 1021, B'0', 25, '2026-06-08 21:04:19.548019-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13087, 905, B'0', 25, '2026-06-08 21:04:19.548352-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13088, 1018, B'0', 25, '2026-06-08 21:04:19.548693-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13089, 1036, B'0', 25, '2026-06-08 21:04:19.549077-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13090, 884, B'0', 25, '2026-06-08 21:04:19.549451-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13091, 1223, B'0', 25, '2026-06-08 21:04:19.549798-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(13092, 871, B'0', 25, '2026-06-08 21:04:19.550161-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13093, 914, B'0', 25, '2026-06-08 21:04:19.550488-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13094, 1043, B'0', 25, '2026-06-08 21:04:19.55078-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13095, 866, B'0', 25, '2026-06-08 21:04:19.551125-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13096, 1054, B'0', 25, '2026-06-08 21:04:19.551447-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13097, 971, B'0', 25, '2026-06-08 21:04:19.551871-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13098, 1001, B'0', 25, '2026-06-08 21:04:19.552192-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13099, 1002, B'0', 25, '2026-06-08 21:04:19.552516-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13100, 983, B'0', 25, '2026-06-08 21:04:19.552837-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13101, 894, B'0', 25, '2026-06-08 21:04:19.553135-06', 3, 51, 0.50777, '32', 0.200, 0.784),
	(13102, 981, B'0', 25, '2026-06-08 21:04:19.553444-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13103, 1012, B'0', 25, '2026-06-08 21:04:19.553746-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13104, 1022, B'0', 25, '2026-06-08 21:04:19.554034-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13105, 982, B'0', 25, '2026-06-08 21:04:19.554332-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13106, 836, B'0', 25, '2026-06-08 21:04:19.554833-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13107, 993, B'0', 25, '2026-06-08 21:04:19.55537-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13108, 1102, B'0', 25, '2026-06-08 21:04:19.556326-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13109, 1040, B'0', 25, '2026-06-08 21:04:19.556632-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13110, 815, B'0', 25, '2026-06-08 21:04:19.556984-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13111, 1042, B'0', 25, '2026-06-08 21:04:19.557449-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13112, 1039, B'0', 25, '2026-06-08 21:04:19.557736-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13113, 974, B'0', 25, '2026-06-08 21:04:19.558031-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13114, 906, B'0', 25, '2026-06-08 21:04:19.558327-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(13115, 1011, B'0', 25, '2026-06-08 21:04:19.558679-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13116, 913, B'0', 25, '2026-06-08 21:04:19.559008-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(13117, 943, B'0', 25, '2026-06-08 21:04:19.559302-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13118, 902, B'0', 25, '2026-06-08 21:04:19.559618-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13119, 898, B'0', 25, '2026-06-08 21:04:19.559912-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(13120, 998, B'0', 25, '2026-06-08 21:04:19.560198-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13121, 975, B'0', 25, '2026-06-08 21:04:19.56052-06', 3, 51, 0.50777, '32', 0.200, 0.784),
	(13122, 944, B'0', 25, '2026-06-08 21:04:19.56083-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13123, 1190, B'0', 25, '2026-06-08 21:04:19.561136-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13124, 1227, B'0', 25, '2026-06-08 21:04:19.56158-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13125, 1224, B'0', 25, '2026-06-08 21:04:19.56192-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13126, 1015, B'0', 25, '2026-06-08 21:04:19.56225-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13127, 880, B'0', 25, '2026-06-08 21:04:19.562604-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13128, 938, B'0', 25, '2026-06-08 21:04:19.562956-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(13129, 918, B'0', 25, '2026-06-08 21:04:19.563278-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13130, 1029, B'0', 25, '2026-06-08 21:04:19.563566-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13131, 912, B'0', 25, '2026-06-08 21:04:19.56385-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(13132, 937, B'0', 25, '2026-06-08 21:04:19.564134-06', 3, 51, 0.50777, '32', 0.200, 0.784),
	(13133, 882, B'0', 25, '2026-06-08 21:04:19.564458-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13134, 867, B'0', 25, '2026-06-08 21:04:19.564762-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13135, 886, B'0', 25, '2026-06-08 21:04:19.565065-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13136, 961, B'0', 25, '2026-06-08 21:04:19.565515-06', 3, 51, 0.50777, '32', 0.200, 0.784),
	(13137, 1127, B'0', 25, '2026-06-08 21:04:19.565831-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13138, 1139, B'0', 25, '2026-06-08 21:04:19.566203-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13139, 1009, B'0', 25, '2026-06-08 21:04:19.566564-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13140, 936, B'0', 25, '2026-06-08 21:04:19.566951-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13141, 957, B'0', 25, '2026-06-08 21:04:19.567355-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13142, 893, B'0', 25, '2026-06-08 21:04:19.56778-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13143, 904, B'0', 25, '2026-06-08 21:04:19.568239-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13144, 840, B'0', 25, '2026-06-08 21:04:19.568755-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13145, 825, B'0', 25, '2026-06-08 21:04:19.569102-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13146, 1129, B'0', 25, '2026-06-08 21:04:19.569486-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13147, 1128, B'0', 25, '2026-06-08 21:04:19.569854-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13148, 1114, B'0', 25, '2026-06-08 21:04:19.570267-06', 3, 51, 0.50777, '32', 0.200, 0.784),
	(13149, 865, B'0', 25, '2026-06-08 21:04:19.570664-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13150, 1086, B'0', 25, '2026-06-08 21:04:19.570989-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13151, 1094, B'0', 25, '2026-06-08 21:04:19.571316-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13152, 1080, B'0', 25, '2026-06-08 21:04:19.571614-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13153, 1089, B'0', 25, '2026-06-08 21:04:19.571897-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13154, 828, B'0', 25, '2026-06-08 21:04:19.572182-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13155, 1033, B'0', 25, '2026-06-08 21:04:19.572538-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13156, 1030, B'0', 25, '2026-06-08 21:04:19.572859-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13157, 995, B'0', 25, '2026-06-08 21:04:19.57316-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13158, 824, B'0', 25, '2026-06-08 21:04:19.573479-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13159, 851, B'0', 25, '2026-06-08 21:04:19.573768-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13160, 1035, B'0', 25, '2026-06-08 21:04:19.574068-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13161, 1078, B'0', 25, '2026-06-08 21:04:19.574409-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13162, 1079, B'0', 25, '2026-06-08 21:04:19.574748-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13163, 1044, B'0', 25, '2026-06-08 21:04:19.575102-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13164, 916, B'0', 25, '2026-06-08 21:04:19.575434-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13165, 1014, B'0', 25, '2026-06-08 21:04:19.575749-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(13166, 818, B'0', 25, '2026-06-08 21:04:19.576048-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13167, 935, B'0', 25, '2026-06-08 21:04:19.576339-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13168, 953, B'0', 25, '2026-06-08 21:04:19.576681-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(13169, 1132, B'0', 25, '2026-06-08 21:04:19.577073-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(13170, 1210, B'0', 25, '2026-06-08 21:04:19.577616-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(13171, 928, B'0', 25, '2026-06-08 21:04:19.577997-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13172, 887, B'0', 25, '2026-06-08 21:04:19.5783-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13173, 915, B'0', 25, '2026-06-08 21:04:19.578649-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13174, 1085, B'0', 25, '2026-06-08 21:04:19.579017-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13175, 834, B'0', 25, '2026-06-08 21:04:19.579312-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13176, 1096, B'0', 25, '2026-06-08 21:04:19.579611-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13177, 968, B'0', 25, '2026-06-08 21:04:19.579897-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(13178, 969, B'0', 25, '2026-06-08 21:04:19.580244-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13179, 855, B'0', 25, '2026-06-08 21:04:19.580536-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13180, 1090, B'0', 25, '2026-06-08 21:04:19.58088-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13181, 1069, B'0', 25, '2026-06-08 21:04:19.581167-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13182, 910, B'0', 25, '2026-06-08 21:04:19.581456-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(13183, 1020, B'0', 25, '2026-06-08 21:04:19.581914-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13184, 1151, B'0', 25, '2026-06-08 21:04:19.582399-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13185, 997, B'0', 25, '2026-06-08 21:04:19.58275-06', 2, 51, 0.50777, '32', 0.200, 0.784),
	(13186, 1165, B'0', 25, '2026-06-08 21:04:19.583071-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13187, 1161, B'0', 25, '2026-06-08 21:04:19.583432-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13188, 889, B'0', 25, '2026-06-08 21:04:19.58379-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13189, 1025, B'0', 25, '2026-06-08 21:04:19.58411-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13190, 1000, B'0', 25, '2026-06-08 21:04:19.584451-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13191, 1023, B'0', 25, '2026-06-08 21:04:19.584761-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13192, 850, B'0', 25, '2026-06-08 21:04:19.585127-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13193, 948, B'0', 25, '2026-06-08 21:04:19.585414-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13194, 1149, B'0', 25, '2026-06-08 21:04:19.585752-06', 1, 51, 0.50777, '32', 0.200, 0.784),
	(13195, 1055, B'0', 25, '2026-06-08 21:04:19.586269-06', 0, 51, 0.50777, '32', 0.200, 0.784),
	(13196, 885, B'0', 25, '2026-06-08 21:04:19.586716-06', 0, 51, 0.50777, '32', 0.200, 0.784);


--
-- Data for Name: playlists; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.playlists OVERRIDING SYSTEM VALUE VALUES
	(2, 'Prueba', NULL, '2026-03-04 21:49:46.413684-06', B'1', B'0'),
	(1, 'Favoritos', 25, '2026-02-22 18:57:37.569194-06', B'1', B'1');


--
-- Data for Name: predicciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.predicciones OVERRIDING SYSTEM VALUE VALUES
	(13063, 1150, 25, '2026-06-08 21:04:40.569252-06', 0.37842, 0, 87.386, 12832),
	(13064, 857, 25, '2026-06-08 21:04:40.569252-06', 1.55926, 0, 48.025, 12833),
	(13065, 832, 25, '2026-06-08 21:04:40.569252-06', 0.07501, 0, 97.500, 12834),
	(13066, 947, 25, '2026-06-08 21:04:40.569252-06', 0.88860, 1, 96.287, 12835),
	(13067, 848, 25, '2026-06-08 21:04:40.569252-06', 0.23991, 0, 92.003, 12836),
	(13068, 858, 25, '2026-06-08 21:04:40.569252-06', 0.72461, 0, 75.846, 12837),
	(13069, 1098, 25, '2026-06-08 21:04:40.569252-06', 0.16670, 0, 94.443, 12838),
	(13070, 984, 25, '2026-06-08 21:04:40.569252-06', 0.29987, 1, 76.662, 12839),
	(13071, 1041, 25, '2026-06-08 21:04:40.569252-06', 1.87485, 2, 95.828, 12840),
	(13072, 991, 25, '2026-06-08 21:04:40.569252-06', 0.44298, 1, 81.433, 12841),
	(13073, 874, 25, '2026-06-08 21:04:40.569252-06', 0.93723, 0, 68.759, 12842),
	(13074, 988, 25, '2026-06-08 21:04:40.569252-06', 2.91918, 3, 97.306, 12843),
	(13075, 840, 25, '2026-06-08 21:04:40.569252-06', 1.65997, 0, 44.668, 13144),
	(13076, 997, 25, '2026-06-08 21:04:40.569252-06', 1.53621, 2, 84.540, 13185),
	(13077, 838, 25, '2026-06-08 21:04:40.569252-06', 0.52451, 0, 82.516, 12844),
	(13078, 864, 25, '2026-06-08 21:04:40.569252-06', 0.71559, 0, 76.147, 12845),
	(13079, 839, 25, '2026-06-08 21:04:40.569252-06', 0.32416, 0, 89.195, 12846),
	(13080, 1122, 25, '2026-06-08 21:04:40.569252-06', 0.53943, 0, 82.019, 12847),
	(13081, 1093, 25, '2026-06-08 21:04:40.569252-06', 0.32556, 0, 89.148, 12848),
	(13082, 872, 25, '2026-06-08 21:04:40.569252-06', 0.38336, 0, 87.221, 12849),
	(13083, 941, 25, '2026-06-08 21:04:40.569252-06', 0.99650, 1, 99.883, 12850),
	(13084, 869, 25, '2026-06-08 21:04:40.569252-06', 0.23820, 0, 92.060, 12851),
	(13085, 897, 25, '2026-06-08 21:04:40.569252-06', 1.85975, 2, 95.325, 12852),
	(13086, 970, 25, '2026-06-08 21:04:40.569252-06', 1.71103, 2, 90.368, 12853),
	(13087, 1091, 25, '2026-06-08 21:04:40.569252-06', 0.25092, 0, 91.636, 12854),
	(13088, 1092, 25, '2026-06-08 21:04:40.569252-06', 0.36774, 0, 87.742, 12855),
	(13089, 1187, 25, '2026-06-08 21:04:40.569252-06', 0.32343, 0, 89.219, 12856),
	(13090, 1107, 25, '2026-06-08 21:04:40.569252-06', 0.30097, 0, 89.968, 12857),
	(13091, 1108, 25, '2026-06-08 21:04:40.569252-06', 0.02398, 0, 99.201, 12858),
	(13092, 895, 25, '2026-06-08 21:04:40.569252-06', 1.15979, 1, 94.674, 12859),
	(13093, 901, 25, '2026-06-08 21:04:40.569252-06', 1.66023, 2, 88.674, 12860),
	(13094, 946, 25, '2026-06-08 21:04:40.569252-06', 0.93289, 1, 97.763, 12861),
	(13095, 1106, 25, '2026-06-08 21:04:40.569252-06', 0.48382, 0, 83.873, 12862),
	(13096, 985, 25, '2026-06-08 21:04:40.569252-06', 0.54023, 1, 84.674, 12863),
	(13097, 842, 25, '2026-06-08 21:04:40.569252-06', 0.94627, 0, 68.458, 12864),
	(13098, 817, 25, '2026-06-08 21:04:40.569252-06', 0.59359, 0, 80.214, 12865),
	(13099, 1112, 25, '2026-06-08 21:04:40.569252-06', 0.51894, 0, 82.702, 12866),
	(13100, 1160, 25, '2026-06-08 21:04:40.569252-06', 0.06235, 0, 97.922, 12867),
	(13101, 830, 25, '2026-06-08 21:04:40.569252-06', 0.28927, 0, 90.358, 12868),
	(13102, 831, 25, '2026-06-08 21:04:40.569252-06', 1.00436, 0, 66.521, 12869),
	(13103, 873, 25, '2026-06-08 21:04:40.569252-06', 0.96979, 0, 67.674, 12870),
	(13104, 1048, 25, '2026-06-08 21:04:40.569252-06', 0.14318, 0, 95.227, 12871),
	(13105, 931, 25, '2026-06-08 21:04:40.569252-06', 1.09127, 1, 96.958, 12872),
	(13106, 1209, 25, '2026-06-08 21:04:40.569252-06', 1.38747, 0, 53.751, 12873),
	(13107, 888, 25, '2026-06-08 21:04:40.569252-06', 0.31204, 0, 89.599, 12874),
	(13108, 917, 25, '2026-06-08 21:04:40.569252-06', 0.49127, 1, 83.042, 12875),
	(13109, 1028, 25, '2026-06-08 21:04:40.569252-06', 1.64963, 1, 78.346, 12876),
	(13110, 1005, 25, '2026-06-08 21:04:40.569252-06', 2.91791, 3, 97.264, 12877),
	(13111, 862, 25, '2026-06-08 21:04:40.569252-06', 0.21156, 0, 92.948, 12878),
	(13112, 927, 25, '2026-06-08 21:04:40.569252-06', 1.66785, 2, 88.928, 12879),
	(13113, 1027, 25, '2026-06-08 21:04:40.569252-06', 1.30702, 1, 89.766, 12880),
	(13114, 962, 25, '2026-06-08 21:04:40.569252-06', 1.03898, 1, 98.701, 12881),
	(13115, 958, 25, '2026-06-08 21:04:40.569252-06', 0.64839, 1, 88.280, 12882),
	(13116, 876, 25, '2026-06-08 21:04:40.569252-06', 0.65171, 0, 78.276, 12883),
	(13117, 1131, 25, '2026-06-08 21:04:40.569252-06', 0.33403, 0, 88.866, 12884),
	(13118, 1074, 25, '2026-06-08 21:04:40.569252-06', 0.85076, 0, 71.641, 12885),
	(13119, 1026, 25, '2026-06-08 21:04:40.569252-06', 1.59338, 2, 86.446, 12886),
	(13120, 1071, 25, '2026-06-08 21:04:40.569252-06', 0.89153, 1, 96.384, 12887),
	(13121, 966, 25, '2026-06-08 21:04:40.569252-06', 1.37386, 1, 87.538, 12888),
	(13122, 856, 25, '2026-06-08 21:04:40.569252-06', 0.87395, 0, 70.868, 12889),
	(13123, 1101, 25, '2026-06-08 21:04:40.569252-06', 0.54460, 0, 81.847, 12890),
	(13124, 870, 25, '2026-06-08 21:04:40.569252-06', 1.28472, 0, 57.176, 12891),
	(13125, 846, 25, '2026-06-08 21:04:40.569252-06', 0.57707, 0, 80.764, 12892),
	(13126, 854, 25, '2026-06-08 21:04:40.569252-06', 0.55252, 0, 81.583, 12893),
	(13127, 924, 25, '2026-06-08 21:04:40.569252-06', 1.78177, 2, 92.726, 12894),
	(13128, 1100, 25, '2026-06-08 21:04:40.569252-06', 0.69684, 0, 76.772, 12895),
	(13129, 1105, 25, '2026-06-08 21:04:40.569252-06', 0.23858, 0, 92.047, 12896),
	(13130, 1175, 25, '2026-06-08 21:04:40.569252-06', 1.13611, 0, 62.130, 12897),
	(13131, 1166, 25, '2026-06-08 21:04:40.569252-06', 1.23733, 1, 92.089, 12898),
	(13132, 1017, 25, '2026-06-08 21:04:40.569252-06', 1.24007, 2, 74.669, 12899),
	(13133, 835, 25, '2026-06-08 21:04:40.569252-06', 1.46126, 2, 82.042, 12900),
	(13134, 929, 25, '2026-06-08 21:04:40.569252-06', 0.76881, 1, 92.294, 12901),
	(13135, 1065, 25, '2026-06-08 21:04:40.569252-06', 0.52004, 0, 82.665, 12902),
	(13136, 1031, 25, '2026-06-08 21:04:40.569252-06', 0.60666, 1, 86.889, 12903),
	(13137, 833, 25, '2026-06-08 21:04:40.569252-06', 0.42125, 0, 85.958, 12904),
	(13138, 1004, 25, '2026-06-08 21:04:40.569252-06', 1.04509, 1, 98.497, 12905),
	(13139, 1077, 25, '2026-06-08 21:04:40.569252-06', 2.13529, 0, 28.824, 12906),
	(13140, 814, 25, '2026-06-08 21:04:40.569252-06', 1.55782, 0, 48.073, 12907),
	(13141, 1191, 25, '2026-06-08 21:04:40.569252-06', 0.51126, 0, 82.958, 12908),
	(13142, 1199, 25, '2026-06-08 21:04:40.569252-06', 1.34503, 0, 55.166, 12909),
	(13143, 979, 25, '2026-06-08 21:04:40.569252-06', 2.90474, 3, 96.825, 12910),
	(13144, 1032, 25, '2026-06-08 21:04:40.569252-06', 1.27594, 2, 75.865, 12911),
	(13145, 1158, 25, '2026-06-08 21:04:40.569252-06', 0.14600, 0, 95.133, 12912),
	(13146, 1197, 25, '2026-06-08 21:04:40.569252-06', 1.24703, 0, 58.432, 12913),
	(13147, 1214, 25, '2026-06-08 21:04:40.569252-06', 0.49610, 0, 83.463, 12914),
	(13148, 1099, 25, '2026-06-08 21:04:40.569252-06', 0.37007, 0, 87.664, 12915),
	(13149, 996, 25, '2026-06-08 21:04:40.569252-06', 1.63201, 1, 78.933, 12916),
	(13150, 822, 25, '2026-06-08 21:04:40.569252-06', 0.38119, 0, 87.294, 12917),
	(13151, 1118, 25, '2026-06-08 21:04:40.569252-06', 1.14387, 0, 61.871, 12918),
	(13152, 1121, 25, '2026-06-08 21:04:40.569252-06', 0.70386, 2, 56.795, 12919),
	(13153, 1141, 25, '2026-06-08 21:04:40.569252-06', 0.91468, 0, 69.511, 12920),
	(13154, 1156, 25, '2026-06-08 21:04:40.569252-06', 0.25608, 0, 91.464, 12921),
	(13155, 1115, 25, '2026-06-08 21:04:40.569252-06', 0.89367, 0, 70.211, 12922),
	(13156, 972, 25, '2026-06-08 21:04:40.569252-06', 1.57482, 1, 80.839, 12923),
	(13157, 821, 25, '2026-06-08 21:04:40.569252-06', 1.03863, 0, 65.379, 12924),
	(13158, 896, 25, '2026-06-08 21:04:40.569252-06', 1.45533, 1, 84.822, 12925),
	(13159, 1097, 25, '2026-06-08 21:04:40.569252-06', 0.97262, 0, 67.579, 12926),
	(13160, 877, 25, '2026-06-08 21:04:40.569252-06', 0.53130, 0, 82.290, 12927),
	(13161, 1063, 25, '2026-06-08 21:04:40.569252-06', 0.38680, 0, 87.107, 12928),
	(13162, 1064, 25, '2026-06-08 21:04:40.569252-06', 0.03301, 0, 98.900, 12929),
	(13163, 903, 25, '2026-06-08 21:04:40.569252-06', 2.88692, 3, 96.231, 12930),
	(13164, 875, 25, '2026-06-08 21:04:40.569252-06', 0.91977, 0, 69.341, 12931),
	(13165, 879, 25, '2026-06-08 21:04:40.569252-06', 0.68266, 0, 77.245, 12932),
	(13166, 932, 25, '2026-06-08 21:04:40.569252-06', 1.86930, 2, 95.643, 12933),
	(13167, 1146, 25, '2026-06-08 21:04:40.569252-06', 1.07000, 1, 97.667, 12934),
	(13168, 930, 25, '2026-06-08 21:04:40.569252-06', 1.74310, 1, 75.230, 12935),
	(13169, 989, 25, '2026-06-08 21:04:40.569252-06', 1.04591, 1, 98.470, 12936),
	(13170, 1046, 25, '2026-06-08 21:04:40.569252-06', 0.18062, 0, 93.979, 12937),
	(13171, 1056, 25, '2026-06-08 21:04:40.569252-06', 0.67199, 1, 89.066, 12938),
	(13172, 1057, 25, '2026-06-08 21:04:40.569252-06', 0.23981, 0, 92.006, 12939),
	(13173, 999, 25, '2026-06-08 21:04:40.569252-06', 0.50970, 1, 83.657, 12940),
	(13174, 878, 25, '2026-06-08 21:04:40.569252-06', 0.17551, 0, 94.150, 12941),
	(13175, 853, 25, '2026-06-08 21:04:40.569252-06', 1.91250, 0, 36.250, 12942),
	(13176, 1119, 25, '2026-06-08 21:04:40.569252-06', 0.11890, 0, 96.037, 12943),
	(13177, 1155, 25, '2026-06-08 21:04:40.569252-06', 2.34281, 0, 21.906, 12944),
	(13178, 1145, 25, '2026-06-08 21:04:40.569252-06', 1.48452, 0, 50.516, 12945),
	(13179, 1152, 25, '2026-06-08 21:04:40.569252-06', 1.96913, 2, 98.971, 12946),
	(13180, 1067, 25, '2026-06-08 21:04:40.569252-06', 0.31415, 0, 89.528, 12947),
	(13181, 861, 25, '2026-06-08 21:04:40.569252-06', 0.38679, 0, 87.107, 12948),
	(13182, 1062, 25, '2026-06-08 21:04:40.569252-06', 0.23171, 0, 92.276, 12949),
	(13183, 940, 25, '2026-06-08 21:04:40.569252-06', 1.32702, 1, 89.099, 12950),
	(13184, 939, 25, '2026-06-08 21:04:40.569252-06', 1.27042, 1, 90.986, 12951),
	(13185, 909, 25, '2026-06-08 21:04:40.569252-06', 1.91551, 2, 97.184, 12952),
	(13186, 964, 25, '2026-06-08 21:04:40.569252-06', 2.92978, 3, 97.659, 12953),
	(13187, 890, 25, '2026-06-08 21:04:40.569252-06', 1.59062, 2, 86.354, 12954),
	(13188, 987, 25, '2026-06-08 21:04:40.569252-06', 1.74792, 2, 91.597, 12955),
	(13189, 945, 25, '2026-06-08 21:04:40.569252-06', 1.74667, 2, 91.556, 12956),
	(13190, 1173, 25, '2026-06-08 21:04:40.569252-06', 0.10599, 0, 96.467, 12957),
	(13191, 1163, 25, '2026-06-08 21:04:40.569252-06', 0.72709, 0, 75.764, 12958),
	(13192, 1181, 25, '2026-06-08 21:04:40.569252-06', 0.87994, 0, 70.669, 12959),
	(13193, 899, 25, '2026-06-08 21:04:40.569252-06', 1.74910, 2, 91.637, 12960),
	(13194, 934, 25, '2026-06-08 21:04:40.569252-06', 1.89108, 2, 96.369, 12961),
	(13195, 1125, 25, '2026-06-08 21:04:40.569252-06', 0.67091, 0, 77.636, 12962),
	(13196, 1059, 25, '2026-06-08 21:04:40.569252-06', 0.22825, 0, 92.392, 12963),
	(13197, 1076, 25, '2026-06-08 21:04:40.569252-06', 0.46717, 0, 84.428, 12964),
	(13198, 1111, 25, '2026-06-08 21:04:40.569252-06', 1.73888, 0, 42.037, 12965),
	(13199, 1038, 25, '2026-06-08 21:04:40.569252-06', 2.90132, 3, 96.711, 12966),
	(13200, 1144, 25, '2026-06-08 21:04:40.569252-06', 0.27470, 0, 90.843, 12967),
	(13201, 1154, 25, '2026-06-08 21:04:40.569252-06', 0.46577, 0, 84.474, 12968),
	(13202, 1169, 25, '2026-06-08 21:04:40.569252-06', 0.30747, 0, 89.751, 12969),
	(13203, 1072, 25, '2026-06-08 21:04:40.569252-06', 0.65206, 0, 78.265, 12970),
	(13204, 820, 25, '2026-06-08 21:04:40.569252-06', 0.24587, 0, 91.804, 12971),
	(13205, 1047, 25, '2026-06-08 21:04:40.569252-06', 0.17200, 0, 94.267, 12972),
	(13206, 1110, 25, '2026-06-08 21:04:40.569252-06', 0.44886, 0, 85.038, 12973),
	(13207, 954, 25, '2026-06-08 21:04:40.569252-06', 1.53655, 2, 84.552, 12974),
	(13208, 955, 25, '2026-06-08 21:04:40.569252-06', 1.04346, 1, 98.551, 12975),
	(13209, 863, 25, '2026-06-08 21:04:40.569252-06', 1.86591, 0, 37.803, 12976),
	(13210, 1185, 25, '2026-06-08 21:04:40.569252-06', 0.46337, 0, 84.554, 12977),
	(13211, 1045, 25, '2026-06-08 21:04:40.569252-06', 0.23924, 0, 92.025, 12978),
	(13212, 1134, 25, '2026-06-08 21:04:40.569252-06', 0.84727, 0, 71.758, 12979),
	(13213, 1170, 25, '2026-06-08 21:04:40.569252-06', 1.02863, 0, 65.712, 12980),
	(13214, 963, 25, '2026-06-08 21:04:40.569252-06', 1.62141, 1, 79.286, 12981),
	(13215, 925, 25, '2026-06-08 21:04:40.569252-06', 1.37862, 1, 87.379, 12982),
	(13216, 1068, 25, '2026-06-08 21:04:40.569252-06', 0.09751, 0, 96.750, 12983),
	(13217, 1070, 25, '2026-06-08 21:04:40.569252-06', 0.39173, 0, 86.942, 12984),
	(13218, 959, 25, '2026-06-08 21:04:40.569252-06', 2.92191, 3, 97.397, 12985),
	(13219, 823, 25, '2026-06-08 21:04:40.569252-06', 0.65247, 0, 78.251, 12986),
	(13220, 992, 25, '2026-06-08 21:04:40.569252-06', 1.34310, 1, 88.563, 12987),
	(13221, 841, 25, '2026-06-08 21:04:40.569252-06', 0.22620, 0, 92.460, 12988),
	(13222, 1084, 25, '2026-06-08 21:04:40.569252-06', 0.62296, 1, 87.432, 12989),
	(13223, 1113, 25, '2026-06-08 21:04:40.569252-06', 0.94025, 0, 68.658, 12990),
	(13224, 1010, 25, '2026-06-08 21:04:40.569252-06', 0.47833, 1, 82.611, 12991),
	(13225, 1120, 25, '2026-06-08 21:04:40.569252-06', 0.95958, 0, 68.014, 12992),
	(13226, 1073, 25, '2026-06-08 21:04:40.569252-06', 0.92265, 0, 69.245, 12993),
	(13227, 1126, 25, '2026-06-08 21:04:40.569252-06', 1.69579, 0, 43.474, 12994),
	(13228, 1204, 25, '2026-06-08 21:04:40.569252-06', 0.56948, 0, 81.017, 12995),
	(13229, 1200, 25, '2026-06-08 21:04:40.569252-06', 0.47718, 0, 84.094, 12996),
	(13230, 1193, 25, '2026-06-08 21:04:40.569252-06', 1.22385, 0, 59.205, 12997),
	(13231, 1218, 25, '2026-06-08 21:04:40.569252-06', 1.91666, 0, 36.111, 12998),
	(13232, 1203, 25, '2026-06-08 21:04:40.569252-06', 0.82151, 0, 72.616, 12999),
	(13233, 951, 25, '2026-06-08 21:04:40.569252-06', 1.46678, 2, 82.226, 13000),
	(13234, 1205, 25, '2026-06-08 21:04:40.569252-06', 2.29980, 1, 56.673, 13001),
	(13235, 1088, 25, '2026-06-08 21:04:40.569252-06', 0.13561, 0, 95.480, 13002),
	(13236, 1019, 25, '2026-06-08 21:04:40.569252-06', 1.67124, 2, 89.041, 13003),
	(13237, 942, 25, '2026-06-08 21:04:40.569252-06', 1.08147, 1, 97.284, 13004),
	(13238, 921, 25, '2026-06-08 21:04:40.569252-06', 1.12079, 1, 95.974, 13005),
	(13239, 1143, 25, '2026-06-08 21:04:40.569252-06', 0.56460, 0, 81.180, 13006),
	(13240, 1217, 25, '2026-06-08 21:04:40.569252-06', 0.31047, 0, 89.651, 13007),
	(13241, 1081, 25, '2026-06-08 21:04:40.569252-06', 1.58084, 0, 47.305, 13008),
	(13242, 1082, 25, '2026-06-08 21:04:40.569252-06', 1.70584, 2, 90.195, 13009),
	(13243, 837, 25, '2026-06-08 21:04:40.569252-06', 0.46264, 1, 82.088, 13010),
	(13244, 926, 25, '2026-06-08 21:04:40.569252-06', 1.83043, 2, 94.348, 13011),
	(13245, 1049, 25, '2026-06-08 21:04:40.569252-06', 0.36916, 0, 87.695, 13012),
	(13246, 1050, 25, '2026-06-08 21:04:40.569252-06', 0.33279, 0, 88.907, 13013),
	(13247, 1123, 25, '2026-06-08 21:04:40.569252-06', 0.82958, 0, 72.347, 13014),
	(13248, 933, 25, '2026-06-08 21:04:40.569252-06', 1.17212, 1, 94.263, 13015),
	(13249, 826, 25, '2026-06-08 21:04:40.569252-06', 0.46850, 0, 84.383, 13016),
	(13250, 911, 25, '2026-06-08 21:04:40.569252-06', 2.92757, 3, 97.586, 13017),
	(13251, 1051, 25, '2026-06-08 21:04:40.569252-06', 0.76200, 1, 92.067, 13018),
	(13252, 1052, 25, '2026-06-08 21:04:40.569252-06', 1.06255, 0, 64.582, 13019),
	(13253, 1053, 25, '2026-06-08 21:04:40.569252-06', 0.08966, 0, 97.011, 13020),
	(13254, 1075, 25, '2026-06-08 21:04:40.569252-06', 1.24461, 0, 58.513, 13021),
	(13255, 920, 25, '2026-06-08 21:04:40.569252-06', 1.48521, 2, 82.840, 13022),
	(13256, 960, 25, '2026-06-08 21:04:40.569252-06', 2.96484, 3, 98.828, 13023),
	(13257, 952, 25, '2026-06-08 21:04:40.569252-06', 0.74929, 1, 91.643, 13024),
	(13258, 949, 25, '2026-06-08 21:04:40.569252-06', 1.69331, 2, 89.777, 13025),
	(13259, 847, 25, '2026-06-08 21:04:40.569252-06', 0.38024, 0, 87.325, 13026),
	(13260, 852, 25, '2026-06-08 21:04:40.569252-06', 0.54231, 0, 81.923, 13027),
	(13261, 1178, 25, '2026-06-08 21:04:40.569252-06', 0.31073, 0, 89.642, 13028),
	(13262, 843, 25, '2026-06-08 21:04:40.569252-06', 0.45793, 0, 84.736, 13029),
	(13263, 892, 25, '2026-06-08 21:04:40.569252-06', 1.20736, 2, 73.579, 13030),
	(13264, 859, 25, '2026-06-08 21:04:40.569252-06', 1.51794, 1, 82.735, 13031),
	(13265, 1104, 25, '2026-06-08 21:04:40.569252-06', 0.46439, 1, 82.146, 13032),
	(13266, 881, 25, '2026-06-08 21:04:40.569252-06', 1.47730, 1, 84.090, 13033),
	(13267, 1060, 25, '2026-06-08 21:04:40.569252-06', 0.08723, 0, 97.092, 13034),
	(13268, 1061, 25, '2026-06-08 21:04:40.569252-06', 0.16629, 0, 94.457, 13035),
	(13269, 1103, 25, '2026-06-08 21:04:40.569252-06', 1.17643, 0, 60.786, 13036),
	(13270, 1013, 25, '2026-06-08 21:04:40.569252-06', 1.95241, 2, 98.414, 13037),
	(13271, 1109, 25, '2026-06-08 21:04:40.569252-06', 0.12192, 0, 95.936, 13038),
	(13272, 907, 25, '2026-06-08 21:04:40.569252-06', 1.90726, 2, 96.909, 13039),
	(13273, 900, 25, '2026-06-08 21:04:40.569252-06', 1.76688, 2, 92.229, 13040),
	(13274, 994, 25, '2026-06-08 21:04:40.569252-06', 1.58704, 1, 80.432, 13041),
	(13275, 950, 25, '2026-06-08 21:04:40.569252-06', 1.09971, 1, 96.676, 13042),
	(13276, 978, 25, '2026-06-08 21:04:40.569252-06', 0.68328, 1, 89.443, 13043),
	(13277, 986, 25, '2026-06-08 21:04:40.569252-06', 1.48912, 1, 83.696, 13044),
	(13278, 1006, 25, '2026-06-08 21:04:40.569252-06', 2.60000, 1, 46.667, 13045),
	(13279, 980, 25, '2026-06-08 21:04:40.569252-06', 0.51650, 1, 83.883, 13046),
	(13280, 976, 25, '2026-06-08 21:04:40.569252-06', 1.80072, 2, 93.357, 13047),
	(13281, 827, 25, '2026-06-08 21:04:40.569252-06', 0.63560, 0, 78.813, 13048),
	(13282, 1219, 25, '2026-06-08 21:04:40.569252-06', 1.18717, 0, 60.428, 13049),
	(13283, 967, 25, '2026-06-08 21:04:40.569252-06', 1.66442, 2, 88.814, 13050),
	(13284, 868, 25, '2026-06-08 21:04:40.569252-06', 0.33243, 0, 88.919, 13051),
	(13285, 1124, 25, '2026-06-08 21:04:40.569252-06', 0.43560, 0, 85.480, 13052),
	(13286, 1007, 25, '2026-06-08 21:04:40.569252-06', 1.61546, 1, 79.485, 13053),
	(13287, 819, 25, '2026-06-08 21:04:40.569252-06', 0.32160, 0, 89.280, 13054),
	(13288, 849, 25, '2026-06-08 21:04:40.569252-06', 0.72419, 0, 75.860, 13055),
	(13289, 1066, 25, '2026-06-08 21:04:40.569252-06', 0.52004, 0, 82.665, 13056),
	(13290, 973, 25, '2026-06-08 21:04:40.569252-06', 1.02839, 1, 99.054, 13057),
	(13291, 1162, 25, '2026-06-08 21:04:40.569252-06', 0.39318, 0, 86.894, 13058),
	(13292, 1164, 25, '2026-06-08 21:04:40.569252-06', 0.31437, 0, 89.521, 13059),
	(13293, 1037, 25, '2026-06-08 21:04:40.569252-06', 1.07016, 1, 97.661, 13060),
	(13294, 1016, 25, '2026-06-08 21:04:40.569252-06', 1.62473, 1, 79.176, 13080),
	(13295, 1136, 25, '2026-06-08 21:04:40.569252-06', 1.72908, 0, 42.364, 13061),
	(13296, 990, 25, '2026-06-08 21:04:40.569252-06', 2.95983, 3, 98.661, 13062),
	(13297, 1116, 25, '2026-06-08 21:04:40.569252-06', 0.63760, 0, 78.747, 13063),
	(13298, 1135, 25, '2026-06-08 21:04:40.569252-06', 0.95679, 0, 68.107, 13064),
	(13299, 1137, 25, '2026-06-08 21:04:40.569252-06', 0.84413, 0, 71.862, 13065),
	(13300, 1095, 25, '2026-06-08 21:04:40.569252-06', 0.46524, 0, 84.492, 13066),
	(13301, 1058, 25, '2026-06-08 21:04:40.569252-06', 0.07295, 0, 97.568, 13067),
	(13302, 1083, 25, '2026-06-08 21:04:40.569252-06', 0.28717, 0, 90.428, 13068),
	(13303, 1087, 25, '2026-06-08 21:04:40.569252-06', 0.06310, 0, 97.897, 13069),
	(13304, 829, 25, '2026-06-08 21:04:40.569252-06', 0.94690, 0, 68.437, 13070),
	(13305, 1008, 25, '2026-06-08 21:04:40.569252-06', 0.67859, 1, 89.286, 13071),
	(13306, 860, 25, '2026-06-08 21:04:40.569252-06', 0.35396, 0, 88.201, 13072),
	(13307, 919, 25, '2026-06-08 21:04:40.569252-06', 0.17055, 0, 94.315, 13073),
	(13308, 816, 25, '2026-06-08 21:04:40.569252-06', 0.25196, 0, 91.601, 13074),
	(13309, 1024, 25, '2026-06-08 21:04:40.569252-06', 1.80304, 1, 73.232, 13075),
	(13310, 956, 25, '2026-06-08 21:04:40.569252-06', 0.99256, 1, 99.752, 13076),
	(13311, 922, 25, '2026-06-08 21:04:40.569252-06', 1.15822, 1, 94.726, 13077),
	(13312, 923, 25, '2026-06-08 21:04:40.569252-06', 1.33355, 1, 88.882, 13078),
	(13313, 965, 25, '2026-06-08 21:04:40.569252-06', 1.58530, 2, 86.177, 13079),
	(13314, 1003, 25, '2026-06-08 21:04:40.569252-06', 2.94949, 3, 98.316, 13081),
	(13315, 891, 25, '2026-06-08 21:04:40.569252-06', 1.57992, 2, 85.997, 13082),
	(13316, 977, 25, '2026-06-08 21:04:40.569252-06', 0.59269, 1, 86.423, 13083),
	(13317, 1216, 25, '2026-06-08 21:04:40.569252-06', 0.45085, 0, 84.972, 13084),
	(13318, 1034, 25, '2026-06-08 21:04:40.569252-06', 1.04685, 1, 98.438, 13085),
	(13319, 1021, 25, '2026-06-08 21:04:40.569252-06', 1.49523, 1, 83.492, 13086),
	(13320, 905, 25, '2026-06-08 21:04:40.569252-06', 0.32187, 1, 77.396, 13087),
	(13321, 1018, 25, '2026-06-08 21:04:40.569252-06', 0.78862, 0, 73.713, 13088),
	(13322, 1036, 25, '2026-06-08 21:04:40.569252-06', 0.09107, 0, 96.964, 13089),
	(13323, 884, 25, '2026-06-08 21:04:40.569252-06', 0.66354, 0, 77.882, 13090),
	(13324, 1223, 25, '2026-06-08 21:04:40.569252-06', 1.49296, 2, 83.099, 13091),
	(13325, 871, 25, '2026-06-08 21:04:40.569252-06', 0.20037, 0, 93.321, 13092),
	(13326, 914, 25, '2026-06-08 21:04:40.569252-06', 1.44000, 1, 85.333, 13093),
	(13327, 1043, 25, '2026-06-08 21:04:40.569252-06', 1.09214, 1, 96.929, 13094),
	(13328, 866, 25, '2026-06-08 21:04:40.569252-06', 0.63805, 0, 78.732, 13095),
	(13329, 1054, 25, '2026-06-08 21:04:40.569252-06', 0.57400, 1, 85.800, 13096),
	(13330, 971, 25, '2026-06-08 21:04:40.569252-06', 1.64238, 1, 78.587, 13097),
	(13331, 1001, 25, '2026-06-08 21:04:40.569252-06', 1.12061, 1, 95.980, 13098),
	(13332, 1002, 25, '2026-06-08 21:04:40.569252-06', 1.65394, 1, 78.202, 13099),
	(13333, 983, 25, '2026-06-08 21:04:40.569252-06', 1.63032, 1, 78.989, 13100),
	(13334, 894, 25, '2026-06-08 21:04:40.569252-06', 2.89793, 3, 96.598, 13101),
	(13335, 981, 25, '2026-06-08 21:04:40.569252-06', 0.49011, 1, 83.004, 13102),
	(13336, 1012, 25, '2026-06-08 21:04:40.569252-06', 0.60385, 1, 86.795, 13103),
	(13337, 1022, 25, '2026-06-08 21:04:40.569252-06', 0.78267, 1, 92.756, 13104),
	(13338, 982, 25, '2026-06-08 21:04:40.569252-06', 0.39341, 1, 79.780, 13105),
	(13339, 836, 25, '2026-06-08 21:04:40.569252-06', 0.21536, 0, 92.821, 13106),
	(13340, 993, 25, '2026-06-08 21:04:40.569252-06', 1.49838, 1, 83.387, 13107),
	(13341, 1102, 25, '2026-06-08 21:04:40.569252-06', 0.50941, 0, 83.020, 13108),
	(13342, 1040, 25, '2026-06-08 21:04:40.569252-06', 1.64997, 1, 78.334, 13109),
	(13343, 815, 25, '2026-06-08 21:04:40.569252-06', 0.19610, 0, 93.463, 13110),
	(13344, 1042, 25, '2026-06-08 21:04:40.569252-06', 1.06463, 1, 97.846, 13111),
	(13345, 1039, 25, '2026-06-08 21:04:40.569252-06', 1.25676, 1, 91.441, 13112),
	(13346, 974, 25, '2026-06-08 21:04:40.569252-06', 1.05198, 1, 98.267, 13113),
	(13347, 906, 25, '2026-06-08 21:04:40.569252-06', 1.87666, 2, 95.889, 13114),
	(13348, 1011, 25, '2026-06-08 21:04:40.569252-06', 1.28774, 1, 90.409, 13115),
	(13349, 913, 25, '2026-06-08 21:04:40.569252-06', 1.89792, 2, 96.597, 13116),
	(13350, 943, 25, '2026-06-08 21:04:40.569252-06', 1.51706, 1, 82.765, 13117),
	(13351, 902, 25, '2026-06-08 21:04:40.569252-06', 1.67427, 1, 77.524, 13118),
	(13352, 898, 25, '2026-06-08 21:04:40.569252-06', 1.84939, 2, 94.980, 13119),
	(13353, 998, 25, '2026-06-08 21:04:40.569252-06', 1.39836, 1, 86.721, 13120),
	(13354, 975, 25, '2026-06-08 21:04:40.569252-06', 2.79313, 3, 93.104, 13121),
	(13355, 944, 25, '2026-06-08 21:04:40.569252-06', 1.68211, 1, 77.263, 13122),
	(13356, 1190, 25, '2026-06-08 21:04:40.569252-06', 0.16630, 0, 94.457, 13123),
	(13357, 1227, 25, '2026-06-08 21:04:40.569252-06', 0.48739, 0, 83.754, 13124),
	(13358, 1224, 25, '2026-06-08 21:04:40.569252-06', 0.84964, 0, 71.679, 13125),
	(13359, 1015, 25, '2026-06-08 21:04:40.569252-06', 1.58501, 1, 80.500, 13126),
	(13360, 880, 25, '2026-06-08 21:04:40.569252-06', 1.60059, 1, 79.980, 13127),
	(13361, 938, 25, '2026-06-08 21:04:40.569252-06', 1.86332, 2, 95.444, 13128),
	(13362, 918, 25, '2026-06-08 21:04:40.569252-06', 0.79098, 1, 93.033, 13129),
	(13363, 1029, 25, '2026-06-08 21:04:40.569252-06', 1.46053, 1, 84.649, 13130),
	(13364, 912, 25, '2026-06-08 21:04:40.569252-06', 1.79221, 2, 93.074, 13131),
	(13365, 937, 25, '2026-06-08 21:04:40.569252-06', 0.42680, 3, 14.227, 13132),
	(13366, 882, 25, '2026-06-08 21:04:40.569252-06', 0.57005, 0, 80.998, 13133),
	(13367, 867, 25, '2026-06-08 21:04:40.569252-06', 0.73766, 0, 75.411, 13134),
	(13368, 886, 25, '2026-06-08 21:04:40.569252-06', 0.77650, 0, 74.117, 13135),
	(13369, 961, 25, '2026-06-08 21:04:40.569252-06', 0.90548, 3, 30.183, 13136),
	(13370, 1127, 25, '2026-06-08 21:04:40.569252-06', 0.76148, 0, 74.617, 13137),
	(13371, 1139, 25, '2026-06-08 21:04:40.569252-06', 0.38503, 0, 87.166, 13138),
	(13372, 1009, 25, '2026-06-08 21:04:40.569252-06', 2.94505, 1, 35.165, 13139),
	(13373, 936, 25, '2026-06-08 21:04:40.569252-06', 0.86006, 1, 95.335, 13140),
	(13374, 957, 25, '2026-06-08 21:04:40.569252-06', 1.22234, 1, 92.589, 13141),
	(13375, 893, 25, '2026-06-08 21:04:40.569252-06', 0.58311, 1, 86.104, 13142),
	(13376, 904, 25, '2026-06-08 21:04:40.569252-06', 1.13351, 1, 95.550, 13143),
	(13377, 825, 25, '2026-06-08 21:04:40.569252-06', 1.71691, 0, 42.770, 13145),
	(13378, 1129, 25, '2026-06-08 21:04:40.569252-06', 1.67491, 0, 44.170, 13146),
	(13379, 1128, 25, '2026-06-08 21:04:40.569252-06', 1.71963, 0, 42.679, 13147),
	(13380, 1114, 25, '2026-06-08 21:04:40.569252-06', 1.53408, 3, 51.136, 13148),
	(13381, 865, 25, '2026-06-08 21:04:40.569252-06', 0.34434, 0, 88.522, 13149),
	(13382, 1086, 25, '2026-06-08 21:04:40.569252-06', 0.96336, 0, 67.888, 13150),
	(13383, 1094, 25, '2026-06-08 21:04:40.569252-06', 0.32556, 0, 89.148, 13151),
	(13384, 1080, 25, '2026-06-08 21:04:40.569252-06', 0.95489, 0, 68.170, 13152),
	(13385, 1089, 25, '2026-06-08 21:04:40.569252-06', 0.16519, 1, 72.173, 13153),
	(13386, 828, 25, '2026-06-08 21:04:40.569252-06', 0.73503, 0, 75.499, 13154),
	(13387, 1033, 25, '2026-06-08 21:04:40.569252-06', 2.00323, 1, 66.559, 13155),
	(13388, 1030, 25, '2026-06-08 21:04:40.569252-06', 1.86078, 1, 71.307, 13156),
	(13389, 995, 25, '2026-06-08 21:04:40.569252-06', 1.20809, 0, 59.730, 13157),
	(13390, 824, 25, '2026-06-08 21:04:40.569252-06', 0.17677, 0, 94.108, 13158),
	(13391, 851, 25, '2026-06-08 21:04:40.569252-06', 0.88840, 0, 70.387, 13159),
	(13392, 1035, 25, '2026-06-08 21:04:40.569252-06', 0.85753, 1, 95.251, 13160),
	(13393, 1078, 25, '2026-06-08 21:04:40.569252-06', 0.21714, 0, 92.762, 13161),
	(13394, 1079, 25, '2026-06-08 21:04:40.569252-06', 0.25854, 1, 75.285, 13162),
	(13395, 1044, 25, '2026-06-08 21:04:40.569252-06', 0.49823, 0, 83.392, 13163),
	(13396, 916, 25, '2026-06-08 21:04:40.569252-06', 0.24275, 1, 74.758, 13164),
	(13397, 1014, 25, '2026-06-08 21:04:40.569252-06', 2.99540, 2, 66.820, 13165),
	(13398, 818, 25, '2026-06-08 21:04:40.569252-06', 0.21999, 0, 92.667, 13166),
	(13399, 935, 25, '2026-06-08 21:04:40.569252-06', 0.57583, 1, 85.861, 13167),
	(13400, 953, 25, '2026-06-08 21:04:40.569252-06', 1.88014, 2, 96.005, 13168),
	(13401, 1132, 25, '2026-06-08 21:04:40.569252-06', 1.07941, 2, 69.314, 13169),
	(13402, 1210, 25, '2026-06-08 21:04:40.569252-06', 0.59668, 2, 53.223, 13170),
	(13403, 928, 25, '2026-06-08 21:04:40.569252-06', 2.68639, 1, 43.787, 13171),
	(13404, 887, 25, '2026-06-08 21:04:40.569252-06', 0.31204, 0, 89.599, 13172),
	(13405, 915, 25, '2026-06-08 21:04:40.569252-06', 1.03205, 1, 98.932, 13173),
	(13406, 1085, 25, '2026-06-08 21:04:40.569252-06', 0.12476, 0, 95.841, 13174),
	(13407, 834, 25, '2026-06-08 21:04:40.569252-06', 0.72420, 0, 75.860, 13175),
	(13408, 1096, 25, '2026-06-08 21:04:40.569252-06', 0.97262, 0, 67.579, 13176),
	(13409, 968, 25, '2026-06-08 21:04:40.569252-06', 1.56915, 2, 85.638, 13177),
	(13410, 969, 25, '2026-06-08 21:04:40.569252-06', 1.48943, 1, 83.686, 13178),
	(13411, 855, 25, '2026-06-08 21:04:40.569252-06', 0.51115, 0, 82.962, 13179),
	(13412, 1090, 25, '2026-06-08 21:04:40.569252-06', 0.45682, 0, 84.773, 13180),
	(13413, 1069, 25, '2026-06-08 21:04:40.569252-06', 0.34538, 0, 88.487, 13181),
	(13414, 910, 25, '2026-06-08 21:04:40.569252-06', 2.97603, 2, 67.466, 13182),
	(13415, 1020, 25, '2026-06-08 21:04:40.569252-06', 1.70102, 1, 76.633, 13183),
	(13416, 1151, 25, '2026-06-08 21:04:40.569252-06', 0.80923, 0, 73.026, 13184),
	(13417, 1165, 25, '2026-06-08 21:04:40.569252-06', 1.08318, 0, 63.894, 13186),
	(13418, 1161, 25, '2026-06-08 21:04:40.569252-06', 0.37029, 0, 87.657, 13187),
	(13419, 889, 25, '2026-06-08 21:04:40.569252-06', 1.40802, 1, 86.399, 13188),
	(13420, 1025, 25, '2026-06-08 21:04:40.569252-06', 0.86211, 1, 95.404, 13189),
	(13421, 1000, 25, '2026-06-08 21:04:40.569252-06', 1.00784, 1, 99.739, 13190),
	(13422, 1023, 25, '2026-06-08 21:04:40.569252-06', 2.33664, 1, 55.445, 13191),
	(13423, 850, 25, '2026-06-08 21:04:40.569252-06', 0.70810, 0, 76.397, 13192),
	(13424, 948, 25, '2026-06-08 21:04:40.569252-06', 0.54133, 1, 84.711, 13193),
	(13425, 1149, 25, '2026-06-08 21:04:40.569252-06', 0.70058, 1, 90.019, 13194),
	(13426, 1055, 25, '2026-06-08 21:04:40.569252-06', 2.61482, 0, 12.839, 13195),
	(13427, 885, 25, '2026-06-08 21:04:40.569252-06', 0.85624, 0, 71.459, 13196);


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
	(25, B'1', 365, 51, '2026-06-08 21:03:06.911301-06', 'model_global', 0.507773, 0.7836, 2, B'1', 0.00100000, 32, 4, 304, '{"type":"sequential","layers":[{"type":"dense","units":256,"activation":"relu","init":"heNormal"},{"type":"dropout","rate":0.2},{"type":"dense","units":128,"activation":"relu","init":"heNormal"},{"type":"dropout","rate":0.2},{"type":"dense","units":4,"activation":"softmax","note":"clasificación 4 clases"}]}');


--
-- Name: canciones_evaluadas_ce_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.canciones_evaluadas_ce_id_seq', 1230, true);


--
-- Name: entrenamientos_en_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.entrenamientos_en_id_seq', 13196, true);


--
-- Name: playlists_pl_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.playlists_pl_id_seq', 2, true);


--
-- Name: predicciones_pd_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.predicciones_pd_id_seq', 13427, true);


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

SELECT pg_catalog.setval('public.ts_modelos_ts_id_seq', 25, true);


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

