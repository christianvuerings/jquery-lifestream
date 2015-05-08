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

INSERT INTO link_categories VALUES (558, 'Academic', 'academic', true, '2015-05-07 22:46:22.051', '2015-05-07 22:46:22.051');
INSERT INTO link_categories VALUES (559, 'Academic Departments', 'academicdepartments', false, '2015-05-07 22:46:22.083', '2015-05-07 22:46:22.083');
INSERT INTO link_categories VALUES (560, 'Academic Planning', 'academicplanning', false, '2015-05-07 22:46:22.096', '2015-05-07 22:46:22.096');
INSERT INTO link_categories VALUES (561, 'Classes', 'classes', false, '2015-05-07 22:46:22.11', '2015-05-07 22:46:22.11');
INSERT INTO link_categories VALUES (562, 'Faculty', 'faculty', false, '2015-05-07 22:46:22.127', '2015-05-07 22:46:22.127');
INSERT INTO link_categories VALUES (563, 'Staff Learning', 'stafflearning', false, '2015-05-07 22:46:22.166', '2015-05-07 22:46:22.166');
INSERT INTO link_categories VALUES (564, 'Administrative', 'administrative', true, '2015-05-07 22:46:22.179', '2015-05-07 22:46:22.179');
INSERT INTO link_categories VALUES (565, 'Campus Departments', 'campusdepartments', false, '2015-05-07 22:46:22.191', '2015-05-07 22:46:22.191');
INSERT INTO link_categories VALUES (566, 'Communication & Collaboration', 'communicationcollaboration', false, '2015-05-07 22:46:22.203', '2015-05-07 22:46:22.203');
INSERT INTO link_categories VALUES (567, 'Policies & Procedures', 'policiesproceedures', false, '2015-05-07 22:46:22.215', '2015-05-07 22:46:22.215');
INSERT INTO link_categories VALUES (568, 'Shared Service Center', 'sharedservices', false, '2015-05-07 22:46:22.226', '2015-05-07 22:46:22.226');
INSERT INTO link_categories VALUES (569, 'Tools & Resources', 'toolsresources', false, '2015-05-07 22:46:22.238', '2015-05-07 22:46:22.238');
INSERT INTO link_categories VALUES (570, 'Campus Life', 'campus life', true, '2015-05-07 22:46:22.255', '2015-05-07 22:46:22.255');
INSERT INTO link_categories VALUES (571, 'Community', 'community', false, '2015-05-07 22:46:22.272', '2015-05-07 22:46:22.272');
INSERT INTO link_categories VALUES (572, 'Getting Around', 'gettingaround', false, '2015-05-07 22:46:22.29', '2015-05-07 22:46:22.29');
INSERT INTO link_categories VALUES (573, 'Recreation & Entertainment', 'recreationentertainment', false, '2015-05-07 22:46:22.307', '2015-05-07 22:46:22.307');
INSERT INTO link_categories VALUES (574, 'Safety & Emergency Information', 'safetyemergencyinfo', false, '2015-05-07 22:46:22.325', '2015-05-07 22:46:22.325');
INSERT INTO link_categories VALUES (575, 'Student Engagement', 'studentgroups', false, '2015-05-07 22:46:22.342', '2015-05-07 22:46:22.342');
INSERT INTO link_categories VALUES (576, 'Support Services', 'supportservices', false, '2015-05-07 22:46:22.359', '2015-05-07 22:46:22.359');
INSERT INTO link_categories VALUES (577, 'Personal', 'personal', true, '2015-05-07 22:46:22.376', '2015-05-07 22:46:22.376');
INSERT INTO link_categories VALUES (578, 'Career', 'career', false, '2015-05-07 22:46:22.392', '2015-05-07 22:46:22.392');
INSERT INTO link_categories VALUES (579, 'Finances', 'finances', false, '2015-05-07 22:46:22.406', '2015-05-07 22:46:22.406');
INSERT INTO link_categories VALUES (580, 'Food & Housing', 'foodandhousing', false, '2015-05-07 22:46:22.421', '2015-05-07 22:46:22.421');
INSERT INTO link_categories VALUES (581, 'HR & Benefits', 'hrbenefits', false, '2015-05-07 22:46:22.435', '2015-05-07 22:46:22.435');
INSERT INTO link_categories VALUES (582, 'Wellness', 'wellness', false, '2015-05-07 22:46:22.449', '2015-05-07 22:46:22.449');
INSERT INTO link_categories VALUES (583, 'Parking & Transportation', 'parking & transportation', false, '2015-05-07 22:46:22.468', '2015-05-07 22:46:22.468');
INSERT INTO link_categories VALUES (584, 'Calendar', 'calendar', false, '2015-05-07 22:46:22.671', '2015-05-07 22:46:22.671');
INSERT INTO link_categories VALUES (585, 'Policies', 'policies', false, '2015-05-07 22:46:22.896', '2015-05-07 22:46:22.896');
INSERT INTO link_categories VALUES (586, 'Resources', 'resources', false, '2015-05-07 22:46:22.971', '2015-05-07 22:46:22.971');
INSERT INTO link_categories VALUES (587, 'Administrative and Other', 'administrative and other', false, '2015-05-07 22:46:23.038', '2015-05-07 22:46:23.038');
INSERT INTO link_categories VALUES (588, 'Security & Access', 'security & access', false, '2015-05-07 22:46:23.114', '2015-05-07 22:46:23.114');
INSERT INTO link_categories VALUES (589, 'Student Government', 'student government', false, '2015-05-07 22:46:23.185', '2015-05-07 22:46:23.185');
INSERT INTO link_categories VALUES (590, 'Benefits', 'benefits', false, '2015-05-07 22:46:23.247', '2015-05-07 22:46:23.247');
INSERT INTO link_categories VALUES (591, 'Students', 'students', false, '2015-05-07 22:46:23.311', '2015-05-07 22:46:23.311');
INSERT INTO link_categories VALUES (592, 'Financial', 'financial', false, '2015-05-07 22:46:23.366', '2015-05-07 22:46:23.366');
INSERT INTO link_categories VALUES (593, 'bConnected Tools', 'bconnected tools', false, '2015-05-07 22:46:23.44', '2015-05-07 22:46:23.44');
INSERT INTO link_categories VALUES (594, 'Academic Record', 'academic record', false, '2015-05-07 22:46:23.681', '2015-05-07 22:46:23.681');
INSERT INTO link_categories VALUES (595, 'Purchasing', 'purchasing', false, '2015-05-07 22:46:23.757', '2015-05-07 22:46:23.757');
INSERT INTO link_categories VALUES (596, 'Night Safety', 'night safety', false, '2015-05-07 22:46:23.825', '2015-05-07 22:46:23.825');
INSERT INTO link_categories VALUES (597, 'Planning', 'planning', false, '2015-05-07 22:46:23.891', '2015-05-07 22:46:23.891');
INSERT INTO link_categories VALUES (598, 'Jobs', 'jobs', false, '2015-05-07 22:46:23.959', '2015-05-07 22:46:23.959');
INSERT INTO link_categories VALUES (599, 'Research', 'research', false, '2015-05-07 22:46:24.03', '2015-05-07 22:46:24.03');
INSERT INTO link_categories VALUES (600, 'Points of Interest', 'points of interest', false, '2015-05-07 22:46:24.128', '2015-05-07 22:46:24.128');
INSERT INTO link_categories VALUES (601, 'Housing', 'housing', false, '2015-05-07 22:46:24.277', '2015-05-07 22:46:24.277');
INSERT INTO link_categories VALUES (602, 'Asset Management', 'asset management', false, '2015-05-07 22:46:24.354', '2015-05-07 22:46:24.354');
INSERT INTO link_categories VALUES (603, 'Billing & Payments', 'billing & payments', false, '2015-05-07 22:46:24.457', '2015-05-07 22:46:24.457');
INSERT INTO link_categories VALUES (604, 'Staff Portal', 'staff portal', false, '2015-05-07 22:46:24.522', '2015-05-07 22:46:24.522');
INSERT INTO link_categories VALUES (605, 'Learning Resources', 'learning resources', false, '2015-05-07 22:46:24.692', '2015-05-07 22:46:24.692');
INSERT INTO link_categories VALUES (606, 'Collaboration Tools', 'collaboration tools', false, '2015-05-07 22:46:24.766', '2015-05-07 22:46:24.766');
INSERT INTO link_categories VALUES (607, 'Tools', 'tools', false, '2015-05-07 22:46:24.915', '2015-05-07 22:46:24.915');
INSERT INTO link_categories VALUES (608, 'Campus Dining', 'campus dining', false, '2015-05-07 22:46:25.006', '2015-05-07 22:46:25.006');
INSERT INTO link_categories VALUES (609, 'Analysis & Reporting', 'analysis & reporting', false, '2015-05-07 22:46:25.101', '2015-05-07 22:46:25.101');
INSERT INTO link_categories VALUES (610, 'Activities', 'activities', false, '2015-05-07 22:46:25.164', '2015-05-07 22:46:25.164');
INSERT INTO link_categories VALUES (611, 'Student Advising', 'student advising', false, '2015-05-07 22:46:25.417', '2015-05-07 22:46:25.417');
INSERT INTO link_categories VALUES (612, 'Your Questions Answered Here', 'your questions answered here', false, '2015-05-07 22:46:25.437', '2015-05-07 22:46:25.437');
INSERT INTO link_categories VALUES (613, 'Athletics', 'athletics', false, '2015-05-07 22:46:25.54', '2015-05-07 22:46:25.54');
INSERT INTO link_categories VALUES (614, 'Student Organizations', 'student organizations', false, '2015-05-07 22:46:25.635', '2015-05-07 22:46:25.635');
INSERT INTO link_categories VALUES (615, 'Campus Messaging', 'campus messaging', false, '2015-05-07 22:46:25.784', '2015-05-07 22:46:25.784');
INSERT INTO link_categories VALUES (616, 'Budget', 'budget', false, '2015-05-07 22:46:25.862', '2015-05-07 22:46:25.862');
INSERT INTO link_categories VALUES (617, 'Payroll', 'payroll', false, '2015-05-07 22:46:25.936', '2015-05-07 22:46:25.936');
INSERT INTO link_categories VALUES (618, 'Philanthropy & Public Service', 'philanthropy & public service', false, '2015-05-07 22:46:25.986', '2015-05-07 22:46:25.986');
INSERT INTO link_categories VALUES (619, 'Directory', 'directory', false, '2015-05-07 22:46:26.11', '2015-05-07 22:46:26.11');
INSERT INTO link_categories VALUES (620, 'Map', 'map', false, '2015-05-07 22:46:26.212', '2015-05-07 22:46:26.212');
INSERT INTO link_categories VALUES (621, 'Overview', 'overview', false, '2015-05-07 22:46:26.262', '2015-05-07 22:46:26.262');
INSERT INTO link_categories VALUES (622, 'Campus Health Center', 'campus health center', false, '2015-05-07 22:46:26.346', '2015-05-07 22:46:26.346');
INSERT INTO link_categories VALUES (623, 'Family', 'family', false, '2015-05-07 22:46:26.546', '2015-05-07 22:46:26.546');
INSERT INTO link_categories VALUES (624, 'Staff Support Services', 'staff support services', false, '2015-05-07 22:46:26.587', '2015-05-07 22:46:26.587');
INSERT INTO link_categories VALUES (625, 'Classroom Technology', 'classroom technology', false, '2015-05-07 22:46:26.729', '2015-05-07 22:46:26.729');
INSERT INTO link_categories VALUES (626, 'Emergency Preparedness', 'emergency preparedness', false, '2015-05-07 22:46:27.172', '2015-05-07 22:46:27.172');
INSERT INTO link_categories VALUES (627, 'Health & Safety', 'health & safety', false, '2015-05-07 22:46:27.28', '2015-05-07 22:46:27.28');
INSERT INTO link_categories VALUES (628, 'Employer & Employee', 'employer & employee', false, '2015-05-07 22:46:27.379', '2015-05-07 22:46:27.379');
INSERT INTO link_categories VALUES (629, 'News & Events', 'news & events', false, '2015-05-07 22:46:27.426', '2015-05-07 22:46:27.426');
INSERT INTO link_categories VALUES (630, 'Financial Assistance', 'financial assistance', false, '2015-05-07 22:46:27.587', '2015-05-07 22:46:27.587');
INSERT INTO link_categories VALUES (631, 'Computing', 'computing', false, '2015-05-07 22:46:27.736', '2015-05-07 22:46:27.736');
INSERT INTO link_categories VALUES (632, 'Graduate', 'graduate', false, '2015-05-07 22:46:27.848', '2015-05-07 22:46:27.848');
INSERT INTO link_categories VALUES (633, 'Student Employees', 'student employees', false, '2015-05-07 22:46:27.925', '2015-05-07 22:46:27.925');
INSERT INTO link_categories VALUES (634, 'Leaving Cal?', 'leaving cal?', false, '2015-05-07 22:46:27.967', '2015-05-07 22:46:27.967');
INSERT INTO link_categories VALUES (635, 'Human Resources', 'human resources', false, '2015-05-07 22:46:28.053', '2015-05-07 22:46:28.053');
INSERT INTO link_categories VALUES (636, 'Library', 'library', false, '2015-05-07 22:46:28.499', '2015-05-07 22:46:28.499');
INSERT INTO link_categories VALUES (637, 'Campus Mail', 'campus mail', false, '2015-05-07 22:46:28.604', '2015-05-07 22:46:28.604');
INSERT INTO link_categories VALUES (638, 'Professional Development', 'professional development', false, '2015-05-07 22:46:28.931', '2015-05-07 22:46:28.931');
INSERT INTO link_categories VALUES (639, 'My Information', 'my information', false, '2015-05-07 22:46:29.096', '2015-05-07 22:46:29.096');
INSERT INTO link_categories VALUES (640, 'Sports & Recreation', 'sports & recreation', false, '2015-05-07 22:46:29.206', '2015-05-07 22:46:29.206');
INSERT INTO link_categories VALUES (641, 'Police', 'police', false, '2015-05-07 22:46:29.252', '2015-05-07 22:46:29.252');
INSERT INTO link_categories VALUES (642, 'Network & Computing', 'network & computing', false, '2015-05-07 22:46:29.57', '2015-05-07 22:46:29.57');
INSERT INTO link_categories VALUES (643, 'Retirement', 'retirement', false, '2015-05-07 22:46:29.655', '2015-05-07 22:46:29.655');
INSERT INTO link_categories VALUES (644, 'Summer Programs', 'summer programs', false, '2015-05-07 22:46:29.792', '2015-05-07 22:46:29.792');
INSERT INTO link_categories VALUES (645, 'Conflict Resolution', 'conflict resolution', false, '2015-05-07 22:46:30.028', '2015-05-07 22:46:30.028');
INSERT INTO link_categories VALUES (646, 'Service Requests', 'service requests', false, '2015-05-07 22:46:30.265', '2015-05-07 22:46:30.265');
INSERT INTO link_categories VALUES (647, 'Student Services', 'student services', false, '2015-05-07 22:46:30.491', '2015-05-07 22:46:30.491');
INSERT INTO link_categories VALUES (648, 'Travel & Entertainment', 'travel & entertainment', false, '2015-05-07 22:46:30.598', '2015-05-07 22:46:30.598');
INSERT INTO link_categories VALUES (649, 'Social Media', 'social media', false, '2015-05-07 22:46:30.643', '2015-05-07 22:46:30.643');
INSERT INTO link_categories VALUES (650, 'News & Information', 'news & information', false, '2015-05-07 22:46:30.749', '2015-05-07 22:46:30.749');


--
-- Name: link_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('link_categories_id_seq', 650, true);


--
-- Data for Name: link_categories_link_sections; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: link_sections; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO link_sections VALUES (454, 570, 572, 583, '2015-05-07 22:46:22.544', '2015-05-07 22:46:22.544');
INSERT INTO link_sections VALUES (455, 558, 560, 584, '2015-05-07 22:46:22.7', '2015-05-07 22:46:22.7');
INSERT INTO link_sections VALUES (456, 558, 559, 558, '2015-05-07 22:46:22.833', '2015-05-07 22:46:22.833');
INSERT INTO link_sections VALUES (457, 564, 567, 585, '2015-05-07 22:46:22.913', '2015-05-07 22:46:22.913');
INSERT INTO link_sections VALUES (458, 558, 562, 586, '2015-05-07 22:46:22.988', '2015-05-07 22:46:22.988');
INSERT INTO link_sections VALUES (459, 564, 565, 587, '2015-05-07 22:46:23.055', '2015-05-07 22:46:23.055');
INSERT INTO link_sections VALUES (460, 564, 569, 588, '2015-05-07 22:46:23.13', '2015-05-07 22:46:23.13');
INSERT INTO link_sections VALUES (461, 570, 575, 589, '2015-05-07 22:46:23.202', '2015-05-07 22:46:23.202');
INSERT INTO link_sections VALUES (462, 577, 581, 590, '2015-05-07 22:46:23.264', '2015-05-07 22:46:23.264');
INSERT INTO link_sections VALUES (463, 570, 576, 591, '2015-05-07 22:46:23.325', '2015-05-07 22:46:23.325');
INSERT INTO link_sections VALUES (464, 564, 569, 592, '2015-05-07 22:46:23.38', '2015-05-07 22:46:23.38');
INSERT INTO link_sections VALUES (465, 564, 566, 593, '2015-05-07 22:46:23.455', '2015-05-07 22:46:23.455');
INSERT INTO link_sections VALUES (466, 558, 561, 561, '2015-05-07 22:46:23.573', '2015-05-07 22:46:23.573');
INSERT INTO link_sections VALUES (467, 558, 560, 594, '2015-05-07 22:46:23.697', '2015-05-07 22:46:23.697');
INSERT INTO link_sections VALUES (468, 564, 569, 595, '2015-05-07 22:46:23.777', '2015-05-07 22:46:23.777');
INSERT INTO link_sections VALUES (469, 570, 574, 596, '2015-05-07 22:46:23.84', '2015-05-07 22:46:23.84');
INSERT INTO link_sections VALUES (470, 558, 560, 597, '2015-05-07 22:46:23.906', '2015-05-07 22:46:23.906');
INSERT INTO link_sections VALUES (471, 577, 578, 598, '2015-05-07 22:46:23.975', '2015-05-07 22:46:23.975');
INSERT INTO link_sections VALUES (472, 558, 559, 599, '2015-05-07 22:46:24.048', '2015-05-07 22:46:24.048');
INSERT INTO link_sections VALUES (473, 570, 572, 600, '2015-05-07 22:46:24.145', '2015-05-07 22:46:24.145');
INSERT INTO link_sections VALUES (474, 577, 580, 601, '2015-05-07 22:46:24.3', '2015-05-07 22:46:24.3');
INSERT INTO link_sections VALUES (475, 564, 569, 602, '2015-05-07 22:46:24.371', '2015-05-07 22:46:24.371');
INSERT INTO link_sections VALUES (476, 577, 579, 603, '2015-05-07 22:46:24.476', '2015-05-07 22:46:24.476');
INSERT INTO link_sections VALUES (477, 564, 569, 604, '2015-05-07 22:46:24.536', '2015-05-07 22:46:24.536');
INSERT INTO link_sections VALUES (478, 558, 561, 605, '2015-05-07 22:46:24.71', '2015-05-07 22:46:24.71');
INSERT INTO link_sections VALUES (479, 564, 566, 606, '2015-05-07 22:46:24.779', '2015-05-07 22:46:24.779');
INSERT INTO link_sections VALUES (480, 558, 560, 561, '2015-05-07 22:46:24.835', '2015-05-07 22:46:24.835');
INSERT INTO link_sections VALUES (481, 558, 562, 607, '2015-05-07 22:46:24.932', '2015-05-07 22:46:24.932');
INSERT INTO link_sections VALUES (482, 577, 580, 608, '2015-05-07 22:46:25.018', '2015-05-07 22:46:25.018');
INSERT INTO link_sections VALUES (483, 564, 569, 609, '2015-05-07 22:46:25.116', '2015-05-07 22:46:25.116');
INSERT INTO link_sections VALUES (484, 570, 573, 610, '2015-05-07 22:46:25.176', '2015-05-07 22:46:25.176');
INSERT INTO link_sections VALUES (485, 570, 573, 600, '2015-05-07 22:46:25.226', '2015-05-07 22:46:25.226');
INSERT INTO link_sections VALUES (486, 570, 575, 610, '2015-05-07 22:46:25.379', '2015-05-07 22:46:25.379');
INSERT INTO link_sections VALUES (487, 558, 560, 611, '2015-05-07 22:46:25.429', '2015-05-07 22:46:25.429');
INSERT INTO link_sections VALUES (488, 577, 579, 612, '2015-05-07 22:46:25.449', '2015-05-07 22:46:25.449');
INSERT INTO link_sections VALUES (489, 570, 573, 613, '2015-05-07 22:46:25.551', '2015-05-07 22:46:25.551');
INSERT INTO link_sections VALUES (490, 570, 575, 614, '2015-05-07 22:46:25.646', '2015-05-07 22:46:25.646');
INSERT INTO link_sections VALUES (491, 564, 566, 615, '2015-05-07 22:46:25.795', '2015-05-07 22:46:25.795');
INSERT INTO link_sections VALUES (492, 564, 569, 616, '2015-05-07 22:46:25.874', '2015-05-07 22:46:25.874');
INSERT INTO link_sections VALUES (493, 564, 569, 617, '2015-05-07 22:46:25.947', '2015-05-07 22:46:25.947');
INSERT INTO link_sections VALUES (494, 570, 571, 618, '2015-05-07 22:46:25.997', '2015-05-07 22:46:25.997');
INSERT INTO link_sections VALUES (495, 570, 571, 619, '2015-05-07 22:46:26.122', '2015-05-07 22:46:26.122');
INSERT INTO link_sections VALUES (496, 570, 572, 620, '2015-05-07 22:46:26.223', '2015-05-07 22:46:26.223');
INSERT INTO link_sections VALUES (497, 564, 568, 621, '2015-05-07 22:46:26.273', '2015-05-07 22:46:26.273');
INSERT INTO link_sections VALUES (498, 577, 582, 622, '2015-05-07 22:46:26.357', '2015-05-07 22:46:26.357');
INSERT INTO link_sections VALUES (499, 577, 580, 623, '2015-05-07 22:46:26.565', '2015-05-07 22:46:26.565');
INSERT INTO link_sections VALUES (500, 577, 581, 623, '2015-05-07 22:46:26.578', '2015-05-07 22:46:26.578');
INSERT INTO link_sections VALUES (501, 577, 582, 624, '2015-05-07 22:46:26.601', '2015-05-07 22:46:26.601');
INSERT INTO link_sections VALUES (502, 558, 562, 625, '2015-05-07 22:46:26.742', '2015-05-07 22:46:26.742');
INSERT INTO link_sections VALUES (503, 570, 574, 626, '2015-05-07 22:46:27.183', '2015-05-07 22:46:27.183');
INSERT INTO link_sections VALUES (504, 558, 563, 627, '2015-05-07 22:46:27.294', '2015-05-07 22:46:27.294');
INSERT INTO link_sections VALUES (505, 564, 567, 628, '2015-05-07 22:46:27.389', '2015-05-07 22:46:27.389');
INSERT INTO link_sections VALUES (506, 570, 571, 629, '2015-05-07 22:46:27.44', '2015-05-07 22:46:27.44');
INSERT INTO link_sections VALUES (507, 577, 579, 630, '2015-05-07 22:46:27.598', '2015-05-07 22:46:27.598');
INSERT INTO link_sections VALUES (508, 564, 569, 631, '2015-05-07 22:46:27.746', '2015-05-07 22:46:27.746');
INSERT INTO link_sections VALUES (509, 558, 559, 632, '2015-05-07 22:46:27.859', '2015-05-07 22:46:27.859');
INSERT INTO link_sections VALUES (510, 577, 578, 633, '2015-05-07 22:46:27.936', '2015-05-07 22:46:27.936');
INSERT INTO link_sections VALUES (511, 577, 579, 634, '2015-05-07 22:46:27.978', '2015-05-07 22:46:27.978');
INSERT INTO link_sections VALUES (512, 564, 569, 635, '2015-05-07 22:46:28.066', '2015-05-07 22:46:28.066');
INSERT INTO link_sections VALUES (513, 558, 563, 621, '2015-05-07 22:46:28.452', '2015-05-07 22:46:28.452');
INSERT INTO link_sections VALUES (514, 558, 559, 636, '2015-05-07 22:46:28.511', '2015-05-07 22:46:28.511');
INSERT INTO link_sections VALUES (515, 564, 569, 637, '2015-05-07 22:46:28.618', '2015-05-07 22:46:28.618');
INSERT INTO link_sections VALUES (516, 558, 563, 638, '2015-05-07 22:46:28.944', '2015-05-07 22:46:28.944');
INSERT INTO link_sections VALUES (517, 577, 581, 639, '2015-05-07 22:46:29.108', '2015-05-07 22:46:29.108');
INSERT INTO link_sections VALUES (518, 570, 573, 640, '2015-05-07 22:46:29.217', '2015-05-07 22:46:29.217');
INSERT INTO link_sections VALUES (519, 570, 574, 641, '2015-05-07 22:46:29.263', '2015-05-07 22:46:29.263');
INSERT INTO link_sections VALUES (520, 577, 580, 642, '2015-05-07 22:46:29.58', '2015-05-07 22:46:29.58');
INSERT INTO link_sections VALUES (521, 577, 581, 643, '2015-05-07 22:46:29.666', '2015-05-07 22:46:29.666');
INSERT INTO link_sections VALUES (522, 577, 579, 644, '2015-05-07 22:46:29.802', '2015-05-07 22:46:29.802');
INSERT INTO link_sections VALUES (523, 577, 581, 645, '2015-05-07 22:46:30.051', '2015-05-07 22:46:30.051');
INSERT INTO link_sections VALUES (524, 564, 568, 646, '2015-05-07 22:46:30.275', '2015-05-07 22:46:30.275');
INSERT INTO link_sections VALUES (525, 564, 565, 647, '2015-05-07 22:46:30.502', '2015-05-07 22:46:30.502');
INSERT INTO link_sections VALUES (526, 564, 569, 648, '2015-05-07 22:46:30.608', '2015-05-07 22:46:30.608');
INSERT INTO link_sections VALUES (527, 570, 571, 649, '2015-05-07 22:46:30.653', '2015-05-07 22:46:30.653');
INSERT INTO link_sections VALUES (528, 577, 582, 650, '2015-05-07 22:46:30.759', '2015-05-07 22:46:30.759');


--
-- Name: link_sections_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('link_sections_id_seq', 528, true);


--
-- Data for Name: link_sections_links; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO link_sections_links VALUES (454, 1062);
INSERT INTO link_sections_links VALUES (455, 1063);
INSERT INTO link_sections_links VALUES (455, 1064);
INSERT INTO link_sections_links VALUES (456, 1065);
INSERT INTO link_sections_links VALUES (457, 1066);
INSERT INTO link_sections_links VALUES (458, 1067);
INSERT INTO link_sections_links VALUES (459, 1068);
INSERT INTO link_sections_links VALUES (460, 1069);
INSERT INTO link_sections_links VALUES (461, 1070);
INSERT INTO link_sections_links VALUES (462, 1071);
INSERT INTO link_sections_links VALUES (463, 1072);
INSERT INTO link_sections_links VALUES (464, 1073);
INSERT INTO link_sections_links VALUES (465, 1074);
INSERT INTO link_sections_links VALUES (465, 1075);
INSERT INTO link_sections_links VALUES (466, 1076);
INSERT INTO link_sections_links VALUES (465, 1077);
INSERT INTO link_sections_links VALUES (467, 1078);
INSERT INTO link_sections_links VALUES (468, 1079);
INSERT INTO link_sections_links VALUES (469, 1080);
INSERT INTO link_sections_links VALUES (470, 1081);
INSERT INTO link_sections_links VALUES (471, 1082);
INSERT INTO link_sections_links VALUES (472, 1083);
INSERT INTO link_sections_links VALUES (473, 1084);
INSERT INTO link_sections_links VALUES (459, 1085);
INSERT INTO link_sections_links VALUES (474, 1086);
INSERT INTO link_sections_links VALUES (475, 1087);
INSERT INTO link_sections_links VALUES (464, 1088);
INSERT INTO link_sections_links VALUES (476, 1089);
INSERT INTO link_sections_links VALUES (477, 1090);
INSERT INTO link_sections_links VALUES (468, 1091);
INSERT INTO link_sections_links VALUES (465, 1092);
INSERT INTO link_sections_links VALUES (478, 1093);
INSERT INTO link_sections_links VALUES (479, 1094);
INSERT INTO link_sections_links VALUES (480, 1095);
INSERT INTO link_sections_links VALUES (466, 1095);
INSERT INTO link_sections_links VALUES (479, 1095);
INSERT INTO link_sections_links VALUES (481, 1096);
INSERT INTO link_sections_links VALUES (458, 1097);
INSERT INTO link_sections_links VALUES (482, 1098);
INSERT INTO link_sections_links VALUES (460, 1098);
INSERT INTO link_sections_links VALUES (483, 1099);
INSERT INTO link_sections_links VALUES (484, 1100);
INSERT INTO link_sections_links VALUES (485, 1101);
INSERT INTO link_sections_links VALUES (485, 1102);
INSERT INTO link_sections_links VALUES (474, 1103);
INSERT INTO link_sections_links VALUES (486, 1104);
INSERT INTO link_sections_links VALUES (487, 1105);
INSERT INTO link_sections_links VALUES (488, 1105);
INSERT INTO link_sections_links VALUES (485, 1106);
INSERT INTO link_sections_links VALUES (489, 1107);
INSERT INTO link_sections_links VALUES (482, 1108);
INSERT INTO link_sections_links VALUES (474, 1109);
INSERT INTO link_sections_links VALUES (490, 1109);
INSERT INTO link_sections_links VALUES (490, 1110);
INSERT INTO link_sections_links VALUES (471, 1111);
INSERT INTO link_sections_links VALUES (465, 1112);
INSERT INTO link_sections_links VALUES (491, 1113);
INSERT INTO link_sections_links VALUES (460, 1114);
INSERT INTO link_sections_links VALUES (492, 1115);
INSERT INTO link_sections_links VALUES (479, 1116);
INSERT INTO link_sections_links VALUES (493, 1117);
INSERT INTO link_sections_links VALUES (494, 1118);
INSERT INTO link_sections_links VALUES (478, 1119);
INSERT INTO link_sections_links VALUES (464, 1120);
INSERT INTO link_sections_links VALUES (495, 1121);
INSERT INTO link_sections_links VALUES (459, 1122);
INSERT INTO link_sections_links VALUES (496, 1123);
INSERT INTO link_sections_links VALUES (497, 1124);
INSERT INTO link_sections_links VALUES (454, 1125);
INSERT INTO link_sections_links VALUES (498, 1126);
INSERT INTO link_sections_links VALUES (471, 1127);
INSERT INTO link_sections_links VALUES (471, 1128);
INSERT INTO link_sections_links VALUES (471, 1129);
INSERT INTO link_sections_links VALUES (471, 1130);
INSERT INTO link_sections_links VALUES (471, 1131);
INSERT INTO link_sections_links VALUES (499, 1132);
INSERT INTO link_sections_links VALUES (500, 1132);
INSERT INTO link_sections_links VALUES (501, 1132);
INSERT INTO link_sections_links VALUES (470, 1133);
INSERT INTO link_sections_links VALUES (454, 1134);
INSERT INTO link_sections_links VALUES (502, 1135);
INSERT INTO link_sections_links VALUES (456, 1136);
INSERT INTO link_sections_links VALUES (457, 1137);
INSERT INTO link_sections_links VALUES (463, 1138);
INSERT INTO link_sections_links VALUES (498, 1138);
INSERT INTO link_sections_links VALUES (470, 1139);
INSERT INTO link_sections_links VALUES (470, 1140);
INSERT INTO link_sections_links VALUES (480, 1141);
INSERT INTO link_sections_links VALUES (466, 1141);
INSERT INTO link_sections_links VALUES (463, 1142);
INSERT INTO link_sections_links VALUES (476, 1143);
INSERT INTO link_sections_links VALUES (487, 1144);
INSERT INTO link_sections_links VALUES (480, 1145);
INSERT INTO link_sections_links VALUES (466, 1145);
INSERT INTO link_sections_links VALUES (503, 1146);
INSERT INTO link_sections_links VALUES (503, 1147);
INSERT INTO link_sections_links VALUES (504, 1148);
INSERT INTO link_sections_links VALUES (459, 1149);
INSERT INTO link_sections_links VALUES (505, 1150);
INSERT INTO link_sections_links VALUES (506, 1151);
INSERT INTO link_sections_links VALUES (456, 1152);
INSERT INTO link_sections_links VALUES (459, 1153);
INSERT INTO link_sections_links VALUES (458, 1154);
INSERT INTO link_sections_links VALUES (507, 1155);
INSERT INTO link_sections_links VALUES (507, 1156);
INSERT INTO link_sections_links VALUES (470, 1157);
INSERT INTO link_sections_links VALUES (463, 1158);
INSERT INTO link_sections_links VALUES (501, 1158);
INSERT INTO link_sections_links VALUES (508, 1159);
INSERT INTO link_sections_links VALUES (494, 1160);
INSERT INTO link_sections_links VALUES (461, 1161);
INSERT INTO link_sections_links VALUES (509, 1162);
INSERT INTO link_sections_links VALUES (507, 1163);
INSERT INTO link_sections_links VALUES (510, 1164);
INSERT INTO link_sections_links VALUES (511, 1165);
INSERT INTO link_sections_links VALUES (476, 1166);
INSERT INTO link_sections_links VALUES (498, 1166);
INSERT INTO link_sections_links VALUES (512, 1167);
INSERT INTO link_sections_links VALUES (512, 1168);
INSERT INTO link_sections_links VALUES (508, 1169);
INSERT INTO link_sections_links VALUES (474, 1170);
INSERT INTO link_sections_links VALUES (508, 1171);
INSERT INTO link_sections_links VALUES (508, 1172);
INSERT INTO link_sections_links VALUES (478, 1173);
INSERT INTO link_sections_links VALUES (506, 1174);
INSERT INTO link_sections_links VALUES (485, 1174);
INSERT INTO link_sections_links VALUES (504, 1175);
INSERT INTO link_sections_links VALUES (486, 1176);
INSERT INTO link_sections_links VALUES (513, 1177);
INSERT INTO link_sections_links VALUES (514, 1178);
INSERT INTO link_sections_links VALUES (478, 1178);
INSERT INTO link_sections_links VALUES (474, 1179);
INSERT INTO link_sections_links VALUES (515, 1180);
INSERT INTO link_sections_links VALUES (463, 1181);
INSERT INTO link_sections_links VALUES (507, 1182);
INSERT INTO link_sections_links VALUES (458, 1183);
INSERT INTO link_sections_links VALUES (463, 1184);
INSERT INTO link_sections_links VALUES (506, 1185);
INSERT INTO link_sections_links VALUES (459, 1186);
INSERT INTO link_sections_links VALUES (467, 1187);
INSERT INTO link_sections_links VALUES (487, 1188);
INSERT INTO link_sections_links VALUES (508, 1189);
INSERT INTO link_sections_links VALUES (516, 1190);
INSERT INTO link_sections_links VALUES (454, 1191);
INSERT INTO link_sections_links VALUES (476, 1192);
INSERT INTO link_sections_links VALUES (493, 1193);
INSERT INTO link_sections_links VALUES (517, 1194);
INSERT INTO link_sections_links VALUES (517, 1195);
INSERT INTO link_sections_links VALUES (505, 1196);
INSERT INTO link_sections_links VALUES (518, 1197);
INSERT INTO link_sections_links VALUES (519, 1198);
INSERT INTO link_sections_links VALUES (457, 1199);
INSERT INTO link_sections_links VALUES (494, 1200);
INSERT INTO link_sections_links VALUES (468, 1201);
INSERT INTO link_sections_links VALUES (518, 1202);
INSERT INTO link_sections_links VALUES (476, 1203);
INSERT INTO link_sections_links VALUES (472, 1204);
INSERT INTO link_sections_links VALUES (479, 1205);
INSERT INTO link_sections_links VALUES (474, 1206);
INSERT INTO link_sections_links VALUES (520, 1207);
INSERT INTO link_sections_links VALUES (508, 1207);
INSERT INTO link_sections_links VALUES (463, 1208);
INSERT INTO link_sections_links VALUES (521, 1209);
INSERT INTO link_sections_links VALUES (521, 1210);
INSERT INTO link_sections_links VALUES (503, 1211);
INSERT INTO link_sections_links VALUES (460, 1212);
INSERT INTO link_sections_links VALUES (522, 1213);
INSERT INTO link_sections_links VALUES (470, 1214);
INSERT INTO link_sections_links VALUES (470, 1215);
INSERT INTO link_sections_links VALUES (466, 1215);
INSERT INTO link_sections_links VALUES (470, 1216);
INSERT INTO link_sections_links VALUES (466, 1216);
INSERT INTO link_sections_links VALUES (508, 1217);
INSERT INTO link_sections_links VALUES (523, 1218);
INSERT INTO link_sections_links VALUES (457, 1219);
INSERT INTO link_sections_links VALUES (459, 1220);
INSERT INTO link_sections_links VALUES (507, 1221);
INSERT INTO link_sections_links VALUES (487, 1222);
INSERT INTO link_sections_links VALUES (463, 1223);
INSERT INTO link_sections_links VALUES (490, 1224);
INSERT INTO link_sections_links VALUES (524, 1225);
INSERT INTO link_sections_links VALUES (522, 1226);
INSERT INTO link_sections_links VALUES (470, 1227);
INSERT INTO link_sections_links VALUES (466, 1227);
INSERT INTO link_sections_links VALUES (476, 1228);
INSERT INTO link_sections_links VALUES (458, 1229);
INSERT INTO link_sections_links VALUES (470, 1230);
INSERT INTO link_sections_links VALUES (506, 1231);
INSERT INTO link_sections_links VALUES (525, 1232);
INSERT INTO link_sections_links VALUES (506, 1233);
INSERT INTO link_sections_links VALUES (463, 1234);
INSERT INTO link_sections_links VALUES (526, 1235);
INSERT INTO link_sections_links VALUES (527, 1236);
INSERT INTO link_sections_links VALUES (527, 1237);
INSERT INTO link_sections_links VALUES (485, 1238);
INSERT INTO link_sections_links VALUES (528, 1239);
INSERT INTO link_sections_links VALUES (480, 1240);
INSERT INTO link_sections_links VALUES (466, 1240);
INSERT INTO link_sections_links VALUES (516, 1240);
INSERT INTO link_sections_links VALUES (516, 1241);
INSERT INTO link_sections_links VALUES (498, 1242);
INSERT INTO link_sections_links VALUES (498, 1243);
INSERT INTO link_sections_links VALUES (455, 1244);
INSERT INTO link_sections_links VALUES (463, 1245);
INSERT INTO link_sections_links VALUES (459, 1246);
INSERT INTO link_sections_links VALUES (458, 1247);
INSERT INTO link_sections_links VALUES (511, 1248);
INSERT INTO link_sections_links VALUES (510, 1249);
INSERT INTO link_sections_links VALUES (507, 1249);
INSERT INTO link_sections_links VALUES (478, 1250);


--
-- Data for Name: links; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO links VALUES (1062, '511.org (Bay Area Transportation Planner)', 'http://www.511.org/', 'Calculates transportation options for traveling', true, '2015-05-07 22:46:22.634', '2015-05-07 22:46:22.634');
INSERT INTO links VALUES (1063, 'Academic Calendar', 'http://registrar.berkeley.edu/CalendarDisp.aspx?terms=current', 'Academic Calendars Future Campus Calendars', true, '2015-05-07 22:46:22.736', '2015-05-07 22:46:22.736');
INSERT INTO links VALUES (1064, 'Academic Calendar - Berkeley Law', 'https://www.law.berkeley.edu/php-programs/courses/academic_calendars.php', 'Academic calendar including academic and administrative holidays', true, '2015-05-07 22:46:22.792', '2015-05-07 22:46:22.792');
INSERT INTO links VALUES (1065, 'Academic Departments & Programs', 'http://www.berkeley.edu/academics/dept/a.shtml', 'UC Berkeley''s variety of degree programs', true, '2015-05-07 22:46:22.865', '2015-05-07 22:46:22.865');
INSERT INTO links VALUES (1066, 'Academic Policies', 'http://bulletin.berkeley.edu/academic-policies/', 'Policies set by the university specific for Berkeley students', true, '2015-05-07 22:46:22.941', '2015-05-07 22:46:22.941');
INSERT INTO links VALUES (1067, 'Academic Senate', 'http://academic-senate.berkeley.edu/', 'Governance held by faculty member to make decisions campus-wide', true, '2015-05-07 22:46:23.014', '2015-05-07 22:46:23.014');
INSERT INTO links VALUES (1068, 'Administration & Finance', 'http://vcaf.berkeley.edu/who-we-are/divisions', 'Administration officials ', true, '2015-05-07 22:46:23.085', '2015-05-07 22:46:23.085');
INSERT INTO links VALUES (1069, 'AirBears', 'http://ist.berkeley.edu/airbears/', 'Berkeley''s free internet wifi for Berkeley affiliates with a calnet and passphrase', true, '2015-05-07 22:46:23.156', '2015-05-07 22:46:23.156');
INSERT INTO links VALUES (1070, 'ASUC', 'http://asuc.org/', 'Student government', true, '2015-05-07 22:46:23.225', '2015-05-07 22:46:23.225');
INSERT INTO links VALUES (1071, 'At Your Service', 'https://atyourserviceonline.ucop.edu', 'Benefits, Earnings, Taxes & Retirement', true, '2015-05-07 22:46:23.287', '2015-05-07 22:46:23.287');
INSERT INTO links VALUES (1072, 'Athletic Study Center', 'https://asc.berkeley.edu/', 'Advising and tutoring for student athletes', true, '2015-05-07 22:46:23.347', '2015-05-07 22:46:23.347');
INSERT INTO links VALUES (1073, 'BAIRS', 'http://www.bai.berkeley.edu/BAIRS/index.htm', 'Berkeley Administrative Initiative Reporting System', true, '2015-05-07 22:46:23.407', '2015-05-07 22:46:23.407');
INSERT INTO links VALUES (1074, 'bCal', 'http://bcal.berkeley.edu', 'Your campus calendar', true, '2015-05-07 22:46:23.486', '2015-05-07 22:46:23.486');
INSERT INTO links VALUES (1075, 'bConnected Support', 'http://ist.berkeley.edu/bconnected', 'Information and resources site for Berkeley''s email, calendar and shared drive solutions, powered by Google Apps for Education', true, '2015-05-07 22:46:23.537', '2015-05-07 22:46:23.537');
INSERT INTO links VALUES (1076, 'bCourses', 'http://bcourses.berkeley.edu', 'Campus Learning Management System (LMS) powered by Canvas', true, '2015-05-07 22:46:23.6', '2015-05-07 22:46:23.6');
INSERT INTO links VALUES (1077, 'bDrive', 'http://bdrive.berkeley.edu', 'An area to store files that can be shared and collaborated', true, '2015-05-07 22:46:23.651', '2015-05-07 22:46:23.651');
INSERT INTO links VALUES (1078, 'Bear Facts', 'https://bearfacts.berkeley.edu', 'Academic record, grades & transcript, bill, degree audit, loans, SLR & personal info', true, '2015-05-07 22:46:23.724', '2015-05-07 22:46:23.724');
INSERT INTO links VALUES (1079, 'BearBuy', 'http://supplychain.berkeley.edu/bearbuy/', 'Campus procurement system with online catalog shopping and electronically-enabled workflows', true, '2015-05-07 22:46:23.802', '2015-05-07 22:46:23.802');
INSERT INTO links VALUES (1080, 'BearWALK Night safety services', 'http://police.berkeley.edu/programsandservices/campus_safety/index.html', 'Free safety night walks to and from a desired location with a Community Service Officer', true, '2015-05-07 22:46:23.864', '2015-05-07 22:46:23.864');
INSERT INTO links VALUES (1081, 'Berkeley Academic Guide', 'http://guide.berkeley.edu/', 'Degree programs, academic policies, and course catalog', true, '2015-05-07 22:46:23.931', '2015-05-07 22:46:23.931');
INSERT INTO links VALUES (1082, 'Berkeley Jobs', 'http://jobs.berkeley.edu/', 'Start here to learn about job openings on campus, student, staff and academic positions', true, '2015-05-07 22:46:23.999', '2015-05-07 22:46:23.999');
INSERT INTO links VALUES (1083, 'Berkeley Research', 'http://vcresearch.berkeley.edu/', 'Research information and opportunities', true, '2015-05-07 22:46:24.084', '2015-05-07 22:46:24.084');
INSERT INTO links VALUES (1084, 'Berkeley Self-Guided Tours', 'http://visitors.berkeley.edu/tour/self.shtml', 'Mobile, podcast, cell phone, and other tours of the Berkeley campus', true, '2015-05-07 22:46:24.173', '2015-05-07 22:46:24.173');
INSERT INTO links VALUES (1085, 'Berkeley Sites (A-Z)', 'http://www.berkeley.edu/a-z/a.shtml', 'Navigating UC Berkeley', true, '2015-05-07 22:46:24.242', '2015-05-07 22:46:24.242');
INSERT INTO links VALUES (1086, 'Berkeley Student Cooperative', 'http://www.bsc.coop/', 'Berkeley''s co-operative student housing option, and an alternative to living in student dorms', true, '2015-05-07 22:46:24.332', '2015-05-07 22:46:24.332');
INSERT INTO links VALUES (1087, 'BETS - equipment tracking', 'http://bets.berkeley.edu/BETS/home/BetsHome.cfm', 'Equipment Tracking System of inventorial and non-inventorial equipment', true, '2015-05-07 22:46:24.395', '2015-05-07 22:46:24.395');
INSERT INTO links VALUES (1088, 'BFS', 'http://www.bai.berkeley.edu/BFS/index.htm', 'Berkeley Financial System', true, '2015-05-07 22:46:24.432', '2015-05-07 22:46:24.432');
INSERT INTO links VALUES (1089, 'Billing Services', 'http://studentbilling.berkeley.edu/', 'Billing and payment options for students and parents', true, '2015-05-07 22:46:24.504', '2015-05-07 22:46:24.504');
INSERT INTO links VALUES (1090, 'Blu', 'http://blu.berkeley.edu', 'Berkeley''s employee portal: work-related tools and information', true, '2015-05-07 22:46:24.56', '2015-05-07 22:46:24.56');
INSERT INTO links VALUES (1091, 'Blu Card', 'http://supplychain.berkeley.edu/programs/card-program-services/blucard', 'A procurement card, issued to select employees, and used for purchasing work-related items and services', true, '2015-05-07 22:46:24.602', '2015-05-07 22:46:24.602');
INSERT INTO links VALUES (1092, 'bMail', 'http://bmail.berkeley.edu', 'Your campus email account', true, '2015-05-07 22:46:24.654', '2015-05-07 22:46:24.654');
INSERT INTO links VALUES (1093, 'Bookstore - Berkeley Law', 'http://www.law.berkeley.edu/15687.htm', 'Textbooks and other learning resources for Berkeley Law students', true, '2015-05-07 22:46:24.741', '2015-05-07 22:46:24.741');
INSERT INTO links VALUES (1094, 'Box.net', 'https://berkeley.box.com/', 'Cloud-hosted platform allowing users to store and share documents and other materials for collaborations', true, '2015-05-07 22:46:24.805', '2015-05-07 22:46:24.805');
INSERT INTO links VALUES (1095, 'bSpace', 'http://bspace.berkeley.edu', 'Homework assignments, lecture slides, syllabi and class resources', true, '2015-05-07 22:46:24.881', '2015-05-07 22:46:24.881');
INSERT INTO links VALUES (1096, 'bSpace Grade book', 'http://gsi.berkeley.edu/teachingguide/tech/bspace-gradebook.html', 'A tool to enter, upload, and calculate student grades on bSpace', true, '2015-05-07 22:46:24.952', '2015-05-07 22:46:24.952');
INSERT INTO links VALUES (1097, 'bSpace Support', 'http://ets.berkeley.edu/bspace', 'A communication and collaboration program that supports teaching and learning', true, '2015-05-07 22:46:24.989', '2015-05-07 22:46:24.989');
INSERT INTO links VALUES (1098, 'Cal 1 Card', 'http://services.housing.berkeley.edu/c1c/static/index.htm', 'The campus identification, and optional, debit and meal points card.', true, '2015-05-07 22:46:25.052', '2015-05-07 22:46:25.052');
INSERT INTO links VALUES (1099, 'Cal Answers', 'http://calanswers.berkeley.edu/', 'Provides reliable and consistent answers to critical campus questions', true, '2015-05-07 22:46:25.143', '2015-05-07 22:46:25.143');
INSERT INTO links VALUES (1100, 'Cal Band', 'http://calband.berkeley.edu/', 'UC Berkeley''s marching band', true, '2015-05-07 22:46:25.196', '2015-05-07 22:46:25.196');
INSERT INTO links VALUES (1101, 'Cal Marketplace', 'http://calmarketplace.berkeley.edu/', 'Everything at Cal you may want to buy, discover or visit', true, '2015-05-07 22:46:25.248', '2015-05-07 22:46:25.248');
INSERT INTO links VALUES (1102, 'Cal Performances', 'http://www.calperformances.org/', 'Information and tickets for Cal music, dance, and theater performances', true, '2015-05-07 22:46:25.303', '2015-05-07 22:46:25.303');
INSERT INTO links VALUES (1103, 'Cal Rentals', 'http://calrentals.housing.berkeley.edu/', 'Listings of housing opportunities for the Berkeley community', true, '2015-05-07 22:46:25.347', '2015-05-07 22:46:25.347');
INSERT INTO links VALUES (1104, 'Cal Spirit Groups', 'http://calspirit.berkeley.edu/', 'Cheerleading and Dance Group ', true, '2015-05-07 22:46:25.399', '2015-05-07 22:46:25.399');
INSERT INTO links VALUES (1105, 'Cal Student Central', 'http://studentcentral.berkeley.edu/', 'A resourceful website with answers to the most frequently asked questions by students', true, '2015-05-07 22:46:25.478', '2015-05-07 22:46:25.478');
INSERT INTO links VALUES (1106, 'Cal Student Store', 'https://calstudentstore.berkeley.edu/', 'Apparel, school supplies, and more ', true, '2015-05-07 22:46:25.513', '2015-05-07 22:46:25.513');
INSERT INTO links VALUES (1107, 'CalBears Intercollegiate Athletics', 'http://www.calbears.com/', 'Berkeley''s official sport teams', true, '2015-05-07 22:46:25.572', '2015-05-07 22:46:25.572');
INSERT INTO links VALUES (1108, 'CalDining', 'http://caldining.berkeley.edu/', 'Campus dining facilities', true, '2015-05-07 22:46:25.608', '2015-05-07 22:46:25.608');
INSERT INTO links VALUES (1109, 'CalGreeks', 'http://www.calgreeks.com/', 'Fraternities, Sororities, and professional fraternities among the Greek Family', true, '2015-05-07 22:46:25.671', '2015-05-07 22:46:25.671');
INSERT INTO links VALUES (1110, 'CalLink (Campus Activities Link)', 'http://callink.berkeley.edu/', 'Official campus student groups', true, '2015-05-07 22:46:25.705', '2015-05-07 22:46:25.705');
INSERT INTO links VALUES (1111, 'Callisto & CalJobs', 'https://career.berkeley.edu/CareerApps/Callisto/CallistoLogin.aspx', 'Official Berkeley website for all things job-related', true, '2015-05-07 22:46:25.733', '2015-05-07 22:46:25.733');
INSERT INTO links VALUES (1112, 'CalMail', 'http://calmail.berkeley.edu', 'Campus email management', true, '2015-05-07 22:46:25.762', '2015-05-07 22:46:25.762');
INSERT INTO links VALUES (1113, 'CalMessages', 'https://calmessages.berkeley.edu/', 'Berkeley''s official messaging system used to send broadcast email notifications to all staff, all students, etc.', true, '2015-05-07 22:46:25.812', '2015-05-07 22:46:25.812');
INSERT INTO links VALUES (1114, 'CalNet', 'https://calnet.berkeley.edu/', 'An online identity username that all Berkeley affiliates have to log into Berkeley websites', true, '2015-05-07 22:46:25.84', '2015-05-07 22:46:25.84');
INSERT INTO links VALUES (1115, 'CalPlanning', 'http://budget.berkeley.edu/systems/calplanning', 'UC Berkeley''s financial planning and analysis tool', true, '2015-05-07 22:46:25.89', '2015-05-07 22:46:25.89');
INSERT INTO links VALUES (1116, 'CalShare', 'https://calshare.berkeley.edu/', 'Tool for creating and managing web sites for collaboration purposes', true, '2015-05-07 22:46:25.918', '2015-05-07 22:46:25.918');
INSERT INTO links VALUES (1117, 'CalTime', 'http://caltime.berkeley.edu', 'Tracking and reporting work and time leave-timekeeping', true, '2015-05-07 22:46:25.966', '2015-05-07 22:46:25.966');
INSERT INTO links VALUES (1118, 'Campaign for Berkeley', 'http://campaign.berkeley.edu/', 'The campaign to raise money to help Berkeley''s programs and affiliates', true, '2015-05-07 22:46:26.016', '2015-05-07 22:46:26.016');
INSERT INTO links VALUES (1119, 'Campus Bookstore', 'https://calstudentstore.berkeley.edu/textbook', 'Text books and more', true, '2015-05-07 22:46:26.057', '2015-05-07 22:46:26.057');
INSERT INTO links VALUES (1120, 'Campus Deposit System (CDS)', 'https://cdsonline.berkeley.edu', 'Financial system used by departments to make cash deposits to their accounts', true, '2015-05-07 22:46:26.091', '2015-05-07 22:46:26.091');
INSERT INTO links VALUES (1121, 'Campus Directory - People Finder', 'http://directory.berkeley.edu', 'Campus directory of faculty, staff and students', true, '2015-05-07 22:46:26.141', '2015-05-07 22:46:26.141');
INSERT INTO links VALUES (1122, 'Campus IT Offices', 'http://www.berkeley.edu/admin/compute.shtml#offices', 'Contact information for information technology services', true, '2015-05-07 22:46:26.189', '2015-05-07 22:46:26.189');
INSERT INTO links VALUES (1123, 'Campus Map', 'http://www.berkeley.edu/map/3dmap/3dmap.shtml', 'Locate campus buildings', true, '2015-05-07 22:46:26.241', '2015-05-07 22:46:26.241');
INSERT INTO links VALUES (1124, 'Campus Shared Services', 'http://sharedservices.berkeley.edu/', 'Answers to questions and the ability to submit help requests', true, '2015-05-07 22:46:26.29', '2015-05-07 22:46:26.29');
INSERT INTO links VALUES (1125, 'Campus Shuttles', 'http://pt.berkeley.edu/around/transit/routes/', 'Bus routes around the Berkeley campus (most are free)', true, '2015-05-07 22:46:26.322', '2015-05-07 22:46:26.322');
INSERT INTO links VALUES (1126, 'CARE Services', 'http://uhs.berkeley.edu/facstaff/care/', 'free, confidential problem assessment and referral for UC Berkeley faculty and staff', true, '2015-05-07 22:46:26.374', '2015-05-07 22:46:26.374');
INSERT INTO links VALUES (1127, 'Career Center', 'http://career.berkeley.edu/', 'Cal jobs, internships & career counseling', true, '2015-05-07 22:46:26.406', '2015-05-07 22:46:26.406');
INSERT INTO links VALUES (1128, 'Career Center: Internships', 'https://career.berkeley.edu/Internships/Internships.stm', 'Resources and Information for Internships', true, '2015-05-07 22:46:26.438', '2015-05-07 22:46:26.438');
INSERT INTO links VALUES (1129, 'Career Center: Job Search Tools', 'https://career.berkeley.edu/Tools/Tools.stm', 'Resources on how to find a good job or internship ', true, '2015-05-07 22:46:26.467', '2015-05-07 22:46:26.467');
INSERT INTO links VALUES (1130, 'Career Center: Part-time Employment', 'https://career.berkeley.edu/Parttime/Parttime.stm', 'Links to part-time websites', true, '2015-05-07 22:46:26.501', '2015-05-07 22:46:26.501');
INSERT INTO links VALUES (1131, 'Career Development Office - Berkeley Law', 'http://www.law.berkeley.edu/careers.htm', 'Berkeley Law career development office', true, '2015-05-07 22:46:26.529', '2015-05-07 22:46:26.529');
INSERT INTO links VALUES (1132, 'Child Care', 'http://www.housing.berkeley.edu/child/', 'Campus child care services', true, '2015-05-07 22:46:26.634', '2015-05-07 22:46:26.634');
INSERT INTO links VALUES (1133, 'Class Enrollment Rules and Guides', 'http://registrar.berkeley.edu/StudentSystems/tbinfo.html', 'Registrar guide to Tele-BEARS, enrollment periods, add-drop deadlines, and other tips', true, '2015-05-07 22:46:26.681', '2015-05-07 22:46:26.681');
INSERT INTO links VALUES (1134, 'Class pass', 'http://pt.berkeley.edu/pay/transit/classpass/', 'AC Transit Pass to bus for free', true, '2015-05-07 22:46:26.712', '2015-05-07 22:46:26.712');
INSERT INTO links VALUES (1135, 'Classroom Technology', 'http://ets.berkeley.edu/classroom-technology/', 'Provide reliable resources and technical support to the UCB campus', true, '2015-05-07 22:46:26.759', '2015-05-07 22:46:26.759');
INSERT INTO links VALUES (1136, 'Colleges & Schools', 'http://www.berkeley.edu/academics/school.shtml', 'Different departments (colleges) that majors fall under', true, '2015-05-07 22:46:26.79', '2015-05-07 22:46:26.79');
INSERT INTO links VALUES (1137, 'Computer Use Policy', 'https://security.berkeley.edu/policy/usepolicy.html', 'Rules, rights, and policies regarding computer facilities', true, '2015-05-07 22:46:26.828', '2015-05-07 22:46:26.828');
INSERT INTO links VALUES (1138, 'Counseling & Psychological Services', 'http://uhs.berkeley.edu/students/counseling/cps.shtml', 'Individual, group, & self-help from Tang Center', true, '2015-05-07 22:46:26.877', '2015-05-07 22:46:26.877');
INSERT INTO links VALUES (1139, 'Course Catalog', 'http://guide.berkeley.edu/courses/', 'Detailed course descriptions', true, '2015-05-07 22:46:26.918', '2015-05-07 22:46:26.918');
INSERT INTO links VALUES (1140, 'DARS', 'https://marin.berkeley.edu/darsweb/servlet/ListAuditsServlet ', 'Degree requirements and track progress', true, '2015-05-07 22:46:26.952', '2015-05-07 22:46:26.952');
INSERT INTO links VALUES (1141, 'DeCal Courses', 'http://www.decal.org/ ', 'Catalog of student-led courses', true, '2015-05-07 22:46:26.992', '2015-05-07 22:46:26.992');
INSERT INTO links VALUES (1142, 'Disabled Students Program', 'http://dsp.berkeley.edu/', 'Resources specific to disabled students', true, '2015-05-07 22:46:27.031', '2015-05-07 22:46:27.031');
INSERT INTO links VALUES (1143, 'e-bills', 'https://bearfacts.berkeley.edu/bearfacts/student/CARS/ebill.do?bfaction=accessEBill ', 'Pay your CARS bill online with either Electronic Billing (e-Bill) or Electronic Payment (e-Check)', true, '2015-05-07 22:46:27.061', '2015-05-07 22:46:27.061');
INSERT INTO links VALUES (1144, 'Educational Opportunity Program', 'http://eop.berkeley.edu', 'Guidance and resources for first generation and low-income college students.', true, '2015-05-07 22:46:27.092', '2015-05-07 22:46:27.092');
INSERT INTO links VALUES (1145, 'Edx Classes at Berkeley', 'https://www.edx.org/university_profile/BerkeleyX', 'Resources that advise, coordinate, and facilitate the University’s online education initiatives', true, '2015-05-07 22:46:27.14', '2015-05-07 22:46:27.14');
INSERT INTO links VALUES (1146, 'Emergency information', 'http://emergency.berkeley.edu/', 'Go-to site for emergency response information', true, '2015-05-07 22:46:27.204', '2015-05-07 22:46:27.204');
INSERT INTO links VALUES (1147, 'Emergency Preparedness', 'http://oep.berkeley.edu/', 'How to be prepared and ready for emergencies', true, '2015-05-07 22:46:27.24', '2015-05-07 22:46:27.24');
INSERT INTO links VALUES (1148, 'Environmental Health & Safety', 'http://www.ehs.berkeley.edu/', 'Services to the campus community that promote health, safety, and environmental stewardship', true, '2015-05-07 22:46:27.314', '2015-05-07 22:46:27.314');
INSERT INTO links VALUES (1149, 'Equity, Inclusion & Diversity', 'http://diversity.berkeley.edu/', 'Creating a fair and inclusive society for all individuals', true, '2015-05-07 22:46:27.357', '2015-05-07 22:46:27.357');
INSERT INTO links VALUES (1150, 'Ethics & Compliance, Administrative guide', 'http://ethicscompliance.berkeley.edu/index.shtml', 'Contact information to report anything suspicious', true, '2015-05-07 22:46:27.406', '2015-05-07 22:46:27.406');
INSERT INTO links VALUES (1151, 'Events.Berkeley', 'http://events.berkeley.edu', 'Campus events calendar', true, '2015-05-07 22:46:27.459', '2015-05-07 22:46:27.459');
INSERT INTO links VALUES (1152, 'Executive Vice Chancellor & Provost', 'http://evcp.chance.berkeley.edu/', 'Meet Executive Vice Chancellor and Provost, Claude M. Steele', true, '2015-05-07 22:46:27.502', '2015-05-07 22:46:27.502');
INSERT INTO links VALUES (1153, 'Facilities Services', 'http://www.cp.berkeley.edu/', 'Cleaning, landscaping and other services to maintain exceptional physical appearance', true, '2015-05-07 22:46:27.537', '2015-05-07 22:46:27.537');
INSERT INTO links VALUES (1154, 'Faculty gateway', 'http://berkeley.edu/faculty/', 'Useful resources for faculty members ', true, '2015-05-07 22:46:27.572', '2015-05-07 22:46:27.572');
INSERT INTO links VALUES (1155, 'FAFSA', 'https://fafsa.ed.gov/', 'Free Application for Federal Student Aid (FAFSA),annual form submission required to receive financial aid', true, '2015-05-07 22:46:27.614', '2015-05-07 22:46:27.614');
INSERT INTO links VALUES (1156, 'Financial Aid & Scholarships Office', 'http://financialaid.berkeley.edu', 'Start here to learn about Financial Aid and for step-by-step guidance about financial aid and select scholarships at UC Berkeley', true, '2015-05-07 22:46:27.642', '2015-05-07 22:46:27.642');
INSERT INTO links VALUES (1157, 'Finding Your Way (L&S)', 'http://ls-yourway.berkeley.edu/', 'Academic advising for students in the Residence Halls under the college of Letters and Science', true, '2015-05-07 22:46:27.669', '2015-05-07 22:46:27.669');
INSERT INTO links VALUES (1158, 'Gender Equity Resource Center', 'http://geneq.berkeley.edu/', 'Community center for students, faculty, staff, & alumni', true, '2015-05-07 22:46:27.71', '2015-05-07 22:46:27.71');
INSERT INTO links VALUES (1159, 'General Access Computing Facilities', 'http://ets.berkeley.edu/computer-facilities/general-access', 'Convenient and secure on-campus computing facilities for registered Berkeley affiliates', true, '2015-05-07 22:46:27.766', '2015-05-07 22:46:27.766');
INSERT INTO links VALUES (1160, 'Give to Berkeley', 'http://givetocal.berkeley.edu/', 'Help donate to further student''s education', true, '2015-05-07 22:46:27.801', '2015-05-07 22:46:27.801');
INSERT INTO links VALUES (1161, 'Graduate Assembly', 'https://ga.berkeley.edu/', 'Graduate student government', true, '2015-05-07 22:46:27.834', '2015-05-07 22:46:27.834');
INSERT INTO links VALUES (1162, 'Graduate Division', 'http://www.grad.berkeley.edu/', 'Information and resources for prospective and graduate students', true, '2015-05-07 22:46:27.877', '2015-05-07 22:46:27.877');
INSERT INTO links VALUES (1163, 'Graduate Financial Support', 'http://www.grad.berkeley.edu/financial/', 'Resources to provide financial support for graduate students', true, '2015-05-07 22:46:27.91', '2015-05-07 22:46:27.91');
INSERT INTO links VALUES (1164, 'GSI, Reader, Tutor, and GSR Positions', 'http://grad.berkeley.edu/professional-development/appointments/', 'Graduate Student Instructor (GSI), Researcher (GSR), Reader, and Tutor appointments at Berkeley', true, '2015-05-07 22:46:27.952', '2015-05-07 22:46:27.952');
INSERT INTO links VALUES (1165, 'Have a loan?', 'http://studentbilling.berkeley.edu/exitDirect.htm', 'Getting ready to graduate? Learn about your responsibilities for paying back your loans through the Exit Loan Counseling requirement', true, '2015-05-07 22:46:27.994', '2015-05-07 22:46:27.994');
INSERT INTO links VALUES (1166, 'How does my SHIP Waiver affect my billing?', 'http://studentcentral.berkeley.edu/faqshipwaiver', 'Frequently Asked Questions about how opt-ing out of the Student Health Insurance Plan effects your bill. ', true, '2015-05-07 22:46:28.032', '2015-05-07 22:46:28.032');
INSERT INTO links VALUES (1167, 'HR System', 'http://hrweb.berkeley.edu/hcm', 'Recording personal information and action for the Berkeley community', true, '2015-05-07 22:46:28.084', '2015-05-07 22:46:28.084');
INSERT INTO links VALUES (1168, 'HR Web', 'http://hrweb.berkeley.edu/', 'Human Resources at Berkeley', true, '2015-05-07 22:46:28.122', '2015-05-07 22:46:28.122');
INSERT INTO links VALUES (1169, 'Imagine Services', 'http://ist.berkeley.edu/imagine', 'Custom electronic document workflows', true, '2015-05-07 22:46:28.156', '2015-05-07 22:46:28.156');
INSERT INTO links VALUES (1170, 'International House', 'http://ihouse.berkeley.edu/', 'On-campus dormitory with a dining common for international students', true, '2015-05-07 22:46:28.189', '2015-05-07 22:46:28.189');
INSERT INTO links VALUES (1171, 'IST Knowledge Base', 'http://ist.berkeley.edu/support/kb', 'Contains answers to Berkeley computing and IT questions', true, '2015-05-07 22:46:28.221', '2015-05-07 22:46:28.221');
INSERT INTO links VALUES (1172, 'IST Support', 'http://ist.berkeley.edu/support/', 'Information Technology support for services and systems', true, '2015-05-07 22:46:28.258', '2015-05-07 22:46:28.258');
INSERT INTO links VALUES (1173, 'iTunesU - Berkeley', 'http://itunes.berkeley.edu', 'Audio files of recordings from lectures or events', true, '2015-05-07 22:46:28.294', '2015-05-07 22:46:28.294');
INSERT INTO links VALUES (1174, 'KALX', 'http://kalx.berkeley.edu/', '90.7 MHz. Berkeley''s campus radio station', true, '2015-05-07 22:46:28.349', '2015-05-07 22:46:28.349');
INSERT INTO links VALUES (1175, 'Lab Safety', 'http://rac.berkeley.edu/compliancebook/labsafety.html', 'Lab Safety & Hazardous Materials Management', true, '2015-05-07 22:46:28.391', '2015-05-07 22:46:28.391');
INSERT INTO links VALUES (1176, 'LEAD Center', 'http://lead.berkeley.edu/', 'Student leadership programs and workshops', true, '2015-05-07 22:46:28.429', '2015-05-07 22:46:28.429');
INSERT INTO links VALUES (1177, 'Learning Resources', 'http://hrweb.berkeley.edu/learning', 'Supports the development of the workforce with learning and development programs', true, '2015-05-07 22:46:28.469', '2015-05-07 22:46:28.469');
INSERT INTO links VALUES (1178, 'Library', 'http://library.berkeley.edu', 'Search the UC Library system', true, '2015-05-07 22:46:28.542', '2015-05-07 22:46:28.542');
INSERT INTO links VALUES (1179, 'Living At Cal', 'http://www.housing.berkeley.edu/livingatcal/', 'UC Berkeley housing options', true, '2015-05-07 22:46:28.589', '2015-05-07 22:46:28.589');
INSERT INTO links VALUES (1180, 'Mail Services', 'http://mailservices.berkeley.edu/', 'United States Postal Service-incoming and outgoing mail', true, '2015-05-07 22:46:28.636', '2015-05-07 22:46:28.636');
INSERT INTO links VALUES (1181, 'My Years at Cal', 'http://myyears.berkeley.edu/', 'Undergraduate advice site with useful resources and on how to stay on track for graduation ', true, '2015-05-07 22:46:28.67', '2015-05-07 22:46:28.67');
INSERT INTO links VALUES (1182, 'MyFinAid', 'https://myfinaid.berkeley.edu/', 'Manage your Financial Aid Awards-grants, scholarships, work-study, loans, etc.', true, '2015-05-07 22:46:28.697', '2015-05-07 22:46:28.697');
INSERT INTO links VALUES (1183, 'New Faculty resources', 'http://teaching.berkeley.edu/new-faculty-resources', 'Hints, resources, and guidelines on productive teaching', true, '2015-05-07 22:46:28.723', '2015-05-07 22:46:28.723');
INSERT INTO links VALUES (1184, 'New Student Services (includes CalSO)', 'http://nss.berkeley.edu/', 'Helping new undergrads get the most out of Cal', true, '2015-05-07 22:46:28.75', '2015-05-07 22:46:28.75');
INSERT INTO links VALUES (1185, 'Newscenter', 'http://newscenter.berkeley.edu', 'News affiliated with UC Berkeley', true, '2015-05-07 22:46:28.779', '2015-05-07 22:46:28.779');
INSERT INTO links VALUES (1186, 'Office of the Chancellor', 'http://chancellor.berkeley.edu/', 'Meet Chancellor Nicholas B. Dirks', true, '2015-05-07 22:46:28.813', '2015-05-07 22:46:28.813');
INSERT INTO links VALUES (1187, 'Office of the Registrar', 'http://registrar.berkeley.edu/', 'Administrative office with helpful links and resources regarding Berkeley', true, '2015-05-07 22:46:28.845', '2015-05-07 22:46:28.845');
INSERT INTO links VALUES (1188, 'Office of Undergraduate Advising', 'http://ls-advise.berkeley.edu/', 'Advising provided for students under the college of Letters and Science', true, '2015-05-07 22:46:28.875', '2015-05-07 22:46:28.875');
INSERT INTO links VALUES (1189, 'Open Computing Facility', 'http://www.ocf.berkeley.edu/', 'Free computing such as printing for Berkeley affiliates', true, '2015-05-07 22:46:28.906', '2015-05-07 22:46:28.906');
INSERT INTO links VALUES (1190, 'Organizational & Workforce Effectiveness', 'http://hrweb.berkeley.edu/learning/corwe', 'Organization supporting managers wanting to make organizational improvements', true, '2015-05-07 22:46:28.963', '2015-05-07 22:46:28.963');
INSERT INTO links VALUES (1191, 'Parking & Transportation', 'http://pt.berkeley.edu/', 'Parking lots, transportation, car sharing, etc.', true, '2015-05-07 22:46:29', '2015-05-07 22:46:29');
INSERT INTO links VALUES (1192, 'Payment Options', 'http://studentbilling.berkeley.edu/carsPaymentOptions.htm', 'Learn more about the options for making payment either electronically or by check to your CARS account', true, '2015-05-07 22:46:29.048', '2015-05-07 22:46:29.048');
INSERT INTO links VALUES (1193, 'Payroll', 'http://controller.berkeley.edu/payroll/', 'Providing accurate paychecks to Berkeley employees', true, '2015-05-07 22:46:29.078', '2015-05-07 22:46:29.078');
INSERT INTO links VALUES (1194, 'Personal Info - Campus Directory', 'https://calnet.berkeley.edu/directory/update/', 'Public contact information of Berkeley affiliates such as email addresses, UIDs, etc.', true, '2015-05-07 22:46:29.124', '2015-05-07 22:46:29.124');
INSERT INTO links VALUES (1195, 'Personal Info - HR record', 'https://auth.berkeley.edu/cas/login?service=https://hrw-vip-prod.is.berkeley.edu/cgi-bin/cas-hrsprod.pl', 'HR personal data, requires log-in.', true, '2015-05-07 22:46:29.157', '2015-05-07 22:46:29.157');
INSERT INTO links VALUES (1196, 'Personnel Policies', 'http://hrweb.berkeley.edu/er/policies', 'Employee relations - personnel policies', true, '2015-05-07 22:46:29.187', '2015-05-07 22:46:29.187');
INSERT INTO links VALUES (1197, 'Physical Education Program', 'http://pe.berkeley.edu/', 'Physical education instructional courses for units', true, '2015-05-07 22:46:29.233', '2015-05-07 22:46:29.233');
INSERT INTO links VALUES (1198, 'Police & Safety', 'http://police.berkeley.edu', 'Campus police and safety', true, '2015-05-07 22:46:29.282', '2015-05-07 22:46:29.282');
INSERT INTO links VALUES (1199, 'Policies & procedures A-Z', 'http://campuspol.chance.berkeley.edu/Home/AtoZPolicies.cfm?long_page=yes', 'A-Z of campuswide policies and procedures', true, '2015-05-07 22:46:29.318', '2015-05-07 22:46:29.318');
INSERT INTO links VALUES (1200, 'Public Service Center', 'http://publicservice.berkeley.edu', 'On and off campus community service engagement', true, '2015-05-07 22:46:29.353', '2015-05-07 22:46:29.353');
INSERT INTO links VALUES (1201, 'Purchasing', 'http://businessservices.berkeley.edu/procurement/services', 'Services that can be purchased by individuals with a CalNet ID and passphrase', true, '2015-05-07 22:46:29.384', '2015-05-07 22:46:29.384');
INSERT INTO links VALUES (1202, 'Recreational Sports Facility', 'http://recsports.berkeley.edu/ ', 'Sports and fitness programs', true, '2015-05-07 22:46:29.425', '2015-05-07 22:46:29.425');
INSERT INTO links VALUES (1203, 'Registration Fees', 'http://registrar.berkeley.edu/Registration/feesched.html', 'Required Berkeley fees to be a Registered Student', true, '2015-05-07 22:46:29.457', '2015-05-07 22:46:29.457');
INSERT INTO links VALUES (1204, 'Research', 'http://berkeley.edu/research/', 'Directory of UC Berkeley research programs', true, '2015-05-07 22:46:29.492', '2015-05-07 22:46:29.492');
INSERT INTO links VALUES (1205, 'Research Hub', 'https://hub.berkeley.edu', 'Tool for content management and collaboration such as managing research data and sharing documents', true, '2015-05-07 22:46:29.524', '2015-05-07 22:46:29.524');
INSERT INTO links VALUES (1206, 'Residential & Student Service Programs', 'http://www.housing.berkeley.edu/', 'UC Berkeley housing options', true, '2015-05-07 22:46:29.556', '2015-05-07 22:46:29.556');
INSERT INTO links VALUES (1207, 'Residential Computing (ResComp)', 'http://www.rescomp.berkeley.edu/', 'Computer and network services for students living in campus housing', true, '2015-05-07 22:46:29.609', '2015-05-07 22:46:29.609');
INSERT INTO links VALUES (1208, 'Resource Guide for Students', 'http://resource.berkeley.edu/', 'Comprehensive campus guide for students', true, '2015-05-07 22:46:29.64', '2015-05-07 22:46:29.64');
INSERT INTO links VALUES (1209, 'Retirement Benefits - At Your Service', 'https://atyourserviceonline.ucop.edu', 'Benefits, Earnings, Taxes & Retirement', true, '2015-05-07 22:46:29.682', '2015-05-07 22:46:29.682');
INSERT INTO links VALUES (1210, 'Retirement Resources', 'http://thecenter.berkeley.edu/index.shtml', 'Programs and services that contribute to the well being of retired faculty', true, '2015-05-07 22:46:29.712', '2015-05-07 22:46:29.712');
INSERT INTO links VALUES (1211, 'Safety', 'http://police.berkeley.edu/index.html', 'Safety information and programs', true, '2015-05-07 22:46:29.743', '2015-05-07 22:46:29.743');
INSERT INTO links VALUES (1212, 'SARA - request system access', 'http://www.bai.berkeley.edu/BFS/systems/systemAccess.htm', 'Form that grants access to different systems for employees', true, '2015-05-07 22:46:29.775', '2015-05-07 22:46:29.775');
INSERT INTO links VALUES (1213, 'Schedule & Deadlines', 'http://summer.berkeley.edu/registration/schedule', 'Key dates and deadlines for summer sessions', true, '2015-05-07 22:46:29.819', '2015-05-07 22:46:29.819');
INSERT INTO links VALUES (1214, 'Schedule Builder', 'https://schedulebuilder.berkeley.edu/', 'Plan your classes', true, '2015-05-07 22:46:29.848', '2015-05-07 22:46:29.848');
INSERT INTO links VALUES (1215, 'Schedule of Classes', 'http://schedule.berkeley.edu/', 'Classes offerings by semester', true, '2015-05-07 22:46:29.893', '2015-05-07 22:46:29.893');
INSERT INTO links VALUES (1216, 'Schedule of Classes - Berkeley Law', 'https://www.law.berkeley.edu/php-programs/courses/courseSearch.php', 'Law School classes offerings by semester', true, '2015-05-07 22:46:29.945', '2015-05-07 22:46:29.945');
INSERT INTO links VALUES (1217, 'Software Central', 'http://ist.berkeley.edu/software-central/', 'Free software for Berkeley affiliates (ex. Adobe, Word, etc.)', true, '2015-05-07 22:46:29.999', '2015-05-07 22:46:29.999');
INSERT INTO links VALUES (1218, 'Staff Ombuds Office', 'http://staffombuds.berkeley.edu/ ', 'An independent department that provides staff with strictly confidential and informal conflict resolution and problem-solving services', true, '2015-05-07 22:46:30.07', '2015-05-07 22:46:30.07');
INSERT INTO links VALUES (1219, 'Student & Student Organization Policies', 'http://sa.berkeley.edu/conduct/policies', 'Rules and policies enforced on students and student organizations', true, '2015-05-07 22:46:30.102', '2015-05-07 22:46:30.102');
INSERT INTO links VALUES (1220, 'Student Affairs', 'http://sa.berkeley.edu/', 'Berkeley''s division responsible for many student life services including the Registrar, Admissions, Financial Aid, Housing & Dining, Conduct, Public Service Center, LEAD center, and ASUC auxiliary', true, '2015-05-07 22:46:30.135', '2015-05-07 22:46:30.135');
INSERT INTO links VALUES (1221, 'Student Budgets', 'http://financialaid.berkeley.edu/cost-attendance', 'Estimated living expense amounts for students', true, '2015-05-07 22:46:30.167', '2015-05-07 22:46:30.167');
INSERT INTO links VALUES (1222, 'Student Learning Center', 'http://slc.berkeley.edu', 'Tutoring, workshops, support services, and 24-hour study access', true, '2015-05-07 22:46:30.201', '2015-05-07 22:46:30.201');
INSERT INTO links VALUES (1223, 'Student Ombuds', 'http://sa.berkeley.edu/ombuds', 'Confidential help with campus issues, conflict situations, and more', true, '2015-05-07 22:46:30.227', '2015-05-07 22:46:30.227');
INSERT INTO links VALUES (1224, 'Student Organizations Search', 'http://students.berkeley.edu/osl/studentgroups/public/index.asp', 'Cal''s clubs and organizations on campus', true, '2015-05-07 22:46:30.251', '2015-05-07 22:46:30.251');
INSERT INTO links VALUES (1225, 'Submit a Service Request', 'https://shared-services-help.berkeley.edu/', 'Help requests for various services such as research', true, '2015-05-07 22:46:30.291', '2015-05-07 22:46:30.291');
INSERT INTO links VALUES (1226, 'Summer Session', 'http://summer.berkeley.edu/', 'Various programs and courses offered during summer for Berkeley students', true, '2015-05-07 22:46:30.319', '2015-05-07 22:46:30.319');
INSERT INTO links VALUES (1227, 'Summer Sessions', 'http://summer.berkeley.edu/', 'Various programs and courses offered during summer for Berkeley students', true, '2015-05-07 22:46:30.355', '2015-05-07 22:46:30.355');
INSERT INTO links VALUES (1228, 'Tax 1098-T Form', 'http://studentbilling.berkeley.edu/taxpayer.htm', 'Start here to access your 1098-T form', true, '2015-05-07 22:46:30.388', '2015-05-07 22:46:30.388');
INSERT INTO links VALUES (1229, 'Teaching resources', 'http://teaching.berkeley.edu/teaching.html', 'Resources that promotes teaching and learning including consultation and program facilitation', true, '2015-05-07 22:46:30.413', '2015-05-07 22:46:30.413');
INSERT INTO links VALUES (1230, 'Tele-BEARS', 'https://telebears.berkeley.edu', 'Register for classes', true, '2015-05-07 22:46:30.438', '2015-05-07 22:46:30.438');
INSERT INTO links VALUES (1231, 'The Berkeley Blog', 'http://blogs.berkeley.edu', 'Issues that are being discussed by members of Berkeley''s academic community ', true, '2015-05-07 22:46:30.465', '2015-05-07 22:46:30.465');
INSERT INTO links VALUES (1232, 'The Center for Student Conduct', 'http://sa.berkeley.edu/conduct', 'Administers and promotes our Code of Student Conduct', true, '2015-05-07 22:46:30.518', '2015-05-07 22:46:30.518');
INSERT INTO links VALUES (1233, 'The Daily Californian (The DailyCal)', 'http://www.dailycal.org/', 'Independent student newspaper', true, '2015-05-07 22:46:30.552', '2015-05-07 22:46:30.552');
INSERT INTO links VALUES (1234, 'Transfer, Re-entry and Student Parent Center', 'http://trsp.berkeley.edu/', 'Resources specific to transfer, re-entering, and parent students', true, '2015-05-07 22:46:30.584', '2015-05-07 22:46:30.584');
INSERT INTO links VALUES (1235, 'Travel & Entertainment', 'http://controller.berkeley.edu/travel/', 'Travel services including airfare and Berkeley''s Direct Bill ID system', true, '2015-05-07 22:46:30.624', '2015-05-07 22:46:30.624');
INSERT INTO links VALUES (1236, 'Twitter', 'https://twitter.com/UCBerkeley', 'UC Berkeley''s primary Stay updated on campus news through Berkeley''s primary Twitter address', true, '2015-05-07 22:46:30.67', '2015-05-07 22:46:30.67');
INSERT INTO links VALUES (1237, 'UC Berkeley Facebook page', 'http://www.facebook.com/UCBerkeley', 'Keep updated with Berkeley news through social media', true, '2015-05-07 22:46:30.702', '2015-05-07 22:46:30.702');
INSERT INTO links VALUES (1238, 'UC Berkeley museums', 'http://bnhm.berkeley.edu/', 'Berkeley''s national history museums ', true, '2015-05-07 22:46:30.729', '2015-05-07 22:46:30.729');
INSERT INTO links VALUES (1239, 'UC Berkeley Wellness Letter', 'http://www.wellnessletter.com/ucberkeley/', 'Tips and information on how to stay healthy', true, '2015-05-07 22:46:30.777', '2015-05-07 22:46:30.777');
INSERT INTO links VALUES (1240, 'UC Extension Classes', 'http://extension.berkeley.edu/', 'Professional development', true, '2015-05-07 22:46:30.828', '2015-05-07 22:46:30.828');
INSERT INTO links VALUES (1241, 'UC Learning Center', 'https://shib.berkeley.edu/idp/profile/Shibboleth/SSO?shire=https://uc.sumtotalsystems.com/Shibboleth.sso/SAML/POST&target=https://uc.sumtotalsystems.com/secure/auth.aspx&providerId=https://uc.sumtotalsystems.com/shibboleth', 'Various services that help students and instructors succeed', true, '2015-05-07 22:46:30.866', '2015-05-07 22:46:30.866');
INSERT INTO links VALUES (1242, 'UC SHIP (Student Health Insurance Plan)', 'http://www.uhs.berkeley.edu/students/insurance/', 'UC Student Health Insurance Plan', true, '2015-05-07 22:46:30.897', '2015-05-07 22:46:30.897');
INSERT INTO links VALUES (1243, 'UHS - Tang Center', 'http://uhs.berkeley.edu/', 'Berkeley''s healthcare center', true, '2015-05-07 22:46:30.927', '2015-05-07 22:46:30.927');
INSERT INTO links VALUES (1244, 'Undergraduate Student Calendar & Deadlines', 'http://registrar.berkeley.edu/current_students/registration_enrollment/stucal.html', 'Student''s academic calendar ', true, '2015-05-07 22:46:30.962', '2015-05-07 22:46:30.962');
INSERT INTO links VALUES (1245, 'Undocumented Students Program', 'http://undocu.berkeley.edu/', 'Personalized services for undocumented undergraduates', true, '2015-05-07 22:46:30.994', '2015-05-07 22:46:30.994');
INSERT INTO links VALUES (1246, 'University Relations', 'http://www.urel.berkeley.edu/', 'Berkeley''s Public Affairs and fundraising Development division', true, '2015-05-07 22:46:31.021', '2015-05-07 22:46:31.021');
INSERT INTO links VALUES (1247, 'Webcast Support', 'http://ets.berkeley.edu/about-webcastberkeley', 'Help with audio and video recordings of class lectures and events that made available through UC Berkeley''s channels', true, '2015-05-07 22:46:31.058', '2015-05-07 22:46:31.058');
INSERT INTO links VALUES (1248, 'Withdrawing or Canceling?', 'http://registrar.berkeley.edu/canwd.html ', 'Learn more about what you need to do if you are planning to cancel, withdraw and readmit to UC Berkeley', true, '2015-05-07 22:46:31.088', '2015-05-07 22:46:31.088');
INSERT INTO links VALUES (1249, 'Work-Study', 'http://financialaid.berkeley.edu/work-study', 'A program that can help you lower your federal loan debt amount through work-study eligible jobs on campus', true, '2015-05-07 22:46:31.126', '2015-05-07 22:46:31.126');
INSERT INTO links VALUES (1250, 'YouTube - UC Berkeley', 'http://www.youtube.com/user/UCBerkeley', 'Videos relating to UC Berkeley on an external website', true, '2015-05-07 22:46:31.155', '2015-05-07 22:46:31.155');


--
-- Name: links_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('links_id_seq', 1250, true);


--
-- Data for Name: links_user_roles; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO links_user_roles VALUES (1062, 1);
INSERT INTO links_user_roles VALUES (1062, 3);
INSERT INTO links_user_roles VALUES (1062, 2);
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
INSERT INTO links_user_roles VALUES (1067, 3);
INSERT INTO links_user_roles VALUES (1068, 1);
INSERT INTO links_user_roles VALUES (1068, 3);
INSERT INTO links_user_roles VALUES (1068, 2);
INSERT INTO links_user_roles VALUES (1069, 1);
INSERT INTO links_user_roles VALUES (1069, 3);
INSERT INTO links_user_roles VALUES (1069, 2);
INSERT INTO links_user_roles VALUES (1070, 1);
INSERT INTO links_user_roles VALUES (1071, 3);
INSERT INTO links_user_roles VALUES (1071, 2);
INSERT INTO links_user_roles VALUES (1072, 1);
INSERT INTO links_user_roles VALUES (1073, 3);
INSERT INTO links_user_roles VALUES (1073, 2);
INSERT INTO links_user_roles VALUES (1074, 1);
INSERT INTO links_user_roles VALUES (1074, 3);
INSERT INTO links_user_roles VALUES (1074, 2);
INSERT INTO links_user_roles VALUES (1075, 1);
INSERT INTO links_user_roles VALUES (1075, 3);
INSERT INTO links_user_roles VALUES (1075, 2);
INSERT INTO links_user_roles VALUES (1076, 1);
INSERT INTO links_user_roles VALUES (1076, 3);
INSERT INTO links_user_roles VALUES (1076, 2);
INSERT INTO links_user_roles VALUES (1077, 1);
INSERT INTO links_user_roles VALUES (1077, 3);
INSERT INTO links_user_roles VALUES (1077, 2);
INSERT INTO links_user_roles VALUES (1078, 1);
INSERT INTO links_user_roles VALUES (1078, 3);
INSERT INTO links_user_roles VALUES (1078, 2);
INSERT INTO links_user_roles VALUES (1079, 3);
INSERT INTO links_user_roles VALUES (1079, 2);
INSERT INTO links_user_roles VALUES (1080, 1);
INSERT INTO links_user_roles VALUES (1080, 3);
INSERT INTO links_user_roles VALUES (1080, 2);
INSERT INTO links_user_roles VALUES (1081, 1);
INSERT INTO links_user_roles VALUES (1081, 3);
INSERT INTO links_user_roles VALUES (1081, 2);
INSERT INTO links_user_roles VALUES (1082, 3);
INSERT INTO links_user_roles VALUES (1082, 2);
INSERT INTO links_user_roles VALUES (1083, 1);
INSERT INTO links_user_roles VALUES (1083, 3);
INSERT INTO links_user_roles VALUES (1083, 2);
INSERT INTO links_user_roles VALUES (1084, 1);
INSERT INTO links_user_roles VALUES (1084, 3);
INSERT INTO links_user_roles VALUES (1084, 2);
INSERT INTO links_user_roles VALUES (1085, 1);
INSERT INTO links_user_roles VALUES (1085, 3);
INSERT INTO links_user_roles VALUES (1085, 2);
INSERT INTO links_user_roles VALUES (1086, 1);
INSERT INTO links_user_roles VALUES (1087, 2);
INSERT INTO links_user_roles VALUES (1088, 3);
INSERT INTO links_user_roles VALUES (1088, 2);
INSERT INTO links_user_roles VALUES (1089, 1);
INSERT INTO links_user_roles VALUES (1090, 3);
INSERT INTO links_user_roles VALUES (1090, 2);
INSERT INTO links_user_roles VALUES (1091, 3);
INSERT INTO links_user_roles VALUES (1091, 2);
INSERT INTO links_user_roles VALUES (1092, 1);
INSERT INTO links_user_roles VALUES (1092, 3);
INSERT INTO links_user_roles VALUES (1092, 2);
INSERT INTO links_user_roles VALUES (1093, 1);
INSERT INTO links_user_roles VALUES (1093, 3);
INSERT INTO links_user_roles VALUES (1094, 1);
INSERT INTO links_user_roles VALUES (1094, 3);
INSERT INTO links_user_roles VALUES (1094, 2);
INSERT INTO links_user_roles VALUES (1095, 1);
INSERT INTO links_user_roles VALUES (1095, 3);
INSERT INTO links_user_roles VALUES (1095, 2);
INSERT INTO links_user_roles VALUES (1096, 3);
INSERT INTO links_user_roles VALUES (1097, 3);
INSERT INTO links_user_roles VALUES (1098, 1);
INSERT INTO links_user_roles VALUES (1098, 3);
INSERT INTO links_user_roles VALUES (1098, 2);
INSERT INTO links_user_roles VALUES (1099, 3);
INSERT INTO links_user_roles VALUES (1099, 2);
INSERT INTO links_user_roles VALUES (1100, 1);
INSERT INTO links_user_roles VALUES (1100, 3);
INSERT INTO links_user_roles VALUES (1100, 2);
INSERT INTO links_user_roles VALUES (1101, 1);
INSERT INTO links_user_roles VALUES (1101, 3);
INSERT INTO links_user_roles VALUES (1101, 2);
INSERT INTO links_user_roles VALUES (1102, 1);
INSERT INTO links_user_roles VALUES (1102, 3);
INSERT INTO links_user_roles VALUES (1102, 2);
INSERT INTO links_user_roles VALUES (1103, 1);
INSERT INTO links_user_roles VALUES (1103, 3);
INSERT INTO links_user_roles VALUES (1103, 2);
INSERT INTO links_user_roles VALUES (1104, 1);
INSERT INTO links_user_roles VALUES (1105, 1);
INSERT INTO links_user_roles VALUES (1106, 1);
INSERT INTO links_user_roles VALUES (1106, 3);
INSERT INTO links_user_roles VALUES (1106, 2);
INSERT INTO links_user_roles VALUES (1107, 1);
INSERT INTO links_user_roles VALUES (1107, 3);
INSERT INTO links_user_roles VALUES (1107, 2);
INSERT INTO links_user_roles VALUES (1108, 1);
INSERT INTO links_user_roles VALUES (1108, 3);
INSERT INTO links_user_roles VALUES (1108, 2);
INSERT INTO links_user_roles VALUES (1109, 1);
INSERT INTO links_user_roles VALUES (1110, 1);
INSERT INTO links_user_roles VALUES (1111, 1);
INSERT INTO links_user_roles VALUES (1112, 1);
INSERT INTO links_user_roles VALUES (1112, 3);
INSERT INTO links_user_roles VALUES (1112, 2);
INSERT INTO links_user_roles VALUES (1113, 2);
INSERT INTO links_user_roles VALUES (1114, 1);
INSERT INTO links_user_roles VALUES (1114, 3);
INSERT INTO links_user_roles VALUES (1114, 2);
INSERT INTO links_user_roles VALUES (1115, 2);
INSERT INTO links_user_roles VALUES (1116, 3);
INSERT INTO links_user_roles VALUES (1116, 2);
INSERT INTO links_user_roles VALUES (1117, 3);
INSERT INTO links_user_roles VALUES (1117, 2);
INSERT INTO links_user_roles VALUES (1118, 1);
INSERT INTO links_user_roles VALUES (1118, 3);
INSERT INTO links_user_roles VALUES (1118, 2);
INSERT INTO links_user_roles VALUES (1119, 1);
INSERT INTO links_user_roles VALUES (1119, 3);
INSERT INTO links_user_roles VALUES (1120, 2);
INSERT INTO links_user_roles VALUES (1121, 1);
INSERT INTO links_user_roles VALUES (1121, 3);
INSERT INTO links_user_roles VALUES (1121, 2);
INSERT INTO links_user_roles VALUES (1122, 1);
INSERT INTO links_user_roles VALUES (1122, 3);
INSERT INTO links_user_roles VALUES (1122, 2);
INSERT INTO links_user_roles VALUES (1123, 1);
INSERT INTO links_user_roles VALUES (1123, 3);
INSERT INTO links_user_roles VALUES (1123, 2);
INSERT INTO links_user_roles VALUES (1124, 3);
INSERT INTO links_user_roles VALUES (1124, 2);
INSERT INTO links_user_roles VALUES (1125, 1);
INSERT INTO links_user_roles VALUES (1125, 3);
INSERT INTO links_user_roles VALUES (1125, 2);
INSERT INTO links_user_roles VALUES (1126, 3);
INSERT INTO links_user_roles VALUES (1126, 2);
INSERT INTO links_user_roles VALUES (1127, 1);
INSERT INTO links_user_roles VALUES (1127, 3);
INSERT INTO links_user_roles VALUES (1127, 2);
INSERT INTO links_user_roles VALUES (1128, 1);
INSERT INTO links_user_roles VALUES (1129, 1);
INSERT INTO links_user_roles VALUES (1130, 1);
INSERT INTO links_user_roles VALUES (1131, 1);
INSERT INTO links_user_roles VALUES (1132, 1);
INSERT INTO links_user_roles VALUES (1132, 3);
INSERT INTO links_user_roles VALUES (1132, 2);
INSERT INTO links_user_roles VALUES (1133, 1);
INSERT INTO links_user_roles VALUES (1134, 1);
INSERT INTO links_user_roles VALUES (1135, 3);
INSERT INTO links_user_roles VALUES (1136, 1);
INSERT INTO links_user_roles VALUES (1136, 3);
INSERT INTO links_user_roles VALUES (1136, 2);
INSERT INTO links_user_roles VALUES (1137, 1);
INSERT INTO links_user_roles VALUES (1137, 3);
INSERT INTO links_user_roles VALUES (1137, 2);
INSERT INTO links_user_roles VALUES (1138, 1);
INSERT INTO links_user_roles VALUES (1138, 3);
INSERT INTO links_user_roles VALUES (1138, 2);
INSERT INTO links_user_roles VALUES (1139, 1);
INSERT INTO links_user_roles VALUES (1139, 3);
INSERT INTO links_user_roles VALUES (1139, 2);
INSERT INTO links_user_roles VALUES (1140, 1);
INSERT INTO links_user_roles VALUES (1141, 1);
INSERT INTO links_user_roles VALUES (1141, 3);
INSERT INTO links_user_roles VALUES (1141, 2);
INSERT INTO links_user_roles VALUES (1142, 1);
INSERT INTO links_user_roles VALUES (1143, 1);
INSERT INTO links_user_roles VALUES (1144, 1);
INSERT INTO links_user_roles VALUES (1145, 1);
INSERT INTO links_user_roles VALUES (1145, 3);
INSERT INTO links_user_roles VALUES (1145, 2);
INSERT INTO links_user_roles VALUES (1146, 1);
INSERT INTO links_user_roles VALUES (1146, 3);
INSERT INTO links_user_roles VALUES (1146, 2);
INSERT INTO links_user_roles VALUES (1147, 1);
INSERT INTO links_user_roles VALUES (1147, 3);
INSERT INTO links_user_roles VALUES (1147, 2);
INSERT INTO links_user_roles VALUES (1148, 1);
INSERT INTO links_user_roles VALUES (1149, 1);
INSERT INTO links_user_roles VALUES (1149, 3);
INSERT INTO links_user_roles VALUES (1149, 2);
INSERT INTO links_user_roles VALUES (1150, 3);
INSERT INTO links_user_roles VALUES (1150, 2);
INSERT INTO links_user_roles VALUES (1151, 1);
INSERT INTO links_user_roles VALUES (1151, 3);
INSERT INTO links_user_roles VALUES (1151, 2);
INSERT INTO links_user_roles VALUES (1152, 1);
INSERT INTO links_user_roles VALUES (1152, 3);
INSERT INTO links_user_roles VALUES (1152, 2);
INSERT INTO links_user_roles VALUES (1153, 1);
INSERT INTO links_user_roles VALUES (1153, 3);
INSERT INTO links_user_roles VALUES (1153, 2);
INSERT INTO links_user_roles VALUES (1154, 3);
INSERT INTO links_user_roles VALUES (1155, 1);
INSERT INTO links_user_roles VALUES (1156, 1);
INSERT INTO links_user_roles VALUES (1157, 1);
INSERT INTO links_user_roles VALUES (1158, 1);
INSERT INTO links_user_roles VALUES (1158, 3);
INSERT INTO links_user_roles VALUES (1158, 2);
INSERT INTO links_user_roles VALUES (1159, 1);
INSERT INTO links_user_roles VALUES (1159, 3);
INSERT INTO links_user_roles VALUES (1159, 2);
INSERT INTO links_user_roles VALUES (1160, 1);
INSERT INTO links_user_roles VALUES (1160, 3);
INSERT INTO links_user_roles VALUES (1160, 2);
INSERT INTO links_user_roles VALUES (1161, 1);
INSERT INTO links_user_roles VALUES (1162, 1);
INSERT INTO links_user_roles VALUES (1162, 3);
INSERT INTO links_user_roles VALUES (1162, 2);
INSERT INTO links_user_roles VALUES (1163, 1);
INSERT INTO links_user_roles VALUES (1164, 1);
INSERT INTO links_user_roles VALUES (1165, 1);
INSERT INTO links_user_roles VALUES (1166, 1);
INSERT INTO links_user_roles VALUES (1167, 3);
INSERT INTO links_user_roles VALUES (1167, 2);
INSERT INTO links_user_roles VALUES (1168, 3);
INSERT INTO links_user_roles VALUES (1168, 2);
INSERT INTO links_user_roles VALUES (1169, 2);
INSERT INTO links_user_roles VALUES (1170, 1);
INSERT INTO links_user_roles VALUES (1171, 1);
INSERT INTO links_user_roles VALUES (1171, 3);
INSERT INTO links_user_roles VALUES (1171, 2);
INSERT INTO links_user_roles VALUES (1172, 1);
INSERT INTO links_user_roles VALUES (1172, 3);
INSERT INTO links_user_roles VALUES (1172, 2);
INSERT INTO links_user_roles VALUES (1173, 1);
INSERT INTO links_user_roles VALUES (1173, 3);
INSERT INTO links_user_roles VALUES (1173, 2);
INSERT INTO links_user_roles VALUES (1174, 1);
INSERT INTO links_user_roles VALUES (1174, 3);
INSERT INTO links_user_roles VALUES (1174, 2);
INSERT INTO links_user_roles VALUES (1175, 1);
INSERT INTO links_user_roles VALUES (1175, 3);
INSERT INTO links_user_roles VALUES (1175, 2);
INSERT INTO links_user_roles VALUES (1176, 1);
INSERT INTO links_user_roles VALUES (1177, 3);
INSERT INTO links_user_roles VALUES (1177, 2);
INSERT INTO links_user_roles VALUES (1178, 1);
INSERT INTO links_user_roles VALUES (1178, 3);
INSERT INTO links_user_roles VALUES (1178, 2);
INSERT INTO links_user_roles VALUES (1179, 1);
INSERT INTO links_user_roles VALUES (1180, 3);
INSERT INTO links_user_roles VALUES (1180, 2);
INSERT INTO links_user_roles VALUES (1181, 1);
INSERT INTO links_user_roles VALUES (1182, 1);
INSERT INTO links_user_roles VALUES (1183, 3);
INSERT INTO links_user_roles VALUES (1184, 1);
INSERT INTO links_user_roles VALUES (1185, 1);
INSERT INTO links_user_roles VALUES (1185, 3);
INSERT INTO links_user_roles VALUES (1185, 2);
INSERT INTO links_user_roles VALUES (1186, 1);
INSERT INTO links_user_roles VALUES (1186, 3);
INSERT INTO links_user_roles VALUES (1186, 2);
INSERT INTO links_user_roles VALUES (1187, 1);
INSERT INTO links_user_roles VALUES (1187, 3);
INSERT INTO links_user_roles VALUES (1187, 2);
INSERT INTO links_user_roles VALUES (1188, 1);
INSERT INTO links_user_roles VALUES (1189, 1);
INSERT INTO links_user_roles VALUES (1189, 3);
INSERT INTO links_user_roles VALUES (1189, 2);
INSERT INTO links_user_roles VALUES (1190, 2);
INSERT INTO links_user_roles VALUES (1191, 1);
INSERT INTO links_user_roles VALUES (1191, 3);
INSERT INTO links_user_roles VALUES (1191, 2);
INSERT INTO links_user_roles VALUES (1192, 1);
INSERT INTO links_user_roles VALUES (1193, 3);
INSERT INTO links_user_roles VALUES (1193, 2);
INSERT INTO links_user_roles VALUES (1194, 3);
INSERT INTO links_user_roles VALUES (1194, 2);
INSERT INTO links_user_roles VALUES (1195, 3);
INSERT INTO links_user_roles VALUES (1195, 2);
INSERT INTO links_user_roles VALUES (1196, 3);
INSERT INTO links_user_roles VALUES (1196, 2);
INSERT INTO links_user_roles VALUES (1197, 1);
INSERT INTO links_user_roles VALUES (1198, 1);
INSERT INTO links_user_roles VALUES (1198, 3);
INSERT INTO links_user_roles VALUES (1198, 2);
INSERT INTO links_user_roles VALUES (1199, 1);
INSERT INTO links_user_roles VALUES (1199, 3);
INSERT INTO links_user_roles VALUES (1199, 2);
INSERT INTO links_user_roles VALUES (1200, 1);
INSERT INTO links_user_roles VALUES (1200, 3);
INSERT INTO links_user_roles VALUES (1200, 2);
INSERT INTO links_user_roles VALUES (1201, 3);
INSERT INTO links_user_roles VALUES (1201, 2);
INSERT INTO links_user_roles VALUES (1202, 1);
INSERT INTO links_user_roles VALUES (1202, 3);
INSERT INTO links_user_roles VALUES (1202, 2);
INSERT INTO links_user_roles VALUES (1203, 1);
INSERT INTO links_user_roles VALUES (1204, 1);
INSERT INTO links_user_roles VALUES (1204, 3);
INSERT INTO links_user_roles VALUES (1204, 2);
INSERT INTO links_user_roles VALUES (1205, 1);
INSERT INTO links_user_roles VALUES (1205, 3);
INSERT INTO links_user_roles VALUES (1205, 2);
INSERT INTO links_user_roles VALUES (1206, 1);
INSERT INTO links_user_roles VALUES (1207, 1);
INSERT INTO links_user_roles VALUES (1208, 1);
INSERT INTO links_user_roles VALUES (1209, 3);
INSERT INTO links_user_roles VALUES (1209, 2);
INSERT INTO links_user_roles VALUES (1210, 3);
INSERT INTO links_user_roles VALUES (1210, 2);
INSERT INTO links_user_roles VALUES (1211, 1);
INSERT INTO links_user_roles VALUES (1211, 3);
INSERT INTO links_user_roles VALUES (1211, 2);
INSERT INTO links_user_roles VALUES (1212, 3);
INSERT INTO links_user_roles VALUES (1212, 2);
INSERT INTO links_user_roles VALUES (1213, 1);
INSERT INTO links_user_roles VALUES (1214, 1);
INSERT INTO links_user_roles VALUES (1214, 3);
INSERT INTO links_user_roles VALUES (1214, 2);
INSERT INTO links_user_roles VALUES (1215, 1);
INSERT INTO links_user_roles VALUES (1215, 3);
INSERT INTO links_user_roles VALUES (1215, 2);
INSERT INTO links_user_roles VALUES (1216, 1);
INSERT INTO links_user_roles VALUES (1216, 3);
INSERT INTO links_user_roles VALUES (1216, 2);
INSERT INTO links_user_roles VALUES (1217, 3);
INSERT INTO links_user_roles VALUES (1217, 2);
INSERT INTO links_user_roles VALUES (1218, 3);
INSERT INTO links_user_roles VALUES (1218, 2);
INSERT INTO links_user_roles VALUES (1219, 1);
INSERT INTO links_user_roles VALUES (1219, 3);
INSERT INTO links_user_roles VALUES (1219, 2);
INSERT INTO links_user_roles VALUES (1220, 1);
INSERT INTO links_user_roles VALUES (1220, 3);
INSERT INTO links_user_roles VALUES (1220, 2);
INSERT INTO links_user_roles VALUES (1221, 1);
INSERT INTO links_user_roles VALUES (1222, 1);
INSERT INTO links_user_roles VALUES (1223, 1);
INSERT INTO links_user_roles VALUES (1224, 1);
INSERT INTO links_user_roles VALUES (1225, 3);
INSERT INTO links_user_roles VALUES (1225, 2);
INSERT INTO links_user_roles VALUES (1226, 1);
INSERT INTO links_user_roles VALUES (1227, 1);
INSERT INTO links_user_roles VALUES (1227, 3);
INSERT INTO links_user_roles VALUES (1227, 2);
INSERT INTO links_user_roles VALUES (1228, 1);
INSERT INTO links_user_roles VALUES (1229, 3);
INSERT INTO links_user_roles VALUES (1230, 1);
INSERT INTO links_user_roles VALUES (1231, 1);
INSERT INTO links_user_roles VALUES (1231, 3);
INSERT INTO links_user_roles VALUES (1231, 2);
INSERT INTO links_user_roles VALUES (1232, 1);
INSERT INTO links_user_roles VALUES (1232, 3);
INSERT INTO links_user_roles VALUES (1232, 2);
INSERT INTO links_user_roles VALUES (1233, 1);
INSERT INTO links_user_roles VALUES (1233, 3);
INSERT INTO links_user_roles VALUES (1233, 2);
INSERT INTO links_user_roles VALUES (1234, 1);
INSERT INTO links_user_roles VALUES (1235, 3);
INSERT INTO links_user_roles VALUES (1235, 2);
INSERT INTO links_user_roles VALUES (1236, 1);
INSERT INTO links_user_roles VALUES (1236, 3);
INSERT INTO links_user_roles VALUES (1236, 2);
INSERT INTO links_user_roles VALUES (1237, 1);
INSERT INTO links_user_roles VALUES (1238, 1);
INSERT INTO links_user_roles VALUES (1238, 3);
INSERT INTO links_user_roles VALUES (1238, 2);
INSERT INTO links_user_roles VALUES (1239, 1);
INSERT INTO links_user_roles VALUES (1240, 1);
INSERT INTO links_user_roles VALUES (1240, 3);
INSERT INTO links_user_roles VALUES (1240, 2);
INSERT INTO links_user_roles VALUES (1241, 3);
INSERT INTO links_user_roles VALUES (1241, 2);
INSERT INTO links_user_roles VALUES (1242, 1);
INSERT INTO links_user_roles VALUES (1243, 1);
INSERT INTO links_user_roles VALUES (1243, 3);
INSERT INTO links_user_roles VALUES (1243, 2);
INSERT INTO links_user_roles VALUES (1244, 1);
INSERT INTO links_user_roles VALUES (1244, 3);
INSERT INTO links_user_roles VALUES (1244, 2);
INSERT INTO links_user_roles VALUES (1245, 1);
INSERT INTO links_user_roles VALUES (1246, 1);
INSERT INTO links_user_roles VALUES (1246, 3);
INSERT INTO links_user_roles VALUES (1246, 2);
INSERT INTO links_user_roles VALUES (1247, 3);
INSERT INTO links_user_roles VALUES (1248, 1);
INSERT INTO links_user_roles VALUES (1249, 1);
INSERT INTO links_user_roles VALUES (1250, 1);

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

