--
-- PostgreSQL database dump, taken from production postgres on 6 December 2013.
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

DROP INDEX public.index_fin_aid_years_on_current_year;
DROP INDEX public.index_user_auths_on_uid;
ALTER TABLE ONLY public.fin_aid_years DROP CONSTRAINT fin_aid_years_pkey;
ALTER TABLE ONLY public.user_roles DROP CONSTRAINT user_roles_pkey;
ALTER TABLE ONLY public.user_auths DROP CONSTRAINT user_auths_pkey;
ALTER TABLE ONLY public.links DROP CONSTRAINT links_pkey;
ALTER TABLE ONLY public.link_sections DROP CONSTRAINT link_sections_pkey;
ALTER TABLE ONLY public.link_categories DROP CONSTRAINT link_categories_pkey;
ALTER TABLE public.fin_aid_years ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.user_roles ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.user_auths ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.links ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.link_sections ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.link_categories ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE public.fin_aid_years_id_seq;
DROP TABLE public.fin_aid_years;
DROP SEQUENCE public.user_roles_id_seq;
DROP TABLE public.user_roles;
DROP SEQUENCE public.user_auths_id_seq;
DROP TABLE public.user_auths;
DROP TABLE public.links_user_roles;
DROP SEQUENCE public.links_id_seq;
DROP TABLE public.links;
DROP TABLE public.link_sections_links;
DROP SEQUENCE public.link_sections_id_seq;
DROP TABLE public.link_sections;
DROP TABLE public.link_categories_link_sections;
DROP SEQUENCE public.link_categories_id_seq;
DROP TABLE public.link_categories;
SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: fin_aid_years; Type: TABLE; Schema: public; Owner: calcentral_development; Tablespace:
--

CREATE TABLE fin_aid_years (
    id integer NOT NULL,
    current_year integer NOT NULL,
    upcoming_start_date date NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.fin_aid_years OWNER TO calcentral_development;

--
-- Name: fin_aid_years_id_seq; Type: SEQUENCE; Schema: public; Owner: calcentral_development
--

CREATE SEQUENCE fin_aid_years_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.fin_aid_years_id_seq OWNER TO calcentral_development;

--
-- Name: fin_aid_years_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: calcentral_development
--

ALTER SEQUENCE fin_aid_years_id_seq OWNED BY fin_aid_years.id;


--
-- Name: link_categories; Type: TABLE; Schema: public; Owner: calcentral; Tablespace:
--

CREATE TABLE link_categories (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    slug character varying(255) NOT NULL,
    root_level boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.link_categories OWNER TO calcentral;

--
-- Name: link_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: calcentral
--

CREATE SEQUENCE link_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.link_categories_id_seq OWNER TO calcentral;

--
-- Name: link_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: calcentral
--

ALTER SEQUENCE link_categories_id_seq OWNED BY link_categories.id;


--
-- Name: link_categories_link_sections; Type: TABLE; Schema: public; Owner: calcentral; Tablespace:
--

CREATE TABLE link_categories_link_sections (
    link_category_id integer,
    link_section_id integer
);


ALTER TABLE public.link_categories_link_sections OWNER TO calcentral;

--
-- Name: link_sections; Type: TABLE; Schema: public; Owner: calcentral; Tablespace:
--

CREATE TABLE link_sections (
    id integer NOT NULL,
    link_root_cat_id integer,
    link_top_cat_id integer,
    link_sub_cat_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.link_sections OWNER TO calcentral;

--
-- Name: link_sections_id_seq; Type: SEQUENCE; Schema: public; Owner: calcentral
--

CREATE SEQUENCE link_sections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.link_sections_id_seq OWNER TO calcentral;

--
-- Name: link_sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: calcentral
--

ALTER SEQUENCE link_sections_id_seq OWNED BY link_sections.id;


--
-- Name: link_sections_links; Type: TABLE; Schema: public; Owner: calcentral; Tablespace:
--

CREATE TABLE link_sections_links (
    link_section_id integer,
    link_id integer
);


ALTER TABLE public.link_sections_links OWNER TO calcentral;

--
-- Name: links; Type: TABLE; Schema: public; Owner: calcentral; Tablespace:
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


ALTER TABLE public.links OWNER TO calcentral;

--
-- Name: links_id_seq; Type: SEQUENCE; Schema: public; Owner: calcentral
--

CREATE SEQUENCE links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.links_id_seq OWNER TO calcentral;

--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: calcentral
--

ALTER SEQUENCE links_id_seq OWNED BY links.id;


--
-- Name: links_user_roles; Type: TABLE; Schema: public; Owner: calcentral; Tablespace:
--

CREATE TABLE links_user_roles (
    link_id integer,
    user_role_id integer
);


ALTER TABLE public.links_user_roles OWNER TO calcentral;

--
-- Name: user_auths; Type: TABLE; Schema: public; Owner: calcentral; Tablespace:
--

CREATE TABLE user_auths (
    id integer NOT NULL,
    uid character varying(255) NOT NULL,
    is_superuser boolean DEFAULT false NOT NULL,
    is_test_user boolean DEFAULT false NOT NULL,
    active boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_author boolean DEFAULT false NOT NULL,
    is_viewer boolean DEFAULT false NOT NULL
);


ALTER TABLE public.user_auths OWNER TO calcentral;

--
-- Name: user_auths_id_seq; Type: SEQUENCE; Schema: public; Owner: calcentral
--

CREATE SEQUENCE user_auths_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_auths_id_seq OWNER TO calcentral;

--
-- Name: user_auths_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: calcentral
--

ALTER SEQUENCE user_auths_id_seq OWNED BY user_auths.id;


--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: calcentral; Tablespace:
--

CREATE TABLE user_roles (
    id integer NOT NULL,
    name character varying(255),
    slug character varying(255)
);


ALTER TABLE public.user_roles OWNER TO calcentral;

--
-- Name: user_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: calcentral
--

CREATE SEQUENCE user_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_roles_id_seq OWNER TO calcentral;

--
-- Name: user_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: calcentral
--

ALTER SEQUENCE user_roles_id_seq OWNED BY user_roles.id;


--
--
-- Name: id; Type: DEFAULT; Schema: public; Owner: calcentral_development
--

ALTER TABLE ONLY fin_aid_years ALTER COLUMN id SET DEFAULT nextval('fin_aid_years_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: calcentral_development
--

ALTER TABLE ONLY link_categories ALTER COLUMN id SET DEFAULT nextval('link_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: calcentral
--

ALTER TABLE ONLY link_sections ALTER COLUMN id SET DEFAULT nextval('link_sections_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: calcentral
--

ALTER TABLE ONLY links ALTER COLUMN id SET DEFAULT nextval('links_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: calcentral
--

ALTER TABLE ONLY user_auths ALTER COLUMN id SET DEFAULT nextval('user_auths_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: calcentral
--

ALTER TABLE ONLY user_roles ALTER COLUMN id SET DEFAULT nextval('user_roles_id_seq'::regclass);


--
-- Data for Name: fin_aid_years; Type: TABLE DATA; Schema: public; Owner: calcentral_development
--

INSERT INTO fin_aid_years VALUES (1, 2014, '2014-03-29', '2014-05-01 21:32:13.581', '2014-05-01 21:32:13.581');
INSERT INTO fin_aid_years VALUES (2, 2015, '2015-03-28', '2014-05-01 21:32:13.588', '2014-05-01 21:32:13.588');
INSERT INTO fin_aid_years VALUES (3, 2016, '2016-03-26', '2014-05-01 21:32:13.593', '2014-05-01 21:32:13.593');

--
-- Name: fin_aid_years_id_seq; Type: SEQUENCE SET; Schema: public; Owner: calcentral_development
--

SELECT pg_catalog.setval('fin_aid_years_id_seq', 3, true);


--
-- Data for Name: link_categories; Type: TABLE DATA; Schema: public; Owner: calcentral_development
--

INSERT INTO link_categories VALUES (280, 'Academic', 'academic', true, '2013-08-15 23:09:37.893', '2013-08-15 23:09:37.893');
INSERT INTO link_categories VALUES (281, 'Academic Departments', 'academicdepartments', false, '2013-08-15 23:09:37.9', '2013-08-15 23:09:37.9');
INSERT INTO link_categories VALUES (282, 'Academic Planning', 'academicplanning', false, '2013-08-15 23:09:37.907', '2013-08-15 23:09:37.907');
INSERT INTO link_categories VALUES (283, 'Classes', 'classes', false, '2013-08-15 23:09:37.913', '2013-08-15 23:09:37.913');
INSERT INTO link_categories VALUES (284, 'Faculty', 'faculty', false, '2013-08-15 23:09:37.923', '2013-08-15 23:09:37.923');
INSERT INTO link_categories VALUES (285, 'Staff Learning', 'stafflearning', false, '2013-08-15 23:09:37.931', '2013-08-15 23:09:37.931');
INSERT INTO link_categories VALUES (286, 'Administrative', 'administrative', true, '2013-08-15 23:09:37.938', '2013-08-15 23:09:37.938');
INSERT INTO link_categories VALUES (287, 'Campus Departments', 'campusdepartments', false, '2013-08-15 23:09:37.945', '2013-08-15 23:09:37.945');
INSERT INTO link_categories VALUES (288, 'Communication & Collaboration', 'communicationcollaboration', false, '2013-08-15 23:09:37.951', '2013-08-15 23:09:37.951');
INSERT INTO link_categories VALUES (289, 'Policies & Procedures', 'policiesproceedures', false, '2013-08-15 23:09:37.958', '2013-08-15 23:09:37.958');
INSERT INTO link_categories VALUES (290, 'Shared Service Center', 'sharedservices', false, '2013-08-15 23:09:37.964', '2013-08-15 23:09:37.964');
INSERT INTO link_categories VALUES (291, 'Tools & Resources', 'toolsresources', false, '2013-08-15 23:09:37.971', '2013-08-15 23:09:37.971');
INSERT INTO link_categories VALUES (292, 'Personal', 'personal', true, '2013-08-15 23:09:37.977', '2013-08-15 23:09:37.977');
INSERT INTO link_categories VALUES (293, 'Career', 'career', false, '2013-08-15 23:09:37.983', '2013-08-15 23:09:37.983');
INSERT INTO link_categories VALUES (294, 'Finances', 'finances', false, '2013-08-15 23:09:37.989', '2013-08-15 23:09:37.989');
INSERT INTO link_categories VALUES (295, 'Food & Housing', 'foodandhousing', false, '2013-08-15 23:09:37.995', '2013-08-15 23:09:37.995');
INSERT INTO link_categories VALUES (296, 'HR & Benefits', 'hrbenefits', false, '2013-08-15 23:09:38.002', '2013-08-15 23:09:38.002');
INSERT INTO link_categories VALUES (297, 'Wellness', 'wellness', false, '2013-08-15 23:09:38.008', '2013-08-15 23:09:38.008');
INSERT INTO link_categories VALUES (298, 'Campus Life', 'campus life', true, '2013-08-15 23:09:38.015', '2013-08-15 23:09:38.015');
INSERT INTO link_categories VALUES (299, 'Community', 'community', false, '2013-08-15 23:09:38.021', '2013-08-15 23:09:38.021');
INSERT INTO link_categories VALUES (300, 'Getting Around', 'gettingaround', false, '2013-08-15 23:09:38.027', '2013-08-15 23:09:38.027');
INSERT INTO link_categories VALUES (301, 'Recreation & Entertainment', 'recreationentertainment', false, '2013-08-15 23:09:38.034', '2013-08-15 23:09:38.034');
INSERT INTO link_categories VALUES (302, 'Safety & Emergency Information', 'safetyemergencyinfo', false, '2013-08-15 23:09:38.04', '2013-08-15 23:09:38.04');
INSERT INTO link_categories VALUES (303, 'Student Engagement', 'studentgroups', false, '2013-08-15 23:09:38.046', '2013-08-15 23:09:38.046');
INSERT INTO link_categories VALUES (304, 'Support Services', 'supportservices', false, '2013-08-15 23:09:38.053', '2013-08-15 23:09:38.053');
INSERT INTO link_categories VALUES (305, 'Computing', 'computing', false, '2013-08-15 23:09:38.061', '2013-08-15 23:09:38.061');
INSERT INTO link_categories VALUES (306, 'Network & Computing', 'network & computing', false, '2013-08-15 23:09:38.08', '2013-08-15 23:09:38.08');
INSERT INTO link_categories VALUES (307, 'Graduate', 'graduate', false, '2013-08-15 23:09:38.133', '2013-08-15 23:09:38.133');
INSERT INTO link_categories VALUES (308, 'Scholarships', 'scholarships', false, '2013-08-15 23:09:38.17', '2013-08-15 23:09:38.17');
INSERT INTO link_categories VALUES (309, 'Fees & Billing', 'fees & billing', false, '2013-08-15 23:09:38.228', '2013-08-15 23:09:38.228');
INSERT INTO link_categories VALUES (310, 'Campus Dining', 'campus dining', false, '2013-08-15 23:09:38.267', '2013-08-15 23:09:38.267');
INSERT INTO link_categories VALUES (311, 'Family', 'family', false, '2013-08-15 23:09:38.314', '2013-08-15 23:09:38.314');
INSERT INTO link_categories VALUES (312, 'Staff Support Services', 'staff support services', false, '2013-08-15 23:09:38.343', '2013-08-15 23:09:38.343');
INSERT INTO link_categories VALUES (313, 'Housing', 'housing', false, '2013-08-15 23:09:38.417', '2013-08-15 23:09:38.417');
INSERT INTO link_categories VALUES (314, 'Benefits', 'benefits', false, '2013-08-15 23:09:38.559', '2013-08-15 23:09:38.559');
INSERT INTO link_categories VALUES (315, 'My Information', 'my information', false, '2013-08-15 23:09:38.601', '2013-08-15 23:09:38.601');
INSERT INTO link_categories VALUES (316, 'Retirement', 'retirement', false, '2013-08-15 23:09:38.672', '2013-08-15 23:09:38.672');
INSERT INTO link_categories VALUES (317, 'Conflict Resolution', 'conflict resolution', false, '2013-08-15 23:09:38.743', '2013-08-15 23:09:38.743');
INSERT INTO link_categories VALUES (318, 'Campus Health Center', 'campus health center', false, '2013-08-15 23:09:38.785', '2013-08-15 23:09:38.785');
INSERT INTO link_categories VALUES (319, 'News & Information', 'news & information', false, '2013-08-15 23:09:38.834', '2013-08-15 23:09:38.834');
INSERT INTO link_categories VALUES (320, 'Professional Development', 'professional development', false, '2013-08-15 23:09:38.932', '2013-08-15 23:09:38.932');
INSERT INTO link_categories VALUES (321, 'Undergraduate', 'undergraduate', false, '2013-08-15 23:09:38.971', '2013-08-15 23:09:38.971');
INSERT INTO link_categories VALUES (322, 'Policies', 'policies', false, '2013-08-15 23:09:39.009', '2013-08-15 23:09:39.009');
INSERT INTO link_categories VALUES (323, 'Emergency Preparedness', 'emergency preparedness', false, '2013-08-15 23:09:39.058', '2013-08-15 23:09:39.058');
INSERT INTO link_categories VALUES (324, 'Academic Record', 'academic record', false, '2013-08-15 23:09:39.108', '2013-08-15 23:09:39.108');
INSERT INTO link_categories VALUES (325, 'Calendar', 'calendar', false, '2013-08-15 23:09:39.19', '2013-08-15 23:09:39.19');
INSERT INTO link_categories VALUES (326, 'Planning', 'planning', false, '2013-08-15 23:09:39.27', '2013-08-15 23:09:39.27');
INSERT INTO link_categories VALUES (327, 'Student Advising', 'student advising', false, '2013-08-15 23:09:39.524', '2013-08-15 23:09:39.524');
INSERT INTO link_categories VALUES (328, 'Library', 'library', false, '2013-08-15 23:09:39.78', '2013-08-15 23:09:39.78');
INSERT INTO link_categories VALUES (329, 'Learning Resources', 'learning resources', false, '2013-08-15 23:09:39.798', '2013-08-15 23:09:39.798');
INSERT INTO link_categories VALUES (330, 'Research', 'research', false, '2013-08-15 23:09:39.851', '2013-08-15 23:09:39.851');
INSERT INTO link_categories VALUES (331, 'Collaboration Tools', 'collaboration tools', false, '2013-08-15 23:09:39.945', '2013-08-15 23:09:39.945');
INSERT INTO link_categories VALUES (332, 'Classroom Technology', 'classroom technology', false, '2013-08-15 23:09:40.276', '2013-08-15 23:09:40.276');
INSERT INTO link_categories VALUES (333, 'Resources', 'resources', false, '2013-08-15 23:09:40.314', '2013-08-15 23:09:40.314');
INSERT INTO link_categories VALUES (334, 'Tools', 'tools', false, '2013-08-15 23:09:40.464', '2013-08-15 23:09:40.464');
INSERT INTO link_categories VALUES (335, 'Health & Safety', 'health & safety', false, '2013-08-15 23:09:40.504', '2013-08-15 23:09:40.504');
INSERT INTO link_categories VALUES (336, 'Overview', 'overview', false, '2013-08-15 23:09:40.578', '2013-08-15 23:09:40.578');
INSERT INTO link_categories VALUES (337, 'Administrative and Other', 'administrative and other', false, '2013-08-15 23:09:40.648', '2013-08-15 23:09:40.648');
INSERT INTO link_categories VALUES (338, 'Student Services', 'student services', false, '2013-08-15 23:09:40.934', '2013-08-15 23:09:40.934');
INSERT INTO link_categories VALUES (339, 'bConnected Tools', 'bconnected tools', false, '2013-08-15 23:09:40.98', '2013-08-15 23:09:40.98');
INSERT INTO link_categories VALUES (340, 'Campus Messaging', 'campus messaging', false, '2013-08-15 23:09:41.157', '2013-08-15 23:09:41.157');
INSERT INTO link_categories VALUES (341, 'Compliance & Risk Management', 'compliance & risk management', false, '2013-08-15 23:09:41.38', '2013-08-15 23:09:41.38');
INSERT INTO link_categories VALUES (342, 'Employer & Employee', 'employer & employee', false, '2013-08-15 23:09:41.431', '2013-08-15 23:09:41.431');
INSERT INTO link_categories VALUES (343, 'Service Requests', 'service requests', false, '2013-08-15 23:09:41.556', '2013-08-15 23:09:41.556');
INSERT INTO link_categories VALUES (344, 'Analysis & Reporting', 'analysis & reporting', false, '2013-08-15 23:09:41.597', '2013-08-15 23:09:41.597');
INSERT INTO link_categories VALUES (345, 'Asset Management', 'asset management', false, '2013-08-15 23:09:41.637', '2013-08-15 23:09:41.637');
INSERT INTO link_categories VALUES (346, 'Campus Mail', 'campus mail', false, '2013-08-15 23:09:41.674', '2013-08-15 23:09:41.674');
INSERT INTO link_categories VALUES (347, 'Financial', 'financial', false, '2013-08-15 23:09:41.891', '2013-08-15 23:09:41.891');
INSERT INTO link_categories VALUES (348, 'Human Resources', 'human resources', false, '2013-08-15 23:09:41.979', '2013-08-15 23:09:41.979');
INSERT INTO link_categories VALUES (349, 'Payroll', 'payroll', false, '2013-08-15 23:09:42.046', '2013-08-15 23:09:42.046');
INSERT INTO link_categories VALUES (350, 'Purchasing', 'purchasing', false, '2013-08-15 23:09:42.112', '2013-08-15 23:09:42.112');
INSERT INTO link_categories VALUES (351, 'Security & Access', 'security & access', false, '2013-08-15 23:09:42.208', '2013-08-15 23:09:42.208');
INSERT INTO link_categories VALUES (352, 'Staff Portal', 'staff portal', false, '2013-08-15 23:09:42.361', '2013-08-15 23:09:42.361');
INSERT INTO link_categories VALUES (353, 'Travel & Entertainment', 'travel & entertainment', false, '2013-08-15 23:09:42.401', '2013-08-15 23:09:42.401');
INSERT INTO link_categories VALUES (354, 'Directory', 'directory', false, '2013-08-15 23:09:42.441', '2013-08-15 23:09:42.441');
INSERT INTO link_categories VALUES (355, 'Philanthropy & Public Service', 'philanthropy & public service', false, '2013-08-15 23:09:42.485', '2013-08-15 23:09:42.485');
INSERT INTO link_categories VALUES (356, 'News & Events', 'news & events', false, '2013-08-15 23:09:42.594', '2013-08-15 23:09:42.594');
INSERT INTO link_categories VALUES (357, 'Social Media', 'social media', false, '2013-08-15 23:09:42.738', '2013-08-15 23:09:42.738');
INSERT INTO link_categories VALUES (358, 'Map', 'map', false, '2013-08-15 23:09:42.807', '2013-08-15 23:09:42.807');
INSERT INTO link_categories VALUES (359, 'Parking & Transportation', 'parking & transportation', false, '2013-08-15 23:09:42.855', '2013-08-15 23:09:42.855');
INSERT INTO link_categories VALUES (360, 'Points of Interest', 'points of interest', false, '2013-08-15 23:09:43.007', '2013-08-15 23:09:43.007');
INSERT INTO link_categories VALUES (361, 'Police', 'police', false, '2013-08-15 23:09:43.088', '2013-08-15 23:09:43.088');
INSERT INTO link_categories VALUES (362, 'Night Safety', 'night safety', false, '2013-08-15 23:09:43.135', '2013-08-15 23:09:43.135');
INSERT INTO link_categories VALUES (363, 'Sports & Recreation', 'sports & recreation', false, '2013-08-15 23:09:43.253', '2013-08-15 23:09:43.253');
INSERT INTO link_categories VALUES (364, 'Athletics', 'athletics', false, '2013-08-15 23:09:43.319', '2013-08-15 23:09:43.319');
INSERT INTO link_categories VALUES (365, 'Activities', 'activities', false, '2013-08-15 23:09:43.368', '2013-08-15 23:09:43.368');
INSERT INTO link_categories VALUES (366, 'Student Government', 'student government', false, '2013-08-15 23:09:43.577', '2013-08-15 23:09:43.577');
INSERT INTO link_categories VALUES (367, 'Student Organizations', 'student organizations', false, '2013-08-15 23:09:43.634', '2013-08-15 23:09:43.634');
INSERT INTO link_categories VALUES (368, 'Students', 'students', false, '2013-08-15 23:09:43.718', '2013-08-15 23:09:43.718');
INSERT INTO link_categories VALUES (369, 'Jobs', 'jobs', false, '2013-08-15 23:09:43.856', '2013-08-15 23:09:43.856');
INSERT INTO link_categories VALUES (370, 'Student Employees', 'student employees', false, '2013-08-15 23:09:43.984', '2013-08-15 23:09:43.984');
INSERT INTO link_categories VALUES (371, 'Federal Loans', 'federal loans', false, '2013-08-15 23:09:44.044', '2013-08-15 23:09:44.044');
INSERT INTO link_categories VALUES (372, 'Financial Aid', 'financial aid', false, '2013-08-15 23:09:44.099', '2013-08-15 23:09:44.099');


--
-- Name: link_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: calcentral
--

SELECT pg_catalog.setval('link_categories_id_seq', 372, true);


--
-- Data for Name: link_categories_link_sections; Type: TABLE DATA; Schema: public; Owner: calcentral
--



--
-- Data for Name: link_sections; Type: TABLE DATA; Schema: public; Owner: calcentral
--

INSERT INTO link_sections VALUES (229, 286, 291, 305, '2013-08-15 23:09:38.072', '2013-08-15 23:09:38.072');
INSERT INTO link_sections VALUES (230, 292, 295, 306, '2013-08-15 23:09:38.09', '2013-08-15 23:09:38.09');
INSERT INTO link_sections VALUES (231, 292, 294, 307, '2013-08-15 23:09:38.144', '2013-08-15 23:09:38.144');
INSERT INTO link_sections VALUES (232, 292, 294, 308, '2013-08-15 23:09:38.18', '2013-08-15 23:09:38.18');
INSERT INTO link_sections VALUES (233, 292, 294, 309, '2013-08-15 23:09:38.238', '2013-08-15 23:09:38.238');
INSERT INTO link_sections VALUES (234, 292, 295, 310, '2013-08-15 23:09:38.277', '2013-08-15 23:09:38.277');
INSERT INTO link_sections VALUES (235, 292, 295, 311, '2013-08-15 23:09:38.324', '2013-08-15 23:09:38.324');
INSERT INTO link_sections VALUES (236, 292, 296, 311, '2013-08-15 23:09:38.336', '2013-08-15 23:09:38.336');
INSERT INTO link_sections VALUES (237, 292, 297, 312, '2013-08-15 23:09:38.353', '2013-08-15 23:09:38.353');
INSERT INTO link_sections VALUES (238, 292, 295, 313, '2013-08-15 23:09:38.432', '2013-08-15 23:09:38.432');
INSERT INTO link_sections VALUES (239, 292, 296, 314, '2013-08-15 23:09:38.569', '2013-08-15 23:09:38.569');
INSERT INTO link_sections VALUES (240, 292, 296, 315, '2013-08-15 23:09:38.612', '2013-08-15 23:09:38.612');
INSERT INTO link_sections VALUES (241, 292, 296, 316, '2013-08-15 23:09:38.682', '2013-08-15 23:09:38.682');
INSERT INTO link_sections VALUES (242, 292, 296, 317, '2013-08-15 23:09:38.753', '2013-08-15 23:09:38.753');
INSERT INTO link_sections VALUES (243, 292, 297, 318, '2013-08-15 23:09:38.795', '2013-08-15 23:09:38.795');
INSERT INTO link_sections VALUES (244, 292, 297, 319, '2013-08-15 23:09:38.845', '2013-08-15 23:09:38.845');
INSERT INTO link_sections VALUES (245, 280, 285, 320, '2013-08-15 23:09:38.943', '2013-08-15 23:09:38.943');
INSERT INTO link_sections VALUES (246, 292, 294, 321, '2013-08-15 23:09:38.982', '2013-08-15 23:09:38.982');
INSERT INTO link_sections VALUES (247, 286, 289, 322, '2013-08-15 23:09:39.02', '2013-08-15 23:09:39.02');
INSERT INTO link_sections VALUES (248, 298, 302, 323, '2013-08-15 23:09:39.069', '2013-08-15 23:09:39.069');
INSERT INTO link_sections VALUES (249, 280, 282, 324, '2013-08-15 23:09:39.118', '2013-08-15 23:09:39.118');
INSERT INTO link_sections VALUES (250, 280, 282, 325, '2013-08-15 23:09:39.2', '2013-08-15 23:09:39.2');
INSERT INTO link_sections VALUES (251, 280, 282, 326, '2013-08-15 23:09:39.28', '2013-08-15 23:09:39.28');
INSERT INTO link_sections VALUES (252, 280, 283, 283, '2013-08-15 23:09:39.342', '2013-08-15 23:09:39.342');
INSERT INTO link_sections VALUES (253, 280, 282, 327, '2013-08-15 23:09:39.534', '2013-08-15 23:09:39.534');
INSERT INTO link_sections VALUES (254, 280, 281, 280, '2013-08-15 23:09:39.636', '2013-08-15 23:09:39.636');
INSERT INTO link_sections VALUES (255, 280, 281, 307, '2013-08-15 23:09:39.742', '2013-08-15 23:09:39.742');
INSERT INTO link_sections VALUES (256, 280, 281, 328, '2013-08-15 23:09:39.79', '2013-08-15 23:09:39.79');
INSERT INTO link_sections VALUES (257, 280, 283, 329, '2013-08-15 23:09:39.807', '2013-08-15 23:09:39.807');
INSERT INTO link_sections VALUES (258, 280, 281, 330, '2013-08-15 23:09:39.861', '2013-08-15 23:09:39.861');
INSERT INTO link_sections VALUES (259, 280, 282, 283, '2013-08-15 23:09:39.938', '2013-08-15 23:09:39.938');
INSERT INTO link_sections VALUES (260, 286, 288, 331, '2013-08-15 23:09:39.955', '2013-08-15 23:09:39.955');
INSERT INTO link_sections VALUES (261, 280, 284, 332, '2013-08-15 23:09:40.286', '2013-08-15 23:09:40.286');
INSERT INTO link_sections VALUES (262, 280, 284, 333, '2013-08-15 23:09:40.324', '2013-08-15 23:09:40.324');
INSERT INTO link_sections VALUES (263, 280, 284, 334, '2013-08-15 23:09:40.475', '2013-08-15 23:09:40.475');
INSERT INTO link_sections VALUES (264, 280, 285, 335, '2013-08-15 23:09:40.514', '2013-08-15 23:09:40.514');
INSERT INTO link_sections VALUES (265, 280, 285, 336, '2013-08-15 23:09:40.588', '2013-08-15 23:09:40.588');
INSERT INTO link_sections VALUES (266, 286, 287, 337, '2013-08-15 23:09:40.658', '2013-08-15 23:09:40.658');
INSERT INTO link_sections VALUES (267, 286, 287, 338, '2013-08-15 23:09:40.944', '2013-08-15 23:09:40.944');
INSERT INTO link_sections VALUES (268, 286, 288, 339, '2013-08-15 23:09:40.99', '2013-08-15 23:09:40.99');
INSERT INTO link_sections VALUES (269, 286, 288, 340, '2013-08-15 23:09:41.167', '2013-08-15 23:09:41.167');
INSERT INTO link_sections VALUES (270, 286, 289, 341, '2013-08-15 23:09:41.39', '2013-08-15 23:09:41.39');
INSERT INTO link_sections VALUES (271, 286, 289, 342, '2013-08-15 23:09:41.459', '2013-08-15 23:09:41.459');
INSERT INTO link_sections VALUES (272, 286, 290, 336, '2013-08-15 23:09:41.523', '2013-08-15 23:09:41.523');
INSERT INTO link_sections VALUES (273, 286, 290, 343, '2013-08-15 23:09:41.565', '2013-08-15 23:09:41.565');
INSERT INTO link_sections VALUES (274, 286, 291, 344, '2013-08-15 23:09:41.607', '2013-08-15 23:09:41.607');
INSERT INTO link_sections VALUES (275, 286, 291, 345, '2013-08-15 23:09:41.647', '2013-08-15 23:09:41.647');
INSERT INTO link_sections VALUES (276, 286, 291, 346, '2013-08-15 23:09:41.683', '2013-08-15 23:09:41.683');
INSERT INTO link_sections VALUES (277, 286, 291, 347, '2013-08-15 23:09:41.9', '2013-08-15 23:09:41.9');
INSERT INTO link_sections VALUES (278, 286, 291, 348, '2013-08-15 23:09:41.989', '2013-08-15 23:09:41.989');
INSERT INTO link_sections VALUES (279, 286, 291, 349, '2013-08-15 23:09:42.056', '2013-08-15 23:09:42.056');
INSERT INTO link_sections VALUES (280, 286, 291, 350, '2013-08-15 23:09:42.122', '2013-08-15 23:09:42.122');
INSERT INTO link_sections VALUES (281, 286, 291, 351, '2013-08-15 23:09:42.218', '2013-08-15 23:09:42.218');
INSERT INTO link_sections VALUES (282, 286, 291, 352, '2013-08-15 23:09:42.37', '2013-08-15 23:09:42.37');
INSERT INTO link_sections VALUES (283, 286, 291, 353, '2013-08-15 23:09:42.41', '2013-08-15 23:09:42.41');
INSERT INTO link_sections VALUES (284, 298, 299, 354, '2013-08-15 23:09:42.45', '2013-08-15 23:09:42.45');
INSERT INTO link_sections VALUES (285, 298, 299, 355, '2013-08-15 23:09:42.495', '2013-08-15 23:09:42.495');
INSERT INTO link_sections VALUES (286, 298, 299, 356, '2013-08-15 23:09:42.605', '2013-08-15 23:09:42.605');
INSERT INTO link_sections VALUES (287, 298, 299, 357, '2013-08-15 23:09:42.747', '2013-08-15 23:09:42.747');
INSERT INTO link_sections VALUES (288, 298, 300, 358, '2013-08-15 23:09:42.817', '2013-08-15 23:09:42.817');
INSERT INTO link_sections VALUES (289, 298, 300, 359, '2013-08-15 23:09:42.865', '2013-08-15 23:09:42.865');
INSERT INTO link_sections VALUES (290, 298, 300, 360, '2013-08-15 23:09:43.016', '2013-08-15 23:09:43.016');
INSERT INTO link_sections VALUES (291, 298, 302, 361, '2013-08-15 23:09:43.098', '2013-08-15 23:09:43.098');
INSERT INTO link_sections VALUES (292, 298, 302, 362, '2013-08-15 23:09:43.145', '2013-08-15 23:09:43.145');
INSERT INTO link_sections VALUES (293, 298, 301, 360, '2013-08-15 23:09:43.216', '2013-08-15 23:09:43.216');
INSERT INTO link_sections VALUES (294, 298, 301, 363, '2013-08-15 23:09:43.262', '2013-08-15 23:09:43.262');
INSERT INTO link_sections VALUES (295, 298, 301, 364, '2013-08-15 23:09:43.329', '2013-08-15 23:09:43.329');
INSERT INTO link_sections VALUES (296, 298, 301, 365, '2013-08-15 23:09:43.377', '2013-08-15 23:09:43.377');
INSERT INTO link_sections VALUES (297, 298, 303, 365, '2013-08-15 23:09:43.552', '2013-08-15 23:09:43.552');
INSERT INTO link_sections VALUES (298, 298, 303, 366, '2013-08-15 23:09:43.586', '2013-08-15 23:09:43.586');
INSERT INTO link_sections VALUES (299, 298, 303, 367, '2013-08-15 23:09:43.643', '2013-08-15 23:09:43.643');
INSERT INTO link_sections VALUES (300, 298, 304, 368, '2013-08-15 23:09:43.728', '2013-08-15 23:09:43.728');
INSERT INTO link_sections VALUES (301, 292, 293, 369, '2013-08-15 23:09:43.865', '2013-08-15 23:09:43.865');
INSERT INTO link_sections VALUES (302, 292, 293, 370, '2013-08-15 23:09:43.993', '2013-08-15 23:09:43.993');
INSERT INTO link_sections VALUES (303, 292, 294, 371, '2013-08-15 23:09:44.054', '2013-08-15 23:09:44.054');
INSERT INTO link_sections VALUES (304, 292, 294, 372, '2013-08-15 23:09:44.109', '2013-08-15 23:09:44.109');


--
-- Name: link_sections_id_seq; Type: SEQUENCE SET; Schema: public; Owner: calcentral
--

SELECT pg_catalog.setval('link_sections_id_seq', 304, true);


--
-- Data for Name: link_sections_links; Type: TABLE DATA; Schema: public; Owner: calcentral
--

INSERT INTO link_sections_links VALUES (229, 528);
INSERT INTO link_sections_links VALUES (230, 528);
INSERT INTO link_sections_links VALUES (231, 529);
INSERT INTO link_sections_links VALUES (232, 530);
INSERT INTO link_sections_links VALUES (231, 531);
INSERT INTO link_sections_links VALUES (233, 532);
INSERT INTO link_sections_links VALUES (234, 533);
INSERT INTO link_sections_links VALUES (235, 534);
INSERT INTO link_sections_links VALUES (236, 534);
INSERT INTO link_sections_links VALUES (237, 534);
INSERT INTO link_sections_links VALUES (238, 535);
INSERT INTO link_sections_links VALUES (238, 536);
INSERT INTO link_sections_links VALUES (238, 537);
INSERT INTO link_sections_links VALUES (238, 538);
INSERT INTO link_sections_links VALUES (238, 539);
INSERT INTO link_sections_links VALUES (239, 540);
INSERT INTO link_sections_links VALUES (240, 541);
INSERT INTO link_sections_links VALUES (240, 542);
INSERT INTO link_sections_links VALUES (241, 543);
INSERT INTO link_sections_links VALUES (241, 544);
INSERT INTO link_sections_links VALUES (242, 545);
INSERT INTO link_sections_links VALUES (243, 546);
INSERT INTO link_sections_links VALUES (244, 547);
INSERT INTO link_sections_links VALUES (243, 548);
INSERT INTO link_sections_links VALUES (243, 549);
INSERT INTO link_sections_links VALUES (245, 550);
INSERT INTO link_sections_links VALUES (246, 551);
INSERT INTO link_sections_links VALUES (247, 552);
INSERT INTO link_sections_links VALUES (248, 553);
INSERT INTO link_sections_links VALUES (249, 554);
INSERT INTO link_sections_links VALUES (249, 555);
INSERT INTO link_sections_links VALUES (250, 556);
INSERT INTO link_sections_links VALUES (250, 557);
INSERT INTO link_sections_links VALUES (251, 558);
INSERT INTO link_sections_links VALUES (251, 559);
INSERT INTO link_sections_links VALUES (252, 559);
INSERT INTO link_sections_links VALUES (251, 560);
INSERT INTO link_sections_links VALUES (252, 560);
INSERT INTO link_sections_links VALUES (251, 561);
INSERT INTO link_sections_links VALUES (251, 562);
INSERT INTO link_sections_links VALUES (251, 563);
INSERT INTO link_sections_links VALUES (251, 564);
INSERT INTO link_sections_links VALUES (253, 565);
INSERT INTO link_sections_links VALUES (233, 565);
INSERT INTO link_sections_links VALUES (253, 566);
INSERT INTO link_sections_links VALUES (253, 567);
INSERT INTO link_sections_links VALUES (253, 568);
INSERT INTO link_sections_links VALUES (254, 569);
INSERT INTO link_sections_links VALUES (254, 570);
INSERT INTO link_sections_links VALUES (254, 571);
INSERT INTO link_sections_links VALUES (255, 572);
INSERT INTO link_sections_links VALUES (256, 573);
INSERT INTO link_sections_links VALUES (257, 573);
INSERT INTO link_sections_links VALUES (258, 574);
INSERT INTO link_sections_links VALUES (258, 575);
INSERT INTO link_sections_links VALUES (252, 576);
INSERT INTO link_sections_links VALUES (259, 576);
INSERT INTO link_sections_links VALUES (260, 576);
INSERT INTO link_sections_links VALUES (252, 577);
INSERT INTO link_sections_links VALUES (252, 578);
INSERT INTO link_sections_links VALUES (259, 578);
INSERT INTO link_sections_links VALUES (252, 579);
INSERT INTO link_sections_links VALUES (259, 579);
INSERT INTO link_sections_links VALUES (252, 580);
INSERT INTO link_sections_links VALUES (259, 580);
INSERT INTO link_sections_links VALUES (245, 580);
INSERT INTO link_sections_links VALUES (257, 582);
INSERT INTO link_sections_links VALUES (257, 583);
INSERT INTO link_sections_links VALUES (257, 584);
INSERT INTO link_sections_links VALUES (261, 585);
INSERT INTO link_sections_links VALUES (262, 586);
INSERT INTO link_sections_links VALUES (262, 587);
INSERT INTO link_sections_links VALUES (262, 588);
INSERT INTO link_sections_links VALUES (262, 589);
INSERT INTO link_sections_links VALUES (262, 590);
INSERT INTO link_sections_links VALUES (262, 591);
INSERT INTO link_sections_links VALUES (263, 592);
INSERT INTO link_sections_links VALUES (264, 593);
INSERT INTO link_sections_links VALUES (264, 594);
INSERT INTO link_sections_links VALUES (265, 595);
INSERT INTO link_sections_links VALUES (245, 596);
INSERT INTO link_sections_links VALUES (266, 597);
INSERT INTO link_sections_links VALUES (266, 598);
INSERT INTO link_sections_links VALUES (266, 599);
INSERT INTO link_sections_links VALUES (266, 600);
INSERT INTO link_sections_links VALUES (266, 601);
INSERT INTO link_sections_links VALUES (266, 602);
INSERT INTO link_sections_links VALUES (266, 603);
INSERT INTO link_sections_links VALUES (266, 604);
INSERT INTO link_sections_links VALUES (267, 605);
INSERT INTO link_sections_links VALUES (268, 606);
INSERT INTO link_sections_links VALUES (268, 607);
INSERT INTO link_sections_links VALUES (268, 608);
INSERT INTO link_sections_links VALUES (268, 609);
INSERT INTO link_sections_links VALUES (268, 610);
INSERT INTO link_sections_links VALUES (269, 611);
INSERT INTO link_sections_links VALUES (260, 612);
INSERT INTO link_sections_links VALUES (260, 613);
INSERT INTO link_sections_links VALUES (260, 614);
INSERT INTO link_sections_links VALUES (247, 615);
INSERT INTO link_sections_links VALUES (247, 616);
INSERT INTO link_sections_links VALUES (247, 617);
INSERT INTO link_sections_links VALUES (270, 618);
INSERT INTO link_sections_links VALUES (271, 619);
INSERT INTO link_sections_links VALUES (271, 620);
INSERT INTO link_sections_links VALUES (272, 621);
INSERT INTO link_sections_links VALUES (273, 622);
INSERT INTO link_sections_links VALUES (274, 623);
INSERT INTO link_sections_links VALUES (275, 624);
INSERT INTO link_sections_links VALUES (276, 625);
INSERT INTO link_sections_links VALUES (229, 626);
INSERT INTO link_sections_links VALUES (229, 627);
INSERT INTO link_sections_links VALUES (229, 628);
INSERT INTO link_sections_links VALUES (229, 629);
INSERT INTO link_sections_links VALUES (229, 630);
INSERT INTO link_sections_links VALUES (229, 631);
INSERT INTO link_sections_links VALUES (277, 632);
INSERT INTO link_sections_links VALUES (277, 633);
INSERT INTO link_sections_links VALUES (277, 634);
INSERT INTO link_sections_links VALUES (278, 635);
INSERT INTO link_sections_links VALUES (278, 636);
INSERT INTO link_sections_links VALUES (279, 637);
INSERT INTO link_sections_links VALUES (279, 638);
INSERT INTO link_sections_links VALUES (280, 639);
INSERT INTO link_sections_links VALUES (280, 640);
INSERT INTO link_sections_links VALUES (280, 641);
INSERT INTO link_sections_links VALUES (281, 642);
INSERT INTO link_sections_links VALUES (281, 643);
INSERT INTO link_sections_links VALUES (234, 643);
INSERT INTO link_sections_links VALUES (281, 644);
INSERT INTO link_sections_links VALUES (281, 645);
INSERT INTO link_sections_links VALUES (282, 646);
INSERT INTO link_sections_links VALUES (283, 647);
INSERT INTO link_sections_links VALUES (284, 648);
INSERT INTO link_sections_links VALUES (285, 649);
INSERT INTO link_sections_links VALUES (285, 650);
INSERT INTO link_sections_links VALUES (285, 651);
INSERT INTO link_sections_links VALUES (286, 652);
INSERT INTO link_sections_links VALUES (286, 653);
INSERT INTO link_sections_links VALUES (286, 654);
INSERT INTO link_sections_links VALUES (286, 655);
INSERT INTO link_sections_links VALUES (287, 656);
INSERT INTO link_sections_links VALUES (287, 657);
INSERT INTO link_sections_links VALUES (288, 658);
INSERT INTO link_sections_links VALUES (289, 659);
INSERT INTO link_sections_links VALUES (289, 660);
INSERT INTO link_sections_links VALUES (289, 661);
INSERT INTO link_sections_links VALUES (289, 662);
INSERT INTO link_sections_links VALUES (290, 663);
INSERT INTO link_sections_links VALUES (248, 664);
INSERT INTO link_sections_links VALUES (291, 665);
INSERT INTO link_sections_links VALUES (292, 666);
INSERT INTO link_sections_links VALUES (248, 667);
INSERT INTO link_sections_links VALUES (293, 668);
INSERT INTO link_sections_links VALUES (294, 669);
INSERT INTO link_sections_links VALUES (294, 670);
INSERT INTO link_sections_links VALUES (295, 671);
INSERT INTO link_sections_links VALUES (296, 672);
INSERT INTO link_sections_links VALUES (293, 673);
INSERT INTO link_sections_links VALUES (293, 674);
INSERT INTO link_sections_links VALUES (293, 675);
INSERT INTO link_sections_links VALUES (286, 676);
INSERT INTO link_sections_links VALUES (293, 676);
INSERT INTO link_sections_links VALUES (297, 677);
INSERT INTO link_sections_links VALUES (298, 678);
INSERT INTO link_sections_links VALUES (298, 679);
INSERT INTO link_sections_links VALUES (299, 680);
INSERT INTO link_sections_links VALUES (238, 680);
INSERT INTO link_sections_links VALUES (299, 681);
INSERT INTO link_sections_links VALUES (299, 682);
INSERT INTO link_sections_links VALUES (300, 683);
INSERT INTO link_sections_links VALUES (300, 684);
INSERT INTO link_sections_links VALUES (300, 685);
INSERT INTO link_sections_links VALUES (300, 686);
INSERT INTO link_sections_links VALUES (300, 687);
INSERT INTO link_sections_links VALUES (300, 688);
INSERT INTO link_sections_links VALUES (301, 689);
INSERT INTO link_sections_links VALUES (301, 690);
INSERT INTO link_sections_links VALUES (301, 691);
INSERT INTO link_sections_links VALUES (301, 692);
INSERT INTO link_sections_links VALUES (301, 693);
INSERT INTO link_sections_links VALUES (302, 694);
INSERT INTO link_sections_links VALUES (301, 695);
INSERT INTO link_sections_links VALUES (303, 696);
INSERT INTO link_sections_links VALUES (303, 697);
INSERT INTO link_sections_links VALUES (304, 698);
INSERT INTO link_sections_links VALUES (233, 699);
INSERT INTO link_sections_links VALUES (233, 700);
INSERT INTO link_sections_links VALUES (246, 701);
INSERT INTO link_sections_links VALUES (233, 702);
INSERT INTO link_sections_links VALUES (304, 703);


--
-- Data for Name: links; Type: TABLE DATA; Schema: public; Owner: calcentral
--

INSERT INTO links VALUES (528, 'Residential Computing (ResComp)', 'http://www.rescomp.berkeley.edu/', 'Computer and network services for students living in campus housing', true, '2013-08-15 23:09:38.097', '2013-08-15 23:09:38.097');
INSERT INTO links VALUES (529, 'Graduate Student Financial Support', 'http://www.grad.berkeley.edu/financial/', '', true, '2013-08-15 23:09:38.15', '2013-08-15 23:09:38.15');
INSERT INTO links VALUES (530, 'Scholarship database', 'http://scholarships.berkeley.edu', '', true, '2013-08-15 23:09:38.187', '2013-08-15 23:09:38.187');
INSERT INTO links VALUES (531, 'Grad Loans', 'http://students.berkeley.edu/finaid/graduates/types_loans.htm', '', true, '2013-08-15 23:09:38.208', '2013-08-15 23:09:38.208');
INSERT INTO links VALUES (532, 'Student Billing Services', 'http://studentbilling.berkeley.edu/', '', true, '2013-08-15 23:09:38.247', '2013-08-15 23:09:38.247');
INSERT INTO links VALUES (533, 'CalDining', 'http://caldining.berkeley.edu/', 'Campus dining facilities', true, '2013-08-15 23:09:38.284', '2013-08-15 23:09:38.284');
INSERT INTO links VALUES (534, 'Child Care', 'http://www.housing.berkeley.edu/child/', 'Campus child care services', true, '2013-08-15 23:09:38.36', '2013-08-15 23:09:38.36');
INSERT INTO links VALUES (535, 'Residential & Student Service Programs', 'http://www.housing.berkeley.edu/', '', true, '2013-08-15 23:09:38.439', '2013-08-15 23:09:38.439');
INSERT INTO links VALUES (536, 'Living At Cal', 'http://www.housing.berkeley.edu/livingatcal/', '', true, '2013-08-15 23:09:38.462', '2013-08-15 23:09:38.462');
INSERT INTO links VALUES (537, 'Berkeley Student Cooperative', 'http://www.bsc.coop/', '', true, '2013-08-15 23:09:38.484', '2013-08-15 23:09:38.484');
INSERT INTO links VALUES (538, 'International House', 'http://ihouse.berkeley.edu/', '', true, '2013-08-15 23:09:38.505', '2013-08-15 23:09:38.505');
INSERT INTO links VALUES (539, 'Cal Rentals', 'http://calrentals.housing.berkeley.edu/', '', true, '2013-08-15 23:09:38.528', '2013-08-15 23:09:38.528');
INSERT INTO links VALUES (540, 'At Your Service', 'https://atyourserviceonline.ucop.edu', 'Benefits, Earnings, Taxes & Retirement', true, '2013-08-15 23:09:38.576', '2013-08-15 23:09:38.576');
INSERT INTO links VALUES (541, 'Personal Info - Campus Directory', 'https://calnet.berkeley.edu/directory/update/', '', true, '2013-08-15 23:09:38.618', '2013-08-15 23:09:38.618');
INSERT INTO links VALUES (542, 'Personal Info - HR record', 'https://auth.berkeley.edu/cas/login?service=https://hrw-vip-prod.is.berkeley.edu/cgi-bin/cas-hrsprod.pl', 'HR personal data, requires log-in.', true, '2013-08-15 23:09:38.647', '2013-08-15 23:09:38.647');
INSERT INTO links VALUES (543, 'Retirement Benefits - At Your Service', 'https://atyourserviceonline.ucop.edu', 'Benefits, Earnings, Taxes & Retirement', true, '2013-08-15 23:09:38.689', '2013-08-15 23:09:38.689');
INSERT INTO links VALUES (544, 'Retirement Resources', 'http://thecenter.berkeley.edu/index.shtml', '', true, '2013-08-15 23:09:38.716', '2013-08-15 23:09:38.716');
INSERT INTO links VALUES (545, 'Staff Ombuds Office', 'http://staffombuds.berkeley.edu/ ', 'an independent department that provides strictly confidential and informal conflict resolution and problem-solving services', true, '2013-08-15 23:09:38.76', '2013-08-15 23:09:38.76');
INSERT INTO links VALUES (546, 'UHS - Tang Center', 'http://uhs.berkeley.edu/', 'Campus healthcare', true, '2013-08-15 23:09:38.802', '2013-08-15 23:09:38.802');
INSERT INTO links VALUES (547, 'UC Berkeley Wellness Letter', 'http://www.wellnessletter.com/ucberkeley/', '', true, '2013-08-15 23:09:38.854', '2013-08-15 23:09:38.854');
INSERT INTO links VALUES (548, 'UC SHIP (Student Health Insurance Plan)', 'http://www.uhs.berkeley.edu/students/insurance/', 'UC Student Health Insurance Plan', true, '2013-08-15 23:09:38.878', '2013-08-15 23:09:38.878');
INSERT INTO links VALUES (549, 'CARE Services', 'http://uhs.berkeley.edu/facstaff/care/', 'free, confidential problem assessment and referral for UC Berkeley faculty and staff', true, '2013-08-15 23:09:38.904', '2013-08-15 23:09:38.904');
INSERT INTO links VALUES (550, 'Organizational & Workforce Effectiveness', 'http://hrweb.berkeley.edu/learning/corwe', 'Organization supporting managers wanting to make organizational improvements', true, '2013-08-15 23:09:38.951', '2013-08-15 23:09:38.951');
INSERT INTO links VALUES (551, 'Undergrad Loans', 'http://students.berkeley.edu/finaid/undergraduates/types_loans.htm', 'Overview of undergraduate loans', true, '2013-08-15 23:09:38.99', '2013-08-15 23:09:38.99');
INSERT INTO links VALUES (552, 'Policies & procedures A-Z', 'http://campuspol.chance.berkeley.edu/Home/AtoZPolicies.cfm?long_page=yes', 'A-Z of campuswide policies and procedures', true, '2013-08-15 23:09:39.027', '2013-08-15 23:09:39.027');
INSERT INTO links VALUES (553, 'Safety', 'http://police.berkeley.edu/index.html', 'Safety information and programs', true, '2013-08-15 23:09:39.075', '2013-08-15 23:09:39.075');
INSERT INTO links VALUES (554, 'Bear Facts', 'https://bearfacts.berkeley.edu', 'Academic record, grades & transcript, bill, degree audit, loans, SLR & personal info', true, '2013-08-15 23:09:39.125', '2013-08-15 23:09:39.125');
INSERT INTO links VALUES (555, 'Office of the Registrar', 'http://registrar.berkeley.edu/', '', true, '2013-08-15 23:09:39.16', '2013-08-15 23:09:39.16');
INSERT INTO links VALUES (556, 'Academic Calendar', 'http://registrar.berkeley.edu/CalendarDisp.aspx?terms=current', 'Academic Calendars Future Campus Calendars', true, '2013-08-15 23:09:39.207', '2013-08-15 23:09:39.207');
INSERT INTO links VALUES (557, 'Undergraduate Student Calendar & Deadlines', 'http://registrar.berkeley.edu/current_students/registration_enrollment/stucal.html', '', true, '2013-08-15 23:09:39.239', '2013-08-15 23:09:39.239');
INSERT INTO links VALUES (558, 'Course Catalog', 'http://general-catalog.berkeley.edu/catalog/gcc_search_menu', 'Detailed course descriptions', true, '2013-08-15 23:09:39.287', '2013-08-15 23:09:39.287');
INSERT INTO links VALUES (559, 'Schedule of Classes', 'http://schedule.berkeley.edu/', 'Classes offerings by semester', true, '2013-08-15 23:09:39.349', '2013-08-15 23:09:39.349');
INSERT INTO links VALUES (560, 'Summer Sessions', 'http://summer.berkeley.edu/', '', true, '2013-08-15 23:09:39.39', '2013-08-15 23:09:39.39');
INSERT INTO links VALUES (561, 'DARS', 'https://marin.berkeley.edu/darsweb/servlet/ListAuditsServlet ', 'Degree requirements and track progress', true, '2013-08-15 23:09:39.428', '2013-08-15 23:09:39.428');
INSERT INTO links VALUES (562, 'Finding Your Way (L&S)', 'http://ls-yourway.berkeley.edu/', '', true, '2013-08-15 23:09:39.45', '2013-08-15 23:09:39.45');
INSERT INTO links VALUES (563, 'Schedule Builder', 'https://schedulebuilder.berkeley.edu/', 'Plan your classes', true, '2013-08-15 23:09:39.472', '2013-08-15 23:09:39.472');
INSERT INTO links VALUES (564, 'TeleBears', 'https://telebears.berkeley.edu', 'Register for classes', true, '2013-08-15 23:09:39.504', '2013-08-15 23:09:39.504');
INSERT INTO links VALUES (565, 'Cal Student Central', 'http://studentcentral.berkeley.edu/', '', true, '2013-08-15 23:09:39.543', '2013-08-15 23:09:39.543');
INSERT INTO links VALUES (566, 'Office of Undergraduate Advising', 'http://ls-advise.berkeley.edu/', '', true, '2013-08-15 23:09:39.57', '2013-08-15 23:09:39.57');
INSERT INTO links VALUES (567, 'Student Learning Center', 'http://slc.berkeley.edu/general/index.htm', '', true, '2013-08-15 23:09:39.592', '2013-08-15 23:09:39.592');
INSERT INTO links VALUES (568, 'Educational Opportunity Program', 'http://eop.berkeley.edu', 'Guidance and resources for first generation and low-income college students.', true, '2013-08-15 23:09:39.613', '2013-08-15 23:09:39.613');
INSERT INTO links VALUES (569, 'Academic Departments & Programs', 'http://www.berkeley.edu/academics/dept/a.shtml', '', true, '2013-08-15 23:09:39.643', '2013-08-15 23:09:39.643');
INSERT INTO links VALUES (570, 'Colleges & Schools', 'http://www.berkeley.edu/academics/school.shtml', '', true, '2013-08-15 23:09:39.674', '2013-08-15 23:09:39.674');
INSERT INTO links VALUES (571, 'Executive Vice Chancellor & Provost', 'http://evcp.chance.berkeley.edu/', '', true, '2013-08-15 23:09:39.707', '2013-08-15 23:09:39.707');
INSERT INTO links VALUES (572, 'Graduate Division', 'http://www.grad.berkeley.edu/', '', true, '2013-08-15 23:09:39.749', '2013-08-15 23:09:39.749');
INSERT INTO links VALUES (573, 'Library', 'http://library.berkeley.edu', 'Search the UC Library system', true, '2013-08-15 23:09:39.814', '2013-08-15 23:09:39.814');
INSERT INTO links VALUES (574, 'Berkeley Research', 'http://vcresearch.berkeley.edu/', '', true, '2013-08-15 23:09:39.868', '2013-08-15 23:09:39.868');
INSERT INTO links VALUES (575, 'Research', 'http://berkeley.edu/research/', 'Directory of UC Berkeley research programs', true, '2013-08-15 23:09:39.901', '2013-08-15 23:09:39.901');
INSERT INTO links VALUES (576, 'bSpace', 'http://bspace.berkeley.edu', 'Homework assignments, lecture slides, syllabi and class resources', true, '2013-08-15 23:09:39.961', '2013-08-15 23:09:39.961');
INSERT INTO links VALUES (577, 'Canvas LMS', 'http://ucberkeley.instructure.com', 'Campus pilot of the Canvas Learning Management System', true, '2013-08-15 23:09:40.005', '2013-08-15 23:09:40.005');
INSERT INTO links VALUES (578, 'DeCal Courses', 'http://www.decal.org/ ', 'Catalog of student-led courses', true, '2013-08-15 23:09:40.041', '2013-08-15 23:09:40.041');
INSERT INTO links VALUES (579, 'Edx Classes at Berkeley', 'https://www.edx.org/university_profile/BerkeleyX', '', true, '2013-08-15 23:09:40.081', '2013-08-15 23:09:40.081');
INSERT INTO links VALUES (580, 'UC Extension Classes', 'http://extension.berkeley.edu/', 'Professional development', true, '2013-08-15 23:09:40.127', '2013-08-15 23:09:40.127');
INSERT INTO links VALUES (582, 'Campus Bookstore', 'http://www.bkstr.com/webapp/wcs/stores/servlet/StoreCatalogDisplay?storeId=10433', 'Text books and more', true, '2013-08-15 23:09:40.196', '2013-08-15 23:09:40.196');
INSERT INTO links VALUES (583, 'iTunesU - Berkeley', 'http://itunes.berkeley.edu', '', true, '2013-08-15 23:09:40.224', '2013-08-15 23:09:40.224');
INSERT INTO links VALUES (584, 'YouTube - UC Berkeley', 'http://www.youtube.com/user/UCBerkeley', '', true, '2013-08-15 23:09:40.257', '2013-08-15 23:09:40.257');
INSERT INTO links VALUES (585, 'Classroom Technology', 'http://ets.berkeley.edu/classroom-technology/', '', true, '2013-08-15 23:09:40.293', '2013-08-15 23:09:40.293');
INSERT INTO links VALUES (586, 'Academic Senate', 'http://academic-senate.berkeley.edu/', '', true, '2013-08-15 23:09:40.331', '2013-08-15 23:09:40.331');
INSERT INTO links VALUES (587, 'Faculty gateway', 'http://berkeley.edu/faculty/', '', true, '2013-08-15 23:09:40.355', '2013-08-15 23:09:40.355');
INSERT INTO links VALUES (588, 'New Faculty resources', 'http://teaching.berkeley.edu/newfaculty.html', '', true, '2013-08-15 23:09:40.376', '2013-08-15 23:09:40.376');
INSERT INTO links VALUES (589, 'Teaching resources', 'http://teaching.berkeley.edu/teaching.html', '', true, '2013-08-15 23:09:40.399', '2013-08-15 23:09:40.399');
INSERT INTO links VALUES (590, 'bSpace Support', 'http://ets.berkeley.edu/bspace', '', true, '2013-08-15 23:09:40.421', '2013-08-15 23:09:40.421');
INSERT INTO links VALUES (591, 'Webcast Support', 'http://ets.berkeley.edu/about-webcastberkeley', '', true, '2013-08-15 23:09:40.443', '2013-08-15 23:09:40.443');
INSERT INTO links VALUES (592, 'Grade book', 'http://gsi.berkeley.edu/teachingguide/tech/bspace-gradebook.html', '', true, '2013-08-15 23:09:40.482', '2013-08-15 23:09:40.482');
INSERT INTO links VALUES (593, 'Environmental Health & Safety', 'http://www.ehs.berkeley.edu/', '', true, '2013-08-15 23:09:40.521', '2013-08-15 23:09:40.521');
INSERT INTO links VALUES (594, 'Lab Safety', 'http://rac.berkeley.edu/compliancebook/labsafety.html', 'Lab Safety & Hazardous Materials Management', true, '2013-08-15 23:09:40.546', '2013-08-15 23:09:40.546');
INSERT INTO links VALUES (595, 'Learning Resources', 'http://hrweb.berkeley.edu/learning', '', true, '2013-08-15 23:09:40.594', '2013-08-15 23:09:40.594');
INSERT INTO links VALUES (596, 'UC Learning Center', 'https://shib.berkeley.edu/idp/profile/Shibboleth/SSO?shire=https://uc.sumtotalsystems.com/Shibboleth.sso/SAML/POST&target=https://uc.sumtotalsystems.com/secure/auth.aspx&providerId=https://uc.sumtotalsystems.com/shibboleth', '', true, '2013-08-15 23:09:40.623', '2013-08-15 23:09:40.623');
INSERT INTO links VALUES (597, 'Administration & Finance', 'http://vcaf.berkeley.edu/divisions', '', true, '2013-08-15 23:09:40.667', '2013-08-15 23:09:40.667');
INSERT INTO links VALUES (598, 'Berkeley Sites (A-Z)', 'http://www.berkeley.edu/a-z/a.shtml', 'Navigating UC Berkeley', true, '2013-08-15 23:09:40.7', '2013-08-15 23:09:40.7');
INSERT INTO links VALUES (599, 'Campus IT Offices', 'http://www.berkeley.edu/admin/compute.shtml#offices', '', true, '2013-08-15 23:09:40.732', '2013-08-15 23:09:40.732');
INSERT INTO links VALUES (600, 'Equity, Inclusion & Diversity', 'http://diversity.berkeley.edu/', '', true, '2013-08-15 23:09:40.764', '2013-08-15 23:09:40.764');
INSERT INTO links VALUES (601, 'Facilities Services', 'http://www.cp.berkeley.edu/', '', true, '2013-08-15 23:09:40.799', '2013-08-15 23:09:40.799');
INSERT INTO links VALUES (602, 'Office of the Chancellor', 'http://chancellor.berkeley.edu/', '', true, '2013-08-15 23:09:40.834', '2013-08-15 23:09:40.834');
INSERT INTO links VALUES (603, 'Student Affairs', 'http://sa.berkeley.edu/', '', true, '2013-08-15 23:09:40.867', '2013-08-15 23:09:40.867');
INSERT INTO links VALUES (604, 'University Relations', 'http://www.urel.berkeley.edu/', '', true, '2013-08-15 23:09:40.901', '2013-08-15 23:09:40.901');
INSERT INTO links VALUES (605, 'Conduct Office', 'http://studentconduct.berkeley.edu', 'Student conduct office', true, '2013-08-15 23:09:40.95', '2013-08-15 23:09:40.95');
INSERT INTO links VALUES (606, 'bConnected Support', 'http://ist.berkeley.edu/bconnected', '', true, '2013-08-15 23:09:40.996', '2013-08-15 23:09:40.996');
INSERT INTO links VALUES (607, 'bCal', 'http://bcal.berkeley.edu', 'personal calandar', true, '2013-08-15 23:09:41.029', '2013-08-15 23:09:41.029');
INSERT INTO links VALUES (608, 'bDrive', 'http://bdrive.berkeley.edu', '', true, '2013-08-15 23:09:41.061', '2013-08-15 23:09:41.061');
INSERT INTO links VALUES (609, 'bMail', 'http://bmail.berkeley.edu', 'email', true, '2013-08-15 23:09:41.093', '2013-08-15 23:09:41.093');
INSERT INTO links VALUES (610, 'CalMail', 'http://calmail.berkeley.edu', 'email', true, '2013-08-15 23:09:41.125', '2013-08-15 23:09:41.125');
INSERT INTO links VALUES (611, 'CalMessages', 'https://calmessages.berkeley.edu/', '', true, '2013-08-15 23:09:41.173', '2013-08-15 23:09:41.173');
INSERT INTO links VALUES (612, 'Box.net', 'https://berkeley.box.com/', '', true, '2013-08-15 23:09:41.194', '2013-08-15 23:09:41.194');
INSERT INTO links VALUES (613, 'CalShare', 'https://calshare.berkeley.edu/', '', true, '2013-08-15 23:09:41.227', '2013-08-15 23:09:41.227');
INSERT INTO links VALUES (614, 'Research Hub', 'https://hub.berkeley.edu', '', true, '2013-08-15 23:09:41.253', '2013-08-15 23:09:41.253');
INSERT INTO links VALUES (615, 'Academic Policies', 'http://catalog.berkeley.edu/policies/', '', true, '2013-08-15 23:09:41.284', '2013-08-15 23:09:41.284');
INSERT INTO links VALUES (616, 'Student Policies & Procedures', 'http://sa.berkeley.edu/sa/student-policies-and-procedures', '', true, '2013-08-15 23:09:41.318', '2013-08-15 23:09:41.318');
INSERT INTO links VALUES (617, 'Computer Use Policy', 'https://security.berkeley.edu/policy/usepolicy.html', '', true, '2013-08-15 23:09:41.35', '2013-08-15 23:09:41.35');
INSERT INTO links VALUES (618, 'Risk Management', 'http://riskservices.berkeley.edu', '', true, '2013-08-15 23:09:41.396', '2013-08-15 23:09:41.396');
INSERT INTO links VALUES (619, 'Ethics & Compliance, Administrative guide', 'http://ethicscompliance.berkeley.edu/index.shtml', '', true, '2013-08-15 23:09:41.466', '2013-08-15 23:09:41.466');
INSERT INTO links VALUES (620, 'Personnel Policies', 'http://hrweb.berkeley.edu/', '', true, '2013-08-15 23:09:41.493', '2013-08-15 23:09:41.493');
INSERT INTO links VALUES (621, 'Campus Shared Services', 'http://sharedservices.berkeley.edu/', '', true, '2013-08-15 23:09:41.53', '2013-08-15 23:09:41.53');
INSERT INTO links VALUES (622, 'Submit a Service Request', 'https://shared-services-help.berkeley.edu/', '', true, '2013-08-15 23:09:41.572', '2013-08-15 23:09:41.572');
INSERT INTO links VALUES (623, 'Cal Answers', 'http://calanswers.berkeley.edu/', '', true, '2013-08-15 23:09:41.613', '2013-08-15 23:09:41.613');
INSERT INTO links VALUES (624, 'BETS - equipment tracking', 'http://bets.berkeley.edu/BETS/home/BetsHome.cfm', '', true, '2013-08-15 23:09:41.654', '2013-08-15 23:09:41.654');
INSERT INTO links VALUES (625, 'Mail Services', 'http://mailservices.berkeley.edu/', '', true, '2013-08-15 23:09:41.689', '2013-08-15 23:09:41.689');
INSERT INTO links VALUES (626, 'General Access Computing Facilities', 'http://ets.berkeley.edu/computer-facilities/general-access', '', true, '2013-08-15 23:09:41.715', '2013-08-15 23:09:41.715');
INSERT INTO links VALUES (627, 'Imagine Services', 'http://imagine.berkeley.edu/', 'custom electronic document workflows', true, '2013-08-15 23:09:41.748', '2013-08-15 23:09:41.748');
INSERT INTO links VALUES (628, 'IST Knowledge Base', 'http://ist.berkeley.edu/support/kb', '', true, '2013-08-15 23:09:41.77', '2013-08-15 23:09:41.77');
INSERT INTO links VALUES (629, 'IST Support', 'http://ist.berkeley.edu/support/', '', true, '2013-08-15 23:09:41.803', '2013-08-15 23:09:41.803');
INSERT INTO links VALUES (630, 'Open Computing Facility', 'http://www.ocf.berkeley.edu/', '', true, '2013-08-15 23:09:41.836', '2013-08-15 23:09:41.836');
INSERT INTO links VALUES (631, 'Software Central', 'http://ist.berkeley.edu/software-central/', '', true, '2013-08-15 23:09:41.867', '2013-08-15 23:09:41.867');
INSERT INTO links VALUES (632, 'BAIRS', 'http://www.bai.berkeley.edu/', '', true, '2013-08-15 23:09:41.907', '2013-08-15 23:09:41.907');
INSERT INTO links VALUES (633, 'BFS', 'http://www.bai.berkeley.edu/', '', true, '2013-08-15 23:09:41.933', '2013-08-15 23:09:41.933');
INSERT INTO links VALUES (634, 'Campus Deposit System', 'https://cdsonline.berkeley.edu', '', true, '2013-08-15 23:09:41.96', '2013-08-15 23:09:41.96');
INSERT INTO links VALUES (635, 'HR Web', 'http://hrweb.berkeley.edu/', '', true, '2013-08-15 23:09:41.995', '2013-08-15 23:09:41.995');
INSERT INTO links VALUES (636, 'HR System', 'http://hrweb.berkeley.edu/hcm', '', true, '2013-08-15 23:09:42.021', '2013-08-15 23:09:42.021');
INSERT INTO links VALUES (637, 'CalTime', 'http://caltime.berkeley.edu', '', true, '2013-08-15 23:09:42.063', '2013-08-15 23:09:42.063');
INSERT INTO links VALUES (638, 'Payroll', 'http://controller.berkeley.edu/payroll/', '', true, '2013-08-15 23:09:42.089', '2013-08-15 23:09:42.089');
INSERT INTO links VALUES (639, 'BearBuy', 'http://www.bai.berkeley.edu/', '', true, '2013-08-15 23:09:42.128', '2013-08-15 23:09:42.128');
INSERT INTO links VALUES (640, 'Blu Card', 'http://businessservices.berkeley.edu/cards/blucard', '', true, '2013-08-15 23:09:42.155', '2013-08-15 23:09:42.155');
INSERT INTO links VALUES (641, 'Purchasing', 'http://businessservices.berkeley.edu/procurement/services', '', true, '2013-08-15 23:09:42.183', '2013-08-15 23:09:42.183');
INSERT INTO links VALUES (642, 'AirBears', 'http://ist.berkeley.edu/airbears/', '', true, '2013-08-15 23:09:42.224', '2013-08-15 23:09:42.224');
INSERT INTO links VALUES (643, 'Cal 1 Card', 'http://services.housing.berkeley.edu/c1c/static/index.htm', 'Identification card for students, staff and faculty', true, '2013-08-15 23:09:42.26', '2013-08-15 23:09:42.26');
INSERT INTO links VALUES (644, 'CalNet', 'https://calnet.berkeley.edu/', '', true, '2013-08-15 23:09:42.297', '2013-08-15 23:09:42.297');
INSERT INTO links VALUES (645, 'SARA - request system access', 'http://www.bai.berkeley.edu/BFS/systems/systemAccess.htm', '', true, '2013-08-15 23:09:42.334', '2013-08-15 23:09:42.334');
INSERT INTO links VALUES (646, 'Blu', 'http://blu.berkeley.edu', '', true, '2013-08-15 23:09:42.376', '2013-08-15 23:09:42.376');
INSERT INTO links VALUES (647, 'Travel & Entertainment', 'http://controller.berkeley.edu/travel/', '', true, '2013-08-15 23:09:42.417', '2013-08-15 23:09:42.417');
INSERT INTO links VALUES (648, 'Campus Directory - People Finder', 'http://directory.berkeley.edu', 'Campus directory of faculty, staff and students', true, '2013-08-15 23:09:42.456', '2013-08-15 23:09:42.456');
INSERT INTO links VALUES (649, 'Campaign for Berkeley', 'http://campaign.berkeley.edu/', '', true, '2013-08-15 23:09:42.501', '2013-08-15 23:09:42.501');
INSERT INTO links VALUES (650, 'Give to Berkeley', 'http://givetocal.berkeley.edu/', '', true, '2013-08-15 23:09:42.532', '2013-08-15 23:09:42.532');
INSERT INTO links VALUES (651, 'Public Service Center', 'http://publicservice.berkeley.edu', 'On and off campus community service engagement', true, '2013-08-15 23:09:42.563', '2013-08-15 23:09:42.563');
INSERT INTO links VALUES (652, 'Newscenter', 'http://newscenter.berkeley.edu', '', true, '2013-08-15 23:09:42.611', '2013-08-15 23:09:42.611');
INSERT INTO links VALUES (653, 'Events.Berkeley', 'http://events.berkeley.edu', 'Campus events calendar', true, '2013-08-15 23:09:42.642', '2013-08-15 23:09:42.642');
INSERT INTO links VALUES (654, 'The Daily Californian (The DailyCal)', 'http://www.dailycal.org/', 'an independent student newspaper', true, '2013-08-15 23:09:42.674', '2013-08-15 23:09:42.674');
INSERT INTO links VALUES (655, 'The Berkeley Blog', 'http://blogs.berkeley.edu', '', true, '2013-08-15 23:09:42.707', '2013-08-15 23:09:42.707');
INSERT INTO links VALUES (656, 'Twitter', 'https://twitter.com/UCBerkeley', '', true, '2013-08-15 23:09:42.755', '2013-08-15 23:09:42.755');
INSERT INTO links VALUES (657, 'UC Berkeley Facebook page', 'http://www.facebook.com/UCBerkeley', '', true, '2013-08-15 23:09:42.786', '2013-08-15 23:09:42.786');
INSERT INTO links VALUES (658, 'Campus Map', 'http://www.berkeley.edu/map/3dmap/3dmap.shtml', 'Locate campus buildings', true, '2013-08-15 23:09:42.824', '2013-08-15 23:09:42.824');
INSERT INTO links VALUES (659, 'Parking & Transportation', 'http://pt.berkeley.edu/', 'Parking lots, transportation, car sharing, etc.', true, '2013-08-15 23:09:42.872', '2013-08-15 23:09:42.872');
INSERT INTO links VALUES (660, 'Campus Shuttles', 'http://pt.berkeley.edu/around/transit/routes/', '', true, '2013-08-15 23:09:42.905', '2013-08-15 23:09:42.905');
INSERT INTO links VALUES (661, '511.org (Bay Area Transportation Planner)', 'http://www.511.org/', '', true, '2013-08-15 23:09:42.955', '2013-08-15 23:09:42.955');
INSERT INTO links VALUES (662, 'Class pass', 'http://pt.berkeley.edu/pay/transit/classpass/', '', true, '2013-08-15 23:09:42.987', '2013-08-15 23:09:42.987');
INSERT INTO links VALUES (663, 'Berkeley Online Tour', 'http://www.berkeley.edu/tour/', '', true, '2013-08-15 23:09:43.023', '2013-08-15 23:09:43.023');
INSERT INTO links VALUES (664, 'Emergency information', 'http://emergency.berkeley.edu/', 'Go-to site for emergency response information', true, '2013-08-15 23:09:43.057', '2013-08-15 23:09:43.057');
INSERT INTO links VALUES (665, 'Police & Safety', 'http://police.berkeley.edu', 'Campus police and safety', true, '2013-08-15 23:09:43.104', '2013-08-15 23:09:43.104');
INSERT INTO links VALUES (666, 'BearWALK Night safety services', 'http://police.berkeley.edu/programsandservices/campus_safety/index.html', '', true, '2013-08-15 23:09:43.151', '2013-08-15 23:09:43.151');
INSERT INTO links VALUES (667, 'Emergency Preparedness', 'http://oep.berkeley.edu/', '', true, '2013-08-15 23:09:43.183', '2013-08-15 23:09:43.183');
INSERT INTO links VALUES (668, 'UC Berkeley museums', 'http://bnhm.berkeley.edu/', '', true, '2013-08-15 23:09:43.222', '2013-08-15 23:09:43.222');
INSERT INTO links VALUES (669, 'Recreational Sports Facility', 'http://recsports.berkeley.edu/ ', 'Sports and fitness programs', true, '2013-08-15 23:09:43.269', '2013-08-15 23:09:43.269');
INSERT INTO links VALUES (670, 'Physical Education Program', 'http://pe.berkeley.edu/', '', true, '2013-08-15 23:09:43.3', '2013-08-15 23:09:43.3');
INSERT INTO links VALUES (671, 'CalBears Intercollegiate Athletics', 'http://www.calbears.com/', '', true, '2013-08-15 23:09:43.336', '2013-08-15 23:09:43.336');
INSERT INTO links VALUES (672, 'Cal Band', 'http://calband.berkeley.edu/', '', true, '2013-08-15 23:09:43.384', '2013-08-15 23:09:43.384');
INSERT INTO links VALUES (673, 'Cal Marketplace', 'http://calmarketplace.berkeley.edu/', 'everything at Cal you may want to buy, discover or visit', true, '2013-08-15 23:09:43.415', '2013-08-15 23:09:43.415');
INSERT INTO links VALUES (674, 'Cal Performances', 'http://www.calperformances.org/', '', true, '2013-08-15 23:09:43.447', '2013-08-15 23:09:43.447');
INSERT INTO links VALUES (675, 'Cal Student Store', 'http://www.bkstr.com/webapp/wcs/stores/servlet/StoreCatalogDisplay?catalogId=10001&langId=-1&demoKey=d&storeId=10433', '', true, '2013-08-15 23:09:43.477', '2013-08-15 23:09:43.477');
INSERT INTO links VALUES (676, 'KALX', 'http://kalx.berkeley.edu/', '90.7 MHz. Berkeley''s campus radio station', true, '2013-08-15 23:09:43.512', '2013-08-15 23:09:43.512');
INSERT INTO links VALUES (677, 'Cal Spirit Groups', 'http://calspirit.berkeley.edu/', '', true, '2013-08-15 23:09:43.559', '2013-08-15 23:09:43.559');
INSERT INTO links VALUES (678, 'ASUC', 'http://asuc.org/', 'Student government', true, '2013-08-15 23:09:43.592', '2013-08-15 23:09:43.592');
INSERT INTO links VALUES (679, 'Graduate Assembly', 'https://ga.berkeley.edu/', 'Graduate student government', true, '2013-08-15 23:09:43.613', '2013-08-15 23:09:43.613');
INSERT INTO links VALUES (680, 'CalGreeks', 'http://www.calgreeks.com/', '', true, '2013-08-15 23:09:43.652', '2013-08-15 23:09:43.652');
INSERT INTO links VALUES (681, 'CalLink (Campus Activities Link)', 'http://callink.berkeley.edu/', 'Official campus student groups', true, '2013-08-15 23:09:43.679', '2013-08-15 23:09:43.679');
INSERT INTO links VALUES (682, 'Student Organizations Search', 'http://students.berkeley.edu/osl/studentgroups/public/index.asp', '', true, '2013-08-15 23:09:43.699', '2013-08-15 23:09:43.699');
INSERT INTO links VALUES (683, 'Student Ombuds', 'http://sa.berkeley.edu/ombuds', 'Confidential help with campus issues, conflict situations, and more', true, '2013-08-15 23:09:43.734', '2013-08-15 23:09:43.734');
INSERT INTO links VALUES (684, 'My Years at Cal', 'http://myyears.berkeley.edu/', '', true, '2013-08-15 23:09:43.756', '2013-08-15 23:09:43.756');
INSERT INTO links VALUES (685, 'New Student Services (includes CalSO)', 'http://nss.berkeley.edu/', '', true, '2013-08-15 23:09:43.777', '2013-08-15 23:09:43.777');
INSERT INTO links VALUES (686, 'Disabled Students Program', 'http://dsp.berkeley.edu/', '', true, '2013-08-15 23:09:43.797', '2013-08-15 23:09:43.797');
INSERT INTO links VALUES (687, 'Transfer, Re-entry and Student Parent Center', 'http://trsp.berkeley.edu/', '', true, '2013-08-15 23:09:43.817', '2013-08-15 23:09:43.817');
INSERT INTO links VALUES (688, 'Resource Guide for Students', 'http://resource.berkeley.edu/', 'Comprehensive campus guide for students', true, '2013-08-15 23:09:43.837', '2013-08-15 23:09:43.837');
INSERT INTO links VALUES (689, 'Career Center', 'http://career.berkeley.edu/', 'Cal jobs, internships & career counseling', true, '2013-08-15 23:09:43.871', '2013-08-15 23:09:43.871');
INSERT INTO links VALUES (690, 'Callisto & CalJobs', 'https://career.berkeley.edu/CareerApps/Callisto/CallistoLogin.aspx', '', true, '2013-08-15 23:09:43.902', '2013-08-15 23:09:43.902');
INSERT INTO links VALUES (691, 'Career Center: Job Search Tools', 'https://career.berkeley.edu/Tools/Tools.stm', '', true, '2013-08-15 23:09:43.923', '2013-08-15 23:09:43.923');
INSERT INTO links VALUES (692, 'Career Center: Internships', 'https://career.berkeley.edu/Internships/Internships.stm', '', true, '2013-08-15 23:09:43.945', '2013-08-15 23:09:43.945');
INSERT INTO links VALUES (693, 'Career Center: Part-time Employment', 'https://career.berkeley.edu/Parttime/Parttime.stm', '', true, '2013-08-15 23:09:43.965', '2013-08-15 23:09:43.965');
INSERT INTO links VALUES (694, 'Work-Study Programs', 'http://students.berkeley.edu/finaid/home/work.htm', '', true, '2013-08-15 23:09:43.999', '2013-08-15 23:09:43.999');
INSERT INTO links VALUES (695, 'Berkeley Jobs', 'http://jobs.berkeley.edu/', 'Employment at Berkeley', true, '2013-08-15 23:09:44.02', '2013-08-15 23:09:44.02');
INSERT INTO links VALUES (696, 'Education loan counseling', 'http://studentbilling.berkeley.edu/exitDirect.htm', '', true, '2013-08-15 23:09:44.06', '2013-08-15 23:09:44.06');
INSERT INTO links VALUES (697, 'FAFSA', 'http://www.fafsa.ed.gov', '', true, '2013-08-15 23:09:44.081', '2013-08-15 23:09:44.081');
INSERT INTO links VALUES (698, 'Financial Aid', 'http://students.berkeley.edu/finaid/', 'Student financial aid options and select scholarships', true, '2013-08-15 23:09:44.115', '2013-08-15 23:09:44.115');
INSERT INTO links VALUES (699, 'Registration Fees', 'http://registrar.berkeley.edu/Registration/feesched.html', '', true, '2013-08-15 23:09:44.138', '2013-08-15 23:09:44.138');
INSERT INTO links VALUES (700, 'Student Budgets', 'http://www.berkeley.edu/about/fact.shtml#fees', '', true, '2013-08-15 23:09:44.159', '2013-08-15 23:09:44.159');
INSERT INTO links VALUES (701, 'Undergrad Financial Facts', 'http://students.berkeley.edu/finaid/undergraduates/FinancialAidFacts2011-12.pdf', '', true, '2013-08-15 23:09:44.18', '2013-08-15 23:09:44.18');
INSERT INTO links VALUES (702, 'Financial Aid Estimator', 'http://calculator.berkeley.edu/', '', true, '2013-08-15 23:09:44.199', '2013-08-15 23:09:44.199');
INSERT INTO links VALUES (703, 'MyFinAid', 'https://myfinaid.berkeley.edu/', '', true, '2013-08-15 23:09:44.219', '2013-08-15 23:09:44.219');


--
-- Name: links_id_seq; Type: SEQUENCE SET; Schema: public; Owner: calcentral
--

SELECT pg_catalog.setval('links_id_seq', 703, true);


--
-- Data for Name: links_user_roles; Type: TABLE DATA; Schema: public; Owner: calcentral
--

INSERT INTO links_user_roles VALUES (528, 1);
INSERT INTO links_user_roles VALUES (529, 1);
INSERT INTO links_user_roles VALUES (530, 1);
INSERT INTO links_user_roles VALUES (531, 1);
INSERT INTO links_user_roles VALUES (532, 1);
INSERT INTO links_user_roles VALUES (533, 1);
INSERT INTO links_user_roles VALUES (533, 3);
INSERT INTO links_user_roles VALUES (533, 2);
INSERT INTO links_user_roles VALUES (534, 1);
INSERT INTO links_user_roles VALUES (534, 3);
INSERT INTO links_user_roles VALUES (534, 2);
INSERT INTO links_user_roles VALUES (535, 1);
INSERT INTO links_user_roles VALUES (536, 1);
INSERT INTO links_user_roles VALUES (537, 1);
INSERT INTO links_user_roles VALUES (538, 1);
INSERT INTO links_user_roles VALUES (539, 1);
INSERT INTO links_user_roles VALUES (539, 3);
INSERT INTO links_user_roles VALUES (539, 2);
INSERT INTO links_user_roles VALUES (540, 3);
INSERT INTO links_user_roles VALUES (540, 2);
INSERT INTO links_user_roles VALUES (541, 3);
INSERT INTO links_user_roles VALUES (541, 2);
INSERT INTO links_user_roles VALUES (542, 3);
INSERT INTO links_user_roles VALUES (542, 2);
INSERT INTO links_user_roles VALUES (543, 3);
INSERT INTO links_user_roles VALUES (543, 2);
INSERT INTO links_user_roles VALUES (544, 3);
INSERT INTO links_user_roles VALUES (544, 2);
INSERT INTO links_user_roles VALUES (545, 3);
INSERT INTO links_user_roles VALUES (545, 2);
INSERT INTO links_user_roles VALUES (546, 1);
INSERT INTO links_user_roles VALUES (546, 3);
INSERT INTO links_user_roles VALUES (546, 2);
INSERT INTO links_user_roles VALUES (547, 1);
INSERT INTO links_user_roles VALUES (548, 1);
INSERT INTO links_user_roles VALUES (549, 3);
INSERT INTO links_user_roles VALUES (549, 2);
INSERT INTO links_user_roles VALUES (550, 2);
INSERT INTO links_user_roles VALUES (551, 1);
INSERT INTO links_user_roles VALUES (552, 1);
INSERT INTO links_user_roles VALUES (552, 3);
INSERT INTO links_user_roles VALUES (552, 2);
INSERT INTO links_user_roles VALUES (553, 1);
INSERT INTO links_user_roles VALUES (553, 3);
INSERT INTO links_user_roles VALUES (553, 2);
INSERT INTO links_user_roles VALUES (554, 1);
INSERT INTO links_user_roles VALUES (554, 3);
INSERT INTO links_user_roles VALUES (554, 2);
INSERT INTO links_user_roles VALUES (555, 1);
INSERT INTO links_user_roles VALUES (555, 3);
INSERT INTO links_user_roles VALUES (555, 2);
INSERT INTO links_user_roles VALUES (556, 1);
INSERT INTO links_user_roles VALUES (556, 3);
INSERT INTO links_user_roles VALUES (556, 2);
INSERT INTO links_user_roles VALUES (557, 1);
INSERT INTO links_user_roles VALUES (557, 3);
INSERT INTO links_user_roles VALUES (557, 2);
INSERT INTO links_user_roles VALUES (558, 1);
INSERT INTO links_user_roles VALUES (558, 3);
INSERT INTO links_user_roles VALUES (558, 2);
INSERT INTO links_user_roles VALUES (559, 1);
INSERT INTO links_user_roles VALUES (559, 3);
INSERT INTO links_user_roles VALUES (559, 2);
INSERT INTO links_user_roles VALUES (560, 1);
INSERT INTO links_user_roles VALUES (560, 3);
INSERT INTO links_user_roles VALUES (560, 2);
INSERT INTO links_user_roles VALUES (561, 1);
INSERT INTO links_user_roles VALUES (562, 1);
INSERT INTO links_user_roles VALUES (563, 1);
INSERT INTO links_user_roles VALUES (563, 3);
INSERT INTO links_user_roles VALUES (563, 2);
INSERT INTO links_user_roles VALUES (564, 1);
INSERT INTO links_user_roles VALUES (565, 1);
INSERT INTO links_user_roles VALUES (566, 1);
INSERT INTO links_user_roles VALUES (567, 1);
INSERT INTO links_user_roles VALUES (568, 1);
INSERT INTO links_user_roles VALUES (569, 1);
INSERT INTO links_user_roles VALUES (569, 3);
INSERT INTO links_user_roles VALUES (569, 2);
INSERT INTO links_user_roles VALUES (570, 1);
INSERT INTO links_user_roles VALUES (570, 3);
INSERT INTO links_user_roles VALUES (570, 2);
INSERT INTO links_user_roles VALUES (571, 1);
INSERT INTO links_user_roles VALUES (571, 3);
INSERT INTO links_user_roles VALUES (571, 2);
INSERT INTO links_user_roles VALUES (572, 1);
INSERT INTO links_user_roles VALUES (572, 3);
INSERT INTO links_user_roles VALUES (572, 2);
INSERT INTO links_user_roles VALUES (573, 1);
INSERT INTO links_user_roles VALUES (573, 3);
INSERT INTO links_user_roles VALUES (573, 2);
INSERT INTO links_user_roles VALUES (574, 1);
INSERT INTO links_user_roles VALUES (574, 3);
INSERT INTO links_user_roles VALUES (574, 2);
INSERT INTO links_user_roles VALUES (575, 1);
INSERT INTO links_user_roles VALUES (575, 3);
INSERT INTO links_user_roles VALUES (575, 2);
INSERT INTO links_user_roles VALUES (576, 1);
INSERT INTO links_user_roles VALUES (576, 3);
INSERT INTO links_user_roles VALUES (576, 2);
INSERT INTO links_user_roles VALUES (577, 1);
INSERT INTO links_user_roles VALUES (577, 3);
INSERT INTO links_user_roles VALUES (577, 2);
INSERT INTO links_user_roles VALUES (578, 1);
INSERT INTO links_user_roles VALUES (578, 3);
INSERT INTO links_user_roles VALUES (578, 2);
INSERT INTO links_user_roles VALUES (579, 1);
INSERT INTO links_user_roles VALUES (579, 3);
INSERT INTO links_user_roles VALUES (579, 2);
INSERT INTO links_user_roles VALUES (580, 1);
INSERT INTO links_user_roles VALUES (580, 3);
INSERT INTO links_user_roles VALUES (580, 2);
INSERT INTO links_user_roles VALUES (582, 1);
INSERT INTO links_user_roles VALUES (582, 3);
INSERT INTO links_user_roles VALUES (583, 1);
INSERT INTO links_user_roles VALUES (583, 3);
INSERT INTO links_user_roles VALUES (583, 2);
INSERT INTO links_user_roles VALUES (584, 1);
INSERT INTO links_user_roles VALUES (585, 3);
INSERT INTO links_user_roles VALUES (586, 3);
INSERT INTO links_user_roles VALUES (587, 3);
INSERT INTO links_user_roles VALUES (588, 3);
INSERT INTO links_user_roles VALUES (589, 3);
INSERT INTO links_user_roles VALUES (590, 3);
INSERT INTO links_user_roles VALUES (591, 3);
INSERT INTO links_user_roles VALUES (592, 3);
INSERT INTO links_user_roles VALUES (593, 1);
INSERT INTO links_user_roles VALUES (594, 1);
INSERT INTO links_user_roles VALUES (594, 3);
INSERT INTO links_user_roles VALUES (594, 2);
INSERT INTO links_user_roles VALUES (595, 3);
INSERT INTO links_user_roles VALUES (595, 2);
INSERT INTO links_user_roles VALUES (596, 3);
INSERT INTO links_user_roles VALUES (596, 2);
INSERT INTO links_user_roles VALUES (597, 1);
INSERT INTO links_user_roles VALUES (597, 3);
INSERT INTO links_user_roles VALUES (597, 2);
INSERT INTO links_user_roles VALUES (598, 1);
INSERT INTO links_user_roles VALUES (598, 3);
INSERT INTO links_user_roles VALUES (598, 2);
INSERT INTO links_user_roles VALUES (599, 1);
INSERT INTO links_user_roles VALUES (599, 3);
INSERT INTO links_user_roles VALUES (599, 2);
INSERT INTO links_user_roles VALUES (600, 1);
INSERT INTO links_user_roles VALUES (600, 3);
INSERT INTO links_user_roles VALUES (600, 2);
INSERT INTO links_user_roles VALUES (601, 1);
INSERT INTO links_user_roles VALUES (601, 3);
INSERT INTO links_user_roles VALUES (601, 2);
INSERT INTO links_user_roles VALUES (602, 1);
INSERT INTO links_user_roles VALUES (602, 3);
INSERT INTO links_user_roles VALUES (602, 2);
INSERT INTO links_user_roles VALUES (603, 1);
INSERT INTO links_user_roles VALUES (603, 3);
INSERT INTO links_user_roles VALUES (603, 2);
INSERT INTO links_user_roles VALUES (604, 1);
INSERT INTO links_user_roles VALUES (604, 3);
INSERT INTO links_user_roles VALUES (604, 2);
INSERT INTO links_user_roles VALUES (605, 1);
INSERT INTO links_user_roles VALUES (605, 3);
INSERT INTO links_user_roles VALUES (605, 2);
INSERT INTO links_user_roles VALUES (606, 1);
INSERT INTO links_user_roles VALUES (606, 3);
INSERT INTO links_user_roles VALUES (606, 2);
INSERT INTO links_user_roles VALUES (607, 1);
INSERT INTO links_user_roles VALUES (607, 3);
INSERT INTO links_user_roles VALUES (607, 2);
INSERT INTO links_user_roles VALUES (608, 1);
INSERT INTO links_user_roles VALUES (608, 3);
INSERT INTO links_user_roles VALUES (608, 2);
INSERT INTO links_user_roles VALUES (609, 1);
INSERT INTO links_user_roles VALUES (609, 3);
INSERT INTO links_user_roles VALUES (609, 2);
INSERT INTO links_user_roles VALUES (610, 1);
INSERT INTO links_user_roles VALUES (610, 3);
INSERT INTO links_user_roles VALUES (610, 2);
INSERT INTO links_user_roles VALUES (611, 2);
INSERT INTO links_user_roles VALUES (612, 1);
INSERT INTO links_user_roles VALUES (612, 3);
INSERT INTO links_user_roles VALUES (612, 2);
INSERT INTO links_user_roles VALUES (613, 3);
INSERT INTO links_user_roles VALUES (613, 2);
INSERT INTO links_user_roles VALUES (614, 1);
INSERT INTO links_user_roles VALUES (614, 3);
INSERT INTO links_user_roles VALUES (614, 2);
INSERT INTO links_user_roles VALUES (615, 1);
INSERT INTO links_user_roles VALUES (615, 3);
INSERT INTO links_user_roles VALUES (615, 2);
INSERT INTO links_user_roles VALUES (616, 1);
INSERT INTO links_user_roles VALUES (616, 3);
INSERT INTO links_user_roles VALUES (616, 2);
INSERT INTO links_user_roles VALUES (617, 1);
INSERT INTO links_user_roles VALUES (617, 3);
INSERT INTO links_user_roles VALUES (617, 2);
INSERT INTO links_user_roles VALUES (618, 3);
INSERT INTO links_user_roles VALUES (618, 2);
INSERT INTO links_user_roles VALUES (619, 3);
INSERT INTO links_user_roles VALUES (619, 2);
INSERT INTO links_user_roles VALUES (620, 3);
INSERT INTO links_user_roles VALUES (620, 2);
INSERT INTO links_user_roles VALUES (621, 3);
INSERT INTO links_user_roles VALUES (621, 2);
INSERT INTO links_user_roles VALUES (622, 3);
INSERT INTO links_user_roles VALUES (622, 2);
INSERT INTO links_user_roles VALUES (623, 3);
INSERT INTO links_user_roles VALUES (623, 2);
INSERT INTO links_user_roles VALUES (624, 2);
INSERT INTO links_user_roles VALUES (625, 3);
INSERT INTO links_user_roles VALUES (625, 2);
INSERT INTO links_user_roles VALUES (626, 1);
INSERT INTO links_user_roles VALUES (626, 3);
INSERT INTO links_user_roles VALUES (626, 2);
INSERT INTO links_user_roles VALUES (627, 2);
INSERT INTO links_user_roles VALUES (628, 1);
INSERT INTO links_user_roles VALUES (628, 3);
INSERT INTO links_user_roles VALUES (628, 2);
INSERT INTO links_user_roles VALUES (629, 1);
INSERT INTO links_user_roles VALUES (629, 3);
INSERT INTO links_user_roles VALUES (629, 2);
INSERT INTO links_user_roles VALUES (630, 1);
INSERT INTO links_user_roles VALUES (630, 3);
INSERT INTO links_user_roles VALUES (630, 2);
INSERT INTO links_user_roles VALUES (631, 3);
INSERT INTO links_user_roles VALUES (631, 2);
INSERT INTO links_user_roles VALUES (632, 3);
INSERT INTO links_user_roles VALUES (632, 2);
INSERT INTO links_user_roles VALUES (633, 3);
INSERT INTO links_user_roles VALUES (633, 2);
INSERT INTO links_user_roles VALUES (634, 2);
INSERT INTO links_user_roles VALUES (635, 3);
INSERT INTO links_user_roles VALUES (635, 2);
INSERT INTO links_user_roles VALUES (636, 3);
INSERT INTO links_user_roles VALUES (636, 2);
INSERT INTO links_user_roles VALUES (637, 3);
INSERT INTO links_user_roles VALUES (637, 2);
INSERT INTO links_user_roles VALUES (638, 3);
INSERT INTO links_user_roles VALUES (638, 2);
INSERT INTO links_user_roles VALUES (639, 3);
INSERT INTO links_user_roles VALUES (639, 2);
INSERT INTO links_user_roles VALUES (640, 3);
INSERT INTO links_user_roles VALUES (640, 2);
INSERT INTO links_user_roles VALUES (641, 3);
INSERT INTO links_user_roles VALUES (641, 2);
INSERT INTO links_user_roles VALUES (642, 1);
INSERT INTO links_user_roles VALUES (642, 3);
INSERT INTO links_user_roles VALUES (642, 2);
INSERT INTO links_user_roles VALUES (643, 1);
INSERT INTO links_user_roles VALUES (643, 3);
INSERT INTO links_user_roles VALUES (643, 2);
INSERT INTO links_user_roles VALUES (644, 1);
INSERT INTO links_user_roles VALUES (644, 3);
INSERT INTO links_user_roles VALUES (644, 2);
INSERT INTO links_user_roles VALUES (645, 3);
INSERT INTO links_user_roles VALUES (645, 2);
INSERT INTO links_user_roles VALUES (646, 3);
INSERT INTO links_user_roles VALUES (646, 2);
INSERT INTO links_user_roles VALUES (647, 3);
INSERT INTO links_user_roles VALUES (647, 2);
INSERT INTO links_user_roles VALUES (648, 1);
INSERT INTO links_user_roles VALUES (648, 3);
INSERT INTO links_user_roles VALUES (648, 2);
INSERT INTO links_user_roles VALUES (649, 1);
INSERT INTO links_user_roles VALUES (649, 3);
INSERT INTO links_user_roles VALUES (649, 2);
INSERT INTO links_user_roles VALUES (650, 1);
INSERT INTO links_user_roles VALUES (650, 3);
INSERT INTO links_user_roles VALUES (650, 2);
INSERT INTO links_user_roles VALUES (651, 1);
INSERT INTO links_user_roles VALUES (651, 3);
INSERT INTO links_user_roles VALUES (651, 2);
INSERT INTO links_user_roles VALUES (652, 1);
INSERT INTO links_user_roles VALUES (652, 3);
INSERT INTO links_user_roles VALUES (652, 2);
INSERT INTO links_user_roles VALUES (653, 1);
INSERT INTO links_user_roles VALUES (653, 3);
INSERT INTO links_user_roles VALUES (653, 2);
INSERT INTO links_user_roles VALUES (654, 1);
INSERT INTO links_user_roles VALUES (654, 3);
INSERT INTO links_user_roles VALUES (654, 2);
INSERT INTO links_user_roles VALUES (655, 1);
INSERT INTO links_user_roles VALUES (655, 3);
INSERT INTO links_user_roles VALUES (655, 2);
INSERT INTO links_user_roles VALUES (656, 1);
INSERT INTO links_user_roles VALUES (656, 3);
INSERT INTO links_user_roles VALUES (656, 2);
INSERT INTO links_user_roles VALUES (657, 1);
INSERT INTO links_user_roles VALUES (658, 1);
INSERT INTO links_user_roles VALUES (658, 3);
INSERT INTO links_user_roles VALUES (658, 2);
INSERT INTO links_user_roles VALUES (659, 1);
INSERT INTO links_user_roles VALUES (659, 3);
INSERT INTO links_user_roles VALUES (659, 2);
INSERT INTO links_user_roles VALUES (660, 1);
INSERT INTO links_user_roles VALUES (660, 3);
INSERT INTO links_user_roles VALUES (660, 2);
INSERT INTO links_user_roles VALUES (661, 1);
INSERT INTO links_user_roles VALUES (661, 3);
INSERT INTO links_user_roles VALUES (661, 2);
INSERT INTO links_user_roles VALUES (662, 1);
INSERT INTO links_user_roles VALUES (663, 1);
INSERT INTO links_user_roles VALUES (663, 3);
INSERT INTO links_user_roles VALUES (663, 2);
INSERT INTO links_user_roles VALUES (664, 1);
INSERT INTO links_user_roles VALUES (664, 3);
INSERT INTO links_user_roles VALUES (664, 2);
INSERT INTO links_user_roles VALUES (665, 1);
INSERT INTO links_user_roles VALUES (665, 3);
INSERT INTO links_user_roles VALUES (665, 2);
INSERT INTO links_user_roles VALUES (666, 1);
INSERT INTO links_user_roles VALUES (666, 3);
INSERT INTO links_user_roles VALUES (666, 2);
INSERT INTO links_user_roles VALUES (667, 1);
INSERT INTO links_user_roles VALUES (667, 3);
INSERT INTO links_user_roles VALUES (667, 2);
INSERT INTO links_user_roles VALUES (668, 1);
INSERT INTO links_user_roles VALUES (668, 3);
INSERT INTO links_user_roles VALUES (668, 2);
INSERT INTO links_user_roles VALUES (669, 1);
INSERT INTO links_user_roles VALUES (669, 3);
INSERT INTO links_user_roles VALUES (669, 2);
INSERT INTO links_user_roles VALUES (670, 1);
INSERT INTO links_user_roles VALUES (671, 1);
INSERT INTO links_user_roles VALUES (671, 3);
INSERT INTO links_user_roles VALUES (671, 2);
INSERT INTO links_user_roles VALUES (672, 1);
INSERT INTO links_user_roles VALUES (672, 3);
INSERT INTO links_user_roles VALUES (672, 2);
INSERT INTO links_user_roles VALUES (673, 1);
INSERT INTO links_user_roles VALUES (673, 3);
INSERT INTO links_user_roles VALUES (673, 2);
INSERT INTO links_user_roles VALUES (674, 1);
INSERT INTO links_user_roles VALUES (674, 3);
INSERT INTO links_user_roles VALUES (674, 2);
INSERT INTO links_user_roles VALUES (675, 1);
INSERT INTO links_user_roles VALUES (675, 3);
INSERT INTO links_user_roles VALUES (675, 2);
INSERT INTO links_user_roles VALUES (676, 1);
INSERT INTO links_user_roles VALUES (676, 3);
INSERT INTO links_user_roles VALUES (676, 2);
INSERT INTO links_user_roles VALUES (677, 1);
INSERT INTO links_user_roles VALUES (678, 1);
INSERT INTO links_user_roles VALUES (679, 1);
INSERT INTO links_user_roles VALUES (680, 1);
INSERT INTO links_user_roles VALUES (681, 1);
INSERT INTO links_user_roles VALUES (682, 1);
INSERT INTO links_user_roles VALUES (683, 1);
INSERT INTO links_user_roles VALUES (684, 1);
INSERT INTO links_user_roles VALUES (685, 1);
INSERT INTO links_user_roles VALUES (686, 1);
INSERT INTO links_user_roles VALUES (687, 1);
INSERT INTO links_user_roles VALUES (688, 1);
INSERT INTO links_user_roles VALUES (689, 1);
INSERT INTO links_user_roles VALUES (689, 3);
INSERT INTO links_user_roles VALUES (689, 2);
INSERT INTO links_user_roles VALUES (690, 1);
INSERT INTO links_user_roles VALUES (691, 1);
INSERT INTO links_user_roles VALUES (692, 1);
INSERT INTO links_user_roles VALUES (693, 1);
INSERT INTO links_user_roles VALUES (694, 1);
INSERT INTO links_user_roles VALUES (695, 3);
INSERT INTO links_user_roles VALUES (695, 2);
INSERT INTO links_user_roles VALUES (696, 1);
INSERT INTO links_user_roles VALUES (697, 1);
INSERT INTO links_user_roles VALUES (698, 1);
INSERT INTO links_user_roles VALUES (699, 1);
INSERT INTO links_user_roles VALUES (700, 1);
INSERT INTO links_user_roles VALUES (701, 1);
INSERT INTO links_user_roles VALUES (702, 1);
INSERT INTO links_user_roles VALUES (703, 1);


--
-- Data for Name: user_auths; Type: TABLE DATA; Schema: public; Owner: calcentral
--

INSERT INTO user_auths VALUES (2, '323487', true, false, true, '2013-03-04 17:06:18.281', '2013-03-04 17:06:18.281', false, false);
INSERT INTO user_auths VALUES (3, '191779', true, false, true, '2013-03-04 17:06:18.288', '2013-03-04 17:06:18.288', false, false);
INSERT INTO user_auths VALUES (4, '238382', true, false, true, '2013-03-04 17:06:18.296', '2013-03-04 17:06:18.296', false, false);
INSERT INTO user_auths VALUES (5, '208861', true, false, true, '2013-03-04 17:06:18.304', '2013-03-04 17:06:18.304', false, false);
INSERT INTO user_auths VALUES (6, '675750', true, false, true, '2013-03-04 17:06:18.312', '2013-03-04 17:06:18.312', false, false);
INSERT INTO user_auths VALUES (8, '2040', true, false, true, '2013-03-04 17:06:18.328', '2013-03-04 17:06:18.328', false, false);
INSERT INTO user_auths VALUES (9, '904715', true, false, true, '2013-03-04 17:06:18.335', '2013-03-04 17:06:18.335', false, false);
INSERT INTO user_auths VALUES (10, '211159', true, false, true, '2013-03-04 17:06:18.343', '2013-03-04 17:06:18.343', false, false);
INSERT INTO user_auths VALUES (11, '978966', true, false, true, '2013-03-04 17:06:18.353', '2013-03-04 17:06:18.353', false, false);
INSERT INTO user_auths VALUES (12, '11002820', false, true, true, '2013-03-04 17:06:18.365', '2013-03-04 17:06:18.365', false, false);
INSERT INTO user_auths VALUES (13, '61889', false, true, true, '2013-03-04 17:06:18.372', '2013-03-04 17:06:18.372', false, false);
INSERT INTO user_auths VALUES (14, '321765', false, true, true, '2013-03-04 17:06:18.39', '2013-03-04 17:06:18.39', false, false);
INSERT INTO user_auths VALUES (15, '321703', false, true, true, '2013-03-04 17:06:18.401', '2013-03-04 17:06:18.401', false, false);
INSERT INTO user_auths VALUES (16, '324731', false, true, true, '2013-03-04 17:06:18.408', '2013-03-04 17:06:18.408', false, false);
INSERT INTO user_auths VALUES (17, '212388', false, true, true, '2013-03-04 17:06:18.414', '2013-03-04 17:06:18.414', false, false);
INSERT INTO user_auths VALUES (18, '212387', false, true, true, '2013-03-04 17:06:18.421', '2013-03-04 17:06:18.421', false, false);
INSERT INTO user_auths VALUES (19, '212372', false, true, true, '2013-03-04 17:06:18.428', '2013-03-04 17:06:18.428', false, false);
INSERT INTO user_auths VALUES (20, '212373', false, true, true, '2013-03-04 17:06:18.434', '2013-03-04 17:06:18.434', false, false);
INSERT INTO user_auths VALUES (21, '212374', false, true, true, '2013-03-04 17:06:18.441', '2013-03-04 17:06:18.441', false, false);
INSERT INTO user_auths VALUES (22, '212375', false, true, true, '2013-03-04 17:06:18.447', '2013-03-04 17:06:18.447', false, false);
INSERT INTO user_auths VALUES (23, '212376', false, true, true, '2013-03-04 17:06:18.463', '2013-03-04 17:06:18.463', false, false);
INSERT INTO user_auths VALUES (24, '212377', false, true, true, '2013-03-04 17:06:18.476', '2013-03-04 17:06:18.476', false, false);
INSERT INTO user_auths VALUES (25, '212378', false, true, true, '2013-03-04 17:06:18.483', '2013-03-04 17:06:18.483', false, false);
INSERT INTO user_auths VALUES (26, '212379', false, true, true, '2013-03-04 17:06:18.509', '2013-03-04 17:06:18.509', false, false);
INSERT INTO user_auths VALUES (27, '212380', false, true, true, '2013-03-04 17:06:18.519', '2013-03-04 17:06:18.519', false, false);
INSERT INTO user_auths VALUES (28, '212381', false, true, true, '2013-03-04 17:06:18.526', '2013-03-04 17:06:18.526', false, false);
INSERT INTO user_auths VALUES (29, '300846', false, true, true, '2013-03-04 17:06:18.534', '2013-03-04 17:06:18.534', false, false);
INSERT INTO user_auths VALUES (30, '300847', false, true, true, '2013-03-04 17:06:18.541', '2013-03-04 17:06:18.541', false, false);
INSERT INTO user_auths VALUES (31, '300848', false, true, true, '2013-03-04 17:06:18.547', '2013-03-04 17:06:18.547', false, false);
INSERT INTO user_auths VALUES (32, '300849', false, true, true, '2013-03-04 17:06:18.556', '2013-03-04 17:06:18.556', false, false);
INSERT INTO user_auths VALUES (33, '300850', false, true, true, '2013-03-04 17:06:18.567', '2013-03-04 17:06:18.567', false, false);
INSERT INTO user_auths VALUES (34, '300851', false, true, true, '2013-03-04 17:06:18.581', '2013-03-04 17:06:18.581', false, false);
INSERT INTO user_auths VALUES (35, '300852', false, true, true, '2013-03-04 17:06:18.589', '2013-03-04 17:06:18.589', false, false);
INSERT INTO user_auths VALUES (36, '300853', false, true, true, '2013-03-04 17:06:18.599', '2013-03-04 17:06:18.599', false, false);
INSERT INTO user_auths VALUES (37, '300854', false, true, true, '2013-03-04 17:06:18.606', '2013-03-04 17:06:18.606', false, false);
INSERT INTO user_auths VALUES (38, '300855', false, true, true, '2013-03-04 17:06:18.614', '2013-03-04 17:06:18.614', false, false);
INSERT INTO user_auths VALUES (39, '300856', false, true, true, '2013-03-04 17:06:18.621', '2013-03-04 17:06:18.621', false, false);
INSERT INTO user_auths VALUES (40, '300857', false, true, true, '2013-03-04 17:06:18.629', '2013-03-04 17:06:18.629', false, false);
INSERT INTO user_auths VALUES (41, '300858', false, true, true, '2013-03-04 17:06:18.636', '2013-03-04 17:06:18.636', false, false);
INSERT INTO user_auths VALUES (42, '300859', false, true, true, '2013-03-04 17:06:18.644', '2013-03-04 17:06:18.644', false, false);
INSERT INTO user_auths VALUES (43, '300860', false, true, true, '2013-03-04 17:06:18.65', '2013-03-04 17:06:18.65', false, false);
INSERT INTO user_auths VALUES (44, '300861', false, true, true, '2013-03-04 17:06:18.657', '2013-03-04 17:06:18.657', false, false);
INSERT INTO user_auths VALUES (45, '300862', false, true, true, '2013-03-04 17:06:18.67', '2013-03-04 17:06:18.67', false, false);
INSERT INTO user_auths VALUES (46, '300863', false, true, true, '2013-03-04 17:06:18.679', '2013-03-04 17:06:18.679', false, false);
INSERT INTO user_auths VALUES (47, '300864', false, true, true, '2013-03-04 17:06:18.685', '2013-03-04 17:06:18.685', false, false);
INSERT INTO user_auths VALUES (48, '300865', false, true, true, '2013-03-04 17:06:18.692', '2013-03-04 17:06:18.692', false, false);
INSERT INTO user_auths VALUES (49, '300866', false, true, true, '2013-03-04 17:06:18.698', '2013-03-04 17:06:18.698', false, false);
INSERT INTO user_auths VALUES (50, '300867', false, true, true, '2013-03-04 17:06:18.704', '2013-03-04 17:06:18.704', false, false);
INSERT INTO user_auths VALUES (51, '300868', false, true, true, '2013-03-04 17:06:18.711', '2013-03-04 17:06:18.711', false, false);
INSERT INTO user_auths VALUES (52, '300869', false, true, true, '2013-03-04 17:06:18.717', '2013-03-04 17:06:18.717', false, false);
INSERT INTO user_auths VALUES (53, '300870', false, true, true, '2013-03-04 17:06:18.723', '2013-03-04 17:06:18.723', false, false);
INSERT INTO user_auths VALUES (54, '300871', false, true, true, '2013-03-04 17:06:18.731', '2013-03-04 17:06:18.731', false, false);
INSERT INTO user_auths VALUES (55, '300872', false, true, true, '2013-03-04 17:06:18.737', '2013-03-04 17:06:18.737', false, false);
INSERT INTO user_auths VALUES (56, '300873', false, true, true, '2013-03-04 17:06:18.745', '2013-03-04 17:06:18.745', false, false);
INSERT INTO user_auths VALUES (57, '300874', false, true, true, '2013-03-04 17:06:18.756', '2013-03-04 17:06:18.756', false, false);
INSERT INTO user_auths VALUES (58, '300875', false, true, true, '2013-03-04 17:06:18.774', '2013-03-04 17:06:18.774', false, false);
INSERT INTO user_auths VALUES (59, '300876', false, true, true, '2013-03-04 17:06:18.782', '2013-03-04 17:06:18.782', false, false);
INSERT INTO user_auths VALUES (60, '300877', false, true, true, '2013-03-04 17:06:18.789', '2013-03-04 17:06:18.789', false, false);
INSERT INTO user_auths VALUES (61, '300878', false, true, true, '2013-03-04 17:06:18.807', '2013-03-04 17:06:18.807', false, false);
INSERT INTO user_auths VALUES (62, '300879', false, true, true, '2013-03-04 17:06:18.817', '2013-03-04 17:06:18.817', false, false);
INSERT INTO user_auths VALUES (63, '300880', false, true, true, '2013-03-04 17:06:18.825', '2013-03-04 17:06:18.825', false, false);
INSERT INTO user_auths VALUES (64, '300881', false, true, true, '2013-03-04 17:06:18.836', '2013-03-04 17:06:18.836', false, false);
INSERT INTO user_auths VALUES (65, '300882', false, true, true, '2013-03-04 17:06:18.844', '2013-03-04 17:06:18.844', false, false);
INSERT INTO user_auths VALUES (66, '300883', false, true, true, '2013-03-04 17:06:18.851', '2013-03-04 17:06:18.851', false, false);
INSERT INTO user_auths VALUES (67, '300884', false, true, true, '2013-03-04 17:06:18.859', '2013-03-04 17:06:18.859', false, false);
INSERT INTO user_auths VALUES (68, '300885', false, true, true, '2013-03-04 17:06:18.868', '2013-03-04 17:06:18.868', false, false);
INSERT INTO user_auths VALUES (69, '300886', false, true, true, '2013-03-04 17:06:18.874', '2013-03-04 17:06:18.874', false, false);
INSERT INTO user_auths VALUES (70, '300887', false, true, true, '2013-03-04 17:06:18.886', '2013-03-04 17:06:18.886', false, false);
INSERT INTO user_auths VALUES (71, '300888', false, true, true, '2013-03-04 17:06:18.893', '2013-03-04 17:06:18.893', false, false);
INSERT INTO user_auths VALUES (72, '300889', false, true, true, '2013-03-04 17:06:18.9', '2013-03-04 17:06:18.9', false, false);
INSERT INTO user_auths VALUES (73, '300890', false, true, true, '2013-03-04 17:06:18.906', '2013-03-04 17:06:18.906', false, false);
INSERT INTO user_auths VALUES (74, '300891', false, true, true, '2013-03-04 17:06:18.913', '2013-03-04 17:06:18.913', false, false);
INSERT INTO user_auths VALUES (75, '300892', false, true, true, '2013-03-04 17:06:18.919', '2013-03-04 17:06:18.919', false, false);
INSERT INTO user_auths VALUES (76, '300893', false, true, true, '2013-03-04 17:06:18.926', '2013-03-04 17:06:18.926', false, false);
INSERT INTO user_auths VALUES (77, '300894', false, true, true, '2013-03-04 17:06:18.932', '2013-03-04 17:06:18.932', false, false);
INSERT INTO user_auths VALUES (78, '300895', false, true, true, '2013-03-04 17:06:18.948', '2013-03-04 17:06:18.948', false, false);
INSERT INTO user_auths VALUES (79, '300896', false, true, true, '2013-03-04 17:06:18.955', '2013-03-04 17:06:18.955', false, false);
INSERT INTO user_auths VALUES (80, '300897', false, true, true, '2013-03-04 17:06:18.97', '2013-03-04 17:06:18.97', false, false);
INSERT INTO user_auths VALUES (81, '300898', false, true, true, '2013-03-04 17:06:18.976', '2013-03-04 17:06:18.976', false, false);
INSERT INTO user_auths VALUES (82, '300899', false, true, true, '2013-03-04 17:06:19.02', '2013-03-04 17:06:19.02', false, false);
INSERT INTO user_auths VALUES (83, '300900', false, true, true, '2013-03-04 17:06:19.026', '2013-03-04 17:06:19.026', false, false);
INSERT INTO user_auths VALUES (84, '300901', false, true, true, '2013-03-04 17:06:19.032', '2013-03-04 17:06:19.032', false, false);
INSERT INTO user_auths VALUES (85, '300902', false, true, true, '2013-03-04 17:06:19.039', '2013-03-04 17:06:19.039', false, false);
INSERT INTO user_auths VALUES (86, '300903', false, true, true, '2013-03-04 17:06:19.045', '2013-03-04 17:06:19.045', false, false);
INSERT INTO user_auths VALUES (87, '300904', false, true, true, '2013-03-04 17:06:19.051', '2013-03-04 17:06:19.051', false, false);
INSERT INTO user_auths VALUES (88, '300905', false, true, true, '2013-03-04 17:06:19.058', '2013-03-04 17:06:19.058', false, false);
INSERT INTO user_auths VALUES (89, '300906', false, true, true, '2013-03-04 17:06:19.065', '2013-03-04 17:06:19.065', false, false);
INSERT INTO user_auths VALUES (90, '300907', false, true, true, '2013-03-04 17:06:19.073', '2013-03-04 17:06:19.073', false, false);
INSERT INTO user_auths VALUES (91, '300908', false, true, true, '2013-03-04 17:06:19.091', '2013-03-04 17:06:19.091', false, false);
INSERT INTO user_auths VALUES (92, '300909', false, true, true, '2013-03-04 17:06:19.099', '2013-03-04 17:06:19.099', false, false);
INSERT INTO user_auths VALUES (93, '300910', false, true, true, '2013-03-04 17:06:19.108', '2013-03-04 17:06:19.108', false, false);
INSERT INTO user_auths VALUES (94, '300911', false, true, true, '2013-03-04 17:06:19.114', '2013-03-04 17:06:19.114', false, false);
INSERT INTO user_auths VALUES (95, '300912', false, true, true, '2013-03-04 17:06:19.122', '2013-03-04 17:06:19.122', false, false);
INSERT INTO user_auths VALUES (96, '300913', false, true, true, '2013-03-04 17:06:19.131', '2013-03-04 17:06:19.131', false, false);
INSERT INTO user_auths VALUES (97, '300914', false, true, true, '2013-03-04 17:06:19.139', '2013-03-04 17:06:19.139', false, false);
INSERT INTO user_auths VALUES (98, '300915', false, true, true, '2013-03-04 17:06:19.145', '2013-03-04 17:06:19.145', false, false);
INSERT INTO user_auths VALUES (99, '300916', false, true, true, '2013-03-04 17:06:19.151', '2013-03-04 17:06:19.151', false, false);
INSERT INTO user_auths VALUES (100, '300917', false, true, true, '2013-03-04 17:06:19.166', '2013-03-04 17:06:19.166', false, false);
INSERT INTO user_auths VALUES (101, '300918', false, true, true, '2013-03-04 17:06:19.18', '2013-03-04 17:06:19.18', false, false);
INSERT INTO user_auths VALUES (102, '300919', false, true, true, '2013-03-04 17:06:19.187', '2013-03-04 17:06:19.187', false, false);
INSERT INTO user_auths VALUES (103, '300920', false, true, true, '2013-03-04 17:06:19.198', '2013-03-04 17:06:19.198', false, false);
INSERT INTO user_auths VALUES (104, '300921', false, true, true, '2013-03-04 17:06:19.206', '2013-03-04 17:06:19.206', false, false);
INSERT INTO user_auths VALUES (105, '300922', false, true, true, '2013-03-04 17:06:19.212', '2013-03-04 17:06:19.212', false, false);
INSERT INTO user_auths VALUES (106, '300923', false, true, true, '2013-03-04 17:06:19.218', '2013-03-04 17:06:19.218', false, false);
INSERT INTO user_auths VALUES (107, '300924', false, true, true, '2013-03-04 17:06:19.225', '2013-03-04 17:06:19.225', false, false);
INSERT INTO user_auths VALUES (108, '300925', false, true, true, '2013-03-04 17:06:19.231', '2013-03-04 17:06:19.231', false, false);
INSERT INTO user_auths VALUES (109, '300926', false, true, true, '2013-03-04 17:06:19.236', '2013-03-04 17:06:19.236', false, false);
INSERT INTO user_auths VALUES (110, '300927', false, true, true, '2013-03-04 17:06:19.243', '2013-03-04 17:06:19.243', false, false);
INSERT INTO user_auths VALUES (111, '300928', false, true, true, '2013-03-04 17:06:19.248', '2013-03-04 17:06:19.248', false, false);
INSERT INTO user_auths VALUES (112, '300929', false, true, true, '2013-03-04 17:06:19.256', '2013-03-04 17:06:19.256', false, false);
INSERT INTO user_auths VALUES (113, '300930', false, true, true, '2013-03-04 17:06:19.262', '2013-03-04 17:06:19.262', false, false);
INSERT INTO user_auths VALUES (114, '300931', false, true, true, '2013-03-04 17:06:19.27', '2013-03-04 17:06:19.27', false, false);
INSERT INTO user_auths VALUES (115, '300932', false, true, true, '2013-03-04 17:06:19.277', '2013-03-04 17:06:19.277', false, false);
INSERT INTO user_auths VALUES (116, '300933', false, true, true, '2013-03-04 17:06:19.285', '2013-03-04 17:06:19.285', false, false);
INSERT INTO user_auths VALUES (117, '300934', false, true, true, '2013-03-04 17:06:19.292', '2013-03-04 17:06:19.292', false, false);
INSERT INTO user_auths VALUES (118, '300935', false, true, true, '2013-03-04 17:06:19.299', '2013-03-04 17:06:19.299', false, false);
INSERT INTO user_auths VALUES (119, '300936', false, true, true, '2013-03-04 17:06:19.306', '2013-03-04 17:06:19.306', false, false);
INSERT INTO user_auths VALUES (120, '300937', false, true, true, '2013-03-04 17:06:19.314', '2013-03-04 17:06:19.314', false, false);
INSERT INTO user_auths VALUES (121, '300938', false, true, true, '2013-03-04 17:06:19.321', '2013-03-04 17:06:19.321', false, false);
INSERT INTO user_auths VALUES (122, '300939', false, true, true, '2013-03-04 17:06:19.339', '2013-03-04 17:06:19.339', false, false);
INSERT INTO user_auths VALUES (123, '300940', false, true, true, '2013-03-04 17:06:19.352', '2013-03-04 17:06:19.352', false, false);
INSERT INTO user_auths VALUES (124, '300941', false, true, true, '2013-03-04 17:06:19.363', '2013-03-04 17:06:19.363', false, false);
INSERT INTO user_auths VALUES (125, '300942', false, true, true, '2013-03-04 17:06:19.375', '2013-03-04 17:06:19.375', false, false);
INSERT INTO user_auths VALUES (126, '300943', false, true, true, '2013-03-04 17:06:19.386', '2013-03-04 17:06:19.386', false, false);
INSERT INTO user_auths VALUES (127, '300944', false, true, true, '2013-03-04 17:06:19.394', '2013-03-04 17:06:19.394', false, false);
INSERT INTO user_auths VALUES (128, '300945', false, true, true, '2013-03-04 17:06:19.402', '2013-03-04 17:06:19.402', false, false);
INSERT INTO user_auths VALUES (129, '212382', false, true, true, '2013-03-04 17:06:19.408', '2013-03-04 17:06:19.408', false, false);
INSERT INTO user_auths VALUES (130, '212383', false, true, true, '2013-03-04 17:06:19.415', '2013-03-04 17:06:19.415', false, false);
INSERT INTO user_auths VALUES (131, '212384', false, true, true, '2013-03-04 17:06:19.422', '2013-03-04 17:06:19.422', false, false);
INSERT INTO user_auths VALUES (132, '212385', false, true, true, '2013-03-04 17:06:19.429', '2013-03-04 17:06:19.429', false, false);
INSERT INTO user_auths VALUES (133, '212386', false, true, true, '2013-03-04 17:06:19.436', '2013-03-04 17:06:19.436', false, false);
INSERT INTO user_auths VALUES (134, '322587', false, true, true, '2013-03-04 17:06:19.444', '2013-03-04 17:06:19.444', false, false);
INSERT INTO user_auths VALUES (135, '322588', false, true, true, '2013-03-04 17:06:19.452', '2013-03-04 17:06:19.452', false, false);
INSERT INTO user_auths VALUES (136, '322589', false, true, true, '2013-03-04 17:06:19.459', '2013-03-04 17:06:19.459', false, false);
INSERT INTO user_auths VALUES (137, '322590', false, true, true, '2013-03-04 17:06:19.469', '2013-03-04 17:06:19.469', false, false);
INSERT INTO user_auths VALUES (138, '322583', false, true, true, '2013-03-04 17:06:19.476', '2013-03-04 17:06:19.476', false, false);
INSERT INTO user_auths VALUES (139, '322584', false, true, true, '2013-03-04 17:06:19.483', '2013-03-04 17:06:19.483', false, false);
INSERT INTO user_auths VALUES (140, '322585', false, true, true, '2013-03-04 17:06:19.489', '2013-03-04 17:06:19.489', false, false);
INSERT INTO user_auths VALUES (141, '322586', false, true, true, '2013-03-04 17:06:19.558', '2013-03-04 17:06:19.558', false, false);
INSERT INTO user_auths VALUES (7, '322279', true, false, true, '2013-03-04 17:06:18.32', '2013-03-04 17:06:21.74', false, false);
INSERT INTO user_auths VALUES (142, '12492', true, false, true, '2013-06-24 13:34:20.219', '2013-06-24 13:34:20.219', false, false);
INSERT INTO user_auths VALUES (143, '53791', true, false, true, '2013-08-15 23:09:30.345', '2013-08-15 23:09:30.345', false, false);
INSERT INTO user_auths VALUES (144, '163093', true, false, true, '2013-09-16 17:34:22.616', '2013-09-16 17:34:22.616', false, false);
INSERT INTO user_auths VALUES (145, '1049291', true, false, true, '2013-09-16 17:35:01.896', '2013-09-16 17:35:01.896', false, false);
INSERT INTO user_auths VALUES (146, '177473', true, false, true, '2013-09-16 17:35:47.59', '2013-09-16 17:35:47.59', false, false);
INSERT INTO user_auths VALUES (147, '95509', true, false, true, '2013-09-16 17:35:58.498', '2013-09-16 17:35:58.498', false, false);
INSERT INTO user_auths VALUES (148, '160965', true, false, true, '2013-09-17 20:27:15.383', '2013-09-17 20:27:15.383', false, false);
INSERT INTO user_auths VALUES (149, '988628', false, false, true, '2013-09-19 18:10:14.663', '2013-09-19 18:10:14.663', false, false);
INSERT INTO user_auths VALUES (152, '162721', true, false, true, '2013-10-01 23:58:44.14', '2013-10-01 23:58:44.14', false, false);
INSERT INTO user_auths VALUES (153, '19609', true, false, true, '2013-10-01 23:59:42.527', '2013-10-01 23:59:42.527', false, false);
INSERT INTO user_auths VALUES (154, '975226', true, false, true, '2013-10-02 00:00:05.933', '2013-10-02 00:00:05.933', false, false);


--
-- Name: user_auths_id_seq; Type: SEQUENCE SET; Schema: public; Owner: calcentral
--

SELECT pg_catalog.setval('user_auths_id_seq', 154, true);


--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: calcentral
--

INSERT INTO user_roles VALUES (1, 'Student', 'student');
INSERT INTO user_roles VALUES (2, 'Staff', 'staff');
INSERT INTO user_roles VALUES (3, 'Faculty', 'faculty');


--
-- Name: user_roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: calcentral
--

SELECT pg_catalog.setval('user_roles_id_seq', 3, true);


--
-- Name: fin_aid_years_pkey; Type: CONSTRAINT; Schema: public; Owner: calcentral_development; Tablespace:
--

ALTER TABLE ONLY fin_aid_years
    ADD CONSTRAINT fin_aid_years_pkey PRIMARY KEY (id);


--
-- Name: link_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: calcentral; Tablespace:
--

ALTER TABLE ONLY link_categories
    ADD CONSTRAINT link_categories_pkey PRIMARY KEY (id);


--
-- Name: link_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: calcentral; Tablespace:
--

ALTER TABLE ONLY link_sections
    ADD CONSTRAINT link_sections_pkey PRIMARY KEY (id);


--
-- Name: links_pkey; Type: CONSTRAINT; Schema: public; Owner: calcentral; Tablespace:
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: user_auths_pkey; Type: CONSTRAINT; Schema: public; Owner: calcentral; Tablespace:
--

ALTER TABLE ONLY user_auths
    ADD CONSTRAINT user_auths_pkey PRIMARY KEY (id);


--
-- Name: user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: calcentral; Tablespace:
--

ALTER TABLE ONLY user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- Name: index_fin_aid_years_on_current_year; Type: INDEX; Schema: public; Owner: calcentral_development; Tablespace:
--

CREATE UNIQUE INDEX index_fin_aid_years_on_current_year ON fin_aid_years USING btree (current_year);


--
-- Name: index_user_auths_on_uid; Type: INDEX; Schema: public; Owner: calcentral; Tablespace:
--

CREATE UNIQUE INDEX index_user_auths_on_uid ON user_auths USING btree (uid);

--
-- PostgreSQL database dump complete
--

