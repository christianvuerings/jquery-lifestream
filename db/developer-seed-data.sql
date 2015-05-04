--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

DROP INDEX public.index_user_auths_on_uid;
DROP INDEX public.index_summer_sub_terms_on_year_and_sub_term_code;
DROP INDEX public.index_fin_aid_years_on_current_year;
ALTER TABLE ONLY public.user_roles DROP CONSTRAINT user_roles_pkey;
ALTER TABLE ONLY public.user_auths DROP CONSTRAINT user_auths_pkey;
ALTER TABLE ONLY public.summer_sub_terms DROP CONSTRAINT summer_sub_terms_pkey;
ALTER TABLE ONLY public.links DROP CONSTRAINT links_pkey;
ALTER TABLE ONLY public.link_sections DROP CONSTRAINT link_sections_pkey;
ALTER TABLE ONLY public.link_categories DROP CONSTRAINT link_categories_pkey;
ALTER TABLE ONLY public.fin_aid_years DROP CONSTRAINT fin_aid_years_pkey;
ALTER TABLE public.user_roles ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.user_auths ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.summer_sub_terms ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.links ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.link_sections ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.link_categories ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.fin_aid_years ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE public.user_roles_id_seq;
DROP TABLE public.user_roles;
DROP SEQUENCE public.user_auths_id_seq;
DROP TABLE public.user_auths;
DROP SEQUENCE public.summer_sub_terms_id_seq;
DROP TABLE public.summer_sub_terms;
DROP TABLE public.links_user_roles;
DROP SEQUENCE public.links_id_seq;
DROP TABLE public.links;
DROP TABLE public.link_sections_links;
DROP SEQUENCE public.link_sections_id_seq;
DROP TABLE public.link_sections;
DROP TABLE public.link_categories_link_sections;
DROP SEQUENCE public.link_categories_id_seq;
DROP TABLE public.link_categories;
DROP SEQUENCE public.fin_aid_years_id_seq;
DROP TABLE public.fin_aid_years;
SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: fin_aid_years; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE fin_aid_years (
    id integer NOT NULL,
    current_year integer NOT NULL,
    upcoming_start_date date NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: fin_aid_years_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE fin_aid_years_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fin_aid_years_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE fin_aid_years_id_seq OWNED BY fin_aid_years.id;


--
-- Name: link_categories; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE link_categories (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    slug character varying(255) NOT NULL,
    root_level boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: link_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE link_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: link_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE link_categories_id_seq OWNED BY link_categories.id;


--
-- Name: link_categories_link_sections; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE link_categories_link_sections (
    link_category_id integer,
    link_section_id integer
);


--
-- Name: link_sections; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE link_sections (
    id integer NOT NULL,
    link_root_cat_id integer,
    link_top_cat_id integer,
    link_sub_cat_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: link_sections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE link_sections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: link_sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE link_sections_id_seq OWNED BY link_sections.id;


--
-- Name: link_sections_links; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE link_sections_links (
    link_section_id integer,
    link_id integer
);


--
-- Name: links; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE links (
    id integer NOT NULL,
    name character varying(255),
    url character varying(255),
    description character varying(255),
    published boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE links_id_seq OWNED BY links.id;


--
-- Name: links_user_roles; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE links_user_roles (
    link_id integer,
    user_role_id integer
);


--
-- Name: summer_sub_terms; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE summer_sub_terms (
    id integer NOT NULL,
    year integer NOT NULL,
    sub_term_code integer NOT NULL,
    start date NOT NULL,
    "end" date NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: summer_sub_terms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE summer_sub_terms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: summer_sub_terms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE summer_sub_terms_id_seq OWNED BY summer_sub_terms.id;


--
-- Name: user_auths; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE user_auths (
    id integer NOT NULL,
    uid character varying(255) NOT NULL,
    is_superuser boolean DEFAULT false NOT NULL,
    active boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_author boolean DEFAULT false NOT NULL,
    is_viewer boolean DEFAULT false NOT NULL
);


--
-- Name: user_auths_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_auths_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_auths_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_auths_id_seq OWNED BY user_auths.id;


--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE user_roles (
    id integer NOT NULL,
    name character varying(255),
    slug character varying(255)
);


--
-- Name: user_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_roles_id_seq OWNED BY user_roles.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY fin_aid_years ALTER COLUMN id SET DEFAULT nextval('fin_aid_years_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY link_categories ALTER COLUMN id SET DEFAULT nextval('link_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY link_sections ALTER COLUMN id SET DEFAULT nextval('link_sections_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY links ALTER COLUMN id SET DEFAULT nextval('links_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY summer_sub_terms ALTER COLUMN id SET DEFAULT nextval('summer_sub_terms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_auths ALTER COLUMN id SET DEFAULT nextval('user_auths_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_roles ALTER COLUMN id SET DEFAULT nextval('user_roles_id_seq'::regclass);


--
-- Data for Name: fin_aid_years; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO fin_aid_years VALUES (4, 2014, '2014-03-29', '2014-05-12 13:03:16.162', '2014-05-12 13:03:16.162');
INSERT INTO fin_aid_years VALUES (5, 2015, '2015-04-25', '2014-05-12 13:03:16.169', '2015-03-31 22:48:01.32');
INSERT INTO fin_aid_years VALUES (6, 2016, '2016-05-01', '2014-05-12 13:03:16.175', '2015-04-27 13:01:59.352');
INSERT INTO fin_aid_years VALUES (7, 2017, '2017-05-01', '2014-06-02 13:02:01.337', '2015-04-27 13:01:59.372');
INSERT INTO fin_aid_years VALUES (8, 2018, '2018-05-01', '2014-06-02 13:02:01.373', '2015-04-27 13:01:59.378');
INSERT INTO fin_aid_years VALUES (9, 2019, '2019-05-01', '2014-06-02 13:02:01.385', '2015-04-27 13:01:59.383');
INSERT INTO fin_aid_years VALUES (10, 2020, '2020-05-01', '2014-06-02 13:02:01.396', '2015-04-27 13:01:59.388');
INSERT INTO fin_aid_years VALUES (11, 2021, '2021-05-01', '2014-06-02 13:02:01.408', '2015-04-27 13:01:59.393');


--
-- Name: fin_aid_years_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('fin_aid_years_id_seq', 11, true);


--
-- Data for Name: link_categories; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO link_categories VALUES (468, 'Academic', 'academic', true, '2015-04-27 13:01:59.577', '2015-04-27 13:01:59.577');
INSERT INTO link_categories VALUES (469, 'Academic Departments', 'academicdepartments', false, '2015-04-27 13:01:59.589', '2015-04-27 13:01:59.589');
INSERT INTO link_categories VALUES (470, 'Academic Planning', 'academicplanning', false, '2015-04-27 13:01:59.601', '2015-04-27 13:01:59.601');
INSERT INTO link_categories VALUES (471, 'Classes', 'classes', false, '2015-04-27 13:01:59.612', '2015-04-27 13:01:59.612');
INSERT INTO link_categories VALUES (472, 'Faculty', 'faculty', false, '2015-04-27 13:01:59.623', '2015-04-27 13:01:59.623');
INSERT INTO link_categories VALUES (473, 'Staff Learning', 'stafflearning', false, '2015-04-27 13:01:59.634', '2015-04-27 13:01:59.634');
INSERT INTO link_categories VALUES (474, 'Administrative', 'administrative', true, '2015-04-27 13:01:59.645', '2015-04-27 13:01:59.645');
INSERT INTO link_categories VALUES (475, 'Campus Departments', 'campusdepartments', false, '2015-04-27 13:01:59.655', '2015-04-27 13:01:59.655');
INSERT INTO link_categories VALUES (476, 'Communication & Collaboration', 'communicationcollaboration', false, '2015-04-27 13:01:59.667', '2015-04-27 13:01:59.667');
INSERT INTO link_categories VALUES (477, 'Policies & Procedures', 'policiesproceedures', false, '2015-04-27 13:01:59.678', '2015-04-27 13:01:59.678');
INSERT INTO link_categories VALUES (478, 'Shared Service Center', 'sharedservices', false, '2015-04-27 13:01:59.689', '2015-04-27 13:01:59.689');
INSERT INTO link_categories VALUES (479, 'Tools & Resources', 'toolsresources', false, '2015-04-27 13:01:59.7', '2015-04-27 13:01:59.7');
INSERT INTO link_categories VALUES (480, 'Campus Life', 'campus life', true, '2015-04-27 13:01:59.711', '2015-04-27 13:01:59.711');
INSERT INTO link_categories VALUES (481, 'Community', 'community', false, '2015-04-27 13:01:59.722', '2015-04-27 13:01:59.722');
INSERT INTO link_categories VALUES (482, 'Getting Around', 'gettingaround', false, '2015-04-27 13:01:59.732', '2015-04-27 13:01:59.732');
INSERT INTO link_categories VALUES (483, 'Recreation & Entertainment', 'recreationentertainment', false, '2015-04-27 13:01:59.742', '2015-04-27 13:01:59.742');
INSERT INTO link_categories VALUES (484, 'Safety & Emergency Information', 'safetyemergencyinfo', false, '2015-04-27 13:01:59.752', '2015-04-27 13:01:59.752');
INSERT INTO link_categories VALUES (485, 'Student Engagement', 'studentgroups', false, '2015-04-27 13:01:59.763', '2015-04-27 13:01:59.763');
INSERT INTO link_categories VALUES (486, 'Support Services', 'supportservices', false, '2015-04-27 13:01:59.773', '2015-04-27 13:01:59.773');
INSERT INTO link_categories VALUES (487, 'Personal', 'personal', true, '2015-04-27 13:01:59.786', '2015-04-27 13:01:59.786');
INSERT INTO link_categories VALUES (488, 'Career', 'career', false, '2015-04-27 13:01:59.797', '2015-04-27 13:01:59.797');
INSERT INTO link_categories VALUES (489, 'Finances', 'finances', false, '2015-04-27 13:01:59.807', '2015-04-27 13:01:59.807');
INSERT INTO link_categories VALUES (490, 'Food & Housing', 'foodandhousing', false, '2015-04-27 13:01:59.818', '2015-04-27 13:01:59.818');
INSERT INTO link_categories VALUES (491, 'HR & Benefits', 'hrbenefits', false, '2015-04-27 13:01:59.829', '2015-04-27 13:01:59.829');
INSERT INTO link_categories VALUES (492, 'Wellness', 'wellness', false, '2015-04-27 13:01:59.84', '2015-04-27 13:01:59.84');
INSERT INTO link_categories VALUES (493, 'Parking & Transportation', 'parking & transportation', false, '2015-04-27 13:01:59.854', '2015-04-27 13:01:59.854');
INSERT INTO link_categories VALUES (494, 'Student Government', 'student government', false, '2015-04-27 13:02:00.063', '2015-04-27 13:02:00.063');
INSERT INTO link_categories VALUES (495, 'Calendar', 'calendar', false, '2015-04-27 13:02:00.127', '2015-04-27 13:02:00.127');
INSERT INTO link_categories VALUES (496, 'Policies', 'policies', false, '2015-04-27 13:02:00.314', '2015-04-27 13:02:00.314');
INSERT INTO link_categories VALUES (497, 'Resources', 'resources', false, '2015-04-27 13:02:00.384', '2015-04-27 13:02:00.384');
INSERT INTO link_categories VALUES (498, 'Administrative and Other', 'administrative and other', false, '2015-04-27 13:02:00.439', '2015-04-27 13:02:00.439');
INSERT INTO link_categories VALUES (499, 'Security & Access', 'security & access', false, '2015-04-27 13:02:00.504', '2015-04-27 13:02:00.504');
INSERT INTO link_categories VALUES (500, 'Benefits', 'benefits', false, '2015-04-27 13:02:00.568', '2015-04-27 13:02:00.568');
INSERT INTO link_categories VALUES (501, 'Financial', 'financial', false, '2015-04-27 13:02:00.628', '2015-04-27 13:02:00.628');
INSERT INTO link_categories VALUES (502, 'Asset Management', 'asset management', false, '2015-04-27 13:02:00.689', '2015-04-27 13:02:00.689');
INSERT INTO link_categories VALUES (503, 'Academic Record', 'academic record', false, '2015-04-27 13:02:00.801', '2015-04-27 13:02:00.801');
INSERT INTO link_categories VALUES (504, 'Purchasing', 'purchasing', false, '2015-04-27 13:02:00.877', '2015-04-27 13:02:00.877');
INSERT INTO link_categories VALUES (505, 'Night Safety', 'night safety', false, '2015-04-27 13:02:00.952', '2015-04-27 13:02:00.952');
INSERT INTO link_categories VALUES (506, 'Planning', 'planning', false, '2015-04-27 13:02:01.015', '2015-04-27 13:02:01.015');
INSERT INTO link_categories VALUES (507, 'Jobs', 'jobs', false, '2015-04-27 13:02:01.075', '2015-04-27 13:02:01.075');
INSERT INTO link_categories VALUES (508, 'Points of Interest', 'points of interest', false, '2015-04-27 13:02:01.129', '2015-04-27 13:02:01.129');
INSERT INTO link_categories VALUES (509, 'Research', 'research', false, '2015-04-27 13:02:01.188', '2015-04-27 13:02:01.188');
INSERT INTO link_categories VALUES (510, 'Housing', 'housing', false, '2015-04-27 13:02:01.286', '2015-04-27 13:02:01.286');
INSERT INTO link_categories VALUES (511, 'Billing & Payments', 'billing & payments', false, '2015-04-27 13:02:01.34', '2015-04-27 13:02:01.34');
INSERT INTO link_categories VALUES (512, 'Staff Portal', 'staff portal', false, '2015-04-27 13:02:01.387', '2015-04-27 13:02:01.387');
INSERT INTO link_categories VALUES (513, 'Learning Resources', 'learning resources', false, '2015-04-27 13:02:01.478', '2015-04-27 13:02:01.478');
INSERT INTO link_categories VALUES (514, 'Collaboration Tools', 'collaboration tools', false, '2015-04-27 13:02:01.532', '2015-04-27 13:02:01.532');
INSERT INTO link_categories VALUES (515, 'Campus Health Center', 'campus health center', false, '2015-04-27 13:02:01.59', '2015-04-27 13:02:01.59');
INSERT INTO link_categories VALUES (516, 'Campus Dining', 'campus dining', false, '2015-04-27 13:02:01.642', '2015-04-27 13:02:01.642');
INSERT INTO link_categories VALUES (517, 'Analysis & Reporting', 'analysis & reporting', false, '2015-04-27 13:02:01.718', '2015-04-27 13:02:01.718');
INSERT INTO link_categories VALUES (518, 'Activities', 'activities', false, '2015-04-27 13:02:01.77', '2015-04-27 13:02:01.77');
INSERT INTO link_categories VALUES (519, 'Student Advising', 'student advising', false, '2015-04-27 13:02:02.007', '2015-04-27 13:02:02.007');
INSERT INTO link_categories VALUES (520, 'Your Questions Answered Here', 'your questions answered here', false, '2015-04-27 13:02:02.027', '2015-04-27 13:02:02.027');
INSERT INTO link_categories VALUES (521, 'Athletics', 'athletics', false, '2015-04-27 13:02:02.124', '2015-04-27 13:02:02.124');
INSERT INTO link_categories VALUES (522, 'Student Organizations', 'student organizations', false, '2015-04-27 13:02:02.223', '2015-04-27 13:02:02.223');
INSERT INTO link_categories VALUES (523, 'bConnected Tools', 'bconnected tools', false, '2015-04-27 13:02:02.335', '2015-04-27 13:02:02.335');
INSERT INTO link_categories VALUES (524, 'Campus Messaging', 'campus messaging', false, '2015-04-27 13:02:02.39', '2015-04-27 13:02:02.39');
INSERT INTO link_categories VALUES (525, 'Budget', 'budget', false, '2015-04-27 13:02:02.491', '2015-04-27 13:02:02.491');
INSERT INTO link_categories VALUES (526, 'Payroll', 'payroll', false, '2015-04-27 13:02:02.571', '2015-04-27 13:02:02.571');
INSERT INTO link_categories VALUES (527, 'Philanthropy & Public Service', 'philanthropy & public service', false, '2015-04-27 13:02:02.651', '2015-04-27 13:02:02.651');
INSERT INTO link_categories VALUES (528, 'Directory', 'directory', false, '2015-04-27 13:02:02.762', '2015-04-27 13:02:02.762');
INSERT INTO link_categories VALUES (529, 'Map', 'map', false, '2015-04-27 13:02:02.85', '2015-04-27 13:02:02.85');
INSERT INTO link_categories VALUES (530, 'Overview', 'overview', false, '2015-04-27 13:02:02.904', '2015-04-27 13:02:02.904');
INSERT INTO link_categories VALUES (531, 'Family', 'family', false, '2015-04-27 13:02:03.363', '2015-04-27 13:02:03.363');
INSERT INTO link_categories VALUES (532, 'Staff Support Services', 'staff support services', false, '2015-04-27 13:02:03.397', '2015-04-27 13:02:03.397');
INSERT INTO link_categories VALUES (533, 'Classroom Technology', 'classroom technology', false, '2015-04-27 13:02:03.497', '2015-04-27 13:02:03.497');
INSERT INTO link_categories VALUES (534, 'Students', 'students', false, '2015-04-27 13:02:03.767', '2015-04-27 13:02:03.767');
INSERT INTO link_categories VALUES (535, 'Emergency Preparedness', 'emergency preparedness', false, '2015-04-27 13:02:03.918', '2015-04-27 13:02:03.918');
INSERT INTO link_categories VALUES (536, 'Health & Safety', 'health & safety', false, '2015-04-27 13:02:04.014', '2015-04-27 13:02:04.014');
INSERT INTO link_categories VALUES (537, 'Employer & Employee', 'employer & employee', false, '2015-04-27 13:02:04.094', '2015-04-27 13:02:04.094');
INSERT INTO link_categories VALUES (538, 'News & Events', 'news & events', false, '2015-04-27 13:02:04.141', '2015-04-27 13:02:04.141');
INSERT INTO link_categories VALUES (539, 'Financial Assistance', 'financial assistance', false, '2015-04-27 13:02:04.227', '2015-04-27 13:02:04.227');
INSERT INTO link_categories VALUES (540, 'Computing', 'computing', false, '2015-04-27 13:02:04.389', '2015-04-27 13:02:04.389');
INSERT INTO link_categories VALUES (541, 'Graduate', 'graduate', false, '2015-04-27 13:02:04.502', '2015-04-27 13:02:04.502');
INSERT INTO link_categories VALUES (542, 'Human Resources', 'human resources', false, '2015-04-27 13:02:04.58', '2015-04-27 13:02:04.58');
INSERT INTO link_categories VALUES (543, 'Leaving Cal?', 'leaving cal?', false, '2015-04-27 13:02:04.654', '2015-04-27 13:02:04.654');
INSERT INTO link_categories VALUES (544, 'Library', 'library', false, '2015-04-27 13:02:05.018', '2015-04-27 13:02:05.018');
INSERT INTO link_categories VALUES (545, 'Campus Mail', 'campus mail', false, '2015-04-27 13:02:05.103', '2015-04-27 13:02:05.103');
INSERT INTO link_categories VALUES (546, 'Professional Development', 'professional development', false, '2015-04-27 13:02:05.409', '2015-04-27 13:02:05.409');
INSERT INTO link_categories VALUES (547, 'My Information', 'my information', false, '2015-04-27 13:02:05.536', '2015-04-27 13:02:05.536');
INSERT INTO link_categories VALUES (548, 'Sports & Recreation', 'sports & recreation', false, '2015-04-27 13:02:05.642', '2015-04-27 13:02:05.642');
INSERT INTO link_categories VALUES (549, 'Police', 'police', false, '2015-04-27 13:02:05.682', '2015-04-27 13:02:05.682');
INSERT INTO link_categories VALUES (550, 'Network & Computing', 'network & computing', false, '2015-04-27 13:02:05.975', '2015-04-27 13:02:05.975');
INSERT INTO link_categories VALUES (551, 'Retirement', 'retirement', false, '2015-04-27 13:02:06.052', '2015-04-27 13:02:06.052');
INSERT INTO link_categories VALUES (552, 'Summer Programs', 'summer programs', false, '2015-04-27 13:02:06.186', '2015-04-27 13:02:06.186');
INSERT INTO link_categories VALUES (553, 'Conflict Resolution', 'conflict resolution', false, '2015-04-27 13:02:06.38', '2015-04-27 13:02:06.38');
INSERT INTO link_categories VALUES (554, 'Service Requests', 'service requests', false, '2015-04-27 13:02:06.588', '2015-04-27 13:02:06.588');
INSERT INTO link_categories VALUES (555, 'Student Services', 'student services', false, '2015-04-27 13:02:06.808', '2015-04-27 13:02:06.808');
INSERT INTO link_categories VALUES (556, 'Travel & Entertainment', 'travel & entertainment', false, '2015-04-27 13:02:06.928', '2015-04-27 13:02:06.928');
INSERT INTO link_categories VALUES (557, 'Social Media', 'social media', false, '2015-04-27 13:02:06.972', '2015-04-27 13:02:06.972');
INSERT INTO link_categories VALUES (558, 'News & Information', 'news & information', false, '2015-04-27 13:02:07.045', '2015-04-27 13:02:07.045');
INSERT INTO link_categories VALUES (559, 'Student Employees', 'student employees', false, '2015-04-27 13:02:07.368', '2015-04-27 13:02:07.368');
INSERT INTO link_categories VALUES (560, 'Tools', 'tools', false, '2015-04-27 13:02:07.663', '2015-04-27 13:02:07.663');


--
-- Name: link_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('link_categories_id_seq', 560, true);


--
-- Data for Name: link_categories_link_sections; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: link_sections; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO link_sections VALUES (382, 480, 482, 493, '2015-04-27 13:01:59.931', '2015-04-27 13:01:59.931');
INSERT INTO link_sections VALUES (383, 480, 485, 494, '2015-04-27 13:02:00.081', '2015-04-27 13:02:00.081');
INSERT INTO link_sections VALUES (384, 468, 470, 495, '2015-04-27 13:02:00.143', '2015-04-27 13:02:00.143');
INSERT INTO link_sections VALUES (385, 468, 469, 468, '2015-04-27 13:02:00.255', '2015-04-27 13:02:00.255');
INSERT INTO link_sections VALUES (386, 474, 477, 496, '2015-04-27 13:02:00.329', '2015-04-27 13:02:00.329');
INSERT INTO link_sections VALUES (387, 468, 472, 497, '2015-04-27 13:02:00.398', '2015-04-27 13:02:00.398');
INSERT INTO link_sections VALUES (388, 474, 475, 498, '2015-04-27 13:02:00.453', '2015-04-27 13:02:00.453');
INSERT INTO link_sections VALUES (389, 474, 479, 499, '2015-04-27 13:02:00.518', '2015-04-27 13:02:00.518');
INSERT INTO link_sections VALUES (390, 487, 491, 500, '2015-04-27 13:02:00.582', '2015-04-27 13:02:00.582');
INSERT INTO link_sections VALUES (391, 474, 479, 501, '2015-04-27 13:02:00.643', '2015-04-27 13:02:00.643');
INSERT INTO link_sections VALUES (392, 474, 479, 502, '2015-04-27 13:02:00.703', '2015-04-27 13:02:00.703');
INSERT INTO link_sections VALUES (393, 468, 470, 503, '2015-04-27 13:02:00.819', '2015-04-27 13:02:00.819');
INSERT INTO link_sections VALUES (394, 474, 479, 504, '2015-04-27 13:02:00.895', '2015-04-27 13:02:00.895');
INSERT INTO link_sections VALUES (395, 480, 484, 505, '2015-04-27 13:02:00.966', '2015-04-27 13:02:00.966');
INSERT INTO link_sections VALUES (396, 468, 470, 506, '2015-04-27 13:02:01.027', '2015-04-27 13:02:01.027');
INSERT INTO link_sections VALUES (397, 487, 488, 507, '2015-04-27 13:02:01.087', '2015-04-27 13:02:01.087');
INSERT INTO link_sections VALUES (398, 480, 482, 508, '2015-04-27 13:02:01.141', '2015-04-27 13:02:01.141');
INSERT INTO link_sections VALUES (399, 468, 469, 509, '2015-04-27 13:02:01.201', '2015-04-27 13:02:01.201');
INSERT INTO link_sections VALUES (400, 487, 490, 510, '2015-04-27 13:02:01.304', '2015-04-27 13:02:01.304');
INSERT INTO link_sections VALUES (401, 487, 489, 511, '2015-04-27 13:02:01.352', '2015-04-27 13:02:01.352');
INSERT INTO link_sections VALUES (402, 474, 479, 512, '2015-04-27 13:02:01.403', '2015-04-27 13:02:01.403');
INSERT INTO link_sections VALUES (403, 468, 471, 513, '2015-04-27 13:02:01.492', '2015-04-27 13:02:01.492');
INSERT INTO link_sections VALUES (404, 474, 476, 514, '2015-04-27 13:02:01.545', '2015-04-27 13:02:01.545');
INSERT INTO link_sections VALUES (405, 487, 492, 515, '2015-04-27 13:02:01.602', '2015-04-27 13:02:01.602');
INSERT INTO link_sections VALUES (406, 487, 490, 516, '2015-04-27 13:02:01.655', '2015-04-27 13:02:01.655');
INSERT INTO link_sections VALUES (407, 474, 479, 517, '2015-04-27 13:02:01.731', '2015-04-27 13:02:01.731');
INSERT INTO link_sections VALUES (408, 480, 483, 518, '2015-04-27 13:02:01.782', '2015-04-27 13:02:01.782');
INSERT INTO link_sections VALUES (409, 480, 483, 508, '2015-04-27 13:02:01.833', '2015-04-27 13:02:01.833');
INSERT INTO link_sections VALUES (410, 480, 485, 518, '2015-04-27 13:02:01.972', '2015-04-27 13:02:01.972');
INSERT INTO link_sections VALUES (411, 468, 470, 519, '2015-04-27 13:02:02.019', '2015-04-27 13:02:02.019');
INSERT INTO link_sections VALUES (412, 487, 489, 520, '2015-04-27 13:02:02.039', '2015-04-27 13:02:02.039');
INSERT INTO link_sections VALUES (413, 480, 483, 521, '2015-04-27 13:02:02.136', '2015-04-27 13:02:02.136');
INSERT INTO link_sections VALUES (414, 480, 485, 522, '2015-04-27 13:02:02.234', '2015-04-27 13:02:02.234');
INSERT INTO link_sections VALUES (415, 474, 476, 523, '2015-04-27 13:02:02.348', '2015-04-27 13:02:02.348');
INSERT INTO link_sections VALUES (416, 474, 476, 524, '2015-04-27 13:02:02.401', '2015-04-27 13:02:02.401');
INSERT INTO link_sections VALUES (417, 474, 479, 525, '2015-04-27 13:02:02.503', '2015-04-27 13:02:02.503');
INSERT INTO link_sections VALUES (418, 474, 479, 526, '2015-04-27 13:02:02.584', '2015-04-27 13:02:02.584');
INSERT INTO link_sections VALUES (419, 480, 481, 527, '2015-04-27 13:02:02.662', '2015-04-27 13:02:02.662');
INSERT INTO link_sections VALUES (420, 480, 481, 528, '2015-04-27 13:02:02.773', '2015-04-27 13:02:02.773');
INSERT INTO link_sections VALUES (421, 480, 482, 529, '2015-04-27 13:02:02.862', '2015-04-27 13:02:02.862');
INSERT INTO link_sections VALUES (422, 474, 478, 530, '2015-04-27 13:02:02.915', '2015-04-27 13:02:02.915');
INSERT INTO link_sections VALUES (423, 487, 490, 531, '2015-04-27 13:02:03.376', '2015-04-27 13:02:03.376');
INSERT INTO link_sections VALUES (424, 487, 491, 531, '2015-04-27 13:02:03.389', '2015-04-27 13:02:03.389');
INSERT INTO link_sections VALUES (425, 487, 492, 532, '2015-04-27 13:02:03.408', '2015-04-27 13:02:03.408');
INSERT INTO link_sections VALUES (426, 468, 472, 533, '2015-04-27 13:02:03.508', '2015-04-27 13:02:03.508');
INSERT INTO link_sections VALUES (427, 468, 470, 471, '2015-04-27 13:02:03.684', '2015-04-27 13:02:03.684');
INSERT INTO link_sections VALUES (428, 468, 471, 471, '2015-04-27 13:02:03.701', '2015-04-27 13:02:03.701');
INSERT INTO link_sections VALUES (429, 480, 486, 534, '2015-04-27 13:02:03.78', '2015-04-27 13:02:03.78');
INSERT INTO link_sections VALUES (430, 480, 484, 535, '2015-04-27 13:02:03.931', '2015-04-27 13:02:03.931');
INSERT INTO link_sections VALUES (431, 468, 473, 536, '2015-04-27 13:02:04.026', '2015-04-27 13:02:04.026');
INSERT INTO link_sections VALUES (432, 474, 477, 537, '2015-04-27 13:02:04.105', '2015-04-27 13:02:04.105');
INSERT INTO link_sections VALUES (433, 480, 481, 538, '2015-04-27 13:02:04.152', '2015-04-27 13:02:04.152');
INSERT INTO link_sections VALUES (434, 487, 489, 539, '2015-04-27 13:02:04.238', '2015-04-27 13:02:04.238');
INSERT INTO link_sections VALUES (435, 474, 479, 540, '2015-04-27 13:02:04.4', '2015-04-27 13:02:04.4');
INSERT INTO link_sections VALUES (436, 468, 469, 541, '2015-04-27 13:02:04.513', '2015-04-27 13:02:04.513');
INSERT INTO link_sections VALUES (437, 474, 479, 542, '2015-04-27 13:02:04.59', '2015-04-27 13:02:04.59');
INSERT INTO link_sections VALUES (438, 487, 489, 543, '2015-04-27 13:02:04.664', '2015-04-27 13:02:04.664');
INSERT INTO link_sections VALUES (439, 468, 473, 530, '2015-04-27 13:02:04.984', '2015-04-27 13:02:04.984');
INSERT INTO link_sections VALUES (440, 468, 469, 544, '2015-04-27 13:02:05.029', '2015-04-27 13:02:05.029');
INSERT INTO link_sections VALUES (441, 474, 479, 545, '2015-04-27 13:02:05.113', '2015-04-27 13:02:05.113');
INSERT INTO link_sections VALUES (442, 468, 473, 546, '2015-04-27 13:02:05.419', '2015-04-27 13:02:05.419');
INSERT INTO link_sections VALUES (443, 487, 491, 547, '2015-04-27 13:02:05.546', '2015-04-27 13:02:05.546');
INSERT INTO link_sections VALUES (444, 480, 483, 548, '2015-04-27 13:02:05.653', '2015-04-27 13:02:05.653');
INSERT INTO link_sections VALUES (445, 480, 484, 549, '2015-04-27 13:02:05.692', '2015-04-27 13:02:05.692');
INSERT INTO link_sections VALUES (446, 487, 490, 550, '2015-04-27 13:02:05.985', '2015-04-27 13:02:05.985');
INSERT INTO link_sections VALUES (447, 487, 491, 551, '2015-04-27 13:02:06.062', '2015-04-27 13:02:06.062');
INSERT INTO link_sections VALUES (448, 487, 489, 552, '2015-04-27 13:02:06.196', '2015-04-27 13:02:06.196');
INSERT INTO link_sections VALUES (449, 487, 491, 553, '2015-04-27 13:02:06.391', '2015-04-27 13:02:06.391');
INSERT INTO link_sections VALUES (450, 474, 478, 554, '2015-04-27 13:02:06.599', '2015-04-27 13:02:06.599');
INSERT INTO link_sections VALUES (451, 474, 475, 555, '2015-04-27 13:02:06.818', '2015-04-27 13:02:06.818');
INSERT INTO link_sections VALUES (452, 474, 479, 556, '2015-04-27 13:02:06.937', '2015-04-27 13:02:06.937');
INSERT INTO link_sections VALUES (453, 480, 481, 557, '2015-04-27 13:02:06.981', '2015-04-27 13:02:06.981');
INSERT INTO link_sections VALUES (454, 487, 492, 558, '2015-04-27 13:02:07.055', '2015-04-27 13:02:07.055');
INSERT INTO link_sections VALUES (455, 487, 488, 559, '2015-04-27 13:02:07.377', '2015-04-27 13:02:07.377');
INSERT INTO link_sections VALUES (456, 468, 472, 560, '2015-04-27 13:02:07.673', '2015-04-27 13:02:07.673');


--
-- Name: link_sections_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('link_sections_id_seq', 456, true);


--
-- Data for Name: link_sections_links; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO link_sections_links VALUES (382, 891);
INSERT INTO link_sections_links VALUES (383, 892);
INSERT INTO link_sections_links VALUES (384, 893);
INSERT INTO link_sections_links VALUES (384, 894);
INSERT INTO link_sections_links VALUES (385, 895);
INSERT INTO link_sections_links VALUES (386, 896);
INSERT INTO link_sections_links VALUES (387, 897);
INSERT INTO link_sections_links VALUES (388, 898);
INSERT INTO link_sections_links VALUES (389, 899);
INSERT INTO link_sections_links VALUES (390, 900);
INSERT INTO link_sections_links VALUES (391, 901);
INSERT INTO link_sections_links VALUES (392, 902);
INSERT INTO link_sections_links VALUES (391, 903);
INSERT INTO link_sections_links VALUES (393, 904);
INSERT INTO link_sections_links VALUES (394, 905);
INSERT INTO link_sections_links VALUES (395, 906);
INSERT INTO link_sections_links VALUES (396, 907);
INSERT INTO link_sections_links VALUES (397, 908);
INSERT INTO link_sections_links VALUES (398, 909);
INSERT INTO link_sections_links VALUES (399, 910);
INSERT INTO link_sections_links VALUES (388, 911);
INSERT INTO link_sections_links VALUES (400, 912);
INSERT INTO link_sections_links VALUES (401, 913);
INSERT INTO link_sections_links VALUES (402, 914);
INSERT INTO link_sections_links VALUES (394, 915);
INSERT INTO link_sections_links VALUES (403, 916);
INSERT INTO link_sections_links VALUES (404, 917);
INSERT INTO link_sections_links VALUES (405, 918);
INSERT INTO link_sections_links VALUES (406, 919);
INSERT INTO link_sections_links VALUES (389, 919);
INSERT INTO link_sections_links VALUES (407, 920);
INSERT INTO link_sections_links VALUES (408, 921);
INSERT INTO link_sections_links VALUES (409, 922);
INSERT INTO link_sections_links VALUES (409, 923);
INSERT INTO link_sections_links VALUES (400, 924);
INSERT INTO link_sections_links VALUES (410, 925);
INSERT INTO link_sections_links VALUES (411, 926);
INSERT INTO link_sections_links VALUES (412, 926);
INSERT INTO link_sections_links VALUES (409, 927);
INSERT INTO link_sections_links VALUES (413, 928);
INSERT INTO link_sections_links VALUES (406, 929);
INSERT INTO link_sections_links VALUES (400, 930);
INSERT INTO link_sections_links VALUES (414, 930);
INSERT INTO link_sections_links VALUES (414, 931);
INSERT INTO link_sections_links VALUES (415, 932);
INSERT INTO link_sections_links VALUES (416, 933);
INSERT INTO link_sections_links VALUES (389, 934);
INSERT INTO link_sections_links VALUES (417, 935);
INSERT INTO link_sections_links VALUES (404, 936);
INSERT INTO link_sections_links VALUES (418, 937);
INSERT INTO link_sections_links VALUES (397, 938);
INSERT INTO link_sections_links VALUES (419, 939);
INSERT INTO link_sections_links VALUES (403, 940);
INSERT INTO link_sections_links VALUES (391, 941);
INSERT INTO link_sections_links VALUES (420, 942);
INSERT INTO link_sections_links VALUES (388, 943);
INSERT INTO link_sections_links VALUES (421, 944);
INSERT INTO link_sections_links VALUES (422, 945);
INSERT INTO link_sections_links VALUES (382, 946);
INSERT INTO link_sections_links VALUES (397, 947);
INSERT INTO link_sections_links VALUES (397, 948);
INSERT INTO link_sections_links VALUES (397, 949);
INSERT INTO link_sections_links VALUES (397, 950);
INSERT INTO link_sections_links VALUES (397, 951);
INSERT INTO link_sections_links VALUES (423, 952);
INSERT INTO link_sections_links VALUES (424, 952);
INSERT INTO link_sections_links VALUES (425, 952);
INSERT INTO link_sections_links VALUES (382, 953);
INSERT INTO link_sections_links VALUES (426, 954);
INSERT INTO link_sections_links VALUES (385, 955);
INSERT INTO link_sections_links VALUES (386, 956);
INSERT INTO link_sections_links VALUES (396, 957);
INSERT INTO link_sections_links VALUES (396, 958);
INSERT INTO link_sections_links VALUES (427, 959);
INSERT INTO link_sections_links VALUES (428, 959);
INSERT INTO link_sections_links VALUES (429, 960);
INSERT INTO link_sections_links VALUES (411, 961);
INSERT INTO link_sections_links VALUES (427, 962);
INSERT INTO link_sections_links VALUES (428, 962);
INSERT INTO link_sections_links VALUES (430, 963);
INSERT INTO link_sections_links VALUES (430, 964);
INSERT INTO link_sections_links VALUES (431, 965);
INSERT INTO link_sections_links VALUES (388, 966);
INSERT INTO link_sections_links VALUES (432, 967);
INSERT INTO link_sections_links VALUES (433, 968);
INSERT INTO link_sections_links VALUES (385, 969);
INSERT INTO link_sections_links VALUES (434, 970);
INSERT INTO link_sections_links VALUES (388, 971);
INSERT INTO link_sections_links VALUES (387, 972);
INSERT INTO link_sections_links VALUES (434, 973);
INSERT INTO link_sections_links VALUES (396, 974);
INSERT INTO link_sections_links VALUES (435, 975);
INSERT INTO link_sections_links VALUES (419, 976);
INSERT INTO link_sections_links VALUES (383, 977);
INSERT INTO link_sections_links VALUES (436, 978);
INSERT INTO link_sections_links VALUES (434, 979);
INSERT INTO link_sections_links VALUES (437, 980);
INSERT INTO link_sections_links VALUES (437, 981);
INSERT INTO link_sections_links VALUES (438, 982);
INSERT INTO link_sections_links VALUES (401, 983);
INSERT INTO link_sections_links VALUES (405, 983);
INSERT INTO link_sections_links VALUES (435, 984);
INSERT INTO link_sections_links VALUES (435, 985);
INSERT INTO link_sections_links VALUES (435, 986);
INSERT INTO link_sections_links VALUES (400, 987);
INSERT INTO link_sections_links VALUES (433, 988);
INSERT INTO link_sections_links VALUES (409, 988);
INSERT INTO link_sections_links VALUES (431, 989);
INSERT INTO link_sections_links VALUES (439, 990);
INSERT INTO link_sections_links VALUES (440, 991);
INSERT INTO link_sections_links VALUES (403, 991);
INSERT INTO link_sections_links VALUES (400, 992);
INSERT INTO link_sections_links VALUES (441, 993);
INSERT INTO link_sections_links VALUES (429, 994);
INSERT INTO link_sections_links VALUES (434, 995);
INSERT INTO link_sections_links VALUES (387, 996);
INSERT INTO link_sections_links VALUES (429, 997);
INSERT INTO link_sections_links VALUES (433, 998);
INSERT INTO link_sections_links VALUES (411, 999);
INSERT INTO link_sections_links VALUES (388, 1000);
INSERT INTO link_sections_links VALUES (393, 1001);
INSERT INTO link_sections_links VALUES (435, 1002);
INSERT INTO link_sections_links VALUES (442, 1003);
INSERT INTO link_sections_links VALUES (382, 1004);
INSERT INTO link_sections_links VALUES (401, 1005);
INSERT INTO link_sections_links VALUES (418, 1006);
INSERT INTO link_sections_links VALUES (443, 1007);
INSERT INTO link_sections_links VALUES (443, 1008);
INSERT INTO link_sections_links VALUES (432, 1009);
INSERT INTO link_sections_links VALUES (444, 1010);
INSERT INTO link_sections_links VALUES (445, 1011);
INSERT INTO link_sections_links VALUES (386, 1012);
INSERT INTO link_sections_links VALUES (419, 1013);
INSERT INTO link_sections_links VALUES (394, 1014);
INSERT INTO link_sections_links VALUES (444, 1015);
INSERT INTO link_sections_links VALUES (401, 1016);
INSERT INTO link_sections_links VALUES (399, 1017);
INSERT INTO link_sections_links VALUES (404, 1018);
INSERT INTO link_sections_links VALUES (400, 1019);
INSERT INTO link_sections_links VALUES (446, 1020);
INSERT INTO link_sections_links VALUES (435, 1020);
INSERT INTO link_sections_links VALUES (429, 1021);
INSERT INTO link_sections_links VALUES (447, 1022);
INSERT INTO link_sections_links VALUES (447, 1023);
INSERT INTO link_sections_links VALUES (389, 1024);
INSERT INTO link_sections_links VALUES (430, 1025);
INSERT INTO link_sections_links VALUES (448, 1026);
INSERT INTO link_sections_links VALUES (396, 1027);
INSERT INTO link_sections_links VALUES (396, 1028);
INSERT INTO link_sections_links VALUES (428, 1028);
INSERT INTO link_sections_links VALUES (396, 1029);
INSERT INTO link_sections_links VALUES (428, 1029);
INSERT INTO link_sections_links VALUES (435, 1030);
INSERT INTO link_sections_links VALUES (449, 1031);
INSERT INTO link_sections_links VALUES (386, 1032);
INSERT INTO link_sections_links VALUES (388, 1033);
INSERT INTO link_sections_links VALUES (434, 1034);
INSERT INTO link_sections_links VALUES (411, 1035);
INSERT INTO link_sections_links VALUES (429, 1036);
INSERT INTO link_sections_links VALUES (414, 1037);
INSERT INTO link_sections_links VALUES (450, 1038);
INSERT INTO link_sections_links VALUES (448, 1039);
INSERT INTO link_sections_links VALUES (396, 1040);
INSERT INTO link_sections_links VALUES (428, 1040);
INSERT INTO link_sections_links VALUES (401, 1041);
INSERT INTO link_sections_links VALUES (387, 1042);
INSERT INTO link_sections_links VALUES (396, 1043);
INSERT INTO link_sections_links VALUES (433, 1044);
INSERT INTO link_sections_links VALUES (451, 1045);
INSERT INTO link_sections_links VALUES (433, 1046);
INSERT INTO link_sections_links VALUES (429, 1047);
INSERT INTO link_sections_links VALUES (452, 1048);
INSERT INTO link_sections_links VALUES (453, 1049);
INSERT INTO link_sections_links VALUES (453, 1050);
INSERT INTO link_sections_links VALUES (454, 1051);
INSERT INTO link_sections_links VALUES (409, 1052);
INSERT INTO link_sections_links VALUES (427, 1053);
INSERT INTO link_sections_links VALUES (428, 1053);
INSERT INTO link_sections_links VALUES (442, 1053);
INSERT INTO link_sections_links VALUES (442, 1054);
INSERT INTO link_sections_links VALUES (405, 1055);
INSERT INTO link_sections_links VALUES (405, 1056);
INSERT INTO link_sections_links VALUES (384, 1057);
INSERT INTO link_sections_links VALUES (388, 1058);
INSERT INTO link_sections_links VALUES (387, 1059);
INSERT INTO link_sections_links VALUES (438, 1060);
INSERT INTO link_sections_links VALUES (455, 1061);
INSERT INTO link_sections_links VALUES (434, 1061);
INSERT INTO link_sections_links VALUES (403, 1062);
INSERT INTO link_sections_links VALUES (415, 1063);
INSERT INTO link_sections_links VALUES (415, 1064);
INSERT INTO link_sections_links VALUES (428, 1065);
INSERT INTO link_sections_links VALUES (415, 1066);
INSERT INTO link_sections_links VALUES (415, 1067);
INSERT INTO link_sections_links VALUES (427, 1068);
INSERT INTO link_sections_links VALUES (428, 1068);
INSERT INTO link_sections_links VALUES (404, 1068);
INSERT INTO link_sections_links VALUES (456, 1069);
INSERT INTO link_sections_links VALUES (387, 1070);
INSERT INTO link_sections_links VALUES (401, 1071);
INSERT INTO link_sections_links VALUES (403, 1072);


--
-- Data for Name: links; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO links VALUES (891, '511.org (Bay Area Transportation Planner)', 'http://www.511.org/', 'Calculates transportation options for traveling', true, '2015-04-27 13:02:00.026', '2015-04-27 13:02:00.026');
INSERT INTO links VALUES (892, 'ASUC', 'http://asuc.org/', 'Student government', true, '2015-04-27 13:02:00.106', '2015-04-27 13:02:00.106');
INSERT INTO links VALUES (893, 'Academic Calendar', 'http://registrar.berkeley.edu/CalendarDisp.aspx?terms=current', 'Academic Calendars Future Campus Calendars', true, '2015-04-27 13:02:00.169', '2015-04-27 13:02:00.169');
INSERT INTO links VALUES (894, 'Academic Calendar - Berkeley Law', 'https://www.law.berkeley.edu/php-programs/courses/academic_calendars.php', 'Academic calendar including academic and administrative holidays', true, '2015-04-27 13:02:00.22', '2015-04-27 13:02:00.22');
INSERT INTO links VALUES (895, 'Academic Departments & Programs', 'http://www.berkeley.edu/academics/dept/a.shtml', 'UC Berkeley''s variety of degree programs', true, '2015-04-27 13:02:00.28', '2015-04-27 13:02:00.28');
INSERT INTO links VALUES (896, 'Academic Policies', 'http://bulletin.berkeley.edu/academic-policies/', 'Policies set by the university specific for Berkeley students', true, '2015-04-27 13:02:00.355', '2015-04-27 13:02:00.355');
INSERT INTO links VALUES (897, 'Academic Senate', 'http://academic-senate.berkeley.edu/', 'Governance held by faculty member to make decisions campus-wide', true, '2015-04-27 13:02:00.419', '2015-04-27 13:02:00.419');
INSERT INTO links VALUES (898, 'Administration & Finance', 'http://vcaf.berkeley.edu/who-we-are/divisions', 'Administration officials ', true, '2015-04-27 13:02:00.477', '2015-04-27 13:02:00.477');
INSERT INTO links VALUES (899, 'AirBears', 'http://ist.berkeley.edu/airbears/', 'Berkeley''s free internet wifi for Berkeley affiliates with a calnet and passphrase', true, '2015-04-27 13:02:00.541', '2015-04-27 13:02:00.541');
INSERT INTO links VALUES (900, 'At Your Service', 'https://atyourserviceonline.ucop.edu', 'Benefits, Earnings, Taxes & Retirement', true, '2015-04-27 13:02:00.605', '2015-04-27 13:02:00.605');
INSERT INTO links VALUES (901, 'BAIRS', 'http://www.bai.berkeley.edu/BAIRS/index.htm', 'Berkeley Administrative Initiative Reporting System', true, '2015-04-27 13:02:00.666', '2015-04-27 13:02:00.666');
INSERT INTO links VALUES (902, 'BETS - equipment tracking', 'http://bets.berkeley.edu/BETS/home/BetsHome.cfm', 'Equipment Tracking System of inventorial and non-inventorial equipment', true, '2015-04-27 13:02:00.723', '2015-04-27 13:02:00.723');
INSERT INTO links VALUES (903, 'BFS', 'http://www.bai.berkeley.edu/BFS/index.htm', 'Berkeley Financial System', true, '2015-04-27 13:02:00.773', '2015-04-27 13:02:00.773');
INSERT INTO links VALUES (904, 'Bear Facts', 'https://bearfacts.berkeley.edu', 'Academic record, grades & transcript, bill, degree audit, loans, SLR & personal info', true, '2015-04-27 13:02:00.844', '2015-04-27 13:02:00.844');
INSERT INTO links VALUES (905, 'BearBuy', 'http://supplychain.berkeley.edu/bearbuy/', 'Campus procurement system with online catalog shopping and electronically-enabled workflows', true, '2015-04-27 13:02:00.925', '2015-04-27 13:02:00.925');
INSERT INTO links VALUES (906, 'BearWALK Night safety services', 'http://police.berkeley.edu/programsandservices/campus_safety/index.html', 'Free safety night walks to and from a desired location with a Community Service Officer', true, '2015-04-27 13:02:00.988', '2015-04-27 13:02:00.988');
INSERT INTO links VALUES (907, 'Berkeley Academic Guide', 'http://guide.berkeley.edu/', 'Degree programs, academic policies, and course catalog', true, '2015-04-27 13:02:01.049', '2015-04-27 13:02:01.049');
INSERT INTO links VALUES (908, 'Berkeley Jobs', 'http://jobs.berkeley.edu/', 'Start here to learn about job openings on campus, student, staff and academic positions', true, '2015-04-27 13:02:01.107', '2015-04-27 13:02:01.107');
INSERT INTO links VALUES (909, 'Berkeley Online Tour', 'http://www.berkeley.edu/tour/', 'Instructor and student perspectives and virtual campus tours of Berkeley', true, '2015-04-27 13:02:01.162', '2015-04-27 13:02:01.162');
INSERT INTO links VALUES (910, 'Berkeley Research', 'http://vcresearch.berkeley.edu/', 'Research information and opportunities', true, '2015-04-27 13:02:01.222', '2015-04-27 13:02:01.222');
INSERT INTO links VALUES (911, 'Berkeley Sites (A-Z)', 'http://www.berkeley.edu/a-z/a.shtml', 'Navigating UC Berkeley', true, '2015-04-27 13:02:01.262', '2015-04-27 13:02:01.262');
INSERT INTO links VALUES (912, 'Berkeley Student Cooperative', 'http://www.bsc.coop/', 'Berkeley''s co-operative student housing option, and an alternative to living in student dorms', true, '2015-04-27 13:02:01.323', '2015-04-27 13:02:01.323');
INSERT INTO links VALUES (913, 'Billing Services', 'http://studentbilling.berkeley.edu/', 'Billing and payment options for students and parents', true, '2015-04-27 13:02:01.37', '2015-04-27 13:02:01.37');
INSERT INTO links VALUES (914, 'Blu', 'http://blu.berkeley.edu', 'Berkeley''s employee portal: work-related tools and information', true, '2015-04-27 13:02:01.423', '2015-04-27 13:02:01.423');
INSERT INTO links VALUES (915, 'Blu Card', 'http://supplychain.berkeley.edu/programs/card-program-services/blucard', 'A procurement card, issued to select employees, and used for purchasing work-related items and services', true, '2015-04-27 13:02:01.458', '2015-04-27 13:02:01.458');
INSERT INTO links VALUES (916, 'Bookstore - Berkeley Law', 'http://www.law.berkeley.edu/15687.htm', 'Textbooks and other learning resources for Berkeley Law students', true, '2015-04-27 13:02:01.512', '2015-04-27 13:02:01.512');
INSERT INTO links VALUES (917, 'Box.net', 'https://berkeley.box.com/', 'Cloud-hosted platform allowing users to store and share documents and other materials for collaborations', true, '2015-04-27 13:02:01.566', '2015-04-27 13:02:01.566');
INSERT INTO links VALUES (918, 'CARE Services', 'http://uhs.berkeley.edu/facstaff/care/', 'free, confidential problem assessment and referral for UC Berkeley faculty and staff', true, '2015-04-27 13:02:01.621', '2015-04-27 13:02:01.621');
INSERT INTO links VALUES (919, 'Cal 1 Card', 'http://services.housing.berkeley.edu/c1c/static/index.htm', 'The campus identification, and optional, debit and meal points card.', true, '2015-04-27 13:02:01.689', '2015-04-27 13:02:01.689');
INSERT INTO links VALUES (920, 'Cal Answers', 'http://calanswers.berkeley.edu/', 'Provides reliable and consistent answers to critical campus questions', true, '2015-04-27 13:02:01.751', '2015-04-27 13:02:01.751');
INSERT INTO links VALUES (921, 'Cal Band', 'http://calband.berkeley.edu/', 'UC Berkeley''s marching band', true, '2015-04-27 13:02:01.803', '2015-04-27 13:02:01.803');
INSERT INTO links VALUES (922, 'Cal Marketplace', 'http://calmarketplace.berkeley.edu/', 'Everything at Cal you may want to buy, discover or visit', true, '2015-04-27 13:02:01.855', '2015-04-27 13:02:01.855');
INSERT INTO links VALUES (923, 'Cal Performances', 'http://www.calperformances.org/', 'Information and tickets for Cal music, dance, and theater performances', true, '2015-04-27 13:02:01.898', '2015-04-27 13:02:01.898');
INSERT INTO links VALUES (924, 'Cal Rentals', 'http://calrentals.housing.berkeley.edu/', 'Listings of housing opportunities for the Berkeley community', true, '2015-04-27 13:02:01.94', '2015-04-27 13:02:01.94');
INSERT INTO links VALUES (925, 'Cal Spirit Groups', 'http://calspirit.berkeley.edu/', 'Cheerleading and Dance Group ', true, '2015-04-27 13:02:01.99', '2015-04-27 13:02:01.99');
INSERT INTO links VALUES (926, 'Cal Student Central', 'http://studentcentral.berkeley.edu/', 'A resourceful website with answers to the most frequently asked questions by students', true, '2015-04-27 13:02:02.065', '2015-04-27 13:02:02.065');
INSERT INTO links VALUES (927, 'Cal Student Store', 'https://calstudentstore.berkeley.edu/', 'Apparel, school supplies, and more ', true, '2015-04-27 13:02:02.101', '2015-04-27 13:02:02.101');
INSERT INTO links VALUES (928, 'CalBears Intercollegiate Athletics', 'http://www.calbears.com/', 'Berkeley''s official sport teams', true, '2015-04-27 13:02:02.156', '2015-04-27 13:02:02.156');
INSERT INTO links VALUES (929, 'CalDining', 'http://caldining.berkeley.edu/', 'Campus dining facilities', true, '2015-04-27 13:02:02.196', '2015-04-27 13:02:02.196');
INSERT INTO links VALUES (930, 'CalGreeks', 'http://www.calgreeks.com/', 'Fraternities, Sororities, and professional fraternities among the Greek Family', true, '2015-04-27 13:02:02.279', '2015-04-27 13:02:02.279');
INSERT INTO links VALUES (931, 'CalLink (Campus Activities Link)', 'http://callink.berkeley.edu/', 'Official campus student groups', true, '2015-04-27 13:02:02.319', '2015-04-27 13:02:02.319');
INSERT INTO links VALUES (932, 'CalMail', 'http://calmail.berkeley.edu', 'Campus email management', true, '2015-04-27 13:02:02.368', '2015-04-27 13:02:02.368');
INSERT INTO links VALUES (933, 'CalMessages', 'https://calmessages.berkeley.edu/', 'Berkeley''s official messaging system used to send broadcast email notifications to all staff, all students, etc.', true, '2015-04-27 13:02:02.419', '2015-04-27 13:02:02.419');
INSERT INTO links VALUES (934, 'CalNet', 'https://calnet.berkeley.edu/', 'An online identity username that all Berkeley affiliates have to log into Berkeley websites', true, '2015-04-27 13:02:02.452', '2015-04-27 13:02:02.452');
INSERT INTO links VALUES (935, 'CalPlanning', 'http://budget.berkeley.edu/systems/calplanning', 'UC Berkeley''s financial planning and analysis tool', true, '2015-04-27 13:02:02.521', '2015-04-27 13:02:02.521');
INSERT INTO links VALUES (936, 'CalShare', 'https://calshare.berkeley.edu/', 'Tool for creating and managing web sites for collaboration purposes', true, '2015-04-27 13:02:02.551', '2015-04-27 13:02:02.551');
INSERT INTO links VALUES (937, 'CalTime', 'http://caltime.berkeley.edu', 'Tracking and reporting work and time leave-timekeeping', true, '2015-04-27 13:02:02.603', '2015-04-27 13:02:02.603');
INSERT INTO links VALUES (938, 'Callisto & CalJobs', 'https://career.berkeley.edu/CareerApps/Callisto/CallistoLogin.aspx', 'Official Berkeley website for all things job-related', true, '2015-04-27 13:02:02.635', '2015-04-27 13:02:02.635');
INSERT INTO links VALUES (939, 'Campaign for Berkeley', 'http://campaign.berkeley.edu/', 'The campaign to raise money to help Berkeley''s programs and affiliates', true, '2015-04-27 13:02:02.68', '2015-04-27 13:02:02.68');
INSERT INTO links VALUES (940, 'Campus Bookstore', 'https://calstudentstore.berkeley.edu/textbook', 'Text books and more', true, '2015-04-27 13:02:02.715', '2015-04-27 13:02:02.715');
INSERT INTO links VALUES (941, 'Campus Deposit System (CDS)', 'https://cdsonline.berkeley.edu', 'Financial system used by departments to make cash deposits to their accounts', true, '2015-04-27 13:02:02.746', '2015-04-27 13:02:02.746');
INSERT INTO links VALUES (942, 'Campus Directory - People Finder', 'http://directory.berkeley.edu', 'Campus directory of faculty, staff and students', true, '2015-04-27 13:02:02.791', '2015-04-27 13:02:02.791');
INSERT INTO links VALUES (943, 'Campus IT Offices', 'http://www.berkeley.edu/admin/compute.shtml#offices', 'Contact information for information technology services', true, '2015-04-27 13:02:02.829', '2015-04-27 13:02:02.829');
INSERT INTO links VALUES (944, 'Campus Map', 'http://www.berkeley.edu/map/3dmap/3dmap.shtml', 'Locate campus buildings', true, '2015-04-27 13:02:02.881', '2015-04-27 13:02:02.881');
INSERT INTO links VALUES (945, 'Campus Shared Services', 'http://sharedservices.berkeley.edu/', 'Answers to questions and the ability to submit help requests', true, '2015-04-27 13:02:02.934', '2015-04-27 13:02:02.934');
INSERT INTO links VALUES (946, 'Campus Shuttles', 'http://pt.berkeley.edu/around/transit/routes/', 'Bus routes around the Berkeley campus (most are free)', true, '2015-04-27 13:02:03.171', '2015-04-27 13:02:03.171');
INSERT INTO links VALUES (947, 'Career Center', 'http://career.berkeley.edu/', 'Cal jobs, internships & career counseling', true, '2015-04-27 13:02:03.219', '2015-04-27 13:02:03.219');
INSERT INTO links VALUES (948, 'Career Center: Internships', 'https://career.berkeley.edu/Internships/Internships.stm', 'Resources and Information for Internships', true, '2015-04-27 13:02:03.257', '2015-04-27 13:02:03.257');
INSERT INTO links VALUES (949, 'Career Center: Job Search Tools', 'https://career.berkeley.edu/Tools/Tools.stm', 'Resources on how to find a good job or internship ', true, '2015-04-27 13:02:03.287', '2015-04-27 13:02:03.287');
INSERT INTO links VALUES (950, 'Career Center: Part-time Employment', 'https://career.berkeley.edu/Parttime/Parttime.stm', 'Links to part-time websites', true, '2015-04-27 13:02:03.32', '2015-04-27 13:02:03.32');
INSERT INTO links VALUES (951, 'Career Development Office - Berkeley Law', 'http://www.law.berkeley.edu/careers.htm', 'Berkeley Law career development office', true, '2015-04-27 13:02:03.347', '2015-04-27 13:02:03.347');
INSERT INTO links VALUES (952, 'Child Care', 'http://www.housing.berkeley.edu/child/', 'Campus child care services', true, '2015-04-27 13:02:03.441', '2015-04-27 13:02:03.441');
INSERT INTO links VALUES (953, 'Class pass', 'http://pt.berkeley.edu/pay/transit/classpass/', 'AC Transit Pass to bus for free', true, '2015-04-27 13:02:03.481', '2015-04-27 13:02:03.481');
INSERT INTO links VALUES (954, 'Classroom Technology', 'http://ets.berkeley.edu/classroom-technology/', 'Provide reliable resources and technical support to the UCB campus', true, '2015-04-27 13:02:03.525', '2015-04-27 13:02:03.525');
INSERT INTO links VALUES (955, 'Colleges & Schools', 'http://www.berkeley.edu/academics/school.shtml', 'Different departments (colleges) that majors fall under', true, '2015-04-27 13:02:03.553', '2015-04-27 13:02:03.553');
INSERT INTO links VALUES (956, 'Computer Use Policy', 'https://security.berkeley.edu/policy/usepolicy.html', 'Rules, rights, and policies regarding computer facilities', true, '2015-04-27 13:02:03.59', '2015-04-27 13:02:03.59');
INSERT INTO links VALUES (957, 'Course Catalog', 'http://guide.berkeley.edu/courses/', 'Detailed course descriptions', true, '2015-04-27 13:02:03.626', '2015-04-27 13:02:03.626');
INSERT INTO links VALUES (958, 'DARS', 'https://marin.berkeley.edu/darsweb/servlet/ListAuditsServlet ', 'Degree requirements and track progress', true, '2015-04-27 13:02:03.662', '2015-04-27 13:02:03.662');
INSERT INTO links VALUES (959, 'DeCal Courses', 'http://www.decal.org/ ', 'Catalog of student-led courses', true, '2015-04-27 13:02:03.736', '2015-04-27 13:02:03.736');
INSERT INTO links VALUES (960, 'Disabled Students Program', 'http://dsp.berkeley.edu/', 'Resources specific to disabled students', true, '2015-04-27 13:02:03.8', '2015-04-27 13:02:03.8');
INSERT INTO links VALUES (961, 'Educational Opportunity Program', 'http://eop.berkeley.edu', 'Guidance and resources for first generation and low-income college students.', true, '2015-04-27 13:02:03.831', '2015-04-27 13:02:03.831');
INSERT INTO links VALUES (962, 'Edx Classes at Berkeley', 'https://www.edx.org/university_profile/BerkeleyX', 'Resources that advise, coordinate, and facilitate the University’s online education initiatives', true, '2015-04-27 13:02:03.881', '2015-04-27 13:02:03.881');
INSERT INTO links VALUES (963, 'Emergency Preparedness', 'http://oep.berkeley.edu/', 'How to be prepared and ready for emergencies', true, '2015-04-27 13:02:03.95', '2015-04-27 13:02:03.95');
INSERT INTO links VALUES (964, 'Emergency information', 'http://emergency.berkeley.edu/', 'Go-to site for emergency response information', true, '2015-04-27 13:02:03.989', '2015-04-27 13:02:03.989');
INSERT INTO links VALUES (965, 'Environmental Health & Safety', 'http://www.ehs.berkeley.edu/', 'Services to the campus community that promote health, safety, and environmental stewardship', true, '2015-04-27 13:02:04.042', '2015-04-27 13:02:04.042');
INSERT INTO links VALUES (966, 'Equity, Inclusion & Diversity', 'http://diversity.berkeley.edu/', 'Creating a fair and inclusive society for all individuals', true, '2015-04-27 13:02:04.072', '2015-04-27 13:02:04.072');
INSERT INTO links VALUES (967, 'Ethics & Compliance, Administrative guide', 'http://ethicscompliance.berkeley.edu/index.shtml', 'Contact information to report anything suspicious', true, '2015-04-27 13:02:04.122', '2015-04-27 13:02:04.122');
INSERT INTO links VALUES (968, 'Events.Berkeley', 'http://events.berkeley.edu', 'Campus events calendar', true, '2015-04-27 13:02:04.17', '2015-04-27 13:02:04.17');
INSERT INTO links VALUES (969, 'Executive Vice Chancellor & Provost', 'http://evcp.chance.berkeley.edu/', 'Meet Executive Vice Chancellor and Provost, Claude M. Steele', true, '2015-04-27 13:02:04.205', '2015-04-27 13:02:04.205');
INSERT INTO links VALUES (970, 'FAFSA', 'https://fafsa.ed.gov/', 'Free Application for Federal Student Aid (FAFSA),annual form submission required to receive financial aid', true, '2015-04-27 13:02:04.253', '2015-04-27 13:02:04.253');
INSERT INTO links VALUES (971, 'Facilities Services', 'http://www.cp.berkeley.edu/', 'Cleaning, landscaping and other services to maintain exceptional physical appearance', true, '2015-04-27 13:02:04.28', '2015-04-27 13:02:04.28');
INSERT INTO links VALUES (972, 'Faculty gateway', 'http://berkeley.edu/faculty/', 'Useful resources for faculty members ', true, '2015-04-27 13:02:04.321', '2015-04-27 13:02:04.321');
INSERT INTO links VALUES (973, 'Financial Aid & Scholarships Office', 'http://financialaid.berkeley.edu', 'Start here to learn about Financial Aid and for step-by-step guidance about financial aid and select scholarships at UC Berkeley', true, '2015-04-27 13:02:04.348', '2015-04-27 13:02:04.348');
INSERT INTO links VALUES (974, 'Finding Your Way (L&S)', 'http://ls-yourway.berkeley.edu/', 'Academic advising for students in the Residence Halls under the college of Letters and Science', true, '2015-04-27 13:02:04.374', '2015-04-27 13:02:04.374');
INSERT INTO links VALUES (975, 'General Access Computing Facilities', 'http://ets.berkeley.edu/computer-facilities/general-access', 'Convenient and secure on-campus computing facilities for registered Berkeley affiliates', true, '2015-04-27 13:02:04.418', '2015-04-27 13:02:04.418');
INSERT INTO links VALUES (976, 'Give to Berkeley', 'http://givetocal.berkeley.edu/', 'Help donate to further student''s education', true, '2015-04-27 13:02:04.453', '2015-04-27 13:02:04.453');
INSERT INTO links VALUES (977, 'Graduate Assembly', 'https://ga.berkeley.edu/', 'Graduate student government', true, '2015-04-27 13:02:04.487', '2015-04-27 13:02:04.487');
INSERT INTO links VALUES (978, 'Graduate Division', 'http://www.grad.berkeley.edu/', 'Information and resources for prospective and graduate students', true, '2015-04-27 13:02:04.53', '2015-04-27 13:02:04.53');
INSERT INTO links VALUES (979, 'Graduate Financial Support', 'http://www.grad.berkeley.edu/financial/', 'Resources to provide financial support for graduate students', true, '2015-04-27 13:02:04.563', '2015-04-27 13:02:04.563');
INSERT INTO links VALUES (980, 'HR System', 'http://hrweb.berkeley.edu/hcm', 'Recording personal information and action for the Berkeley community', true, '2015-04-27 13:02:04.606', '2015-04-27 13:02:04.606');
INSERT INTO links VALUES (981, 'HR Web', 'http://hrweb.berkeley.edu/', 'Human Resources at Berkeley', true, '2015-04-27 13:02:04.636', '2015-04-27 13:02:04.636');
INSERT INTO links VALUES (982, 'Have a loan?', 'http://studentbilling.berkeley.edu/exitDirect.htm', 'Getting ready to graduate? Learn about your responsibilities for paying back your loans through the Exit Loan Counseling requirement', true, '2015-04-27 13:02:04.681', '2015-04-27 13:02:04.681');
INSERT INTO links VALUES (983, 'How does my SHIP Waiver affect my billing?', 'http://studentcentral.berkeley.edu/faqshipwaiver', 'Frequently Asked Questions about how opt-ing out of the Student Health Insurance Plan effects your bill. ', true, '2015-04-27 13:02:04.72', '2015-04-27 13:02:04.72');
INSERT INTO links VALUES (984, 'IST Knowledge Base', 'http://ist.berkeley.edu/support/kb', 'Contains answers to Berkeley computing and IT questions', true, '2015-04-27 13:02:04.756', '2015-04-27 13:02:04.756');
INSERT INTO links VALUES (985, 'IST Support', 'http://ist.berkeley.edu/support/', 'Information Technology support for services and systems', true, '2015-04-27 13:02:04.799', '2015-04-27 13:02:04.799');
INSERT INTO links VALUES (986, 'Imagine Services', 'http://ist.berkeley.edu/imagine', 'Custom electronic document workflows', true, '2015-04-27 13:02:04.833', '2015-04-27 13:02:04.833');
INSERT INTO links VALUES (987, 'International House', 'http://ihouse.berkeley.edu/', 'On-campus dormitory with a dining common for international students', true, '2015-04-27 13:02:04.884', '2015-04-27 13:02:04.884');
INSERT INTO links VALUES (988, 'KALX', 'http://kalx.berkeley.edu/', '90.7 MHz. Berkeley''s campus radio station', true, '2015-04-27 13:02:04.923', '2015-04-27 13:02:04.923');
INSERT INTO links VALUES (989, 'Lab Safety', 'http://rac.berkeley.edu/compliancebook/labsafety.html', 'Lab Safety & Hazardous Materials Management', true, '2015-04-27 13:02:04.96', '2015-04-27 13:02:04.96');
INSERT INTO links VALUES (990, 'Learning Resources', 'http://hrweb.berkeley.edu/learning', 'Supports the development of the workforce with learning and development programs', true, '2015-04-27 13:02:04.999', '2015-04-27 13:02:04.999');
INSERT INTO links VALUES (991, 'Library', 'http://library.berkeley.edu', 'Search the UC Library system', true, '2015-04-27 13:02:05.056', '2015-04-27 13:02:05.056');
INSERT INTO links VALUES (992, 'Living At Cal', 'http://www.housing.berkeley.edu/livingatcal/', 'UC Berkeley housing options', true, '2015-04-27 13:02:05.089', '2015-04-27 13:02:05.089');
INSERT INTO links VALUES (993, 'Mail Services', 'http://mailservices.berkeley.edu/', 'United States Postal Service-incoming and outgoing mail', true, '2015-04-27 13:02:05.128', '2015-04-27 13:02:05.128');
INSERT INTO links VALUES (994, 'My Years at Cal', 'http://myyears.berkeley.edu/', 'Undergraduate advice site with useful resources and on how to stay on track for graduation ', true, '2015-04-27 13:02:05.157', '2015-04-27 13:02:05.157');
INSERT INTO links VALUES (995, 'MyFinAid', 'https://myfinaid.berkeley.edu/', 'Manage your Financial Aid Awards-grants, scholarships, work-study, loans, etc.', true, '2015-04-27 13:02:05.183', '2015-04-27 13:02:05.183');
INSERT INTO links VALUES (996, 'New Faculty resources', 'http://teaching.berkeley.edu/new-faculty-resources', 'Hints, resources, and guidelines on productive teaching', true, '2015-04-27 13:02:05.207', '2015-04-27 13:02:05.207');
INSERT INTO links VALUES (997, 'New Student Services (includes CalSO)', 'http://nss.berkeley.edu/', 'Helping new undergrads get the most out of Cal', true, '2015-04-27 13:02:05.234', '2015-04-27 13:02:05.234');
INSERT INTO links VALUES (998, 'Newscenter', 'http://newscenter.berkeley.edu', 'News affiliated with UC Berkeley', true, '2015-04-27 13:02:05.262', '2015-04-27 13:02:05.262');
INSERT INTO links VALUES (999, 'Office of Undergraduate Advising', 'http://ls-advise.berkeley.edu/', 'Advising provided for students under the college of Letters and Science', true, '2015-04-27 13:02:05.297', '2015-04-27 13:02:05.297');
INSERT INTO links VALUES (1000, 'Office of the Chancellor', 'http://chancellor.berkeley.edu/', 'Meet Chancellor Nicholas B. Dirks', true, '2015-04-27 13:02:05.323', '2015-04-27 13:02:05.323');
INSERT INTO links VALUES (1001, 'Office of the Registrar', 'http://registrar.berkeley.edu/', 'Administrative office with helpful links and resources regarding Berkeley', true, '2015-04-27 13:02:05.357', '2015-04-27 13:02:05.357');
INSERT INTO links VALUES (1002, 'Open Computing Facility', 'http://www.ocf.berkeley.edu/', 'Free computing such as printing for Berkeley affiliates', true, '2015-04-27 13:02:05.389', '2015-04-27 13:02:05.389');
INSERT INTO links VALUES (1003, 'Organizational & Workforce Effectiveness', 'http://hrweb.berkeley.edu/learning/corwe', 'Organization supporting managers wanting to make organizational improvements', true, '2015-04-27 13:02:05.434', '2015-04-27 13:02:05.434');
INSERT INTO links VALUES (1004, 'Parking & Transportation', 'http://pt.berkeley.edu/', 'Parking lots, transportation, car sharing, etc.', true, '2015-04-27 13:02:05.462', '2015-04-27 13:02:05.462');
INSERT INTO links VALUES (1005, 'Payment Options', 'http://studentbilling.berkeley.edu/carsPaymentOptions.htm', 'Learn more about the options for making payment either electronically or by check to your CARS account', true, '2015-04-27 13:02:05.492', '2015-04-27 13:02:05.492');
INSERT INTO links VALUES (1006, 'Payroll', 'http://controller.berkeley.edu/payroll/', 'Providing accurate paychecks to Berkeley employees', true, '2015-04-27 13:02:05.519', '2015-04-27 13:02:05.519');
INSERT INTO links VALUES (1007, 'Personal Info - Campus Directory', 'https://calnet.berkeley.edu/directory/update/', 'Public contact information of Berkeley affiliates such as email addresses, UIDs, etc.', true, '2015-04-27 13:02:05.564', '2015-04-27 13:02:05.564');
INSERT INTO links VALUES (1008, 'Personal Info - HR record', 'https://auth.berkeley.edu/cas/login?service=https://hrw-vip-prod.is.berkeley.edu/cgi-bin/cas-hrsprod.pl', 'HR personal data, requires log-in.', true, '2015-04-27 13:02:05.592', '2015-04-27 13:02:05.592');
INSERT INTO links VALUES (1009, 'Personnel Policies', 'http://hrweb.berkeley.edu/er/policies', 'Employee relations - personnel policies', true, '2015-04-27 13:02:05.623', '2015-04-27 13:02:05.623');
INSERT INTO links VALUES (1010, 'Physical Education Program', 'http://pe.berkeley.edu/', 'Physical education instructional courses for units', true, '2015-04-27 13:02:05.668', '2015-04-27 13:02:05.668');
INSERT INTO links VALUES (1011, 'Police & Safety', 'http://police.berkeley.edu', 'Campus police and safety', true, '2015-04-27 13:02:05.709', '2015-04-27 13:02:05.709');
INSERT INTO links VALUES (1012, 'Policies & procedures A-Z', 'http://campuspol.chance.berkeley.edu/Home/AtoZPolicies.cfm?long_page=yes', 'A-Z of campuswide policies and procedures', true, '2015-04-27 13:02:05.741', '2015-04-27 13:02:05.741');
INSERT INTO links VALUES (1013, 'Public Service Center', 'http://publicservice.berkeley.edu', 'On and off campus community service engagement', true, '2015-04-27 13:02:05.776', '2015-04-27 13:02:05.776');
INSERT INTO links VALUES (1014, 'Purchasing', 'http://businessservices.berkeley.edu/procurement/services', 'Services that can be purchased by individuals with a CalNet ID and passphrase', true, '2015-04-27 13:02:05.808', '2015-04-27 13:02:05.808');
INSERT INTO links VALUES (1015, 'Recreational Sports Facility', 'http://recsports.berkeley.edu/ ', 'Sports and fitness programs', true, '2015-04-27 13:02:05.837', '2015-04-27 13:02:05.837');
INSERT INTO links VALUES (1016, 'Registration Fees', 'http://registrar.berkeley.edu/Registration/feesched.html', 'Required Berkeley fees to be a Registered Student', true, '2015-04-27 13:02:05.868', '2015-04-27 13:02:05.868');
INSERT INTO links VALUES (1017, 'Research', 'http://berkeley.edu/research/', 'Directory of UC Berkeley research programs', true, '2015-04-27 13:02:05.894', '2015-04-27 13:02:05.894');
INSERT INTO links VALUES (1018, 'Research Hub', 'https://hub.berkeley.edu', 'Tool for content management and collaboration such as managing research data and sharing documents', true, '2015-04-27 13:02:05.927', '2015-04-27 13:02:05.927');
INSERT INTO links VALUES (1019, 'Residential & Student Service Programs', 'http://www.housing.berkeley.edu/', 'UC Berkeley housing options', true, '2015-04-27 13:02:05.961', '2015-04-27 13:02:05.961');
INSERT INTO links VALUES (1020, 'Residential Computing (ResComp)', 'http://www.rescomp.berkeley.edu/', 'Computer and network services for students living in campus housing', true, '2015-04-27 13:02:06.01', '2015-04-27 13:02:06.01');
INSERT INTO links VALUES (1021, 'Resource Guide for Students', 'http://resource.berkeley.edu/', 'Comprehensive campus guide for students', true, '2015-04-27 13:02:06.038', '2015-04-27 13:02:06.038');
INSERT INTO links VALUES (1022, 'Retirement Benefits - At Your Service', 'https://atyourserviceonline.ucop.edu', 'Benefits, Earnings, Taxes & Retirement', true, '2015-04-27 13:02:06.077', '2015-04-27 13:02:06.077');
INSERT INTO links VALUES (1023, 'Retirement Resources', 'http://thecenter.berkeley.edu/index.shtml', 'Programs and services that contribute to the well being of retired faculty', true, '2015-04-27 13:02:06.106', '2015-04-27 13:02:06.106');
INSERT INTO links VALUES (1024, 'SARA - request system access', 'http://www.bai.berkeley.edu/BFS/systems/systemAccess.htm', 'Form that grants access to different systems for employees', true, '2015-04-27 13:02:06.136', '2015-04-27 13:02:06.136');
INSERT INTO links VALUES (1025, 'Safety', 'http://police.berkeley.edu/index.html', 'Safety information and programs', true, '2015-04-27 13:02:06.165', '2015-04-27 13:02:06.165');
INSERT INTO links VALUES (1026, 'Schedule & Deadlines', 'http://summer.berkeley.edu/registration/schedule', 'Key dates and deadlines for summer sessions', true, '2015-04-27 13:02:06.21', '2015-04-27 13:02:06.21');
INSERT INTO links VALUES (1027, 'Schedule Builder', 'https://schedulebuilder.berkeley.edu/', 'Plan your classes', true, '2015-04-27 13:02:06.237', '2015-04-27 13:02:06.237');
INSERT INTO links VALUES (1028, 'Schedule of Classes', 'http://schedule.berkeley.edu/', 'Classes offerings by semester', true, '2015-04-27 13:02:06.279', '2015-04-27 13:02:06.279');
INSERT INTO links VALUES (1029, 'Schedule of Classes - Berkeley Law', 'https://www.law.berkeley.edu/php-programs/courses/courseSearch.php', 'Law School classes offerings by semester', true, '2015-04-27 13:02:06.329', '2015-04-27 13:02:06.329');
INSERT INTO links VALUES (1030, 'Software Central', 'http://ist.berkeley.edu/software-central/', 'Free software for Berkeley affiliates (ex. Adobe, Word, etc.)', true, '2015-04-27 13:02:06.364', '2015-04-27 13:02:06.364');
INSERT INTO links VALUES (1031, 'Staff Ombuds Office', 'http://staffombuds.berkeley.edu/ ', 'An independent department that provides staff with strictly confidential and informal conflict resolution and problem-solving services', true, '2015-04-27 13:02:06.407', '2015-04-27 13:02:06.407');
INSERT INTO links VALUES (1032, 'Student & Student Organization Policies', 'http://sa.berkeley.edu/conduct/policies', 'Rules and policies enforced on students and student organizations', true, '2015-04-27 13:02:06.438', '2015-04-27 13:02:06.438');
INSERT INTO links VALUES (1033, 'Student Affairs', 'http://sa.berkeley.edu/', 'Berkeley''s division responsible for many student life services including the Registrar, Admissions, Financial Aid, Housing & Dining, Conduct, Public Service Center, LEAD center, and ASUC auxiliary', true, '2015-04-27 13:02:06.469', '2015-04-27 13:02:06.469');
INSERT INTO links VALUES (1034, 'Student Budgets', 'http://financialaid.berkeley.edu/cost-attendance', 'Estimated living expense amounts for students', true, '2015-04-27 13:02:06.5', '2015-04-27 13:02:06.5');
INSERT INTO links VALUES (1035, 'Student Learning Center', 'http://slc.berkeley.edu', 'Tutoring, workshops, support services, and 24-hour study access', true, '2015-04-27 13:02:06.524', '2015-04-27 13:02:06.524');
INSERT INTO links VALUES (1036, 'Student Ombuds', 'http://sa.berkeley.edu/ombuds', 'Confidential help with campus issues, conflict situations, and more', true, '2015-04-27 13:02:06.548', '2015-04-27 13:02:06.548');
INSERT INTO links VALUES (1037, 'Student Organizations Search', 'http://students.berkeley.edu/osl/studentgroups/public/index.asp', 'Cal''s clubs and organizations on campus', true, '2015-04-27 13:02:06.573', '2015-04-27 13:02:06.573');
INSERT INTO links VALUES (1038, 'Submit a Service Request', 'https://shared-services-help.berkeley.edu/', 'Help requests for various services such as research', true, '2015-04-27 13:02:06.614', '2015-04-27 13:02:06.614');
INSERT INTO links VALUES (1039, 'Summer Session', 'http://summer.berkeley.edu/', 'Various programs and courses offered during summer for Berkeley students', true, '2015-04-27 13:02:06.642', '2015-04-27 13:02:06.642');
INSERT INTO links VALUES (1040, 'Summer Sessions', 'http://summer.berkeley.edu/', 'Various programs and courses offered during summer for Berkeley students', true, '2015-04-27 13:02:06.676', '2015-04-27 13:02:06.676');
INSERT INTO links VALUES (1041, 'Tax 1098-T Form', 'http://studentbilling.berkeley.edu/taxpayer.htm', 'Start here to access your 1098-T form', true, '2015-04-27 13:02:06.71', '2015-04-27 13:02:06.71');
INSERT INTO links VALUES (1042, 'Teaching resources', 'http://teaching.berkeley.edu/teaching.html', 'Resources that promotes teaching and learning including consultation and program facilitation', true, '2015-04-27 13:02:06.733', '2015-04-27 13:02:06.733');
INSERT INTO links VALUES (1043, 'TeleBears', 'https://telebears.berkeley.edu', 'Register for classes', true, '2015-04-27 13:02:06.758', '2015-04-27 13:02:06.758');
INSERT INTO links VALUES (1044, 'The Berkeley Blog', 'http://blogs.berkeley.edu', 'Issues that are being discussed by members of Berkeley''s academic community ', true, '2015-04-27 13:02:06.787', '2015-04-27 13:02:06.787');
INSERT INTO links VALUES (1045, 'The Center for Student Conduct', 'http://sa.berkeley.edu/conduct', 'Administers and promotes our Code of Student Conduct', true, '2015-04-27 13:02:06.834', '2015-04-27 13:02:06.834');
INSERT INTO links VALUES (1046, 'The Daily Californian (The DailyCal)', 'http://www.dailycal.org/', 'Independent student newspaper', true, '2015-04-27 13:02:06.867', '2015-04-27 13:02:06.867');
INSERT INTO links VALUES (1047, 'Transfer, Re-entry and Student Parent Center', 'http://trsp.berkeley.edu/', 'Resources specific to transfer, re-entering, and parent students', true, '2015-04-27 13:02:06.913', '2015-04-27 13:02:06.913');
INSERT INTO links VALUES (1048, 'Travel & Entertainment', 'http://controller.berkeley.edu/travel/', 'Travel services including airfare and Berkeley''s Direct Bill ID system', true, '2015-04-27 13:02:06.953', '2015-04-27 13:02:06.953');
INSERT INTO links VALUES (1049, 'Twitter', 'https://twitter.com/UCBerkeley', 'UC Berkeley''s primary Stay updated on campus news through Berkeley''s primary Twitter address', true, '2015-04-27 13:02:06.997', '2015-04-27 13:02:06.997');
INSERT INTO links VALUES (1050, 'UC Berkeley Facebook page', 'http://www.facebook.com/UCBerkeley', 'Keep updated with Berkeley news through social media', true, '2015-04-27 13:02:07.03', '2015-04-27 13:02:07.03');
INSERT INTO links VALUES (1051, 'UC Berkeley Wellness Letter', 'http://www.wellnessletter.com/ucberkeley/', 'Tips and information on how to stay healthy', true, '2015-04-27 13:02:07.071', '2015-04-27 13:02:07.071');
INSERT INTO links VALUES (1052, 'UC Berkeley museums', 'http://bnhm.berkeley.edu/', 'Berkeley''s national history museums ', true, '2015-04-27 13:02:07.096', '2015-04-27 13:02:07.096');
INSERT INTO links VALUES (1053, 'UC Extension Classes', 'http://extension.berkeley.edu/', 'Professional development', true, '2015-04-27 13:02:07.147', '2015-04-27 13:02:07.147');
INSERT INTO links VALUES (1054, 'UC Learning Center', 'https://shib.berkeley.edu/idp/profile/Shibboleth/SSO?shire=https://uc.sumtotalsystems.com/Shibboleth.sso/SAML/POST&target=https://uc.sumtotalsystems.com/secure/auth.aspx&providerId=https://uc.sumtotalsystems.com/shibboleth', 'Various services that help students and instructors succeed', true, '2015-04-27 13:02:07.183', '2015-04-27 13:02:07.183');
INSERT INTO links VALUES (1055, 'UC SHIP (Student Health Insurance Plan)', 'http://www.uhs.berkeley.edu/students/insurance/', 'UC Student Health Insurance Plan', true, '2015-04-27 13:02:07.21', '2015-04-27 13:02:07.21');
INSERT INTO links VALUES (1056, 'UHS - Tang Center', 'http://uhs.berkeley.edu/', 'Berkeley''s healthcare center', true, '2015-04-27 13:02:07.234', '2015-04-27 13:02:07.234');
INSERT INTO links VALUES (1057, 'Undergraduate Student Calendar & Deadlines', 'http://registrar.berkeley.edu/current_students/registration_enrollment/stucal.html', 'Student''s academic calendar ', true, '2015-04-27 13:02:07.266', '2015-04-27 13:02:07.266');
INSERT INTO links VALUES (1058, 'University Relations', 'http://www.urel.berkeley.edu/', 'Berkeley''s Public Affairs and fundraising Development division', true, '2015-04-27 13:02:07.301', '2015-04-27 13:02:07.301');
INSERT INTO links VALUES (1059, 'Webcast Support', 'http://ets.berkeley.edu/about-webcastberkeley', 'Help with audio and video recordings of class lectures and events that made available through UC Berkeley''s channels', true, '2015-04-27 13:02:07.331', '2015-04-27 13:02:07.331');
INSERT INTO links VALUES (1060, 'Withdrawing or Canceling?', 'http://registrar.berkeley.edu/canwd.html ', 'Learn more about what you need to do if you are planning to cancel, withdraw and readmit to UC Berkeley', true, '2015-04-27 13:02:07.355', '2015-04-27 13:02:07.355');
INSERT INTO links VALUES (1061, 'Work-Study', 'http://financialaid.berkeley.edu/work-study', 'A program that can help you lower your federal loan debt amount through work-study eligible jobs on campus', true, '2015-04-27 13:02:07.402', '2015-04-27 13:02:07.402');
INSERT INTO links VALUES (1062, 'YouTube - UC Berkeley', 'http://www.youtube.com/user/UCBerkeley', 'Videos relating to UC Berkeley on an external website', true, '2015-04-27 13:02:07.428', '2015-04-27 13:02:07.428');
INSERT INTO links VALUES (1063, 'bCal', 'http://bcal.berkeley.edu', 'Your campus calendar', true, '2015-04-27 13:02:07.453', '2015-04-27 13:02:07.453');
INSERT INTO links VALUES (1064, 'bConnected Support', 'http://ist.berkeley.edu/bconnected', 'Information and resources site for Berkeley''s email, calendar and shared drive solutions, powered by Google Apps for Education', true, '2015-04-27 13:02:07.485', '2015-04-27 13:02:07.485');
INSERT INTO links VALUES (1065, 'bCourses', 'http://bcourses.berkeley.edu', 'Campus Learning Management System (LMS) powered by Canvas', true, '2015-04-27 13:02:07.521', '2015-04-27 13:02:07.521');
INSERT INTO links VALUES (1066, 'bDrive', 'http://bdrive.berkeley.edu', 'An area to store files that can be shared and collaborated', true, '2015-04-27 13:02:07.556', '2015-04-27 13:02:07.556');
INSERT INTO links VALUES (1067, 'bMail', 'http://bmail.berkeley.edu', 'Your campus email account', true, '2015-04-27 13:02:07.589', '2015-04-27 13:02:07.589');
INSERT INTO links VALUES (1068, 'bSpace', 'http://bspace.berkeley.edu', 'Homework assignments, lecture slides, syllabi and class resources', true, '2015-04-27 13:02:07.637', '2015-04-27 13:02:07.637');
INSERT INTO links VALUES (1069, 'bSpace Grade book', 'http://gsi.berkeley.edu/teachingguide/tech/bspace-gradebook.html', 'A tool to enter, upload, and calculate student grades on bSpace', true, '2015-04-27 13:02:07.691', '2015-04-27 13:02:07.691');
INSERT INTO links VALUES (1070, 'bSpace Support', 'http://ets.berkeley.edu/bspace', 'A communication and collaboration program that supports teaching and learning', true, '2015-04-27 13:02:07.725', '2015-04-27 13:02:07.725');
INSERT INTO links VALUES (1071, 'e-bills', 'https://bearfacts.berkeley.edu/bearfacts/student/CARS/ebill.do?bfaction=accessEBill ', 'Pay your CARS bill online with either Electronic Billing (e-Bill) or Electronic Payment (e-Check)', true, '2015-04-27 13:02:07.751', '2015-04-27 13:02:07.751');
INSERT INTO links VALUES (1072, 'iTunesU - Berkeley', 'http://itunes.berkeley.edu', 'Audio files of recordings from lectures or events', true, '2015-04-27 13:02:07.778', '2015-04-27 13:02:07.778');


--
-- Name: links_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('links_id_seq', 1072, true);


--
-- Data for Name: links_user_roles; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO links_user_roles VALUES (891, 1);
INSERT INTO links_user_roles VALUES (891, 3);
INSERT INTO links_user_roles VALUES (891, 2);
INSERT INTO links_user_roles VALUES (892, 1);
INSERT INTO links_user_roles VALUES (893, 1);
INSERT INTO links_user_roles VALUES (893, 3);
INSERT INTO links_user_roles VALUES (893, 2);
INSERT INTO links_user_roles VALUES (894, 1);
INSERT INTO links_user_roles VALUES (894, 3);
INSERT INTO links_user_roles VALUES (894, 2);
INSERT INTO links_user_roles VALUES (895, 1);
INSERT INTO links_user_roles VALUES (895, 3);
INSERT INTO links_user_roles VALUES (895, 2);
INSERT INTO links_user_roles VALUES (896, 1);
INSERT INTO links_user_roles VALUES (896, 3);
INSERT INTO links_user_roles VALUES (896, 2);
INSERT INTO links_user_roles VALUES (897, 3);
INSERT INTO links_user_roles VALUES (898, 1);
INSERT INTO links_user_roles VALUES (898, 3);
INSERT INTO links_user_roles VALUES (898, 2);
INSERT INTO links_user_roles VALUES (899, 1);
INSERT INTO links_user_roles VALUES (899, 3);
INSERT INTO links_user_roles VALUES (899, 2);
INSERT INTO links_user_roles VALUES (900, 3);
INSERT INTO links_user_roles VALUES (900, 2);
INSERT INTO links_user_roles VALUES (901, 3);
INSERT INTO links_user_roles VALUES (901, 2);
INSERT INTO links_user_roles VALUES (902, 2);
INSERT INTO links_user_roles VALUES (903, 3);
INSERT INTO links_user_roles VALUES (903, 2);
INSERT INTO links_user_roles VALUES (904, 1);
INSERT INTO links_user_roles VALUES (904, 3);
INSERT INTO links_user_roles VALUES (904, 2);
INSERT INTO links_user_roles VALUES (905, 3);
INSERT INTO links_user_roles VALUES (905, 2);
INSERT INTO links_user_roles VALUES (906, 1);
INSERT INTO links_user_roles VALUES (906, 3);
INSERT INTO links_user_roles VALUES (906, 2);
INSERT INTO links_user_roles VALUES (907, 1);
INSERT INTO links_user_roles VALUES (907, 3);
INSERT INTO links_user_roles VALUES (907, 2);
INSERT INTO links_user_roles VALUES (908, 3);
INSERT INTO links_user_roles VALUES (908, 2);
INSERT INTO links_user_roles VALUES (909, 1);
INSERT INTO links_user_roles VALUES (909, 3);
INSERT INTO links_user_roles VALUES (909, 2);
INSERT INTO links_user_roles VALUES (910, 1);
INSERT INTO links_user_roles VALUES (910, 3);
INSERT INTO links_user_roles VALUES (910, 2);
INSERT INTO links_user_roles VALUES (911, 1);
INSERT INTO links_user_roles VALUES (911, 3);
INSERT INTO links_user_roles VALUES (911, 2);
INSERT INTO links_user_roles VALUES (912, 1);
INSERT INTO links_user_roles VALUES (913, 1);
INSERT INTO links_user_roles VALUES (914, 3);
INSERT INTO links_user_roles VALUES (914, 2);
INSERT INTO links_user_roles VALUES (915, 3);
INSERT INTO links_user_roles VALUES (915, 2);
INSERT INTO links_user_roles VALUES (916, 1);
INSERT INTO links_user_roles VALUES (916, 3);
INSERT INTO links_user_roles VALUES (917, 1);
INSERT INTO links_user_roles VALUES (917, 3);
INSERT INTO links_user_roles VALUES (917, 2);
INSERT INTO links_user_roles VALUES (918, 3);
INSERT INTO links_user_roles VALUES (918, 2);
INSERT INTO links_user_roles VALUES (919, 1);
INSERT INTO links_user_roles VALUES (919, 3);
INSERT INTO links_user_roles VALUES (919, 2);
INSERT INTO links_user_roles VALUES (920, 3);
INSERT INTO links_user_roles VALUES (920, 2);
INSERT INTO links_user_roles VALUES (921, 1);
INSERT INTO links_user_roles VALUES (921, 3);
INSERT INTO links_user_roles VALUES (921, 2);
INSERT INTO links_user_roles VALUES (922, 1);
INSERT INTO links_user_roles VALUES (922, 3);
INSERT INTO links_user_roles VALUES (922, 2);
INSERT INTO links_user_roles VALUES (923, 1);
INSERT INTO links_user_roles VALUES (923, 3);
INSERT INTO links_user_roles VALUES (923, 2);
INSERT INTO links_user_roles VALUES (924, 1);
INSERT INTO links_user_roles VALUES (924, 3);
INSERT INTO links_user_roles VALUES (924, 2);
INSERT INTO links_user_roles VALUES (925, 1);
INSERT INTO links_user_roles VALUES (926, 1);
INSERT INTO links_user_roles VALUES (927, 1);
INSERT INTO links_user_roles VALUES (927, 3);
INSERT INTO links_user_roles VALUES (927, 2);
INSERT INTO links_user_roles VALUES (928, 1);
INSERT INTO links_user_roles VALUES (928, 3);
INSERT INTO links_user_roles VALUES (928, 2);
INSERT INTO links_user_roles VALUES (929, 1);
INSERT INTO links_user_roles VALUES (929, 3);
INSERT INTO links_user_roles VALUES (929, 2);
INSERT INTO links_user_roles VALUES (930, 1);
INSERT INTO links_user_roles VALUES (931, 1);
INSERT INTO links_user_roles VALUES (932, 1);
INSERT INTO links_user_roles VALUES (932, 3);
INSERT INTO links_user_roles VALUES (932, 2);
INSERT INTO links_user_roles VALUES (933, 2);
INSERT INTO links_user_roles VALUES (934, 1);
INSERT INTO links_user_roles VALUES (934, 3);
INSERT INTO links_user_roles VALUES (934, 2);
INSERT INTO links_user_roles VALUES (935, 2);
INSERT INTO links_user_roles VALUES (936, 3);
INSERT INTO links_user_roles VALUES (936, 2);
INSERT INTO links_user_roles VALUES (937, 3);
INSERT INTO links_user_roles VALUES (937, 2);
INSERT INTO links_user_roles VALUES (938, 1);
INSERT INTO links_user_roles VALUES (939, 1);
INSERT INTO links_user_roles VALUES (939, 3);
INSERT INTO links_user_roles VALUES (939, 2);
INSERT INTO links_user_roles VALUES (940, 1);
INSERT INTO links_user_roles VALUES (940, 3);
INSERT INTO links_user_roles VALUES (941, 2);
INSERT INTO links_user_roles VALUES (942, 1);
INSERT INTO links_user_roles VALUES (942, 3);
INSERT INTO links_user_roles VALUES (942, 2);
INSERT INTO links_user_roles VALUES (943, 1);
INSERT INTO links_user_roles VALUES (943, 3);
INSERT INTO links_user_roles VALUES (943, 2);
INSERT INTO links_user_roles VALUES (944, 1);
INSERT INTO links_user_roles VALUES (944, 3);
INSERT INTO links_user_roles VALUES (944, 2);
INSERT INTO links_user_roles VALUES (945, 3);
INSERT INTO links_user_roles VALUES (945, 2);
INSERT INTO links_user_roles VALUES (946, 1);
INSERT INTO links_user_roles VALUES (946, 3);
INSERT INTO links_user_roles VALUES (946, 2);
INSERT INTO links_user_roles VALUES (947, 1);
INSERT INTO links_user_roles VALUES (947, 3);
INSERT INTO links_user_roles VALUES (947, 2);
INSERT INTO links_user_roles VALUES (948, 1);
INSERT INTO links_user_roles VALUES (949, 1);
INSERT INTO links_user_roles VALUES (950, 1);
INSERT INTO links_user_roles VALUES (951, 1);
INSERT INTO links_user_roles VALUES (952, 1);
INSERT INTO links_user_roles VALUES (952, 3);
INSERT INTO links_user_roles VALUES (952, 2);
INSERT INTO links_user_roles VALUES (953, 1);
INSERT INTO links_user_roles VALUES (954, 3);
INSERT INTO links_user_roles VALUES (955, 1);
INSERT INTO links_user_roles VALUES (955, 3);
INSERT INTO links_user_roles VALUES (955, 2);
INSERT INTO links_user_roles VALUES (956, 1);
INSERT INTO links_user_roles VALUES (956, 3);
INSERT INTO links_user_roles VALUES (956, 2);
INSERT INTO links_user_roles VALUES (957, 1);
INSERT INTO links_user_roles VALUES (957, 3);
INSERT INTO links_user_roles VALUES (957, 2);
INSERT INTO links_user_roles VALUES (958, 1);
INSERT INTO links_user_roles VALUES (959, 1);
INSERT INTO links_user_roles VALUES (959, 3);
INSERT INTO links_user_roles VALUES (959, 2);
INSERT INTO links_user_roles VALUES (960, 1);
INSERT INTO links_user_roles VALUES (961, 1);
INSERT INTO links_user_roles VALUES (962, 1);
INSERT INTO links_user_roles VALUES (962, 3);
INSERT INTO links_user_roles VALUES (962, 2);
INSERT INTO links_user_roles VALUES (963, 1);
INSERT INTO links_user_roles VALUES (963, 3);
INSERT INTO links_user_roles VALUES (963, 2);
INSERT INTO links_user_roles VALUES (964, 1);
INSERT INTO links_user_roles VALUES (964, 3);
INSERT INTO links_user_roles VALUES (964, 2);
INSERT INTO links_user_roles VALUES (965, 1);
INSERT INTO links_user_roles VALUES (966, 1);
INSERT INTO links_user_roles VALUES (966, 3);
INSERT INTO links_user_roles VALUES (966, 2);
INSERT INTO links_user_roles VALUES (967, 3);
INSERT INTO links_user_roles VALUES (967, 2);
INSERT INTO links_user_roles VALUES (968, 1);
INSERT INTO links_user_roles VALUES (968, 3);
INSERT INTO links_user_roles VALUES (968, 2);
INSERT INTO links_user_roles VALUES (969, 1);
INSERT INTO links_user_roles VALUES (969, 3);
INSERT INTO links_user_roles VALUES (969, 2);
INSERT INTO links_user_roles VALUES (970, 1);
INSERT INTO links_user_roles VALUES (971, 1);
INSERT INTO links_user_roles VALUES (971, 3);
INSERT INTO links_user_roles VALUES (971, 2);
INSERT INTO links_user_roles VALUES (972, 3);
INSERT INTO links_user_roles VALUES (973, 1);
INSERT INTO links_user_roles VALUES (974, 1);
INSERT INTO links_user_roles VALUES (975, 1);
INSERT INTO links_user_roles VALUES (975, 3);
INSERT INTO links_user_roles VALUES (975, 2);
INSERT INTO links_user_roles VALUES (976, 1);
INSERT INTO links_user_roles VALUES (976, 3);
INSERT INTO links_user_roles VALUES (976, 2);
INSERT INTO links_user_roles VALUES (977, 1);
INSERT INTO links_user_roles VALUES (978, 1);
INSERT INTO links_user_roles VALUES (978, 3);
INSERT INTO links_user_roles VALUES (978, 2);
INSERT INTO links_user_roles VALUES (979, 1);
INSERT INTO links_user_roles VALUES (980, 3);
INSERT INTO links_user_roles VALUES (980, 2);
INSERT INTO links_user_roles VALUES (981, 3);
INSERT INTO links_user_roles VALUES (981, 2);
INSERT INTO links_user_roles VALUES (982, 1);
INSERT INTO links_user_roles VALUES (983, 1);
INSERT INTO links_user_roles VALUES (984, 1);
INSERT INTO links_user_roles VALUES (984, 3);
INSERT INTO links_user_roles VALUES (984, 2);
INSERT INTO links_user_roles VALUES (985, 1);
INSERT INTO links_user_roles VALUES (985, 3);
INSERT INTO links_user_roles VALUES (985, 2);
INSERT INTO links_user_roles VALUES (986, 2);
INSERT INTO links_user_roles VALUES (987, 1);
INSERT INTO links_user_roles VALUES (988, 1);
INSERT INTO links_user_roles VALUES (988, 3);
INSERT INTO links_user_roles VALUES (988, 2);
INSERT INTO links_user_roles VALUES (989, 1);
INSERT INTO links_user_roles VALUES (989, 3);
INSERT INTO links_user_roles VALUES (989, 2);
INSERT INTO links_user_roles VALUES (990, 3);
INSERT INTO links_user_roles VALUES (990, 2);
INSERT INTO links_user_roles VALUES (991, 1);
INSERT INTO links_user_roles VALUES (991, 3);
INSERT INTO links_user_roles VALUES (991, 2);
INSERT INTO links_user_roles VALUES (992, 1);
INSERT INTO links_user_roles VALUES (993, 3);
INSERT INTO links_user_roles VALUES (993, 2);
INSERT INTO links_user_roles VALUES (994, 1);
INSERT INTO links_user_roles VALUES (995, 1);
INSERT INTO links_user_roles VALUES (996, 3);
INSERT INTO links_user_roles VALUES (997, 1);
INSERT INTO links_user_roles VALUES (998, 1);
INSERT INTO links_user_roles VALUES (998, 3);
INSERT INTO links_user_roles VALUES (998, 2);
INSERT INTO links_user_roles VALUES (999, 1);
INSERT INTO links_user_roles VALUES (1000, 1);
INSERT INTO links_user_roles VALUES (1000, 3);
INSERT INTO links_user_roles VALUES (1000, 2);
INSERT INTO links_user_roles VALUES (1001, 1);
INSERT INTO links_user_roles VALUES (1001, 3);
INSERT INTO links_user_roles VALUES (1001, 2);
INSERT INTO links_user_roles VALUES (1002, 1);
INSERT INTO links_user_roles VALUES (1002, 3);
INSERT INTO links_user_roles VALUES (1002, 2);
INSERT INTO links_user_roles VALUES (1003, 2);
INSERT INTO links_user_roles VALUES (1004, 1);
INSERT INTO links_user_roles VALUES (1004, 3);
INSERT INTO links_user_roles VALUES (1004, 2);
INSERT INTO links_user_roles VALUES (1005, 1);
INSERT INTO links_user_roles VALUES (1006, 3);
INSERT INTO links_user_roles VALUES (1006, 2);
INSERT INTO links_user_roles VALUES (1007, 3);
INSERT INTO links_user_roles VALUES (1007, 2);
INSERT INTO links_user_roles VALUES (1008, 3);
INSERT INTO links_user_roles VALUES (1008, 2);
INSERT INTO links_user_roles VALUES (1009, 3);
INSERT INTO links_user_roles VALUES (1009, 2);
INSERT INTO links_user_roles VALUES (1010, 1);
INSERT INTO links_user_roles VALUES (1011, 1);
INSERT INTO links_user_roles VALUES (1011, 3);
INSERT INTO links_user_roles VALUES (1011, 2);
INSERT INTO links_user_roles VALUES (1012, 1);
INSERT INTO links_user_roles VALUES (1012, 3);
INSERT INTO links_user_roles VALUES (1012, 2);
INSERT INTO links_user_roles VALUES (1013, 1);
INSERT INTO links_user_roles VALUES (1013, 3);
INSERT INTO links_user_roles VALUES (1013, 2);
INSERT INTO links_user_roles VALUES (1014, 3);
INSERT INTO links_user_roles VALUES (1014, 2);
INSERT INTO links_user_roles VALUES (1015, 1);
INSERT INTO links_user_roles VALUES (1015, 3);
INSERT INTO links_user_roles VALUES (1015, 2);
INSERT INTO links_user_roles VALUES (1016, 1);
INSERT INTO links_user_roles VALUES (1017, 1);
INSERT INTO links_user_roles VALUES (1017, 3);
INSERT INTO links_user_roles VALUES (1017, 2);
INSERT INTO links_user_roles VALUES (1018, 1);
INSERT INTO links_user_roles VALUES (1018, 3);
INSERT INTO links_user_roles VALUES (1018, 2);
INSERT INTO links_user_roles VALUES (1019, 1);
INSERT INTO links_user_roles VALUES (1020, 1);
INSERT INTO links_user_roles VALUES (1021, 1);
INSERT INTO links_user_roles VALUES (1022, 3);
INSERT INTO links_user_roles VALUES (1022, 2);
INSERT INTO links_user_roles VALUES (1023, 3);
INSERT INTO links_user_roles VALUES (1023, 2);
INSERT INTO links_user_roles VALUES (1024, 3);
INSERT INTO links_user_roles VALUES (1024, 2);
INSERT INTO links_user_roles VALUES (1025, 1);
INSERT INTO links_user_roles VALUES (1025, 3);
INSERT INTO links_user_roles VALUES (1025, 2);
INSERT INTO links_user_roles VALUES (1026, 1);
INSERT INTO links_user_roles VALUES (1027, 1);
INSERT INTO links_user_roles VALUES (1027, 3);
INSERT INTO links_user_roles VALUES (1027, 2);
INSERT INTO links_user_roles VALUES (1028, 1);
INSERT INTO links_user_roles VALUES (1028, 3);
INSERT INTO links_user_roles VALUES (1028, 2);
INSERT INTO links_user_roles VALUES (1029, 1);
INSERT INTO links_user_roles VALUES (1029, 3);
INSERT INTO links_user_roles VALUES (1029, 2);
INSERT INTO links_user_roles VALUES (1030, 3);
INSERT INTO links_user_roles VALUES (1030, 2);
INSERT INTO links_user_roles VALUES (1031, 3);
INSERT INTO links_user_roles VALUES (1031, 2);
INSERT INTO links_user_roles VALUES (1032, 1);
INSERT INTO links_user_roles VALUES (1032, 3);
INSERT INTO links_user_roles VALUES (1032, 2);
INSERT INTO links_user_roles VALUES (1033, 1);
INSERT INTO links_user_roles VALUES (1033, 3);
INSERT INTO links_user_roles VALUES (1033, 2);
INSERT INTO links_user_roles VALUES (1034, 1);
INSERT INTO links_user_roles VALUES (1035, 1);
INSERT INTO links_user_roles VALUES (1036, 1);
INSERT INTO links_user_roles VALUES (1037, 1);
INSERT INTO links_user_roles VALUES (1038, 3);
INSERT INTO links_user_roles VALUES (1038, 2);
INSERT INTO links_user_roles VALUES (1039, 1);
INSERT INTO links_user_roles VALUES (1040, 1);
INSERT INTO links_user_roles VALUES (1040, 3);
INSERT INTO links_user_roles VALUES (1040, 2);
INSERT INTO links_user_roles VALUES (1041, 1);
INSERT INTO links_user_roles VALUES (1042, 3);
INSERT INTO links_user_roles VALUES (1043, 1);
INSERT INTO links_user_roles VALUES (1044, 1);
INSERT INTO links_user_roles VALUES (1044, 3);
INSERT INTO links_user_roles VALUES (1044, 2);
INSERT INTO links_user_roles VALUES (1045, 1);
INSERT INTO links_user_roles VALUES (1045, 3);
INSERT INTO links_user_roles VALUES (1045, 2);
INSERT INTO links_user_roles VALUES (1046, 1);
INSERT INTO links_user_roles VALUES (1046, 3);
INSERT INTO links_user_roles VALUES (1046, 2);
INSERT INTO links_user_roles VALUES (1047, 1);
INSERT INTO links_user_roles VALUES (1048, 3);
INSERT INTO links_user_roles VALUES (1048, 2);
INSERT INTO links_user_roles VALUES (1049, 1);
INSERT INTO links_user_roles VALUES (1049, 3);
INSERT INTO links_user_roles VALUES (1049, 2);
INSERT INTO links_user_roles VALUES (1050, 1);
INSERT INTO links_user_roles VALUES (1051, 1);
INSERT INTO links_user_roles VALUES (1052, 1);
INSERT INTO links_user_roles VALUES (1052, 3);
INSERT INTO links_user_roles VALUES (1052, 2);
INSERT INTO links_user_roles VALUES (1053, 1);
INSERT INTO links_user_roles VALUES (1053, 3);
INSERT INTO links_user_roles VALUES (1053, 2);
INSERT INTO links_user_roles VALUES (1054, 3);
INSERT INTO links_user_roles VALUES (1054, 2);
INSERT INTO links_user_roles VALUES (1055, 1);
INSERT INTO links_user_roles VALUES (1056, 1);
INSERT INTO links_user_roles VALUES (1056, 3);
INSERT INTO links_user_roles VALUES (1056, 2);
INSERT INTO links_user_roles VALUES (1057, 1);
INSERT INTO links_user_roles VALUES (1057, 3);
INSERT INTO links_user_roles VALUES (1057, 2);
INSERT INTO links_user_roles VALUES (1058, 1);
INSERT INTO links_user_roles VALUES (1058, 3);
INSERT INTO links_user_roles VALUES (1058, 2);
INSERT INTO links_user_roles VALUES (1059, 3);
INSERT INTO links_user_roles VALUES (1060, 1);
INSERT INTO links_user_roles VALUES (1061, 1);
INSERT INTO links_user_roles VALUES (1062, 1);
INSERT INTO links_user_roles VALUES (1063, 1);
INSERT INTO links_user_roles VALUES (1063, 3);
INSERT INTO links_user_roles VALUES (1063, 2);
INSERT INTO links_user_roles VALUES (1064, 1);
INSERT INTO links_user_roles VALUES (1064, 3);
INSERT INTO links_user_roles VALUES (1064, 2);
INSERT INTO links_user_roles VALUES (1065, 1);
INSERT INTO links_user_roles VALUES (1065, 3);
INSERT INTO links_user_roles VALUES (1065, 2);
INSERT INTO links_user_roles VALUES (1066, 1);
INSERT INTO links_user_roles VALUES (1066, 3);
INSERT INTO links_user_roles VALUES (1066, 2);
INSERT INTO links_user_roles VALUES (1067, 1);
INSERT INTO links_user_roles VALUES (1067, 3);
INSERT INTO links_user_roles VALUES (1067, 2);
INSERT INTO links_user_roles VALUES (1068, 1);
INSERT INTO links_user_roles VALUES (1068, 3);
INSERT INTO links_user_roles VALUES (1068, 2);
INSERT INTO links_user_roles VALUES (1069, 3);
INSERT INTO links_user_roles VALUES (1070, 3);
INSERT INTO links_user_roles VALUES (1071, 1);
INSERT INTO links_user_roles VALUES (1072, 1);
INSERT INTO links_user_roles VALUES (1072, 3);
INSERT INTO links_user_roles VALUES (1072, 2);


--
-- Data for Name: summer_sub_terms; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO summer_sub_terms VALUES (1, 2015, 5, '2015-05-26', '2015-07-02', '2015-02-23 14:01:54.282', '2015-02-23 14:01:54.282');
INSERT INTO summer_sub_terms VALUES (2, 2015, 8, '2015-06-08', '2015-08-14', '2015-02-23 14:01:54.31', '2015-02-23 14:01:54.31');
INSERT INTO summer_sub_terms VALUES (3, 2015, 7, '2015-06-22', '2015-08-14', '2015-02-23 14:01:54.318', '2015-02-23 14:01:54.318');
INSERT INTO summer_sub_terms VALUES (4, 2015, 6, '2015-07-06', '2015-08-14', '2015-02-23 14:01:54.326', '2015-02-23 14:01:54.326');
INSERT INTO summer_sub_terms VALUES (5, 2015, 9, '2015-07-27', '2015-08-14', '2015-02-23 14:01:54.334', '2015-02-23 14:01:54.334');
INSERT INTO summer_sub_terms VALUES (6, 2016, 5, '2016-05-23', '2016-07-01', '2015-02-23 14:01:54.344', '2015-02-23 14:01:54.344');
INSERT INTO summer_sub_terms VALUES (7, 2016, 8, '2016-06-06', '2016-08-12', '2015-02-23 14:01:54.352', '2015-02-23 14:01:54.352');
INSERT INTO summer_sub_terms VALUES (8, 2016, 7, '2016-06-20', '2016-08-12', '2015-02-23 14:01:54.361', '2015-02-23 14:01:54.361');
INSERT INTO summer_sub_terms VALUES (9, 2016, 6, '2016-07-05', '2016-08-12', '2015-02-23 14:01:54.369', '2015-02-23 14:01:54.369');
INSERT INTO summer_sub_terms VALUES (10, 2016, 9, '2016-07-25', '2016-08-12', '2015-02-23 14:01:54.377', '2015-02-23 14:01:54.377');
INSERT INTO summer_sub_terms VALUES (11, 2017, 5, '2017-05-22', '2017-06-30', '2015-02-23 14:01:54.385', '2015-02-23 14:01:54.385');
INSERT INTO summer_sub_terms VALUES (12, 2017, 8, '2017-06-05', '2017-08-11', '2015-02-23 14:01:54.393', '2015-02-23 14:01:54.393');
INSERT INTO summer_sub_terms VALUES (13, 2017, 7, '2017-06-19', '2017-08-11', '2015-02-23 14:01:54.401', '2015-02-23 14:01:54.401');
INSERT INTO summer_sub_terms VALUES (14, 2017, 6, '2017-07-03', '2017-08-11', '2015-02-23 14:01:54.408', '2015-02-23 14:01:54.408');
INSERT INTO summer_sub_terms VALUES (15, 2017, 9, '2017-07-24', '2017-08-11', '2015-02-23 14:01:54.418', '2015-02-23 14:01:54.418');
INSERT INTO summer_sub_terms VALUES (16, 2018, 5, '2018-05-21', '2018-06-29', '2015-02-23 14:01:54.427', '2015-02-23 14:01:54.427');
INSERT INTO summer_sub_terms VALUES (17, 2018, 8, '2018-06-04', '2018-08-10', '2015-02-23 14:01:54.434', '2015-02-23 14:01:54.434');
INSERT INTO summer_sub_terms VALUES (18, 2018, 7, '2018-06-18', '2018-08-10', '2015-02-23 14:01:54.442', '2015-02-23 14:01:54.442');
INSERT INTO summer_sub_terms VALUES (19, 2018, 6, '2018-07-02', '2018-08-10', '2015-02-23 14:01:54.45', '2015-02-23 14:01:54.45');
INSERT INTO summer_sub_terms VALUES (20, 2018, 9, '2018-07-23', '2018-08-10', '2015-02-23 14:01:54.457', '2015-02-23 14:01:54.457');


--
-- Name: summer_sub_terms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('summer_sub_terms_id_seq', 20, true);


--
-- Data for Name: user_auths; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO user_auths VALUES (158, '1022796', true, true, '2014-05-22 21:52:49.751', '2014-05-22 21:52:49.751', false, false);
INSERT INTO user_auths VALUES (162, '1015674', false, true, '2014-08-01 03:48:32.548', '2014-08-01 03:48:32.548', false, true);
INSERT INTO user_auths VALUES (163, '1015779', false, true, '2014-08-12 14:45:47.037', '2014-08-12 14:45:47.037', false, true);
INSERT INTO user_auths VALUES (168, '10746', false, true, '2014-08-14 21:52:03.31', '2014-08-14 21:52:03.31', false, true);
INSERT INTO user_auths VALUES (172, '36504', false, true, '2014-09-04 17:45:19.169', '2014-09-04 17:45:19.169', false, true);
INSERT INTO user_auths VALUES (176, '125126', false, true, '2014-09-11 22:16:34.694', '2014-09-11 22:16:34.694', false, true);
INSERT INTO user_auths VALUES (180, '1080239', false, true, '2014-09-25 23:25:20.466', '2014-09-25 23:25:20.466', false, true);
INSERT INTO user_auths VALUES (184, '217127', false, true, '2014-09-25 23:32:33.638', '2014-09-25 23:32:33.638', false, true);
INSERT INTO user_auths VALUES (188, '1049763', false, true, '2014-10-30 21:43:44.417', '2014-10-30 21:43:44.417', false, true);
INSERT INTO user_auths VALUES (192, '89696', false, true, '2014-10-30 21:56:43.967', '2014-10-30 21:56:43.967', false, true);
INSERT INTO user_auths VALUES (197, '301286', false, true, '2014-11-22 05:30:58.485', '2014-11-22 05:30:58.485', false, true);
INSERT INTO user_auths VALUES (199, '7071', false, true, '2014-12-16 19:43:58.51', '2014-12-16 19:43:58.51', false, true);
INSERT INTO user_auths VALUES (204, '878901', false, true, '2015-02-26 00:26:00.577', '2015-02-26 00:26:00.577', false, true);
INSERT INTO user_auths VALUES (169, '7129', false, true, '2014-08-28 22:32:46.231', '2014-08-28 22:32:46.231', false, true);
INSERT INTO user_auths VALUES (173, '1073565', false, true, '2014-09-04 17:47:55.668', '2014-09-04 17:47:55.668', false, true);
INSERT INTO user_auths VALUES (177, '323858', false, true, '2014-09-25 23:15:54.992', '2014-09-25 23:15:54.992', false, true);
INSERT INTO user_auths VALUES (181, '300229', false, true, '2014-09-25 23:26:54.427', '2014-09-25 23:26:54.427', false, true);
INSERT INTO user_auths VALUES (189, '285132', false, true, '2014-10-30 21:45:35.838', '2014-10-30 21:45:35.838', false, true);
INSERT INTO user_auths VALUES (193, '462463', false, true, '2014-10-30 22:00:03.287', '2014-10-30 22:00:03.287', false, true);
INSERT INTO user_auths VALUES (198, '956647', false, true, '2014-11-26 21:24:22.723', '2014-11-26 21:24:22.723', false, true);
INSERT INTO user_auths VALUES (200, '1051119', false, true, '2014-12-17 00:53:18.389', '2014-12-17 00:53:18.389', false, true);
INSERT INTO user_auths VALUES (157, '943220', false, true, '2014-02-11 23:41:46.792', '2014-02-11 23:41:46.792', false, true);
INSERT INTO user_auths VALUES (160, '1081785', false, true, '2014-07-21 18:54:03.096', '2014-07-21 18:54:03.096', false, true);
INSERT INTO user_auths VALUES (5, '208861', false, false, '2013-03-04 17:06:18.304', '2014-07-24 17:49:03.211', false, false);
INSERT INTO user_auths VALUES (165, '1051011', false, true, '2014-08-13 00:06:49.437', '2014-08-13 00:06:49.437', false, true);
INSERT INTO user_auths VALUES (170, '1051067', false, true, '2014-08-29 00:07:05.985', '2014-08-29 00:07:05.985', false, true);
INSERT INTO user_auths VALUES (174, '1083263', false, true, '2014-09-09 17:19:29.77', '2014-09-09 17:19:29.77', false, true);
INSERT INTO user_auths VALUES (178, '5047', false, true, '2014-09-25 23:19:29.678', '2014-09-25 23:19:29.678', false, true);
INSERT INTO user_auths VALUES (182, '971585', false, true, '2014-09-25 23:29:00.258', '2014-09-25 23:29:00.258', false, true);
INSERT INTO user_auths VALUES (186, '175137', false, true, '2014-09-26 19:40:26.913', '2014-09-26 19:40:26.913', false, true);
INSERT INTO user_auths VALUES (190, '1022681', false, true, '2014-10-30 21:47:26.493', '2014-10-30 21:47:26.493', false, true);
INSERT INTO user_auths VALUES (194, '956649', false, true, '2014-10-30 22:01:16.852', '2014-10-30 22:01:16.852', false, true);
INSERT INTO user_auths VALUES (195, '973930', false, true, '2014-10-30 22:02:24.77', '2014-10-30 22:02:24.77', false, true);
INSERT INTO user_auths VALUES (201, '1081885', false, true, '2014-12-17 19:26:13.582', '2014-12-17 19:26:13.582', false, true);
INSERT INTO user_auths VALUES (2, '323487', true, true, '2013-03-04 17:06:18.281', '2013-03-04 17:06:18.281', false, false);
INSERT INTO user_auths VALUES (4, '238382', true, true, '2013-03-04 17:06:18.296', '2013-03-04 17:06:18.296', false, false);
INSERT INTO user_auths VALUES (8, '2040', true, true, '2013-03-04 17:06:18.328', '2013-03-04 17:06:18.328', false, false);
INSERT INTO user_auths VALUES (9, '904715', true, true, '2013-03-04 17:06:18.335', '2013-03-04 17:06:18.335', false, false);
INSERT INTO user_auths VALUES (10, '211159', true, true, '2013-03-04 17:06:18.343', '2013-03-04 17:06:18.343', false, false);
INSERT INTO user_auths VALUES (11, '978966', true, true, '2013-03-04 17:06:18.353', '2013-03-04 17:06:18.353', false, false);
INSERT INTO user_auths VALUES (12, '11002820', false, true, '2013-03-04 17:06:18.365', '2013-03-04 17:06:18.365', false, false);
INSERT INTO user_auths VALUES (13, '61889', false, true, '2013-03-04 17:06:18.372', '2013-03-04 17:06:18.372', false, false);
INSERT INTO user_auths VALUES (14, '321765', false, true, '2013-03-04 17:06:18.39', '2013-03-04 17:06:18.39', false, false);
INSERT INTO user_auths VALUES (15, '321703', false, true, '2013-03-04 17:06:18.401', '2013-03-04 17:06:18.401', false, false);
INSERT INTO user_auths VALUES (16, '324731', false, true, '2013-03-04 17:06:18.408', '2013-03-04 17:06:18.408', false, false);
INSERT INTO user_auths VALUES (17, '212388', false, true, '2013-03-04 17:06:18.414', '2013-03-04 17:06:18.414', false, false);
INSERT INTO user_auths VALUES (18, '212387', false, true, '2013-03-04 17:06:18.421', '2013-03-04 17:06:18.421', false, false);
INSERT INTO user_auths VALUES (19, '212372', false, true, '2013-03-04 17:06:18.428', '2013-03-04 17:06:18.428', false, false);
INSERT INTO user_auths VALUES (20, '212373', false, true, '2013-03-04 17:06:18.434', '2013-03-04 17:06:18.434', false, false);
INSERT INTO user_auths VALUES (21, '212374', false, true, '2013-03-04 17:06:18.441', '2013-03-04 17:06:18.441', false, false);
INSERT INTO user_auths VALUES (22, '212375', false, true, '2013-03-04 17:06:18.447', '2013-03-04 17:06:18.447', false, false);
INSERT INTO user_auths VALUES (23, '212376', false, true, '2013-03-04 17:06:18.463', '2013-03-04 17:06:18.463', false, false);
INSERT INTO user_auths VALUES (24, '212377', false, true, '2013-03-04 17:06:18.476', '2013-03-04 17:06:18.476', false, false);
INSERT INTO user_auths VALUES (25, '212378', false, true, '2013-03-04 17:06:18.483', '2013-03-04 17:06:18.483', false, false);
INSERT INTO user_auths VALUES (26, '212379', false, true, '2013-03-04 17:06:18.509', '2013-03-04 17:06:18.509', false, false);
INSERT INTO user_auths VALUES (27, '212380', false, true, '2013-03-04 17:06:18.519', '2013-03-04 17:06:18.519', false, false);
INSERT INTO user_auths VALUES (28, '212381', false, true, '2013-03-04 17:06:18.526', '2013-03-04 17:06:18.526', false, false);
INSERT INTO user_auths VALUES (29, '300846', false, true, '2013-03-04 17:06:18.534', '2013-03-04 17:06:18.534', false, false);
INSERT INTO user_auths VALUES (30, '300847', false, true, '2013-03-04 17:06:18.541', '2013-03-04 17:06:18.541', false, false);
INSERT INTO user_auths VALUES (31, '300848', false, true, '2013-03-04 17:06:18.547', '2013-03-04 17:06:18.547', false, false);
INSERT INTO user_auths VALUES (32, '300849', false, true, '2013-03-04 17:06:18.556', '2013-03-04 17:06:18.556', false, false);
INSERT INTO user_auths VALUES (33, '300850', false, true, '2013-03-04 17:06:18.567', '2013-03-04 17:06:18.567', false, false);
INSERT INTO user_auths VALUES (34, '300851', false, true, '2013-03-04 17:06:18.581', '2013-03-04 17:06:18.581', false, false);
INSERT INTO user_auths VALUES (35, '300852', false, true, '2013-03-04 17:06:18.589', '2013-03-04 17:06:18.589', false, false);
INSERT INTO user_auths VALUES (36, '300853', false, true, '2013-03-04 17:06:18.599', '2013-03-04 17:06:18.599', false, false);
INSERT INTO user_auths VALUES (37, '300854', false, true, '2013-03-04 17:06:18.606', '2013-03-04 17:06:18.606', false, false);
INSERT INTO user_auths VALUES (38, '300855', false, true, '2013-03-04 17:06:18.614', '2013-03-04 17:06:18.614', false, false);
INSERT INTO user_auths VALUES (39, '300856', false, true, '2013-03-04 17:06:18.621', '2013-03-04 17:06:18.621', false, false);
INSERT INTO user_auths VALUES (40, '300857', false, true, '2013-03-04 17:06:18.629', '2013-03-04 17:06:18.629', false, false);
INSERT INTO user_auths VALUES (41, '300858', false, true, '2013-03-04 17:06:18.636', '2013-03-04 17:06:18.636', false, false);
INSERT INTO user_auths VALUES (42, '300859', false, true, '2013-03-04 17:06:18.644', '2013-03-04 17:06:18.644', false, false);
INSERT INTO user_auths VALUES (43, '300860', false, true, '2013-03-04 17:06:18.65', '2013-03-04 17:06:18.65', false, false);
INSERT INTO user_auths VALUES (44, '300861', false, true, '2013-03-04 17:06:18.657', '2013-03-04 17:06:18.657', false, false);
INSERT INTO user_auths VALUES (45, '300862', false, true, '2013-03-04 17:06:18.67', '2013-03-04 17:06:18.67', false, false);
INSERT INTO user_auths VALUES (46, '300863', false, true, '2013-03-04 17:06:18.679', '2013-03-04 17:06:18.679', false, false);
INSERT INTO user_auths VALUES (47, '300864', false, true, '2013-03-04 17:06:18.685', '2013-03-04 17:06:18.685', false, false);
INSERT INTO user_auths VALUES (48, '300865', false, true, '2013-03-04 17:06:18.692', '2013-03-04 17:06:18.692', false, false);
INSERT INTO user_auths VALUES (49, '300866', false, true, '2013-03-04 17:06:18.698', '2013-03-04 17:06:18.698', false, false);
INSERT INTO user_auths VALUES (50, '300867', false, true, '2013-03-04 17:06:18.704', '2013-03-04 17:06:18.704', false, false);
INSERT INTO user_auths VALUES (51, '300868', false, true, '2013-03-04 17:06:18.711', '2013-03-04 17:06:18.711', false, false);
INSERT INTO user_auths VALUES (52, '300869', false, true, '2013-03-04 17:06:18.717', '2013-03-04 17:06:18.717', false, false);
INSERT INTO user_auths VALUES (53, '300870', false, true, '2013-03-04 17:06:18.723', '2013-03-04 17:06:18.723', false, false);
INSERT INTO user_auths VALUES (54, '300871', false, true, '2013-03-04 17:06:18.731', '2013-03-04 17:06:18.731', false, false);
INSERT INTO user_auths VALUES (55, '300872', false, true, '2013-03-04 17:06:18.737', '2013-03-04 17:06:18.737', false, false);
INSERT INTO user_auths VALUES (56, '300873', false, true, '2013-03-04 17:06:18.745', '2013-03-04 17:06:18.745', false, false);
INSERT INTO user_auths VALUES (57, '300874', false, true, '2013-03-04 17:06:18.756', '2013-03-04 17:06:18.756', false, false);
INSERT INTO user_auths VALUES (58, '300875', false, true, '2013-03-04 17:06:18.774', '2013-03-04 17:06:18.774', false, false);
INSERT INTO user_auths VALUES (59, '300876', false, true, '2013-03-04 17:06:18.782', '2013-03-04 17:06:18.782', false, false);
INSERT INTO user_auths VALUES (60, '300877', false, true, '2013-03-04 17:06:18.789', '2013-03-04 17:06:18.789', false, false);
INSERT INTO user_auths VALUES (61, '300878', false, true, '2013-03-04 17:06:18.807', '2013-03-04 17:06:18.807', false, false);
INSERT INTO user_auths VALUES (62, '300879', false, true, '2013-03-04 17:06:18.817', '2013-03-04 17:06:18.817', false, false);
INSERT INTO user_auths VALUES (63, '300880', false, true, '2013-03-04 17:06:18.825', '2013-03-04 17:06:18.825', false, false);
INSERT INTO user_auths VALUES (64, '300881', false, true, '2013-03-04 17:06:18.836', '2013-03-04 17:06:18.836', false, false);
INSERT INTO user_auths VALUES (65, '300882', false, true, '2013-03-04 17:06:18.844', '2013-03-04 17:06:18.844', false, false);
INSERT INTO user_auths VALUES (66, '300883', false, true, '2013-03-04 17:06:18.851', '2013-03-04 17:06:18.851', false, false);
INSERT INTO user_auths VALUES (67, '300884', false, true, '2013-03-04 17:06:18.859', '2013-03-04 17:06:18.859', false, false);
INSERT INTO user_auths VALUES (68, '300885', false, true, '2013-03-04 17:06:18.868', '2013-03-04 17:06:18.868', false, false);
INSERT INTO user_auths VALUES (69, '300886', false, true, '2013-03-04 17:06:18.874', '2013-03-04 17:06:18.874', false, false);
INSERT INTO user_auths VALUES (70, '300887', false, true, '2013-03-04 17:06:18.886', '2013-03-04 17:06:18.886', false, false);
INSERT INTO user_auths VALUES (71, '300888', false, true, '2013-03-04 17:06:18.893', '2013-03-04 17:06:18.893', false, false);
INSERT INTO user_auths VALUES (72, '300889', false, true, '2013-03-04 17:06:18.9', '2013-03-04 17:06:18.9', false, false);
INSERT INTO user_auths VALUES (73, '300890', false, true, '2013-03-04 17:06:18.906', '2013-03-04 17:06:18.906', false, false);
INSERT INTO user_auths VALUES (74, '300891', false, true, '2013-03-04 17:06:18.913', '2013-03-04 17:06:18.913', false, false);
INSERT INTO user_auths VALUES (75, '300892', false, true, '2013-03-04 17:06:18.919', '2013-03-04 17:06:18.919', false, false);
INSERT INTO user_auths VALUES (76, '300893', false, true, '2013-03-04 17:06:18.926', '2013-03-04 17:06:18.926', false, false);
INSERT INTO user_auths VALUES (77, '300894', false, true, '2013-03-04 17:06:18.932', '2013-03-04 17:06:18.932', false, false);
INSERT INTO user_auths VALUES (78, '300895', false, true, '2013-03-04 17:06:18.948', '2013-03-04 17:06:18.948', false, false);
INSERT INTO user_auths VALUES (79, '300896', false, true, '2013-03-04 17:06:18.955', '2013-03-04 17:06:18.955', false, false);
INSERT INTO user_auths VALUES (80, '300897', false, true, '2013-03-04 17:06:18.97', '2013-03-04 17:06:18.97', false, false);
INSERT INTO user_auths VALUES (81, '300898', false, true, '2013-03-04 17:06:18.976', '2013-03-04 17:06:18.976', false, false);
INSERT INTO user_auths VALUES (82, '300899', false, true, '2013-03-04 17:06:19.02', '2013-03-04 17:06:19.02', false, false);
INSERT INTO user_auths VALUES (83, '300900', false, true, '2013-03-04 17:06:19.026', '2013-03-04 17:06:19.026', false, false);
INSERT INTO user_auths VALUES (84, '300901', false, true, '2013-03-04 17:06:19.032', '2013-03-04 17:06:19.032', false, false);
INSERT INTO user_auths VALUES (85, '300902', false, true, '2013-03-04 17:06:19.039', '2013-03-04 17:06:19.039', false, false);
INSERT INTO user_auths VALUES (86, '300903', false, true, '2013-03-04 17:06:19.045', '2013-03-04 17:06:19.045', false, false);
INSERT INTO user_auths VALUES (87, '300904', false, true, '2013-03-04 17:06:19.051', '2013-03-04 17:06:19.051', false, false);
INSERT INTO user_auths VALUES (164, '979770', false, false, '2014-08-13 00:01:42.014', '2015-03-06 17:52:48.44', false, false);
INSERT INTO user_auths VALUES (167, '730973', false, false, '2014-08-14 21:10:50.328', '2015-03-06 17:54:03.086', false, false);
INSERT INTO user_auths VALUES (88, '300905', false, true, '2013-03-04 17:06:19.058', '2013-03-04 17:06:19.058', false, false);
INSERT INTO user_auths VALUES (89, '300906', false, true, '2013-03-04 17:06:19.065', '2013-03-04 17:06:19.065', false, false);
INSERT INTO user_auths VALUES (90, '300907', false, true, '2013-03-04 17:06:19.073', '2013-03-04 17:06:19.073', false, false);
INSERT INTO user_auths VALUES (91, '300908', false, true, '2013-03-04 17:06:19.091', '2013-03-04 17:06:19.091', false, false);
INSERT INTO user_auths VALUES (92, '300909', false, true, '2013-03-04 17:06:19.099', '2013-03-04 17:06:19.099', false, false);
INSERT INTO user_auths VALUES (93, '300910', false, true, '2013-03-04 17:06:19.108', '2013-03-04 17:06:19.108', false, false);
INSERT INTO user_auths VALUES (94, '300911', false, true, '2013-03-04 17:06:19.114', '2013-03-04 17:06:19.114', false, false);
INSERT INTO user_auths VALUES (95, '300912', false, true, '2013-03-04 17:06:19.122', '2013-03-04 17:06:19.122', false, false);
INSERT INTO user_auths VALUES (96, '300913', false, true, '2013-03-04 17:06:19.131', '2013-03-04 17:06:19.131', false, false);
INSERT INTO user_auths VALUES (97, '300914', false, true, '2013-03-04 17:06:19.139', '2013-03-04 17:06:19.139', false, false);
INSERT INTO user_auths VALUES (98, '300915', false, true, '2013-03-04 17:06:19.145', '2013-03-04 17:06:19.145', false, false);
INSERT INTO user_auths VALUES (99, '300916', false, true, '2013-03-04 17:06:19.151', '2013-03-04 17:06:19.151', false, false);
INSERT INTO user_auths VALUES (100, '300917', false, true, '2013-03-04 17:06:19.166', '2013-03-04 17:06:19.166', false, false);
INSERT INTO user_auths VALUES (101, '300918', false, true, '2013-03-04 17:06:19.18', '2013-03-04 17:06:19.18', false, false);
INSERT INTO user_auths VALUES (102, '300919', false, true, '2013-03-04 17:06:19.187', '2013-03-04 17:06:19.187', false, false);
INSERT INTO user_auths VALUES (103, '300920', false, true, '2013-03-04 17:06:19.198', '2013-03-04 17:06:19.198', false, false);
INSERT INTO user_auths VALUES (104, '300921', false, true, '2013-03-04 17:06:19.206', '2013-03-04 17:06:19.206', false, false);
INSERT INTO user_auths VALUES (105, '300922', false, true, '2013-03-04 17:06:19.212', '2013-03-04 17:06:19.212', false, false);
INSERT INTO user_auths VALUES (106, '300923', false, true, '2013-03-04 17:06:19.218', '2013-03-04 17:06:19.218', false, false);
INSERT INTO user_auths VALUES (107, '300924', false, true, '2013-03-04 17:06:19.225', '2013-03-04 17:06:19.225', false, false);
INSERT INTO user_auths VALUES (108, '300925', false, true, '2013-03-04 17:06:19.231', '2013-03-04 17:06:19.231', false, false);
INSERT INTO user_auths VALUES (109, '300926', false, true, '2013-03-04 17:06:19.236', '2013-03-04 17:06:19.236', false, false);
INSERT INTO user_auths VALUES (110, '300927', false, true, '2013-03-04 17:06:19.243', '2013-03-04 17:06:19.243', false, false);
INSERT INTO user_auths VALUES (111, '300928', false, true, '2013-03-04 17:06:19.248', '2013-03-04 17:06:19.248', false, false);
INSERT INTO user_auths VALUES (112, '300929', false, true, '2013-03-04 17:06:19.256', '2013-03-04 17:06:19.256', false, false);
INSERT INTO user_auths VALUES (113, '300930', false, true, '2013-03-04 17:06:19.262', '2013-03-04 17:06:19.262', false, false);
INSERT INTO user_auths VALUES (114, '300931', false, true, '2013-03-04 17:06:19.27', '2013-03-04 17:06:19.27', false, false);
INSERT INTO user_auths VALUES (115, '300932', false, true, '2013-03-04 17:06:19.277', '2013-03-04 17:06:19.277', false, false);
INSERT INTO user_auths VALUES (116, '300933', false, true, '2013-03-04 17:06:19.285', '2013-03-04 17:06:19.285', false, false);
INSERT INTO user_auths VALUES (117, '300934', false, true, '2013-03-04 17:06:19.292', '2013-03-04 17:06:19.292', false, false);
INSERT INTO user_auths VALUES (118, '300935', false, true, '2013-03-04 17:06:19.299', '2013-03-04 17:06:19.299', false, false);
INSERT INTO user_auths VALUES (119, '300936', false, true, '2013-03-04 17:06:19.306', '2013-03-04 17:06:19.306', false, false);
INSERT INTO user_auths VALUES (120, '300937', false, true, '2013-03-04 17:06:19.314', '2013-03-04 17:06:19.314', false, false);
INSERT INTO user_auths VALUES (121, '300938', false, true, '2013-03-04 17:06:19.321', '2013-03-04 17:06:19.321', false, false);
INSERT INTO user_auths VALUES (122, '300939', false, true, '2013-03-04 17:06:19.339', '2013-03-04 17:06:19.339', false, false);
INSERT INTO user_auths VALUES (123, '300940', false, true, '2013-03-04 17:06:19.352', '2013-03-04 17:06:19.352', false, false);
INSERT INTO user_auths VALUES (124, '300941', false, true, '2013-03-04 17:06:19.363', '2013-03-04 17:06:19.363', false, false);
INSERT INTO user_auths VALUES (125, '300942', false, true, '2013-03-04 17:06:19.375', '2013-03-04 17:06:19.375', false, false);
INSERT INTO user_auths VALUES (126, '300943', false, true, '2013-03-04 17:06:19.386', '2013-03-04 17:06:19.386', false, false);
INSERT INTO user_auths VALUES (127, '300944', false, true, '2013-03-04 17:06:19.394', '2013-03-04 17:06:19.394', false, false);
INSERT INTO user_auths VALUES (128, '300945', false, true, '2013-03-04 17:06:19.402', '2013-03-04 17:06:19.402', false, false);
INSERT INTO user_auths VALUES (129, '212382', false, true, '2013-03-04 17:06:19.408', '2013-03-04 17:06:19.408', false, false);
INSERT INTO user_auths VALUES (130, '212383', false, true, '2013-03-04 17:06:19.415', '2013-03-04 17:06:19.415', false, false);
INSERT INTO user_auths VALUES (131, '212384', false, true, '2013-03-04 17:06:19.422', '2013-03-04 17:06:19.422', false, false);
INSERT INTO user_auths VALUES (132, '212385', false, true, '2013-03-04 17:06:19.429', '2013-03-04 17:06:19.429', false, false);
INSERT INTO user_auths VALUES (133, '212386', false, true, '2013-03-04 17:06:19.436', '2013-03-04 17:06:19.436', false, false);
INSERT INTO user_auths VALUES (134, '322587', false, true, '2013-03-04 17:06:19.444', '2013-03-04 17:06:19.444', false, false);
INSERT INTO user_auths VALUES (135, '322588', false, true, '2013-03-04 17:06:19.452', '2013-03-04 17:06:19.452', false, false);
INSERT INTO user_auths VALUES (136, '322589', false, true, '2013-03-04 17:06:19.459', '2013-03-04 17:06:19.459', false, false);
INSERT INTO user_auths VALUES (137, '322590', false, true, '2013-03-04 17:06:19.469', '2013-03-04 17:06:19.469', false, false);
INSERT INTO user_auths VALUES (138, '322583', false, true, '2013-03-04 17:06:19.476', '2013-03-04 17:06:19.476', false, false);
INSERT INTO user_auths VALUES (139, '322584', false, true, '2013-03-04 17:06:19.483', '2013-03-04 17:06:19.483', false, false);
INSERT INTO user_auths VALUES (140, '322585', false, true, '2013-03-04 17:06:19.489', '2013-03-04 17:06:19.489', false, false);
INSERT INTO user_auths VALUES (141, '322586', false, true, '2013-03-04 17:06:19.558', '2013-03-04 17:06:19.558', false, false);
INSERT INTO user_auths VALUES (143, '53791', true, true, '2013-08-15 23:09:30.345', '2013-08-15 23:09:30.345', false, false);
INSERT INTO user_auths VALUES (145, '1049291', true, true, '2013-09-16 17:35:01.896', '2013-09-16 17:35:01.896', false, false);
INSERT INTO user_auths VALUES (144, '163093', false, true, '2013-09-16 17:34:22.616', '2013-09-16 17:34:22.616', false, true);
INSERT INTO user_auths VALUES (148, '160965', false, true, '2013-09-17 20:27:15.383', '2013-09-17 20:27:15.383', false, true);
INSERT INTO user_auths VALUES (152, '162721', false, true, '2013-10-01 23:58:44.14', '2013-10-01 23:58:44.14', false, true);
INSERT INTO user_auths VALUES (153, '19609', false, true, '2013-10-01 23:59:42.527', '2013-10-01 23:59:42.527', false, true);
INSERT INTO user_auths VALUES (154, '975226', false, true, '2013-10-02 00:00:05.933', '2013-10-02 00:00:05.933', false, true);
INSERT INTO user_auths VALUES (142, '12492', false, true, '2013-06-24 13:34:20.219', '2014-06-04 18:37:57.922', false, true);
INSERT INTO user_auths VALUES (147, '95509', true, true, '2013-09-16 17:35:58.498', '2014-07-22 20:53:42.923', false, true);
INSERT INTO user_auths VALUES (146, '177473', true, true, '2013-09-16 17:35:47.59', '2014-07-22 20:54:10.065', false, true);
INSERT INTO user_auths VALUES (161, '1081940', false, true, '2014-07-28 23:45:10.454', '2014-07-28 23:46:48.197', false, true);
INSERT INTO user_auths VALUES (166, '1049994', false, true, '2014-08-13 18:32:10.912', '2014-08-13 18:32:10.912', false, true);
INSERT INTO user_auths VALUES (175, '235920', false, true, '2014-09-11 17:22:42.014', '2014-09-11 17:22:42.014', false, true);
INSERT INTO user_auths VALUES (179, '31428', false, true, '2014-09-25 23:24:03.134', '2014-09-25 23:24:03.134', false, true);
INSERT INTO user_auths VALUES (183, '3305', false, true, '2014-09-25 23:30:50.906', '2014-09-25 23:30:50.906', false, true);
INSERT INTO user_auths VALUES (187, '56241', false, true, '2014-10-30 21:39:02.826', '2014-10-30 21:39:02.826', false, true);
INSERT INTO user_auths VALUES (191, '1001783', false, true, '2014-10-30 21:55:14.818', '2014-10-30 21:55:14.818', false, true);
INSERT INTO user_auths VALUES (196, '1049863', false, true, '2014-10-30 22:03:49.095', '2014-10-30 22:03:49.095', false, true);
INSERT INTO user_auths VALUES (202, '16', false, true, '2014-12-17 19:26:30.074', '2014-12-17 19:26:30.074', false, true);
INSERT INTO user_auths VALUES (205, '1086049', false, true, '2015-03-03 18:59:54.095', '2015-03-03 18:59:54.095', false, true);
INSERT INTO user_auths VALUES (7, '322279', false, false, '2013-03-04 17:06:18.32', '2015-03-06 17:46:54.384', false, false);
INSERT INTO user_auths VALUES (159, '1078671', false, false, '2014-06-02 13:02:01.548', '2015-03-06 17:51:05.057', false, false);
INSERT INTO user_auths VALUES (171, '1015780', false, false, '2014-09-03 23:58:04.042', '2015-03-06 17:55:05.85', false, false);
INSERT INTO user_auths VALUES (203, '865595', false, false, '2015-01-06 00:19:57.308', '2015-03-10 18:33:08.681', false, false);
INSERT INTO user_auths VALUES (206, '196233', false, true, '2015-03-31 22:19:06.372', '2015-03-31 22:19:06.372', false, true);
INSERT INTO user_auths VALUES (207, '1087593', false, true, '2015-04-02 16:57:50.835', '2015-04-02 16:57:50.835', false, true);
INSERT INTO user_auths VALUES (208, '242881', true, true, '2015-04-02 18:54:23.544', '2015-04-02 18:54:23.544', false, false);
INSERT INTO user_auths VALUES (209, '1010430', false, true, '2015-04-06 18:30:10.031', '2015-04-06 18:30:10.031', false, true);


--
-- Name: user_auths_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('user_auths_id_seq', 209, true);


--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO user_roles VALUES (1, 'Student', 'student');
INSERT INTO user_roles VALUES (2, 'Staff', 'staff');
INSERT INTO user_roles VALUES (3, 'Faculty', 'faculty');


--
-- Name: user_roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('user_roles_id_seq', 3, true);


--
-- Name: fin_aid_years_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY fin_aid_years
    ADD CONSTRAINT fin_aid_years_pkey PRIMARY KEY (id);


--
-- Name: link_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY link_categories
    ADD CONSTRAINT link_categories_pkey PRIMARY KEY (id);


--
-- Name: link_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY link_sections
    ADD CONSTRAINT link_sections_pkey PRIMARY KEY (id);


--
-- Name: links_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: summer_sub_terms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY summer_sub_terms
    ADD CONSTRAINT summer_sub_terms_pkey PRIMARY KEY (id);


--
-- Name: user_auths_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY user_auths
    ADD CONSTRAINT user_auths_pkey PRIMARY KEY (id);


--
-- Name: user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- Name: index_fin_aid_years_on_current_year; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_fin_aid_years_on_current_year ON fin_aid_years USING btree (current_year);


--
-- Name: index_summer_sub_terms_on_year_and_sub_term_code; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_summer_sub_terms_on_year_and_sub_term_code ON summer_sub_terms USING btree (year, sub_term_code);


--
-- Name: index_user_auths_on_uid; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_user_auths_on_uid ON user_auths USING btree (uid);


--
-- PostgreSQL database dump complete
--

