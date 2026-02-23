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
-- Name: calibracion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.calibracion (
    cl_id integer NOT NULL,
    cl_ca_id integer NOT NULL,
    cl_calif_usuario integer,
    cl_calif_predict integer,
    cl_estatus_calibracion integer DEFAULT 0 NOT NULL,
    cl_fecha_calibracion date
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
    pl_is_global bit(1) DEFAULT '0'::"bit" NOT NULL
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
-- Data for Name: calibracion; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: canciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.canciones OVERRIDING SYSTEM VALUE VALUES
	(600, 2, 6828754, '1736825389386_[Music] Livetune (feat Hatsune Miku)   Redia.mp3', 0, 1, true, '1736825389386_[Music] Livetune (feat Hatsune Miku)   Redia.mp3.json.gz', NULL, 0),
	(616, 1, 7850571, '1736825393644_【初音ミク】 children 【オリジナル曲】.mp3', 0, 1, true, '1736825393644_【初音ミク】 children 【オリジナル曲】.mp3.json.gz', NULL, 0),
	(612, 2, 5665155, '1736825392721_【ミク・MAYU・がくぽ】「Ib」 forever 【オリジナルPV】.mp3', 0, 1, true, '1736825392721_【ミク・MAYU・がくぽ】「Ib」 forever 【オリジナルPV】.mp3.json.gz', NULL, 0),
	(615, 1, 6389897, '1736825393366_【初音ミク】 Baby Steps 【オリジナル�.mp3', 0, 1, true, '1736825393366_【初音ミク】 Baby Steps 【オリジナル�.mp3.json.gz', NULL, 0),
	(677, 2, 6596786, '1736825410928_Hatsune Miku Original Song.mp3', 0, 1, true, '1736825410928_Hatsune Miku Original Song.mp3.json.gz', NULL, 0),
	(705, 3, 5994925, '1736825418138_TsunTsun  ftHatsune Miku_192kbps.mp3', 0, 1, true, '1736825418138_TsunTsun  ftHatsune Miku_192kbps.mp3.json.gz', NULL, 0),
	(666, 1, 5669544, '1736825408245_Dream Chase.mp3', 0, 1, true, '1736825408245_Dream Chase.mp3.json.gz', NULL, 0),
	(638, 1, 7572210, '1736825399489_【水野大輔 feat 初音ミく】 Brilliance.mp3', 0, 1, true, '1736825399489_【水野大輔 feat 初音ミく】 Brilliance.mp3.json.gz', NULL, 0),
	(646, 1, 8783761, '1736825402286_09. ☆Fighting Pose☆.mp3', 0, 1, true, '1736825402286_09. ☆Fighting Pose☆.mp3.json.gz', NULL, 0),
	(656, 1, 6064515, '1736825405825_by your side   小川大輝 feat初音ミク.mp3', 0, 1, true, '1736825405825_by your side   小川大輝 feat初音ミク.mp3.json.gz', NULL, 0),
	(619, 2, 6362311, '1736825394473_【初音ミク】 紫陽花が咲く頃に、君と恋をする 【nk】.mp3', 0, 1, true, '1736825394473_【初音ミク】 紫陽花が咲く頃に、君と恋をする 【nk】.mp3.json.gz', NULL, 0),
	(628, 2, 5038124, '1736825396692_【初音ミク】アクリルスター【オリジナル】.mp3', 0, 1, true, '1736825396692_【初音ミク】アクリルスター【オリジナル】.mp3.json.gz', NULL, 0),
	(701, 3, 5258272, '1736825416993_sasakureUK x DECO27   39 feat Hatsune Miku.mp3', 0, 1, true, '1736825416993_sasakureUK x DECO27   39 feat Hatsune Miku.mp3.json.gz', NULL, 0),
	(640, 2, 4125202, '1736825400091_01 - Tell Your World.mp3', 0, 1, true, '1736825400091_01 - Tell Your World.mp3.json.gz', NULL, 0),
	(603, 1, 7767281, '1736825390213_[VOCALOID] Sailing  初音ミク [公式.mp3', 0, 1, true, '1736825390213_[VOCALOID] Sailing  初音ミク [公式.mp3.json.gz', NULL, 0),
	(672, 3, 4211818, '1736825409659_Hatsune Miku   Sayonara·Good bye [English Sub].mp3', 0, 1, true, '1736825409659_Hatsune Miku   Sayonara·Good bye [English Sub].mp3.json.gz', NULL, 0),
	(605, 1, 4734685, '1736825390821_【Hatsune Miku】Body Music【Original Song】.mp3', 0, 1, true, '1736825390821_【Hatsune Miku】Body Music【Original Song】.mp3.json.gz', NULL, 0),
	(608, 1, 5282723, '1736825391540_【Kagamine Rin V4X】 Hop! Step! Instant Death! A Happiness Dance Death Trap 【VOCALOID Cover�.mp3', 0, 1, true, '1736825391540_【Kagamine Rin V4X】 Hop! Step! Instant Death! A Happiness Dance Death Trap 【VOCALOID Cover�.mp3.json.gz', NULL, 0),
	(682, 2, 4771141, '1736825412364_Lamaze P ft 初音ミク.mp3', 0, 1, true, '1736825412364_Lamaze P ft 初音ミク.mp3.json.gz', NULL, 0),
	(696, 3, 4358615, '1736825415658_PinocchioP (feat Hatsune Miku and Yukkuri)   Proliferation of Imamur.mp3', 0, 1, true, '1736825415658_PinocchioP (feat Hatsune Miku and Yukkuri)   Proliferation of Imamur.mp3.json.gz', NULL, 0),
	(699, 2, 7008058, '1736825416398_Robo feat. Hatsune Miku SPACERUN オリジナル曲.mp3', 0, 1, true, '1736825416398_Robo feat. Hatsune Miku SPACERUN オリジナル曲.mp3.json.gz', NULL, 0),
	(708, 2, 3490932, '1736825418924_yt1s.com - ElectronicMizusano ft Hatsune Miku  Smile Walker.mp3', 0, 1, true, '1736825418924_yt1s.com - ElectronicMizusano ft Hatsune Miku  Smile Walker.mp3.json.gz', NULL, 0),
	(712, 1, 4394884, '1736825419691_アンドロメダアンドロメダ   ナユタン星人 feat 初音ミク.mp3', 0, 1, true, '1736825419691_アンドロメダアンドロメダ   ナユタン星人 feat 初音ミク.mp3.json.gz', NULL, 0),
	(717, 2, 6314664, '1736825420788_ひとりぼっちとココロの本と - PIPPO feat. 初音ミク.mp3', 0, 1, true, '1736825420788_ひとりぼっちとココロの本と - PIPPO feat. 初音ミク.mp3.json.gz', NULL, 0),
	(723, 1, 4155905, '1736825422330_初音ミク Project Diva f 2nd  nanou  Hatsune Miku  Glory 3usi9  Best of nanou (high volume).mp3', 0, 1, true, '1736825422330_初音ミク Project Diva f 2nd  nanou  Hatsune Miku  Glory 3usi9  Best of nanou (high volume).mp3.json.gz', NULL, 0),
	(632, 1, 6603683, '1736825397805_【初音ミク】アンドロメダの夢【SmileR】ChineseSub.mp3', 0, 1, true, '1736825397805_【初音ミク】アンドロメダの夢【SmileR】ChineseSub.mp3.json.gz', NULL, 0),
	(636, 1, 6171002, '1736825398899_【初音ミク・GUMI】あの日、描いたDIARY【オリジナル曲PV】OFFICIAL　MV.mp3', 0, 1, true, '1736825398899_【初音ミク・GUMI】あの日、描いたDIARY【オリジナル曲PV】OFFICIAL　MV.mp3.json.gz', NULL, 0),
	(618, NULL, 3336705, '1736825394297_【初音ミク】 だんだん早くなる Getting Faster and Faster【オリジナル�.mp3', 0, 1, true, '1736825394297_【初音ミク】 だんだん早くなる Getting Faster and Faster【オリジナル�.mp3.json.gz', 2.8285434246063232, 0),
	(635, 1, 4826938, '1736825398647_【初音ミク×アルクロ】センセーションはおわらない！ フルver【コラボオリジナル楽曲�.mp3', 0, 1, true, '1736825398647_【初音ミク×アルクロ】センセーションはおわらない！ フルver【コラボオリジナル楽曲�.mp3.json.gz', NULL, 0),
	(661, 2, 5739134, '1736825407071_DECO27   ハートアラモード feat 初音ミ�.mp3', 0, 1, true, '1736825407071_DECO27   ハートアラモード feat 初音ミ�.mp3.json.gz', NULL, 0),
	(625, 2, 5927750, '1736825396074_【初音ミク】bpm full ver 【PV】.mp3', 0, 1, true, '1736825396074_【初音ミク】bpm full ver 【PV】.mp3.json.gz', NULL, 0),
	(626, 1, 4315457, '1736825396331_【初音ミク】Hatsune Miku  Bright future 【EDMオリジナル曲】.mp3', 0, 1, true, '1736825396331_【初音ミク】Hatsune Miku  Bright future 【EDMオリジナル曲】.mp3.json.gz', NULL, 0),
	(611, 2, 6712770, '1736825392413_【オリジナルMV】ユメノアメ feat初音ミク  ドッシ�.mp3', 0, 1, true, '1736825392413_【オリジナルMV】ユメノアメ feat初音ミク  ドッシ�.mp3.json.gz', NULL, 0),
	(697, 3, 6709008, '1736825415859_Rainbow Palace feat Hatsune Miku   Jonathan Parecki 【Vocaloid Original�.mp3', 0, 1, true, '1736825415859_Rainbow Palace feat Hatsune Miku   Jonathan Parecki 【Vocaloid Original�.mp3.json.gz', NULL, 0),
	(710, 1, 3010279, '1736825419323_yt1s.com - Mizusano feat 初音ミク Universe.mp3', 0, 1, true, '1736825419323_yt1s.com - Mizusano feat 初音ミク Universe.mp3.json.gz', NULL, 0),
	(657, 2, 6532212, '1736825406101_CATS RULE THE WORLD   daniwell feat Hatsune Miku  Momone Momo.mp3', 0, 1, true, '1736825406101_CATS RULE THE WORLD   daniwell feat Hatsune Miku  Momone Momo.mp3.json.gz', NULL, 0),
	(687, 2, 5193070, '1736825413579_Melancholic  Junky ft Rin Kagamine.mp3', 0, 1, true, '1736825413579_Melancholic  Junky ft Rin Kagamine.mp3.json.gz', NULL, 0),
	(688, 1, 4341061, '1736825413814_METEOR  DIVELA feat初音ミク.mp3', 0, 1, true, '1736825413814_METEOR  DIVELA feat初音ミク.mp3.json.gz', NULL, 0),
	(691, 1, 5480835, '1736825414481_Neo.mp3', 0, 1, true, '1736825414481_Neo.mp3.json.gz', NULL, 0),
	(663, 2, 3930207, '1736825407591_DECO27  愛言葉Ⅲ feat 初音ミク.mp3', 0, 1, true, '1736825407591_DECO27  愛言葉Ⅲ feat 初音ミク.mp3.json.gz', NULL, 0),
	(668, 2, 4117035, '1736825408808_east end and bocci  feat初音ミク.mp3', 0, 1, true, '1736825408808_east end and bocci  feat初音ミク.mp3.json.gz', NULL, 0),
	(706, 2, 5112842, '1736825418412_Weekender Girl   Hatsune Miku Project Diva F (HD).mp3', 0, 1, true, '1736825418412_Weekender Girl   Hatsune Miku Project Diva F (HD).mp3.json.gz', NULL, 0),
	(724, 1, 3593657, '1736825422575_初音ミク　オリジナル曲　『アンダワ』.mp3', 0, 1, true, '1736825422575_初音ミク　オリジナル曲　『アンダワ』.mp3.json.gz', NULL, 0),
	(730, 2, 6621237, '1736825424184_夏至の踊り子 ／初音ミ�.mp3', 0, 1, true, '1736825424184_夏至の踊り子 ／初音ミ�.mp3.json.gz', NULL, 0),
	(639, 1, 5813740, '1736825399835_┗ ∵ ┓夢ファンファーレ／HoneyWorks feat初音ミクu0026GUM.mp3', 0, 1, true, '1736825399835_┗ ∵ ┓夢ファンファーレ／HoneyWorks feat初音ミクu0026GUM.mp3.json.gz', NULL, 0),
	(683, 1, 4625064, '1736825412592_Landscape  初音ミク   歩く人×春�.mp3', 0, 1, true, '1736825412592_Landscape  初音ミク   歩く人×春�.mp3.json.gz', NULL, 0),
	(606, 1, 5380525, '1736825391028_‪【Hatsune Miku】‬Cerita SMU【Original】‬.mp3', 0, 1, true, '1736825391028_‪【Hatsune Miku】‬Cerita SMU【Original】‬.mp3.json.gz', NULL, 0),
	(609, 1, 6793881, '1736825391799_【Robo feat 初音ミク】 CALL ME CALL ME 【PV by Thanks】.mp3', 0, 1, true, '1736825391799_【Robo feat 初音ミク】 CALL ME CALL ME 【PV by Thanks】.mp3.json.gz', NULL, 0),
	(602, 3, 5733185, '1736825389958_[VnSharing] Umi Yuri Kaiteitan   Hatsune Miku   Vocaloid vietsub.mp3', 0, 1, true, '1736825389958_[VnSharing] Umi Yuri Kaiteitan   Hatsune Miku   Vocaloid vietsub.mp3.json.gz', NULL, 0),
	(599, 3, 6080189, '1736825389035_[Hatsune Miku] Sayonara Arpeggio [VOSTFR].mp3', 0, 1, true, '1736825389035_[Hatsune Miku] Sayonara Arpeggio [VOSTFR].mp3.json.gz', NULL, 0),
	(655, 1, 7367828, '1736825405491_Breath of Urban   keisei feat Hatsune Miku.mp3', 0, 1, true, '1736825405491_Breath of Urban   keisei feat Hatsune Miku.mp3.json.gz', NULL, 0),
	(670, 1, 3786847, '1736825409205_Hatsune Miku   Akeomeakeomeakeomeakeome (Happy New Year).mp3', 0, 1, true, '1736825409205_Hatsune Miku   Akeomeakeomeakeomeakeome (Happy New Year).mp3.json.gz', NULL, 0),
	(732, 3, 5257645, '1736825424802_愛の詩（V3） 初音ミク for lamaze.mp3', 0, 1, true, '1736825424802_愛の詩（V3） 初音ミク for lamaze.mp3.json.gz', NULL, 0),
	(614, 1, 2797444, '1736825393236_【初音ミク】 Anata no Utahime (8ch arr) 【休闲の1月曲】.mp3', 0, 1, true, '1736825393236_【初音ミク】 Anata no Utahime (8ch arr) 【休闲の1月曲】.mp3.json.gz', NULL, 0),
	(673, 3, 5048248, '1736825409863_Hatsune Miku   Torinoko City  (トリノコシティ)(Left Behind City) Sub Esp (+mp3 + romaji.mp3', 0, 1, true, '1736825409863_Hatsune Miku   Torinoko City  (トリノコシティ)(Left Behind City) Sub Esp (+mp3 + romaji.mp3.json.gz', NULL, 0),
	(596, NULL, 3246008, '1736825387932_- Ranaエレクトロサチュレイタ ElectrosaturatorVSQx.mp3', 0, 1, true, '1736825387932_- Ranaエレクトロサチュレイタ ElectrosaturatorVSQx.mp3.json.gz', 1.3202213048934937, 0),
	(629, 1, 8402370, '1736825396902_【初音ミク】アネモネ【オリジナル】.mp3', 0, 1, true, '1736825396902_【初音ミク】アネモネ【オリジナル】.mp3.json.gz', NULL, 0),
	(630, 1, 6108935, '1736825397258_【初音ミク】アポロ【オリジナルMMD PV】.mp3', 0, 1, true, '1736825397258_【初音ミク】アポロ【オリジナルMMD PV】.mp3.json.gz', NULL, 0),
	(631, 1, 6677788, '1736825397522_【初音ミク】アンダンテ【オリジナル】.mp3', 0, 1, true, '1736825397522_【初音ミク】アンダンテ【オリジナル】.mp3.json.gz', NULL, 0),
	(621, 1, 6517072, '1736825395011_【初音ミク】a tail of the wind【Cazオリジナル】.mp3', 0, 1, true, '1736825395011_【初音ミク】a tail of the wind【Cazオリジナル】.mp3.json.gz', NULL, 0),
	(622, 1, 7945959, '1736825395278_【初音ミク】Another Mine【オリジナル21】[HD720p].mp3', 0, 1, true, '1736825395278_【初音ミク】Another Mine【オリジナル21】[HD720p].mp3.json.gz', NULL, 0),
	(624, 1, 5260243, '1736825395852_【初音ミク】aria【オリジナル曲PV付】.mp3', 0, 1, true, '1736825395852_【初音ミク】aria【オリジナル曲PV付】.mp3.json.gz', NULL, 0),
	(693, 1, 5959817, '1736825414955_night  (t)rain  初音ミ�.mp3', 0, 1, true, '1736825414955_night  (t)rain  初音ミ�.mp3.json.gz', NULL, 0),
	(598, 2, 6143688, '1736825388738_[Hatsune Miku] After Rain SweetDrops [English Sub].mp3', 0, 1, true, '1736825388738_[Hatsune Miku] After Rain SweetDrops [English Sub].mp3.json.gz', NULL, 0),
	(647, 1, 7637962, '1736825402675_09. GIFT.mp3', 0, 1, true, '1736825402675_09. GIFT.mp3.json.gz', NULL, 0),
	(604, 3, 5561211, '1736825390560_【Hatsune Miku】  EARTH DAY  【English Sub】.mp3', 0, 1, true, '1736825390560_【Hatsune Miku】  EARTH DAY  【English Sub】.mp3.json.gz', NULL, 0),
	(654, 1, 7011193, '1736825405183_An ／ DECO＊27 feat初音ミク.mp3', 0, 1, true, '1736825405183_An ／ DECO＊27 feat初音ミク.mp3.json.gz', NULL, 0),
	(671, 2, 5663275, '1736825409400_Hatsune Miku   Calc (English  Romaji Subs).mp3', 0, 1, true, '1736825409400_Hatsune Miku   Calc (English  Romaji Subs).mp3.json.gz', NULL, 0),
	(674, 1, 5371884, '1736825410099_Hatsune Miku   Vocaloid   I am not a Robot.mp3', 0, 1, true, '1736825410099_Hatsune Miku   Vocaloid   I am not a Robot.mp3.json.gz', NULL, 0),
	(675, 1, 6067199, '1736825410344_Hatsune Miku  Aoharu (with English lyrics).mp3', 0, 1, true, '1736825410344_Hatsune Miku  Aoharu (with English lyrics).mp3.json.gz', NULL, 0),
	(690, 1, 4247438, '1736825414236_Musunde Hiraite Rasetsu to Mukuro ORIGINAL.mp3', 0, 1, true, '1736825414236_Musunde Hiraite Rasetsu to Mukuro ORIGINAL.mp3.json.gz', NULL, 0),
	(634, 1, 6232535, '1736825398403_【初音ミク】名前のない誰か【オリジナル�.mp3', 0, 1, true, '1736825398403_【初音ミク】名前のない誰か【オリジナル�.mp3.json.gz', NULL, 0),
	(649, 3, 9631379, '1736825403658_09. ツユメロ.mp3', 0, 1, true, '1736825403658_09. ツユメロ.mp3.json.gz', NULL, 0),
	(684, 1, 6453844, '1736825412805_livetune   never ende.mp3', 0, 1, true, '1736825412805_livetune   never ende.mp3.json.gz', NULL, 0),
	(652, 2, 8169778, '1736825404565_18. リンリンシグナル.mp3', 0, 1, true, '1736825404565_18. リンリンシグナル.mp3.json.gz', NULL, 0),
	(641, 3, 8411420, '1736825400297_02 yellow.mp3', 0, 1, true, '1736825400297_02 yellow.mp3.json.gz', NULL, 0),
	(642, 3, 8224103, '1736825400693_03. Palette.mp3', 0, 1, true, '1736825400693_03. Palette.mp3.json.gz', NULL, 0),
	(676, 2, 6265136, '1736825410641_Hatsune Miku Original Song Bright City.mp3', 0, 1, true, '1736825410641_Hatsune Miku Original Song Bright City.mp3.json.gz', NULL, 0),
	(644, 2, 9410964, '1736825401480_04. 彼方まで虹を架けて.mp3', 0, 1, true, '1736825401480_04. 彼方まで虹を架けて.mp3.json.gz', NULL, 0),
	(669, 3, 4234899, '1736825408995_Equation.mp3', 0, 1, true, '1736825408995_Equation.mp3.json.gz', NULL, 0),
	(650, 2, 6483666, '1736825404068_16. ローリンガール.mp3', 0, 1, true, '1736825404068_16. ローリンガール.mp3.json.gz', NULL, 0),
	(651, 3, 4558903, '1736825404353_17. Ievan Polkka.mp3', 0, 1, true, '1736825404353_17. Ievan Polkka.mp3.json.gz', NULL, 0),
	(658, 1, 5117211, '1736825406385_Child   初音ミク.mp3', 0, 1, true, '1736825406385_Child   初音ミク.mp3.json.gz', NULL, 0),
	(694, 1, 2852290, '1736825415233_Onesided Love Samba  Hatsune Miku Traduccion.mp3', 0, 1, true, '1736825415233_Onesided Love Samba  Hatsune Miku Traduccion.mp3.json.gz', NULL, 0),
	(698, 3, 5303359, '1736825416149_Rin Kagamine Sweet Magic.mp3', 0, 1, true, '1736825416149_Rin Kagamine Sweet Magic.mp3.json.gz', NULL, 0),
	(664, 2, 6406197, '1736825407800_Deco27 ft 初音ミク.mp3', 0, 1, true, '1736825407800_Deco27 ft 初音ミク.mp3.json.gz', NULL, 0),
	(665, 1, 2885309, '1736825408083_DokiDokiBeat 初音ミク for Lamaze.mp3', 0, 1, true, '1736825408083_DokiDokiBeat 初音ミク for Lamaze.mp3.json.gz', NULL, 0),
	(713, 3, 3719764, '1736825419908_えいえんがみつからない - daniwell feat. Hatsune Miku & Momone Momo.mp3', 0, 1, true, '1736825419908_えいえんがみつからない - daniwell feat. Hatsune Miku & Momone Momo.mp3.json.gz', NULL, 0),
	(714, 2, 5367986, '1736825420081_くるくるついんてーる_192kbps.mp3', 0, 1, true, '1736825420081_くるくるついんてーる_192kbps.mp3.json.gz', NULL, 0),
	(715, 2, 6309022, '1736825420328_シネマセレク�.mp3', 0, 1, true, '1736825420328_シネマセレク�.mp3.json.gz', NULL, 0),
	(597, 1, 3758426, '1736825388542_- 初音ミクねこみみスイッチオリジナル.mp3', 0, 1, true, '1736825388542_- 初音ミクねこみみスイッチオリジナル.mp3.json.gz', NULL, 0),
	(718, 2, 4097808, '1736825421077_プリエ  初音ミク  Hatsune Miku.mp3', 0, 1, true, '1736825421077_プリエ  初音ミク  Hatsune Miku.mp3.json.gz', NULL, 0),
	(722, 3, 6077421, '1736825422052_初音ミク poppin'' jumpin まらしぃ kors k.mp3', 0, 1, true, '1736825422052_初音ミク poppin'' jumpin まらしぃ kors k.mp3.json.gz', NULL, 0),
	(726, 1, 6597947, '1736825423032_初音ミクオリジナル曲 「Breath of mechanical」.mp3', 0, 1, true, '1736825423032_初音ミクオリジナル曲 「Breath of mechanical」.mp3.json.gz', NULL, 0),
	(727, 2, 6063262, '1736825423351_初音ミクオリジナル曲「Singularity�.mp3', 0, 1, true, '1736825423351_初音ミクオリジナル曲「Singularity�.mp3.json.gz', NULL, 0),
	(729, 1, 5623777, '1736825423853_初音ミク灯火syudou_192kbps.mp3', 0, 1, true, '1736825423853_初音ミク灯火syudou_192kbps.mp3.json.gz', NULL, 0),
	(633, 1, 6737848, '1736825398101_【初音ミク】スターナイトスノウ【オリジナルMV�.mp3', 0, 1, true, '1736825398101_【初音ミク】スターナイトスノウ【オリジナルMV�.mp3.json.gz', NULL, 0),
	(645, 3, 8975210, '1736825401894_08. xハロー、プラネット。.mp3', 0, 1, true, '1736825401894_08. xハロー、プラネット。.mp3.json.gz', NULL, 0),
	(648, 1, 15100066, '1736825403008_09. キューティージェリー.mp3', 0, 1, true, '1736825403008_09. キューティージェリー.mp3.json.gz', NULL, 0),
	(601, 1, 5636316, '1736825389702_[MV]さよならカンパニュラ  mehikari feat 初音ミ�.mp3', 0, 1, true, '1736825389702_[MV]さよならカンパニュラ  mehikari feat 初音ミ�.mp3.json.gz', NULL, 0),
	(653, 2, 5874730, '1736825404920_396  40mP feat初音ミク.mp3', 0, 1, true, '1736825404920_396  40mP feat初音ミク.mp3.json.gz', NULL, 0),
	(659, 1, 5848222, '1736825406621_cloudway (feat Hatsune Miku)   keisei.mp3', 0, 1, true, '1736825406621_cloudway (feat Hatsune Miku)   keisei.mp3.json.gz', NULL, 0),
	(667, 2, 6794899, '1736825408504_DreamerTeary Planet feat. 初音ミク.mp3', 0, 1, true, '1736825408504_DreamerTeary Planet feat. 初音ミク.mp3.json.gz', NULL, 0),
	(607, 2, 6109192, '1736825391266_【Hatsune Miku】The Sound of Rain and Petrichor    eng sub【Koyuki】.mp3', 0, 1, true, '1736825391266_【Hatsune Miku】The Sound of Rain and Petrichor    eng sub【Koyuki】.mp3.json.gz', NULL, 0),
	(731, 2, 7307735, '1736825424475_大嫌いなはずだったHoneyWorks feat.GUMI初音ミク.mp3', 0, 1, true, '1736825424475_大嫌いなはずだったHoneyWorks feat.GUMI初音ミク.mp3.json.gz', NULL, 0),
	(613, 3, 5138434, '1736825393001_【公式】アイシテ  とあ feat 初音ミク　  LOVE ME  toa feat Hatsune Miku.mp3', 0, 1, true, '1736825393001_【公式】アイシテ  とあ feat 初音ミク　  LOVE ME  toa feat Hatsune Miku.mp3.json.gz', NULL, 0),
	(702, 3, 4354050, '1736825417234_spica- hatsune miku.mp3', 0, 1, true, '1736825417234_spica- hatsune miku.mp3.json.gz', NULL, 0),
	(737, 1, 2564734, '1736825426195_鏡音レン唐傘さんが通るオリジナルPV.mp3', 0, 1, true, '1736825426195_鏡音レン唐傘さんが通るオリジナルPV.mp3.json.gz', NULL, 0),
	(736, 1, 7083291, '1736825425887_膵臓  Luna feat 初音ミク ガールズコレクション.mp3', 0, 1, true, '1736825425887_膵臓  Luna feat 初音ミク ガールズコレクション.mp3.json.gz', NULL, 0),
	(623, 1, 6122906, '1736825395607_【初音ミク】Anti X''mas Superstar【クリスマス曲PV】OFFICIAL　MV.mp3', 0, 1, true, '1736825395607_【初音ミク】Anti X''mas Superstar【クリスマス曲PV】OFFICIAL　MV.mp3.json.gz', NULL, 0),
	(627, 3, 4925388, '1736825396500_【初音ミク】Hatsune Miku「DECORATOR」MP3 High Quality![8].mp3', 0, 1, true, '1736825396500_【初音ミク】Hatsune Miku「DECORATOR」MP3 High Quality![8].mp3.json.gz', NULL, 0),
	(679, 3, 8051818, '1736825411436_Heavenz   アルファ.mp3', 0, 1, true, '1736825411436_Heavenz   アルファ.mp3.json.gz', NULL, 0),
	(681, 1, 5841325, '1736825412098_kiRakiLa  gaogao feat初音ミ�.mp3', 0, 1, true, '1736825412098_kiRakiLa  gaogao feat初音ミ�.mp3.json.gz', NULL, 0),
	(685, 1, 6381119, '1736825413090_LOST NOTE  No85 feat初音ミ�.mp3', 0, 1, true, '1736825413090_LOST NOTE  No85 feat初音ミ�.mp3.json.gz', NULL, 0),
	(686, 1, 4369900, '1736825413372_MASA WORKS DESIGN ft初音ミクu0026GUMI   BRASS NOISE FLAMENC.mp3', 0, 1, true, '1736825413372_MASA WORKS DESIGN ft初音ミクu0026GUMI   BRASS NOISE FLAMENC.mp3.json.gz', NULL, 0),
	(689, 1, 3980123, '1736825414011_miku hatsune - po pi po356.mp3', 0, 1, true, '1736825414011_miku hatsune - po pi po356.mp3.json.gz', NULL, 0),
	(695, 3, 6140375, '1736825415369_Ordinary   ポリスピカデリー feat 初音ミク  Ordinary   Police Piccadilly feat Hatsune Mik.mp3', 0, 1, true, '1736825415369_Ordinary   ポリスピカデリー feat 初音ミク  Ordinary   Police Piccadilly feat Hatsune Mik.mp3.json.gz', NULL, 0),
	(700, 1, 5960444, '1736825416704_ryuryu   Flowers featHatsune Miku 初音ミ�.mp3', 0, 1, true, '1736825416704_ryuryu   Flowers featHatsune Miku 初音ミ�.mp3.json.gz', NULL, 0),
	(719, 2, 5883330, '1736825421278_みきとP Hoi MV.mp3', 0, 1, true, '1736825421278_みきとP Hoi MV.mp3.json.gz', NULL, 0),
	(711, 3, 4870197, '1736825419471_あいまいクエスチョン／yamada feat初音ミク   The Quizmaste.mp3', 0, 1, true, '1736825419471_あいまいクエスチョン／yamada feat初音ミク   The Quizmaste.mp3.json.gz', NULL, 0),
	(720, 3, 5228806, '1736825421540_みきとP『 だいあもんど 』M.mp3', 0, 1, true, '1736825421540_みきとP『 だいあもんど 』M.mp3.json.gz', NULL, 0),
	(721, 2, 5887092, '1736825421780_モノクロブルースカイ  のぼる feat 初音ミク  MonochromeBlueSky.mp3', 0, 1, true, '1736825421780_モノクロブルースカイ  のぼる feat 初音ミク  MonochromeBlueSky.mp3.json.gz', NULL, 0),
	(725, 3, 5785135, '1736825422748_初音ミク（Θ）どういうことなの！？中文字幕.mp3', 0, 1, true, '1736825422748_初音ミク（Θ）どういうことなの！？中文字幕.mp3.json.gz', NULL, 0),
	(728, 3, 5212088, '1736825423611_初音ミクリンレンルカ夢の続きオリジナル中文字幕.mp3', 0, 1, true, '1736825423611_初音ミクリンレンルカ夢の続きオリジナル中文字幕.mp3.json.gz', NULL, 0),
	(734, 2, 7273880, '1736825425334_神経衰弱  初音ミク 【 Nervous Breakdown  Hatsune Miku �.mp3', 0, 1, true, '1736825425334_神経衰弱  初音ミク 【 Nervous Breakdown  Hatsune Miku �.mp3.json.gz', NULL, 0),
	(610, 1, 5545410, '1736825392166_【Robo feat 初音ミク】 SKY HIGHWAY【オリジナル曲�.mp3', 0, 1, true, '1736825392166_【Robo feat 初音ミク】 SKY HIGHWAY【オリジナル曲�.mp3.json.gz', NULL, 0),
	(704, 3, 9821039, '1736825417711_triple baka - miku hatsune.mp3', 0, 1, true, '1736825417711_triple baka - miku hatsune.mp3.json.gz', NULL, 0),
	(709, 2, 4900708, '1736825419105_yt1s.com - Far Away.mp3', 0, 1, true, '1736825419105_yt1s.com - Far Away.mp3.json.gz', NULL, 0),
	(707, 2, 6310275, '1736825418633_White Dove with English  Romaji Sub  Hatsune Miku  ハト  sm2583719  HQ.mp3', 0, 1, true, '1736825418633_White Dove with English  Romaji Sub  Hatsune Miku  ハト  sm2583719  HQ.mp3.json.gz', NULL, 0),
	(716, 2, 3628022, '1736825420616_なりすましゲンガー鏡音リン初音ミクオリジナルPV.mp3', 0, 1, true, '1736825420616_なりすましゲンガー鏡音リン初音ミクオリジナルPV.mp3.json.gz', NULL, 0),
	(620, 1, 5189936, '1736825394776_【初音ミク】　表面張力　【オリジナル�.mp3', 0, 1, true, '1736825394776_【初音ミク】　表面張力　【オリジナル�.mp3.json.gz', NULL, 0),
	(735, 1, 5404349, '1736825425650_私は足りないでいっぱい_192kbps.mp3', 0, 1, true, '1736825425650_私は足りないでいっぱい_192kbps.mp3.json.gz', NULL, 0),
	(692, 2, 5230687, '1736825414728_Neru - ロストワンの号哭(Lost One''s Weeping) feat. Kagamine Rin.mp3', 0, 1, true, '1736825414728_Neru - ロストワンの号哭(Lost One''s Weeping) feat. Kagamine Rin.mp3.json.gz', NULL, 0),
	(660, 1, 4039294, '1736825406881_Cressida   ftHatsune Miku 【english subtitles】.mp3', 0, 1, true, '1736825406881_Cressida   ftHatsune Miku 【english subtitles】.mp3.json.gz', NULL, 0),
	(680, 1, 6777972, '1736825411799_irucaice   White Step feat Hatsune Mik.mp3', 0, 1, true, '1736825411799_irucaice   White Step feat Hatsune Mik.mp3.json.gz', NULL, 0),
	(678, 1, 4499071, '1736825411220_Hatsune Miku Two Faced Lovers.mp3', 0, 1, true, '1736825411220_Hatsune Miku Two Faced Lovers.mp3.json.gz', NULL, 0),
	(703, 2, 6151033, '1736825417429_SushiP ft 初音ミク ''Align'' アライン (English Subtitles).mp3', 0, 1, true, '1736825417429_SushiP ft 初音ミク ''Align'' アライン (English Subtitles).mp3.json.gz', NULL, 0),
	(733, 1, 6643180, '1736825425042_手�.mp3', 0, 1, true, '1736825425042_手�.mp3.json.gz', NULL, 0),
	(643, NULL, 8460721, '1736825401058_04. ワールス゛エント゛タ゛ンスホール.mp3', 0, 1, true, '1736825401058_04. ワールス゛エント゛タ゛ンスホール.mp3.json.gz', 2.50999116897583, 0),
	(662, NULL, 5704653, '1736825407321_DECO27   夜行性ハイズ feat 初音ミ�.mp3', 0, 1, true, '1736825407321_DECO27   夜行性ハイズ feat 初音ミ�.mp3.json.gz', 2.2651588916778564, 0),
	(617, NULL, 7658408, '1736825393984_【初音ミク】 Hand in Hand (Magical Mirai ver) 【マジカルミライ 2015】.mp3', 0, 1, true, '1736825393984_【初音ミク】 Hand in Hand (Magical Mirai ver) 【マジカルミライ 2015】.mp3.json.gz', 2.7110376358032227, 0),
	(637, NULL, 6689480, '1736825399173_【初音ミクAppend DARK】Carbuncle【オリジナル曲】.mp3', 0, 1, true, '1736825399173_【初音ミクAppend DARK】Carbuncle【オリジナル曲】.mp3.json.gz', 2.162421703338623, 0);


--
-- Data for Name: playlists; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.playlists OVERRIDING SYSTEM VALUE VALUES
	(1, 'global', NULL, '2026-02-22 18:57:37.569194-06', B'1', B'0');


--
-- Data for Name: rel_playlists_canciones; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: tipos_datos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tipos_datos OVERRIDING SYSTEM VALUE VALUES
	(1, 'archivo', 'file', 'archivos que se guardan en disco con formato .mp3 (primeras pruebas)'),
	(2, 'enlace', 'link', 'enlaces extraidos de otros sitios (por definir)');


--
-- Name: calibracion_cl_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.calibracion_cl_id_seq', 1, false);


--
-- Name: canciones_evaluadas_ce_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.canciones_evaluadas_ce_id_seq', 738, true);


--
-- Name: playlists_pl_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.playlists_pl_id_seq', 1, true);


--
-- Name: rel_playlists_canciones_pc_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rel_playlists_canciones_pc_id_seq', 1, false);


--
-- Name: tipos_datos_td_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tipos_datos_td_id_seq', 2, true);


--
-- Name: canciones PK_509f2887bb0bd963b5f723f27be; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.canciones
    ADD CONSTRAINT "PK_509f2887bb0bd963b5f723f27be" PRIMARY KEY (ca_id);


--
-- Name: calibracion calibracion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calibracion
    ADD CONSTRAINT calibracion_pkey PRIMARY KEY (cl_id);


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
-- Name: index_cl_ca_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_cl_ca_id ON public.calibracion USING btree (cl_ca_id);


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
    ADD CONSTRAINT link_canciones_calibracion FOREIGN KEY (cl_ca_id) REFERENCES public.canciones(ca_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: rel_playlists_canciones link_canciones_rel_playlists_canciones; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rel_playlists_canciones
    ADD CONSTRAINT link_canciones_rel_playlists_canciones FOREIGN KEY (pr_ca_id) REFERENCES public.canciones(ca_id) MATCH FULL ON UPDATE CASCADE;


--
-- Name: rel_playlists_canciones link_playlists_rel_playlists_canciones; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rel_playlists_canciones
    ADD CONSTRAINT link_playlists_rel_playlists_canciones FOREIGN KEY (pr_pl_id) REFERENCES public.playlists(pl_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

