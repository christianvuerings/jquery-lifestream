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
DROP INDEX public.index_fin_aid_years_on_current_year;
ALTER TABLE ONLY public.user_roles DROP CONSTRAINT user_roles_pkey;
ALTER TABLE ONLY public.user_auths DROP CONSTRAINT user_auths_pkey;
ALTER TABLE ONLY public.links DROP CONSTRAINT links_pkey;
ALTER TABLE ONLY public.link_sections DROP CONSTRAINT link_sections_pkey;
ALTER TABLE ONLY public.link_categories DROP CONSTRAINT link_categories_pkey;
ALTER TABLE ONLY public.fin_aid_years DROP CONSTRAINT fin_aid_years_pkey;
ALTER TABLE public.user_roles ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.user_auths ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.links ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.link_sections ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.link_categories ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.fin_aid_years ALTER COLUMN id DROP DEFAULT;
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
DROP SEQUENCE public.fin_aid_years_id_seq;
DROP TABLE public.fin_aid_years;
SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: fin_aid_years; Type: TABLE; Schema: public; Owner: calcentral; Tablespace: 
--

CREATE TABLE fin_aid_years (
    id integer NOT NULL,
    current_year integer NOT NULL,
    upcoming_start_date date NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

--
-- Name: fin_aid_years_id_seq; Type: SEQUENCE; Schema: public; Owner: calcentral
--

CREATE SEQUENCE fin_aid_years_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: fin_aid_years_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: calcentral
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

--
-- Name: link_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: calcentral
--

CREATE SEQUENCE link_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

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

--
-- Name: link_sections_id_seq; Type: SEQUENCE; Schema: public; Owner: calcentral
--

CREATE SEQUENCE link_sections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

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

--
-- Name: links_id_seq; Type: SEQUENCE; Schema: public; Owner: calcentral
--

CREATE SEQUENCE links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

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

--
-- Name: user_auths; Type: TABLE; Schema: public; Owner: calcentral; Tablespace: 
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
-- Name: user_auths_id_seq; Type: SEQUENCE; Schema: public; Owner: calcentral
--

CREATE SEQUENCE user_auths_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

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

--
-- Name: user_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: calcentral
--

CREATE SEQUENCE user_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: user_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: calcentral
--

ALTER SEQUENCE user_roles_id_seq OWNED BY user_roles.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: calcentral
--

ALTER TABLE ONLY fin_aid_years ALTER COLUMN id SET DEFAULT nextval('fin_aid_years_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: calcentral
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
-- Data for Name: fin_aid_years; Type: TABLE DATA; Schema: public; Owner: calcentral
--

INSERT INTO fin_aid_years VALUES (4, 2014, '2014-03-29', '2014-05-12 13:03:16.162', '2014-05-12 13:03:16.162');
INSERT INTO fin_aid_years VALUES (5, 2015, '2015-03-28', '2014-05-12 13:03:16.169', '2014-05-12 13:03:16.169');
INSERT INTO fin_aid_years VALUES (6, 2016, '2016-03-26', '2014-05-12 13:03:16.175', '2014-05-12 13:03:16.175');
INSERT INTO fin_aid_years VALUES (7, 2017, '2017-04-01', '2014-06-02 13:02:01.337', '2014-06-02 13:02:01.337');
INSERT INTO fin_aid_years VALUES (8, 2018, '2018-03-31', '2014-06-02 13:02:01.373', '2014-06-02 13:02:01.373');
INSERT INTO fin_aid_years VALUES (9, 2019, '2019-03-30', '2014-06-02 13:02:01.385', '2014-06-02 13:02:01.385');
INSERT INTO fin_aid_years VALUES (10, 2020, '2020-03-28', '2014-06-02 13:02:01.396', '2014-06-02 13:02:01.396');
INSERT INTO fin_aid_years VALUES (11, 2021, '2021-03-27', '2014-06-02 13:02:01.408', '2014-06-02 13:02:01.408');


--
-- Name: fin_aid_years_id_seq; Type: SEQUENCE SET; Schema: public; Owner: calcentral
--

SELECT pg_catalog.setval('fin_aid_years_id_seq', 11, true);


--
-- Data for Name: link_categories; Type: TABLE DATA; Schema: public; Owner: calcentral
--

INSERT INTO link_categories VALUES (376, 'Academic', 'academic', true, '2014-05-12 13:03:07.64', '2014-05-12 13:03:07.64');
INSERT INTO link_categories VALUES (377, 'Academic Departments', 'academicdepartments', false, '2014-05-12 13:03:07.695', '2014-05-12 13:03:07.695');
INSERT INTO link_categories VALUES (378, 'Academic Planning', 'academicplanning', false, '2014-05-12 13:03:07.713', '2014-05-12 13:03:07.713');
INSERT INTO link_categories VALUES (379, 'Classes', 'classes', false, '2014-05-12 13:03:07.752', '2014-05-12 13:03:07.752');
INSERT INTO link_categories VALUES (380, 'Faculty', 'faculty', false, '2014-05-12 13:03:07.768', '2014-05-12 13:03:07.768');
INSERT INTO link_categories VALUES (381, 'Staff Learning', 'stafflearning', false, '2014-05-12 13:03:07.782', '2014-05-12 13:03:07.782');
INSERT INTO link_categories VALUES (382, 'Administrative', 'administrative', true, '2014-05-12 13:03:07.797', '2014-05-12 13:03:07.797');
INSERT INTO link_categories VALUES (383, 'Campus Departments', 'campusdepartments', false, '2014-05-12 13:03:07.812', '2014-05-12 13:03:07.812');
INSERT INTO link_categories VALUES (384, 'Communication & Collaboration', 'communicationcollaboration', false, '2014-05-12 13:03:07.828', '2014-05-12 13:03:07.828');
INSERT INTO link_categories VALUES (385, 'Policies & Procedures', 'policiesproceedures', false, '2014-05-12 13:03:07.843', '2014-05-12 13:03:07.843');
INSERT INTO link_categories VALUES (386, 'Shared Service Center', 'sharedservices', false, '2014-05-12 13:03:07.857', '2014-05-12 13:03:07.857');
INSERT INTO link_categories VALUES (387, 'Tools & Resources', 'toolsresources', false, '2014-05-12 13:03:07.871', '2014-05-12 13:03:07.871');
INSERT INTO link_categories VALUES (388, 'Personal', 'personal', true, '2014-05-12 13:03:07.886', '2014-05-12 13:03:07.886');
INSERT INTO link_categories VALUES (389, 'Career', 'career', false, '2014-05-12 13:03:07.9', '2014-05-12 13:03:07.9');
INSERT INTO link_categories VALUES (390, 'Finances', 'finances', false, '2014-05-12 13:03:07.914', '2014-05-12 13:03:07.914');
INSERT INTO link_categories VALUES (391, 'Food & Housing', 'foodandhousing', false, '2014-05-12 13:03:07.929', '2014-05-12 13:03:07.929');
INSERT INTO link_categories VALUES (392, 'HR & Benefits', 'hrbenefits', false, '2014-05-12 13:03:07.943', '2014-05-12 13:03:07.943');
INSERT INTO link_categories VALUES (393, 'Wellness', 'wellness', false, '2014-05-12 13:03:07.959', '2014-05-12 13:03:07.959');
INSERT INTO link_categories VALUES (394, 'Campus Life', 'campus life', true, '2014-05-12 13:03:07.973', '2014-05-12 13:03:07.973');
INSERT INTO link_categories VALUES (395, 'Community', 'community', false, '2014-05-12 13:03:07.988', '2014-05-12 13:03:07.988');
INSERT INTO link_categories VALUES (396, 'Getting Around', 'gettingaround', false, '2014-05-12 13:03:08.004', '2014-05-12 13:03:08.004');
INSERT INTO link_categories VALUES (397, 'Recreation & Entertainment', 'recreationentertainment', false, '2014-05-12 13:03:08.018', '2014-05-12 13:03:08.018');
INSERT INTO link_categories VALUES (398, 'Safety & Emergency Information', 'safetyemergencyinfo', false, '2014-05-12 13:03:08.033', '2014-05-12 13:03:08.033');
INSERT INTO link_categories VALUES (399, 'Student Engagement', 'studentgroups', false, '2014-05-12 13:03:08.047', '2014-05-12 13:03:08.047');
INSERT INTO link_categories VALUES (400, 'Support Services', 'supportservices', false, '2014-05-12 13:03:08.061', '2014-05-12 13:03:08.061');
INSERT INTO link_categories VALUES (401, 'Points of Interest', 'points of interest', false, '2014-05-12 13:03:08.08', '2014-05-12 13:03:08.08');
INSERT INTO link_categories VALUES (402, 'Night Safety', 'night safety', false, '2014-05-12 13:03:08.306', '2014-05-12 13:03:08.306');
INSERT INTO link_categories VALUES (403, 'Philanthropy & Public Service', 'philanthropy & public service', false, '2014-05-12 13:03:08.393', '2014-05-12 13:03:08.393');
INSERT INTO link_categories VALUES (404, 'Travel & Entertainment', 'travel & entertainment', false, '2014-05-12 13:03:08.475', '2014-05-12 13:03:08.475');
INSERT INTO link_categories VALUES (405, 'Purchasing', 'purchasing', false, '2014-05-12 13:03:08.56', '2014-05-12 13:03:08.56');
INSERT INTO link_categories VALUES (406, 'Human Resources', 'human resources', false, '2014-05-12 13:03:08.634', '2014-05-12 13:03:08.634');
INSERT INTO link_categories VALUES (407, 'Financial', 'financial', false, '2014-05-12 13:03:08.708', '2014-05-12 13:03:08.708');
INSERT INTO link_categories VALUES (408, 'Computing', 'computing', false, '2014-05-12 13:03:08.78', '2014-05-12 13:03:08.78');
INSERT INTO link_categories VALUES (409, 'Service Requests', 'service requests', false, '2014-05-12 13:03:08.896', '2014-05-12 13:03:08.896');
INSERT INTO link_categories VALUES (410, 'Student Organizations', 'student organizations', false, '2014-05-12 13:03:09.001', '2014-05-12 13:03:09.001');
INSERT INTO link_categories VALUES (411, 'Students', 'students', false, '2014-05-12 13:03:09.077', '2014-05-12 13:03:09.077');
INSERT INTO link_categories VALUES (412, 'Sports & Recreation', 'sports & recreation', false, '2014-05-12 13:03:09.149', '2014-05-12 13:03:09.149');
INSERT INTO link_categories VALUES (413, 'Social Media', 'social media', false, '2014-05-12 13:03:09.275', '2014-05-12 13:03:09.275');
INSERT INTO link_categories VALUES (414, 'Security & Access', 'security & access', false, '2014-05-12 13:03:09.347', '2014-05-12 13:03:09.347');
INSERT INTO link_categories VALUES (415, 'Employer & Employee', 'employer & employee', false, '2014-05-12 13:03:09.419', '2014-05-12 13:03:09.419');
INSERT INTO link_categories VALUES (416, 'Collaboration Tools', 'collaboration tools', false, '2014-05-12 13:03:09.486', '2014-05-12 13:03:09.486');
INSERT INTO link_categories VALUES (417, 'bConnected Tools', 'bconnected tools', false, '2014-05-12 13:03:09.571', '2014-05-12 13:03:09.571');
INSERT INTO link_categories VALUES (418, 'Administrative and Other', 'administrative and other', false, '2014-05-12 13:03:09.639', '2014-05-12 13:03:09.639');
INSERT INTO link_categories VALUES (419, 'Professional Development', 'professional development', false, '2014-05-12 13:03:09.782', '2014-05-12 13:03:09.782');
INSERT INTO link_categories VALUES (420, 'Resources', 'resources', false, '2014-05-12 13:03:09.844', '2014-05-12 13:03:09.844');
INSERT INTO link_categories VALUES (421, 'Learning Resources', 'learning resources', false, '2014-05-12 13:03:09.931', '2014-05-12 13:03:09.931');
INSERT INTO link_categories VALUES (422, 'Student Advising', 'student advising', false, '2014-05-12 13:03:10.166', '2014-05-12 13:03:10.166');
INSERT INTO link_categories VALUES (423, 'Planning', 'planning', false, '2014-05-12 13:03:10.228', '2014-05-12 13:03:10.228');
INSERT INTO link_categories VALUES (424, 'Policies', 'policies', false, '2014-05-12 13:03:10.285', '2014-05-12 13:03:10.285');
INSERT INTO link_categories VALUES (425, 'Academic Record', 'academic record', false, '2014-05-12 13:03:10.352', '2014-05-12 13:03:10.352');
INSERT INTO link_categories VALUES (426, 'Calendar', 'calendar', false, '2014-05-12 13:03:10.461', '2014-05-12 13:03:10.461');
INSERT INTO link_categories VALUES (427, 'News & Information', 'news & information', false, '2014-05-12 13:03:10.556', '2014-05-12 13:03:10.556');
INSERT INTO link_categories VALUES (428, 'Retirement', 'retirement', false, '2014-05-12 13:03:10.611', '2014-05-12 13:03:10.611');
INSERT INTO link_categories VALUES (429, 'My Information', 'my information', false, '2014-05-12 13:03:10.675', '2014-05-12 13:03:10.675');
INSERT INTO link_categories VALUES (430, 'Housing', 'housing', false, '2014-05-12 13:03:10.742', '2014-05-12 13:03:10.742');
INSERT INTO link_categories VALUES (431, 'Network & Computing', 'network & computing', false, '2014-05-12 13:03:10.934', '2014-05-12 13:03:10.934');
INSERT INTO link_categories VALUES (432, 'Campus Dining', 'campus dining', false, '2014-05-12 13:03:10.996', '2014-05-12 13:03:10.996');
INSERT INTO link_categories VALUES (433, 'Family', 'family', false, '2014-05-12 13:03:11.062', '2014-05-12 13:03:11.062');
INSERT INTO link_categories VALUES (434, 'Staff Support Services', 'staff support services', false, '2014-05-12 13:03:11.136', '2014-05-12 13:03:11.136');
INSERT INTO link_categories VALUES (435, 'Benefits', 'benefits', false, '2014-05-12 13:03:11.211', '2014-05-12 13:03:11.211');
INSERT INTO link_categories VALUES (436, 'Conflict Resolution', 'conflict resolution', false, '2014-05-12 13:03:11.344', '2014-05-12 13:03:11.344');
INSERT INTO link_categories VALUES (437, 'Campus Health Center', 'campus health center', false, '2014-05-12 13:03:11.403', '2014-05-12 13:03:11.403');
INSERT INTO link_categories VALUES (438, 'Emergency Preparedness', 'emergency preparedness', false, '2014-05-12 13:03:11.616', '2014-05-12 13:03:11.616');
INSERT INTO link_categories VALUES (439, 'Library', 'library', false, '2014-05-12 13:03:11.936', '2014-05-12 13:03:11.936');
INSERT INTO link_categories VALUES (440, 'Research', 'research', false, '2014-05-12 13:03:12.009', '2014-05-12 13:03:12.009');
INSERT INTO link_categories VALUES (441, 'Health & Safety', 'health & safety', false, '2014-05-12 13:03:12.292', '2014-05-12 13:03:12.292');
INSERT INTO link_categories VALUES (442, 'Student Services', 'student services', false, '2014-05-12 13:03:12.385', '2014-05-12 13:03:12.385');
INSERT INTO link_categories VALUES (443, 'Campus Mail', 'campus mail', false, '2014-05-12 13:03:12.563', '2014-05-12 13:03:12.563');
INSERT INTO link_categories VALUES (444, 'Asset Management', 'asset management', false, '2014-05-12 13:03:12.621', '2014-05-12 13:03:12.621');
INSERT INTO link_categories VALUES (445, 'Analysis & Reporting', 'analysis & reporting', false, '2014-05-12 13:03:12.675', '2014-05-12 13:03:12.675');
INSERT INTO link_categories VALUES (446, 'Overview', 'overview', false, '2014-05-12 13:03:12.731', '2014-05-12 13:03:12.731');
INSERT INTO link_categories VALUES (447, 'Campus Messaging', 'campus messaging', false, '2014-05-12 13:03:12.947', '2014-05-12 13:03:12.947');
INSERT INTO link_categories VALUES (448, 'Financial Assistance', 'financial assistance', false, '2014-05-12 13:03:13.036', '2014-05-12 13:03:13.036');
INSERT INTO link_categories VALUES (449, 'Tools', 'tools', false, '2014-05-12 13:03:13.3', '2014-05-12 13:03:13.3');
INSERT INTO link_categories VALUES (450, 'Classroom Technology', 'classroom technology', false, '2014-05-12 13:03:13.459', '2014-05-12 13:03:13.459');
INSERT INTO link_categories VALUES (451, 'Graduate', 'graduate', false, '2014-05-12 13:03:13.563', '2014-05-12 13:03:13.563');
INSERT INTO link_categories VALUES (452, 'Your Questions Answered Here', 'your questions answered here', false, '2014-05-12 13:03:13.697', '2014-05-12 13:03:13.697');
INSERT INTO link_categories VALUES (453, 'Directory', 'directory', false, '2014-05-12 13:03:13.823', '2014-05-12 13:03:13.823');
INSERT INTO link_categories VALUES (454, 'News & Events', 'news & events', false, '2014-05-12 13:03:13.93', '2014-05-12 13:03:13.93');
INSERT INTO link_categories VALUES (455, 'Map', 'map', false, '2014-05-12 13:03:14.019', '2014-05-12 13:03:14.019');
INSERT INTO link_categories VALUES (456, 'Parking & Transportation', 'parking & transportation', false, '2014-05-12 13:03:14.082', '2014-05-12 13:03:14.082');
INSERT INTO link_categories VALUES (457, 'Police', 'police', false, '2014-05-12 13:03:14.172', '2014-05-12 13:03:14.172');
INSERT INTO link_categories VALUES (458, 'Student Government', 'student government', false, '2014-05-12 13:03:14.331', '2014-05-12 13:03:14.331');
INSERT INTO link_categories VALUES (459, 'Jobs', 'jobs', false, '2014-05-12 13:03:14.503', '2014-05-12 13:03:14.503');
INSERT INTO link_categories VALUES (460, 'Activities', 'activities', false, '2014-05-12 13:03:14.627', '2014-05-12 13:03:14.627');
INSERT INTO link_categories VALUES (461, 'Athletics', 'athletics', false, '2014-05-12 13:03:14.942', '2014-05-12 13:03:14.942');
INSERT INTO link_categories VALUES (462, 'Staff Portal', 'staff portal', false, '2014-05-12 13:03:15.236', '2014-05-12 13:03:15.236');
INSERT INTO link_categories VALUES (463, 'Payroll', 'payroll', false, '2014-05-12 13:03:15.382', '2014-05-12 13:03:15.382');
INSERT INTO link_categories VALUES (464, 'Billing & Payments', 'billing & payments', false, '2014-05-12 13:03:15.606', '2014-05-12 13:03:15.606');
INSERT INTO link_categories VALUES (465, 'Leaving Cal?', 'leaving cal?', false, '2014-05-12 13:03:15.747', '2014-05-12 13:03:15.747');
INSERT INTO link_categories VALUES (466, 'Summer Programs', 'summer programs', false, '2014-05-12 13:03:15.797', '2014-05-12 13:03:15.797');
INSERT INTO link_categories VALUES (467, 'Student Employees', 'student employees', false, '2014-05-12 13:03:15.842', '2014-05-12 13:03:15.842');


--
-- Name: link_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: calcentral
--

SELECT pg_catalog.setval('link_categories_id_seq', 467, true);


--
-- Data for Name: link_categories_link_sections; Type: TABLE DATA; Schema: public; Owner: calcentral
--



--
-- Data for Name: link_sections; Type: TABLE DATA; Schema: public; Owner: calcentral
--

INSERT INTO link_sections VALUES (308, 394, 397, 401, '2014-05-12 13:03:08.198', '2014-05-12 13:03:08.198');
INSERT INTO link_sections VALUES (309, 394, 398, 402, '2014-05-12 13:03:08.338', '2014-05-12 13:03:08.338');
INSERT INTO link_sections VALUES (310, 394, 395, 403, '2014-05-12 13:03:08.422', '2014-05-12 13:03:08.422');
INSERT INTO link_sections VALUES (311, 382, 387, 404, '2014-05-12 13:03:08.508', '2014-05-12 13:03:08.508');
INSERT INTO link_sections VALUES (312, 382, 387, 405, '2014-05-12 13:03:08.59', '2014-05-12 13:03:08.59');
INSERT INTO link_sections VALUES (313, 382, 387, 406, '2014-05-12 13:03:08.661', '2014-05-12 13:03:08.661');
INSERT INTO link_sections VALUES (314, 382, 387, 407, '2014-05-12 13:03:08.736', '2014-05-12 13:03:08.736');
INSERT INTO link_sections VALUES (315, 382, 387, 408, '2014-05-12 13:03:08.806', '2014-05-12 13:03:08.806');
INSERT INTO link_sections VALUES (316, 382, 386, 409, '2014-05-12 13:03:08.921', '2014-05-12 13:03:08.921');
INSERT INTO link_sections VALUES (317, 394, 399, 410, '2014-05-12 13:03:09.028', '2014-05-12 13:03:09.028');
INSERT INTO link_sections VALUES (318, 394, 400, 411, '2014-05-12 13:03:09.104', '2014-05-12 13:03:09.104');
INSERT INTO link_sections VALUES (319, 394, 397, 412, '2014-05-12 13:03:09.172', '2014-05-12 13:03:09.172');
INSERT INTO link_sections VALUES (320, 394, 396, 401, '2014-05-12 13:03:09.226', '2014-05-12 13:03:09.226');
INSERT INTO link_sections VALUES (321, 394, 395, 413, '2014-05-12 13:03:09.303', '2014-05-12 13:03:09.303');
INSERT INTO link_sections VALUES (322, 382, 387, 414, '2014-05-12 13:03:09.373', '2014-05-12 13:03:09.373');
INSERT INTO link_sections VALUES (323, 382, 385, 415, '2014-05-12 13:03:09.447', '2014-05-12 13:03:09.447');
INSERT INTO link_sections VALUES (324, 382, 384, 416, '2014-05-12 13:03:09.511', '2014-05-12 13:03:09.511');
INSERT INTO link_sections VALUES (325, 382, 384, 417, '2014-05-12 13:03:09.596', '2014-05-12 13:03:09.596');
INSERT INTO link_sections VALUES (326, 382, 383, 418, '2014-05-12 13:03:09.666', '2014-05-12 13:03:09.666');
INSERT INTO link_sections VALUES (327, 376, 381, 419, '2014-05-12 13:03:09.805', '2014-05-12 13:03:09.805');
INSERT INTO link_sections VALUES (328, 376, 380, 420, '2014-05-12 13:03:09.867', '2014-05-12 13:03:09.867');
INSERT INTO link_sections VALUES (329, 376, 379, 421, '2014-05-12 13:03:09.954', '2014-05-12 13:03:09.954');
INSERT INTO link_sections VALUES (330, 376, 379, 379, '2014-05-12 13:03:10.01', '2014-05-12 13:03:10.01');
INSERT INTO link_sections VALUES (331, 376, 378, 379, '2014-05-12 13:03:10.037', '2014-05-12 13:03:10.037');
INSERT INTO link_sections VALUES (332, 376, 377, 376, '2014-05-12 13:03:10.124', '2014-05-12 13:03:10.124');
INSERT INTO link_sections VALUES (333, 376, 378, 422, '2014-05-12 13:03:10.191', '2014-05-12 13:03:10.191');
INSERT INTO link_sections VALUES (334, 376, 378, 423, '2014-05-12 13:03:10.25', '2014-05-12 13:03:10.25');
INSERT INTO link_sections VALUES (335, 382, 385, 424, '2014-05-12 13:03:10.31', '2014-05-12 13:03:10.31');
INSERT INTO link_sections VALUES (336, 376, 378, 425, '2014-05-12 13:03:10.375', '2014-05-12 13:03:10.375');
INSERT INTO link_sections VALUES (337, 376, 378, 426, '2014-05-12 13:03:10.482', '2014-05-12 13:03:10.482');
INSERT INTO link_sections VALUES (338, 388, 393, 427, '2014-05-12 13:03:10.577', '2014-05-12 13:03:10.577');
INSERT INTO link_sections VALUES (339, 388, 392, 428, '2014-05-12 13:03:10.635', '2014-05-12 13:03:10.635');
INSERT INTO link_sections VALUES (340, 388, 392, 429, '2014-05-12 13:03:10.699', '2014-05-12 13:03:10.699');
INSERT INTO link_sections VALUES (341, 388, 391, 430, '2014-05-12 13:03:10.764', '2014-05-12 13:03:10.764');
INSERT INTO link_sections VALUES (342, 388, 391, 431, '2014-05-12 13:03:10.956', '2014-05-12 13:03:10.956');
INSERT INTO link_sections VALUES (343, 388, 391, 432, '2014-05-12 13:03:11.019', '2014-05-12 13:03:11.019');
INSERT INTO link_sections VALUES (344, 388, 391, 433, '2014-05-12 13:03:11.091', '2014-05-12 13:03:11.091');
INSERT INTO link_sections VALUES (345, 388, 392, 433, '2014-05-12 13:03:11.122', '2014-05-12 13:03:11.122');
INSERT INTO link_sections VALUES (346, 388, 393, 434, '2014-05-12 13:03:11.159', '2014-05-12 13:03:11.159');
INSERT INTO link_sections VALUES (347, 388, 392, 435, '2014-05-12 13:03:11.235', '2014-05-12 13:03:11.235');
INSERT INTO link_sections VALUES (348, 388, 392, 436, '2014-05-12 13:03:11.366', '2014-05-12 13:03:11.366');
INSERT INTO link_sections VALUES (349, 388, 393, 437, '2014-05-12 13:03:11.426', '2014-05-12 13:03:11.426');
INSERT INTO link_sections VALUES (350, 394, 398, 438, '2014-05-12 13:03:11.638', '2014-05-12 13:03:11.638');
INSERT INTO link_sections VALUES (351, 376, 377, 439, '2014-05-12 13:03:11.956', '2014-05-12 13:03:11.956');
INSERT INTO link_sections VALUES (352, 376, 377, 440, '2014-05-12 13:03:12.029', '2014-05-12 13:03:12.029');
INSERT INTO link_sections VALUES (353, 376, 381, 441, '2014-05-12 13:03:12.312', '2014-05-12 13:03:12.312');
INSERT INTO link_sections VALUES (354, 382, 383, 442, '2014-05-12 13:03:12.405', '2014-05-12 13:03:12.405');
INSERT INTO link_sections VALUES (355, 382, 387, 443, '2014-05-12 13:03:12.585', '2014-05-12 13:03:12.585');
INSERT INTO link_sections VALUES (356, 382, 387, 444, '2014-05-12 13:03:12.641', '2014-05-12 13:03:12.641');
INSERT INTO link_sections VALUES (357, 382, 387, 445, '2014-05-12 13:03:12.695', '2014-05-12 13:03:12.695');
INSERT INTO link_sections VALUES (358, 382, 386, 446, '2014-05-12 13:03:12.753', '2014-05-12 13:03:12.753');
INSERT INTO link_sections VALUES (359, 382, 384, 447, '2014-05-12 13:03:12.968', '2014-05-12 13:03:12.968');
INSERT INTO link_sections VALUES (360, 388, 390, 448, '2014-05-12 13:03:13.058', '2014-05-12 13:03:13.058');
INSERT INTO link_sections VALUES (361, 376, 381, 446, '2014-05-12 13:03:13.238', '2014-05-12 13:03:13.238');
INSERT INTO link_sections VALUES (362, 376, 380, 449, '2014-05-12 13:03:13.321', '2014-05-12 13:03:13.321');
INSERT INTO link_sections VALUES (363, 376, 380, 450, '2014-05-12 13:03:13.479', '2014-05-12 13:03:13.479');
INSERT INTO link_sections VALUES (364, 376, 377, 451, '2014-05-12 13:03:13.584', '2014-05-12 13:03:13.584');
INSERT INTO link_sections VALUES (365, 388, 390, 452, '2014-05-12 13:03:13.715', '2014-05-12 13:03:13.715');
INSERT INTO link_sections VALUES (366, 394, 395, 453, '2014-05-12 13:03:13.849', '2014-05-12 13:03:13.849');
INSERT INTO link_sections VALUES (367, 394, 395, 454, '2014-05-12 13:03:13.951', '2014-05-12 13:03:13.951');
INSERT INTO link_sections VALUES (368, 394, 396, 455, '2014-05-12 13:03:14.04', '2014-05-12 13:03:14.04');
INSERT INTO link_sections VALUES (369, 394, 396, 456, '2014-05-12 13:03:14.102', '2014-05-12 13:03:14.102');
INSERT INTO link_sections VALUES (370, 394, 398, 457, '2014-05-12 13:03:14.192', '2014-05-12 13:03:14.192');
INSERT INTO link_sections VALUES (371, 394, 399, 458, '2014-05-12 13:03:14.353', '2014-05-12 13:03:14.353');
INSERT INTO link_sections VALUES (372, 388, 389, 459, '2014-05-12 13:03:14.522', '2014-05-12 13:03:14.522');
INSERT INTO link_sections VALUES (373, 394, 397, 460, '2014-05-12 13:03:14.646', '2014-05-12 13:03:14.646');
INSERT INTO link_sections VALUES (374, 394, 399, 460, '2014-05-12 13:03:14.908', '2014-05-12 13:03:14.908');
INSERT INTO link_sections VALUES (375, 394, 397, 461, '2014-05-12 13:03:14.961', '2014-05-12 13:03:14.961');
INSERT INTO link_sections VALUES (376, 382, 387, 462, '2014-05-12 13:03:15.265', '2014-05-12 13:03:15.265');
INSERT INTO link_sections VALUES (377, 382, 387, 463, '2014-05-12 13:03:15.4', '2014-05-12 13:03:15.4');
INSERT INTO link_sections VALUES (378, 388, 390, 464, '2014-05-12 13:03:15.624', '2014-05-12 13:03:15.624');
INSERT INTO link_sections VALUES (379, 388, 390, 465, '2014-05-12 13:03:15.766', '2014-05-12 13:03:15.766');
INSERT INTO link_sections VALUES (380, 388, 390, 466, '2014-05-12 13:03:15.815', '2014-05-12 13:03:15.815');
INSERT INTO link_sections VALUES (381, 388, 389, 467, '2014-05-12 13:03:15.858', '2014-05-12 13:03:15.858');


--
-- Name: link_sections_id_seq; Type: SEQUENCE SET; Schema: public; Owner: calcentral
--

SELECT pg_catalog.setval('link_sections_id_seq', 381, true);


--
-- Data for Name: link_sections_links; Type: TABLE DATA; Schema: public; Owner: calcentral
--

INSERT INTO link_sections_links VALUES (308, 710);
INSERT INTO link_sections_links VALUES (309, 711);
INSERT INTO link_sections_links VALUES (310, 712);
INSERT INTO link_sections_links VALUES (311, 713);
INSERT INTO link_sections_links VALUES (312, 714);
INSERT INTO link_sections_links VALUES (313, 715);
INSERT INTO link_sections_links VALUES (314, 716);
INSERT INTO link_sections_links VALUES (315, 717);
INSERT INTO link_sections_links VALUES (315, 718);
INSERT INTO link_sections_links VALUES (316, 719);
INSERT INTO link_sections_links VALUES (312, 720);
INSERT INTO link_sections_links VALUES (317, 721);
INSERT INTO link_sections_links VALUES (318, 722);
INSERT INTO link_sections_links VALUES (319, 723);
INSERT INTO link_sections_links VALUES (320, 724);
INSERT INTO link_sections_links VALUES (321, 725);
INSERT INTO link_sections_links VALUES (322, 726);
INSERT INTO link_sections_links VALUES (323, 727);
INSERT INTO link_sections_links VALUES (324, 728);
INSERT INTO link_sections_links VALUES (325, 729);
INSERT INTO link_sections_links VALUES (326, 730);
INSERT INTO link_sections_links VALUES (326, 731);
INSERT INTO link_sections_links VALUES (326, 732);
INSERT INTO link_sections_links VALUES (327, 733);
INSERT INTO link_sections_links VALUES (328, 734);
INSERT INTO link_sections_links VALUES (328, 735);
INSERT INTO link_sections_links VALUES (329, 736);
INSERT INTO link_sections_links VALUES (330, 737);
INSERT INTO link_sections_links VALUES (331, 737);
INSERT INTO link_sections_links VALUES (332, 738);
INSERT INTO link_sections_links VALUES (333, 739);
INSERT INTO link_sections_links VALUES (334, 740);
INSERT INTO link_sections_links VALUES (335, 741);
INSERT INTO link_sections_links VALUES (336, 742);
INSERT INTO link_sections_links VALUES (334, 743);
INSERT INTO link_sections_links VALUES (330, 743);
INSERT INTO link_sections_links VALUES (337, 744);
INSERT INTO link_sections_links VALUES (336, 745);
INSERT INTO link_sections_links VALUES (338, 746);
INSERT INTO link_sections_links VALUES (339, 747);
INSERT INTO link_sections_links VALUES (340, 748);
INSERT INTO link_sections_links VALUES (341, 749);
INSERT INTO link_sections_links VALUES (341, 750);
INSERT INTO link_sections_links VALUES (341, 751);
INSERT INTO link_sections_links VALUES (341, 752);
INSERT INTO link_sections_links VALUES (341, 753);
INSERT INTO link_sections_links VALUES (315, 754);
INSERT INTO link_sections_links VALUES (342, 754);
INSERT INTO link_sections_links VALUES (343, 755);
INSERT INTO link_sections_links VALUES (344, 756);
INSERT INTO link_sections_links VALUES (345, 756);
INSERT INTO link_sections_links VALUES (346, 756);
INSERT INTO link_sections_links VALUES (347, 757);
INSERT INTO link_sections_links VALUES (340, 758);
INSERT INTO link_sections_links VALUES (339, 759);
INSERT INTO link_sections_links VALUES (348, 760);
INSERT INTO link_sections_links VALUES (349, 761);
INSERT INTO link_sections_links VALUES (349, 762);
INSERT INTO link_sections_links VALUES (349, 763);
INSERT INTO link_sections_links VALUES (327, 764);
INSERT INTO link_sections_links VALUES (335, 765);
INSERT INTO link_sections_links VALUES (350, 766);
INSERT INTO link_sections_links VALUES (337, 767);
INSERT INTO link_sections_links VALUES (334, 768);
INSERT INTO link_sections_links VALUES (334, 769);
INSERT INTO link_sections_links VALUES (330, 769);
INSERT INTO link_sections_links VALUES (334, 770);
INSERT INTO link_sections_links VALUES (334, 771);
INSERT INTO link_sections_links VALUES (334, 772);
INSERT INTO link_sections_links VALUES (333, 773);
INSERT INTO link_sections_links VALUES (351, 774);
INSERT INTO link_sections_links VALUES (329, 774);
INSERT INTO link_sections_links VALUES (352, 775);
INSERT INTO link_sections_links VALUES (330, 776);
INSERT INTO link_sections_links VALUES (331, 776);
INSERT INTO link_sections_links VALUES (324, 776);
INSERT INTO link_sections_links VALUES (330, 777);
INSERT INTO link_sections_links VALUES (331, 777);
INSERT INTO link_sections_links VALUES (327, 778);
INSERT INTO link_sections_links VALUES (330, 778);
INSERT INTO link_sections_links VALUES (331, 778);
INSERT INTO link_sections_links VALUES (330, 779);
INSERT INTO link_sections_links VALUES (329, 780);
INSERT INTO link_sections_links VALUES (353, 781);
INSERT INTO link_sections_links VALUES (326, 782);
INSERT INTO link_sections_links VALUES (354, 783);
INSERT INTO link_sections_links VALUES (325, 784);
INSERT INTO link_sections_links VALUES (325, 785);
INSERT INTO link_sections_links VALUES (325, 786);
INSERT INTO link_sections_links VALUES (315, 787);
INSERT INTO link_sections_links VALUES (355, 788);
INSERT INTO link_sections_links VALUES (356, 789);
INSERT INTO link_sections_links VALUES (357, 790);
INSERT INTO link_sections_links VALUES (358, 791);
INSERT INTO link_sections_links VALUES (328, 792);
INSERT INTO link_sections_links VALUES (335, 793);
INSERT INTO link_sections_links VALUES (335, 794);
INSERT INTO link_sections_links VALUES (324, 795);
INSERT INTO link_sections_links VALUES (324, 796);
INSERT INTO link_sections_links VALUES (359, 797);
INSERT INTO link_sections_links VALUES (325, 798);
INSERT INTO link_sections_links VALUES (360, 799);
INSERT INTO link_sections_links VALUES (326, 800);
INSERT INTO link_sections_links VALUES (326, 801);
INSERT INTO link_sections_links VALUES (326, 802);
INSERT INTO link_sections_links VALUES (326, 803);
INSERT INTO link_sections_links VALUES (361, 804);
INSERT INTO link_sections_links VALUES (353, 805);
INSERT INTO link_sections_links VALUES (362, 806);
INSERT INTO link_sections_links VALUES (328, 807);
INSERT INTO link_sections_links VALUES (328, 808);
INSERT INTO link_sections_links VALUES (333, 809);
INSERT INTO link_sections_links VALUES (328, 810);
INSERT INTO link_sections_links VALUES (363, 811);
INSERT INTO link_sections_links VALUES (329, 812);
INSERT INTO link_sections_links VALUES (352, 813);
INSERT INTO link_sections_links VALUES (364, 814);
INSERT INTO link_sections_links VALUES (332, 815);
INSERT INTO link_sections_links VALUES (332, 816);
INSERT INTO link_sections_links VALUES (333, 817);
INSERT INTO link_sections_links VALUES (365, 817);
INSERT INTO link_sections_links VALUES (323, 818);
INSERT INTO link_sections_links VALUES (343, 819);
INSERT INTO link_sections_links VALUES (322, 819);
INSERT INTO link_sections_links VALUES (366, 820);
INSERT INTO link_sections_links VALUES (310, 821);
INSERT INTO link_sections_links VALUES (367, 822);
INSERT INTO link_sections_links VALUES (367, 823);
INSERT INTO link_sections_links VALUES (368, 824);
INSERT INTO link_sections_links VALUES (369, 825);
INSERT INTO link_sections_links VALUES (350, 826);
INSERT INTO link_sections_links VALUES (370, 827);
INSERT INTO link_sections_links VALUES (319, 828);
INSERT INTO link_sections_links VALUES (308, 829);
INSERT INTO link_sections_links VALUES (367, 830);
INSERT INTO link_sections_links VALUES (308, 830);
INSERT INTO link_sections_links VALUES (371, 831);
INSERT INTO link_sections_links VALUES (371, 832);
INSERT INTO link_sections_links VALUES (317, 833);
INSERT INTO link_sections_links VALUES (318, 834);
INSERT INTO link_sections_links VALUES (318, 835);
INSERT INTO link_sections_links VALUES (372, 836);
INSERT INTO link_sections_links VALUES (372, 837);
INSERT INTO link_sections_links VALUES (341, 838);
INSERT INTO link_sections_links VALUES (317, 838);
INSERT INTO link_sections_links VALUES (373, 839);
INSERT INTO link_sections_links VALUES (308, 840);
INSERT INTO link_sections_links VALUES (372, 841);
INSERT INTO link_sections_links VALUES (369, 842);
INSERT INTO link_sections_links VALUES (372, 843);
INSERT INTO link_sections_links VALUES (372, 844);
INSERT INTO link_sections_links VALUES (372, 845);
INSERT INTO link_sections_links VALUES (318, 846);
INSERT INTO link_sections_links VALUES (318, 847);
INSERT INTO link_sections_links VALUES (318, 848);
INSERT INTO link_sections_links VALUES (374, 849);
INSERT INTO link_sections_links VALUES (375, 850);
INSERT INTO link_sections_links VALUES (308, 851);
INSERT INTO link_sections_links VALUES (350, 852);
INSERT INTO link_sections_links VALUES (369, 853);
INSERT INTO link_sections_links VALUES (369, 854);
INSERT INTO link_sections_links VALUES (321, 855);
INSERT INTO link_sections_links VALUES (367, 856);
INSERT INTO link_sections_links VALUES (367, 857);
INSERT INTO link_sections_links VALUES (310, 858);
INSERT INTO link_sections_links VALUES (376, 859);
INSERT INTO link_sections_links VALUES (322, 860);
INSERT INTO link_sections_links VALUES (322, 861);
INSERT INTO link_sections_links VALUES (312, 862);
INSERT INTO link_sections_links VALUES (377, 863);
INSERT INTO link_sections_links VALUES (377, 864);
INSERT INTO link_sections_links VALUES (314, 865);
INSERT INTO link_sections_links VALUES (313, 866);
INSERT INTO link_sections_links VALUES (314, 867);
INSERT INTO link_sections_links VALUES (315, 868);
INSERT INTO link_sections_links VALUES (315, 869);
INSERT INTO link_sections_links VALUES (315, 870);
INSERT INTO link_sections_links VALUES (378, 871);
INSERT INTO link_sections_links VALUES (378, 872);
INSERT INTO link_sections_links VALUES (360, 873);
INSERT INTO link_sections_links VALUES (360, 874);
INSERT INTO link_sections_links VALUES (360, 875);
INSERT INTO link_sections_links VALUES (379, 876);
INSERT INTO link_sections_links VALUES (380, 877);
INSERT INTO link_sections_links VALUES (381, 878);
INSERT INTO link_sections_links VALUES (360, 878);
INSERT INTO link_sections_links VALUES (380, 879);
INSERT INTO link_sections_links VALUES (379, 880);
INSERT INTO link_sections_links VALUES (378, 881);
INSERT INTO link_sections_links VALUES (378, 882);
INSERT INTO link_sections_links VALUES (378, 883);
INSERT INTO link_sections_links VALUES (360, 884);


--
-- Data for Name: links; Type: TABLE DATA; Schema: public; Owner: calcentral
--

INSERT INTO links VALUES (837, 'Berkeley Jobs', 'http://jobs.berkeley.edu/', 'Start here to learn about job openings on campus, student, staff and academic positions', true, '2014-05-12 13:03:14.567', '2014-05-30 23:01:50.776');
INSERT INTO links VALUES (722, 'My Years at Cal', 'http://myyears.berkeley.edu/', 'Undergraduate advice site with useful resources and on how to stay on track for graduation ', true, '2014-05-12 13:03:09.122', '2014-05-30 23:06:33.137');
INSERT INTO links VALUES (855, 'Twitter', 'https://twitter.com/UCBerkeley', 'UC Berkeley''s primary Stay updated on campus news through Berkeley''s primary Twitter address', true, '2014-05-12 13:03:15.126', '2014-05-30 23:08:47.536');
INSERT INTO links VALUES (797, 'CalMessages', 'https://calmessages.berkeley.edu/', 'Berkeley''s official messaging system used to send broadcast email notifications to all staff, all students, etc.', true, '2014-05-12 13:03:12.982', '2014-05-30 23:20:37.794');
INSERT INTO links VALUES (798, 'bConnected Support', 'http://ist.berkeley.edu/bconnected', 'Information and resources site for Berkeley''s email, calendar and shared drive solutions, powered by Google Apps for Education', true, '2014-05-12 13:03:13.01', '2014-05-30 23:23:00.48');
INSERT INTO links VALUES (760, 'Staff Ombuds Office', 'http://staffombuds.berkeley.edu/ ', 'An independent department that provides staff with strictly confidential and informal conflict resolution and problem-solving services', true, '2014-05-12 13:03:11.381', '2014-05-30 23:32:30.674');
INSERT INTO links VALUES (710, 'Cal Student Store', 'http://www.bkstr.com/webapp/wcs/stores/servlet/StoreCatalogDisplay?catalogId=10001&langId=-1&demoKey=d&storeId=10433', 'Apparel, school supplies, and more ', true, '2014-05-12 13:03:08.266', '2014-05-12 13:03:08.266');
INSERT INTO links VALUES (711, 'BearWALK Night safety services', 'http://police.berkeley.edu/programsandservices/campus_safety/index.html', 'Free safety night walks to and from a desired location with a Community Service Officer', true, '2014-05-12 13:03:08.358', '2014-05-12 13:03:08.358');
INSERT INTO links VALUES (712, 'Give to Berkeley', 'http://givetocal.berkeley.edu/', 'Help donate to further student''s education', true, '2014-05-12 13:03:08.442', '2014-05-12 13:03:08.442');
INSERT INTO links VALUES (713, 'Travel & Entertainment', 'http://controller.berkeley.edu/travel/', 'Travel services including airfare and Berkeley''s Direct Bill ID system', true, '2014-05-12 13:03:08.53', '2014-05-12 13:03:08.53');
INSERT INTO links VALUES (714, 'Purchasing', 'http://businessservices.berkeley.edu/procurement/services', 'Services that can be purchased by individuals with a CalNet ID and passphrase', true, '2014-05-12 13:03:08.607', '2014-05-12 13:03:08.607');
INSERT INTO links VALUES (715, 'HR Web', 'http://hrweb.berkeley.edu/', 'Human Resources at Berkeley', true, '2014-05-12 13:03:08.678', '2014-05-12 13:03:08.678');
INSERT INTO links VALUES (716, 'BAIRS', 'http://www.bai.berkeley.edu/', 'Berkeley Administrative Initiative Reporting System', true, '2014-05-12 13:03:08.753', '2014-05-12 13:03:08.753');
INSERT INTO links VALUES (717, 'Open Computing Facility', 'http://www.ocf.berkeley.edu/', 'Free computing such as printing for Berkeley affiliates', true, '2014-05-12 13:03:08.823', '2014-05-12 13:03:08.823');
INSERT INTO links VALUES (718, 'General Access Computing Facilities', 'http://ets.berkeley.edu/computer-facilities/general-access', 'Convenient and secure on-campus computing facilities for registered Berkeley affiliates', true, '2014-05-12 13:03:08.865', '2014-05-12 13:03:08.865');
INSERT INTO links VALUES (719, 'Submit a Service Request', 'https://shared-services-help.berkeley.edu/', 'Help requests for various services such as research', true, '2014-05-12 13:03:08.937', '2014-05-12 13:03:08.937');
INSERT INTO links VALUES (720, 'BearBuy Procurement', 'http://procurement.berkeley.edu/bearbuy/', 'Campus'' procurement system that allows for catalog shopping and electronically-enabled workflows', true, '2014-05-12 13:03:08.975', '2014-05-12 13:03:08.975');
INSERT INTO links VALUES (721, 'Student Organizations Search', 'http://students.berkeley.edu/osl/studentgroups/public/index.asp', 'Cal''s clubs and organizations on campus', true, '2014-05-12 13:03:09.05', '2014-05-12 13:03:09.05');
INSERT INTO links VALUES (723, 'Physical Education Program', 'http://pe.berkeley.edu/', 'Physical education instructional courses for units', true, '2014-05-12 13:03:09.189', '2014-05-12 13:03:09.189');
INSERT INTO links VALUES (724, 'Berkeley Online Tour', 'http://www.berkeley.edu/tour/', 'Instructor and student perspectives and virtual campus tours of Berkeley', true, '2014-05-12 13:03:09.243', '2014-05-12 13:03:09.243');
INSERT INTO links VALUES (725, 'UC Berkeley Facebook page', 'http://www.facebook.com/UCBerkeley', 'Keep updated with Berkeley news through social media', true, '2014-05-12 13:03:09.32', '2014-05-12 13:03:09.32');
INSERT INTO links VALUES (726, 'CalNet', 'https://calnet.berkeley.edu/', 'An online identity username that all Berkeley affiliates have to log into Berkeley websites', true, '2014-05-12 13:03:09.391', '2014-05-12 13:03:09.391');
INSERT INTO links VALUES (727, 'Ethics & Compliance, Administrative guide', 'http://ethicscompliance.berkeley.edu/index.shtml', 'Contact information to report anything suspicious', true, '2014-05-12 13:03:09.462', '2014-05-12 13:03:09.462');
INSERT INTO links VALUES (728, 'Box.net', 'https://berkeley.box.com/', 'Cloud-hosted platform allowing users to store and share documents and other materials for collaborations', true, '2014-05-12 13:03:09.528', '2014-05-12 13:03:09.528');
INSERT INTO links VALUES (729, 'bDrive', 'http://bdrive.berkeley.edu', 'An area to store files that can be shared and collaborated', true, '2014-05-12 13:03:09.612', '2014-05-12 13:03:09.612');
INSERT INTO links VALUES (731, 'Facilities Services', 'http://www.cp.berkeley.edu/', 'Cleaning, landscaping and other services to maintain exceptional physical appearance', true, '2014-05-12 13:03:09.719', '2014-05-12 13:03:09.719');
INSERT INTO links VALUES (732, 'Campus IT Offices', 'http://www.berkeley.edu/admin/compute.shtml#offices', 'Contact information for information technology services', true, '2014-05-12 13:03:09.758', '2014-05-12 13:03:09.758');
INSERT INTO links VALUES (733, 'UC Learning Center', 'https://shib.berkeley.edu/idp/profile/Shibboleth/SSO?shire=https://uc.sumtotalsystems.com/Shibboleth.sso/SAML/POST&target=https://uc.sumtotalsystems.com/secure/auth.aspx&providerId=https://uc.sumtotalsystems.com/shibboleth', 'Various services that help students and instructors succeed', true, '2014-05-12 13:03:09.82', '2014-05-12 13:03:09.82');
INSERT INTO links VALUES (734, 'Teaching resources', 'http://teaching.berkeley.edu/teaching.html', 'Resources that promotes teaching and learning including consultation and program facilitation', true, '2014-05-12 13:03:09.882', '2014-05-12 13:03:09.882');
INSERT INTO links VALUES (735, 'Academic Senate', 'http://academic-senate.berkeley.edu/', 'Governance held by faculty member to make decisions campus-wide', true, '2014-05-12 13:03:09.911', '2014-05-12 13:03:09.911');
INSERT INTO links VALUES (736, 'iTunesU - Berkeley', 'http://itunes.berkeley.edu', 'Audio files of recordings from lectures or events', true, '2014-05-12 13:03:09.968', '2014-05-12 13:03:09.968');
INSERT INTO links VALUES (737, 'Edx Classes at Berkeley', 'https://www.edx.org/university_profile/BerkeleyX', 'Resources that advise, coordinate, and facilitate the University’s online education initiatives', true, '2014-05-12 13:03:10.053', '2014-05-12 13:03:10.053');
INSERT INTO links VALUES (738, 'Academic Departments & Programs', 'http://www.berkeley.edu/academics/dept/a.shtml', 'UC Berkeley''s variety of degree programs', true, '2014-05-12 13:03:10.139', '2014-05-12 13:03:10.139');
INSERT INTO links VALUES (739, 'Office of Undergraduate Advising', 'http://ls-advise.berkeley.edu/', 'Advising provided for students under the college of Letters and Science', true, '2014-05-12 13:03:10.208', '2014-05-12 13:03:10.208');
INSERT INTO links VALUES (740, 'Finding Your Way (L&S)', 'http://ls-yourway.berkeley.edu/', 'Academic advising for students in the Residence Halls under the college of Letters and Science', true, '2014-05-12 13:03:10.264', '2014-05-12 13:03:10.264');
INSERT INTO links VALUES (741, 'Academic Policies', 'http://bulletin.berkeley.edu/academicpolicies/', 'Policies set by the university specific for Berkeley students', true, '2014-05-12 13:03:10.326', '2014-05-12 13:03:10.326');
INSERT INTO links VALUES (742, 'Bear Facts', 'https://bearfacts.berkeley.edu', 'Academic record, grades & transcript, bill, degree audit, loans, SLR & personal info', true, '2014-05-12 13:03:10.39', '2014-05-12 13:03:10.39');
INSERT INTO links VALUES (743, 'Summer Sessions', 'http://summer.berkeley.edu/', 'Various programs and courses offered during summer for Berkeley students', true, '2014-05-12 13:03:10.434', '2014-05-12 13:03:10.434');
INSERT INTO links VALUES (744, 'Undergraduate Student Calendar & Deadlines', 'http://registrar.berkeley.edu/current_students/registration_enrollment/stucal.html', 'Student''s academic calendar ', true, '2014-05-12 13:03:10.497', '2014-05-12 13:03:10.497');
INSERT INTO links VALUES (745, 'Office of the Registrar', 'http://registrar.berkeley.edu/', 'Administrative office with helpful links and resources regarding Berkeley', true, '2014-05-12 13:03:10.53', '2014-05-12 13:03:10.53');
INSERT INTO links VALUES (746, 'UC Berkeley Wellness Letter', 'http://www.wellnessletter.com/ucberkeley/', 'Tips and information on how to stay healthy', true, '2014-05-12 13:03:10.592', '2014-05-12 13:03:10.592');
INSERT INTO links VALUES (747, 'Retirement Resources', 'http://thecenter.berkeley.edu/index.shtml', 'Programs and services that contribute to the well being of retired faculty', true, '2014-05-12 13:03:10.65', '2014-05-12 13:03:10.65');
INSERT INTO links VALUES (748, 'Personal Info - Campus Directory', 'https://calnet.berkeley.edu/directory/update/', 'Public contact information of Berkeley affiliates such as email addresses, UIDs, etc.', true, '2014-05-12 13:03:10.715', '2014-05-12 13:03:10.715');
INSERT INTO links VALUES (749, 'Cal Rentals', 'http://calrentals.housing.berkeley.edu/', 'Listings of housing opportunities for the Berkeley community', true, '2014-05-12 13:03:10.779', '2014-05-12 13:03:10.779');
INSERT INTO links VALUES (750, 'International House', 'http://ihouse.berkeley.edu/', 'On-campus dormitory with a dining common for international students', true, '2014-05-12 13:03:10.814', '2014-05-12 13:03:10.814');
INSERT INTO links VALUES (752, 'Living At Cal', 'http://www.housing.berkeley.edu/livingatcal/', 'UC Berkeley housing options', true, '2014-05-12 13:03:10.875', '2014-05-12 13:03:10.875');
INSERT INTO links VALUES (753, 'Residential & Student Service Programs', 'http://www.housing.berkeley.edu/', 'UC Berkeley housing options', true, '2014-05-12 13:03:10.906', '2014-05-12 13:03:10.906');
INSERT INTO links VALUES (754, 'Residential Computing (ResComp)', 'http://www.rescomp.berkeley.edu/', 'Computer and network services for students living in campus housing', true, '2014-05-12 13:03:10.972', '2014-05-12 13:03:10.972');
INSERT INTO links VALUES (755, 'CalDining', 'http://caldining.berkeley.edu/', 'Campus dining facilities', true, '2014-05-12 13:03:11.034', '2014-05-12 13:03:11.034');
INSERT INTO links VALUES (756, 'Child Care', 'http://www.housing.berkeley.edu/child/', 'Campus child care services', true, '2014-05-12 13:03:11.178', '2014-05-12 13:03:11.178');
INSERT INTO links VALUES (757, 'At Your Service', 'https://atyourserviceonline.ucop.edu', 'Benefits, Earnings, Taxes & Retirement', true, '2014-05-12 13:03:11.251', '2014-05-12 13:03:11.251');
INSERT INTO links VALUES (758, 'Personal Info - HR record', 'https://auth.berkeley.edu/cas/login?service=https://hrw-vip-prod.is.berkeley.edu/cgi-bin/cas-hrsprod.pl', 'HR personal data, requires log-in.', true, '2014-05-12 13:03:11.284', '2014-05-12 13:03:11.284');
INSERT INTO links VALUES (759, 'Retirement Benefits - At Your Service', 'https://atyourserviceonline.ucop.edu', 'Benefits, Earnings, Taxes & Retirement', true, '2014-05-12 13:03:11.317', '2014-05-12 13:03:11.317');
INSERT INTO links VALUES (864, 'CalTime', 'http://caltime.berkeley.edu', 'Tracking and reporting work and time leave-timekeeping', true, '2014-05-12 13:03:15.436', '2014-05-12 13:03:15.436');
INSERT INTO links VALUES (730, 'University Relations', 'http://www.urel.berkeley.edu/', 'Berkeley''s Public Affairs and fundraising Development division', true, '2014-05-12 13:03:09.682', '2014-05-30 23:25:00.713');
INSERT INTO links VALUES (762, 'UC SHIP (Student Health Insurance Plan)', 'http://www.uhs.berkeley.edu/students/insurance/', 'UC Student Health Insurance Plan', true, '2014-05-12 13:03:11.476', '2014-05-12 13:03:11.476');
INSERT INTO links VALUES (763, 'CARE Services', 'http://uhs.berkeley.edu/facstaff/care/', 'free, confidential problem assessment and referral for UC Berkeley faculty and staff', true, '2014-05-12 13:03:11.528', '2014-05-12 13:03:11.528');
INSERT INTO links VALUES (764, 'Organizational & Workforce Effectiveness', 'http://hrweb.berkeley.edu/learning/corwe', 'Organization supporting managers wanting to make organizational improvements', true, '2014-05-12 13:03:11.56', '2014-05-12 13:03:11.56');
INSERT INTO links VALUES (765, 'Policies & procedures A-Z', 'http://campuspol.chance.berkeley.edu/Home/AtoZPolicies.cfm?long_page=yes', 'A-Z of campuswide policies and procedures', true, '2014-05-12 13:03:11.589', '2014-05-12 13:03:11.589');
INSERT INTO links VALUES (766, 'Safety', 'http://police.berkeley.edu/index.html', 'Safety information and programs', true, '2014-05-12 13:03:11.652', '2014-05-12 13:03:11.652');
INSERT INTO links VALUES (767, 'Academic Calendar', 'http://registrar.berkeley.edu/CalendarDisp.aspx?terms=current', 'Academic Calendars Future Campus Calendars', true, '2014-05-12 13:03:11.688', '2014-05-12 13:03:11.688');
INSERT INTO links VALUES (768, 'Course Catalog', 'http://general-catalog.berkeley.edu/catalog/gcc_search_menu', 'Detailed course descriptions', true, '2014-05-12 13:03:11.727', '2014-05-12 13:03:11.727');
INSERT INTO links VALUES (769, 'Schedule of Classes', 'http://schedule.berkeley.edu/', 'Classes offerings by semester', true, '2014-05-12 13:03:11.78', '2014-05-12 13:03:11.78');
INSERT INTO links VALUES (770, 'DARS', 'https://marin.berkeley.edu/darsweb/servlet/ListAuditsServlet ', 'Degree requirements and track progress', true, '2014-05-12 13:03:11.823', '2014-05-12 13:03:11.823');
INSERT INTO links VALUES (771, 'Schedule Builder', 'https://schedulebuilder.berkeley.edu/', 'Plan your classes', true, '2014-05-12 13:03:11.851', '2014-05-12 13:03:11.851');
INSERT INTO links VALUES (772, 'TeleBears', 'https://telebears.berkeley.edu', 'Register for classes', true, '2014-05-12 13:03:11.887', '2014-05-12 13:03:11.887');
INSERT INTO links VALUES (773, 'Educational Opportunity Program', 'http://eop.berkeley.edu', 'Guidance and resources for first generation and low-income college students.', true, '2014-05-12 13:03:11.916', '2014-05-12 13:03:11.916');
INSERT INTO links VALUES (774, 'Library', 'http://library.berkeley.edu', 'Search the UC Library system', true, '2014-05-12 13:03:11.978', '2014-05-12 13:03:11.978');
INSERT INTO links VALUES (775, 'Research', 'http://berkeley.edu/research/', 'Directory of UC Berkeley research programs', true, '2014-05-12 13:03:12.042', '2014-05-12 13:03:12.042');
INSERT INTO links VALUES (776, 'bSpace', 'http://bspace.berkeley.edu', 'Homework assignments, lecture slides, syllabi and class resources', true, '2014-05-12 13:03:12.095', '2014-05-12 13:03:12.095');
INSERT INTO links VALUES (777, 'DeCal Courses', 'http://www.decal.org/ ', 'Catalog of student-led courses', true, '2014-05-12 13:03:12.146', '2014-05-12 13:03:12.146');
INSERT INTO links VALUES (778, 'UC Extension Classes', 'http://extension.berkeley.edu/', 'Professional development', true, '2014-05-12 13:03:12.199', '2014-05-12 13:03:12.199');
INSERT INTO links VALUES (779, 'bCourses', 'http://bcourses.berkeley.edu', 'Campus Learning Management System (LMS) powered by Canvas', true, '2014-05-12 13:03:12.235', '2014-05-12 13:03:12.235');
INSERT INTO links VALUES (780, 'Campus Bookstore', 'http://www.bkstr.com/webapp/wcs/stores/servlet/StoreCatalogDisplay?storeId=10433', 'Text books and more', true, '2014-05-12 13:03:12.27', '2014-05-12 13:03:12.27');
INSERT INTO links VALUES (781, 'Lab Safety', 'http://rac.berkeley.edu/compliancebook/labsafety.html', 'Lab Safety & Hazardous Materials Management', true, '2014-05-12 13:03:12.328', '2014-05-12 13:03:12.328');
INSERT INTO links VALUES (782, 'Berkeley Sites (A-Z)', 'http://www.berkeley.edu/a-z/a.shtml', 'Navigating UC Berkeley', true, '2014-05-12 13:03:12.361', '2014-05-12 13:03:12.361');
INSERT INTO links VALUES (783, 'Conduct Office', 'http://studentconduct.berkeley.edu', 'Student conduct office', true, '2014-05-12 13:03:12.417', '2014-05-12 13:03:12.417');
INSERT INTO links VALUES (784, 'bCal', 'http://bcal.berkeley.edu', 'personal calandar', true, '2014-05-12 13:03:12.449', '2014-05-12 13:03:12.449');
INSERT INTO links VALUES (785, 'bMail', 'http://bmail.berkeley.edu', 'email', true, '2014-05-12 13:03:12.482', '2014-05-12 13:03:12.482');
INSERT INTO links VALUES (786, 'CalMail', 'http://calmail.berkeley.edu', 'email', true, '2014-05-12 13:03:12.514', '2014-05-12 13:03:12.514');
INSERT INTO links VALUES (787, 'Imagine Services', 'http://imagine.berkeley.edu/', 'custom electronic document workflows', true, '2014-05-12 13:03:12.544', '2014-05-12 13:03:12.544');
INSERT INTO links VALUES (788, 'Mail Services', 'http://mailservices.berkeley.edu/', 'United States Postal Service-incoming and outgoing mail', true, '2014-05-12 13:03:12.598', '2014-05-12 13:03:12.598');
INSERT INTO links VALUES (789, 'BETS - equipment tracking', 'http://bets.berkeley.edu/BETS/home/BetsHome.cfm', 'Equipment Tracking System of inventorial and non-inventorial equipment', true, '2014-05-12 13:03:12.656', '2014-05-12 13:03:12.656');
INSERT INTO links VALUES (790, 'Cal Answers', 'http://calanswers.berkeley.edu/', 'Provides reliable and consistent answers to critical campus questions', true, '2014-05-12 13:03:12.708', '2014-05-12 13:03:12.708');
INSERT INTO links VALUES (791, 'Campus Shared Services', 'http://sharedservices.berkeley.edu/', 'Answers to questions and the ability to submit help requests', true, '2014-05-12 13:03:12.766', '2014-05-12 13:03:12.766');
INSERT INTO links VALUES (792, 'New Faculty resources', 'http://teaching.berkeley.edu/new-faculty-resources', 'Hints, resources, and guidelines on productive teaching', true, '2014-05-12 13:03:12.796', '2014-05-12 13:03:12.796');
INSERT INTO links VALUES (793, 'Computer Use Policy', 'https://security.berkeley.edu/policy/usepolicy.html', 'Rules, rights, and policies regarding computer facilities', true, '2014-05-12 13:03:12.823', '2014-05-12 13:03:12.823');
INSERT INTO links VALUES (794, 'Student Policies & Procedures', 'http://sa.berkeley.edu/sa/student-policies-and-procedures', 'Rules and policies enforced on students', true, '2014-05-12 13:03:12.858', '2014-05-12 13:03:12.858');
INSERT INTO links VALUES (795, 'Research Hub', 'https://hub.berkeley.edu', 'Tool for content management and collaboration such as managing research data and sharing documents', true, '2014-05-12 13:03:12.891', '2014-05-12 13:03:12.891');
INSERT INTO links VALUES (796, 'CalShare', 'https://calshare.berkeley.edu/', 'Tool for creating and managing web sites for collaboration purposes', true, '2014-05-12 13:03:12.925', '2014-05-12 13:03:12.925');
INSERT INTO links VALUES (799, 'Graduate Financial Support', 'http://www.grad.berkeley.edu/financial/', 'Resources to provide financial support for graduate students', true, '2014-05-12 13:03:13.072', '2014-05-12 13:03:13.072');
INSERT INTO links VALUES (801, 'Office of the Chancellor', 'http://chancellor.berkeley.edu/', 'Meet Chancellor Nicholas B. Dirks', true, '2014-05-12 13:03:13.136', '2014-05-12 13:03:13.136');
INSERT INTO links VALUES (802, 'Equity, Inclusion & Diversity', 'http://diversity.berkeley.edu/', 'Creating a fair and inclusive society for all individuals', true, '2014-05-12 13:03:13.169', '2014-05-12 13:03:13.169');
INSERT INTO links VALUES (803, 'Administration & Finance', 'http://vcaf.berkeley.edu/divisions', 'Adminstration officials ', true, '2014-05-12 13:03:13.203', '2014-05-12 13:03:13.203');
INSERT INTO links VALUES (804, 'Learning Resources', 'http://hrweb.berkeley.edu/learning', 'Supports the development of the workforce with learning and development programs', true, '2014-05-12 13:03:13.251', '2014-05-12 13:03:13.251');
INSERT INTO links VALUES (805, 'Environmental Health & Safety', 'http://www.ehs.berkeley.edu/', 'Services to the campus community that promote health, safety, and environmental stewardship', true, '2014-05-12 13:03:13.281', '2014-05-12 13:03:13.281');
INSERT INTO links VALUES (806, 'Grade book', 'http://gsi.berkeley.edu/teachingguide/tech/bspace-gradebook.html', 'A tool to enter, upload, and calculate student grades on bSpace', true, '2014-05-12 13:03:13.334', '2014-05-12 13:03:13.334');
INSERT INTO links VALUES (807, 'Webcast Support', 'http://ets.berkeley.edu/about-webcastberkeley', 'Help with audio and video recordings of class lectures and events that made available through UC Berkeley''s channels', true, '2014-05-12 13:03:13.361', '2014-05-12 13:03:13.361');
INSERT INTO links VALUES (808, 'bSpace Support', 'http://ets.berkeley.edu/bspace', 'A communication and collaboration program that supports teaching and learning', true, '2014-05-12 13:03:13.389', '2014-05-12 13:03:13.389');
INSERT INTO links VALUES (809, 'Student Learning Center', 'http://slc.berkeley.edu', 'Resources such as tutoring and is open 24 hour to provide students with a place to study', true, '2014-05-12 13:03:13.416', '2014-05-12 13:03:13.416');
INSERT INTO links VALUES (810, 'Faculty gateway', 'http://berkeley.edu/faculty/', 'Useful resources for faculty members ', true, '2014-05-12 13:03:13.442', '2014-05-12 13:03:13.442');
INSERT INTO links VALUES (800, 'Student Affairs', 'http://sa.berkeley.edu/', 'Berkeley''s division responsible for many student life services including the Registrar, Admissions, Financial Aid, Housing & Dining, Conduct, Public Service Center, LEAD center, and ASUC auxiliary', true, '2014-05-12 13:03:13.102', '2014-05-30 23:27:20.746');
INSERT INTO links VALUES (761, 'UHS - Tang Center', 'http://uhs.berkeley.edu/', 'Berkeley''s healthcare center', true, '2014-05-12 13:03:11.441', '2014-05-30 23:31:27.978');
INSERT INTO links VALUES (811, 'Classroom Technology', 'http://ets.berkeley.edu/classroom-technology/', 'Provide reliable resources and technical support to the UCB campus', true, '2014-05-12 13:03:13.491', '2014-05-12 13:03:13.491');
INSERT INTO links VALUES (812, 'YouTube - UC Berkeley', 'http://www.youtube.com/user/UCBerkeley', 'Videos relating to UC Berkeley on an external website', true, '2014-05-12 13:03:13.515', '2014-05-12 13:03:13.515');
INSERT INTO links VALUES (813, 'Berkeley Research', 'http://vcresearch.berkeley.edu/', 'Research information and opportunities', true, '2014-05-12 13:03:13.541', '2014-05-12 13:03:13.541');
INSERT INTO links VALUES (814, 'Graduate Division', 'http://www.grad.berkeley.edu/', 'Information and resources for prospective and graduate students', true, '2014-05-12 13:03:13.6', '2014-05-12 13:03:13.6');
INSERT INTO links VALUES (816, 'Colleges & Schools', 'http://www.berkeley.edu/academics/school.shtml', 'Different departments (colleges) that majors fall under', true, '2014-05-12 13:03:13.666', '2014-05-12 13:03:13.666');
INSERT INTO links VALUES (817, 'Cal Student Central', 'http://studentcentral.berkeley.edu/', 'A resourceful website with answers to the most frequently asked questions by students', true, '2014-05-12 13:03:13.729', '2014-05-12 13:03:13.729');
INSERT INTO links VALUES (818, 'Personnel Policies', 'http://hrweb.berkeley.edu/er/policies', 'Employee relations - personnel policies', true, '2014-05-12 13:03:13.758', '2014-05-12 13:03:13.758');
INSERT INTO links VALUES (820, 'Campus Directory - People Finder', 'http://directory.berkeley.edu', 'Campus directory of faculty, staff and students', true, '2014-05-12 13:03:13.867', '2014-05-12 13:03:13.867');
INSERT INTO links VALUES (821, 'Public Service Center', 'http://publicservice.berkeley.edu', 'On and off campus community service engagement', true, '2014-05-12 13:03:13.904', '2014-05-12 13:03:13.904');
INSERT INTO links VALUES (822, 'Events.Berkeley', 'http://events.berkeley.edu', 'Campus events calendar', true, '2014-05-12 13:03:13.964', '2014-05-12 13:03:13.964');
INSERT INTO links VALUES (823, 'The Daily Californian (The DailyCal)', 'http://www.dailycal.org/', 'an independent student newspaper', true, '2014-05-12 13:03:13.995', '2014-05-12 13:03:13.995');
INSERT INTO links VALUES (824, 'Campus Map', 'http://www.berkeley.edu/map/3dmap/3dmap.shtml', 'Locate campus buildings', true, '2014-05-12 13:03:14.056', '2014-05-12 13:03:14.056');
INSERT INTO links VALUES (825, 'Parking & Transportation', 'http://pt.berkeley.edu/', 'Parking lots, transportation, car sharing, etc.', true, '2014-05-12 13:03:14.115', '2014-05-12 13:03:14.115');
INSERT INTO links VALUES (826, 'Emergency information', 'http://emergency.berkeley.edu/', 'Go-to site for emergency response information', true, '2014-05-12 13:03:14.148', '2014-05-12 13:03:14.148');
INSERT INTO links VALUES (827, 'Police & Safety', 'http://police.berkeley.edu', 'Campus police and safety', true, '2014-05-12 13:03:14.207', '2014-05-12 13:03:14.207');
INSERT INTO links VALUES (828, 'Recreational Sports Facility', 'http://recsports.berkeley.edu/ ', 'Sports and fitness programs', true, '2014-05-12 13:03:14.236', '2014-05-12 13:03:14.236');
INSERT INTO links VALUES (829, 'Cal Marketplace', 'http://calmarketplace.berkeley.edu/', 'everything at Cal you may want to buy, discover or visit', true, '2014-05-12 13:03:14.266', '2014-05-12 13:03:14.266');
INSERT INTO links VALUES (830, 'KALX', 'http://kalx.berkeley.edu/', '90.7 MHz. Berkeley''s campus radio station', true, '2014-05-12 13:03:14.305', '2014-05-12 13:03:14.305');
INSERT INTO links VALUES (831, 'ASUC', 'http://asuc.org/', 'Student government', true, '2014-05-12 13:03:14.368', '2014-05-12 13:03:14.368');
INSERT INTO links VALUES (832, 'Graduate Assembly', 'https://ga.berkeley.edu/', 'Graduate student government', true, '2014-05-12 13:03:14.396', '2014-05-12 13:03:14.396');
INSERT INTO links VALUES (833, 'CalLink (Campus Activities Link)', 'http://callink.berkeley.edu/', 'Official campus student groups', true, '2014-05-12 13:03:14.424', '2014-05-12 13:03:14.424');
INSERT INTO links VALUES (834, 'Student Ombuds', 'http://sa.berkeley.edu/ombuds', 'Confidential help with campus issues, conflict situations, and more', true, '2014-05-12 13:03:14.457', '2014-05-12 13:03:14.457');
INSERT INTO links VALUES (835, 'Resource Guide for Students', 'http://resource.berkeley.edu/', 'Comprehensive campus guide for students', true, '2014-05-12 13:03:14.484', '2014-05-12 13:03:14.484');
INSERT INTO links VALUES (836, 'Career Center', 'http://career.berkeley.edu/', 'Cal jobs, internships & career counseling', true, '2014-05-12 13:03:14.535', '2014-05-12 13:03:14.535');
INSERT INTO links VALUES (838, 'CalGreeks', 'http://www.calgreeks.com/', 'Fraternities, Sororities, and professional fraternities among the Greek Family', true, '2014-05-12 13:03:14.604', '2014-05-12 13:03:14.604');
INSERT INTO links VALUES (839, 'Cal Band', 'http://calband.berkeley.edu/', 'UC Berkeley''s marching band', true, '2014-05-12 13:03:14.658', '2014-05-12 13:03:14.658');
INSERT INTO links VALUES (840, 'Cal Performances', 'http://www.calperformances.org/', 'Information and tickets for Cal music, dance, and theater performances', true, '2014-05-12 13:03:14.687', '2014-05-12 13:03:14.687');
INSERT INTO links VALUES (841, 'Career Center: Part-time Employment', 'https://career.berkeley.edu/Parttime/Parttime.stm', 'Links to part-time websites', true, '2014-05-12 13:03:14.715', '2014-05-12 13:03:14.715');
INSERT INTO links VALUES (842, 'Class pass', 'http://pt.berkeley.edu/pay/transit/classpass/', 'AC Transit Pass to bus for free', true, '2014-05-12 13:03:14.744', '2014-05-12 13:03:14.744');
INSERT INTO links VALUES (843, 'Career Center: Internships', 'https://career.berkeley.edu/Internships/Internships.stm', 'Resources and Information for Internships', true, '2014-05-12 13:03:14.767', '2014-05-12 13:03:14.767');
INSERT INTO links VALUES (844, 'Career Center: Job Search Tools', 'https://career.berkeley.edu/Tools/Tools.stm', 'Resources on how to find a good job or internship ', true, '2014-05-12 13:03:14.79', '2014-05-12 13:03:14.79');
INSERT INTO links VALUES (845, 'Callisto & CalJobs', 'https://career.berkeley.edu/CareerApps/Callisto/CallistoLogin.aspx', 'Official Berkeley website for all things job-related', true, '2014-05-12 13:03:14.812', '2014-05-12 13:03:14.812');
INSERT INTO links VALUES (846, 'Transfer, Re-entry and Student Parent Center', 'http://trsp.berkeley.edu/', 'Resources specific to transfer, re-entering, and parent students', true, '2014-05-12 13:03:14.835', '2014-05-12 13:03:14.835');
INSERT INTO links VALUES (847, 'Disabled Students Program', 'http://dsp.berkeley.edu/', 'Resources specific to disabled students', true, '2014-05-12 13:03:14.857', '2014-05-12 13:03:14.857');
INSERT INTO links VALUES (848, 'New Student Services (includes CalSO)', 'http://nss.berkeley.edu/', 'Helping new undergrads get the most out of Cal', true, '2014-05-12 13:03:14.881', '2014-05-12 13:03:14.881');
INSERT INTO links VALUES (849, 'Cal Spirit Groups', 'http://calspirit.berkeley.edu/', 'Cheerleading and Dance Group ', true, '2014-05-12 13:03:14.922', '2014-05-12 13:03:14.922');
INSERT INTO links VALUES (850, 'CalBears Intercollegiate Athletics', 'http://www.calbears.com/', 'Berkeley''s official sport teams', true, '2014-05-12 13:03:14.975', '2014-05-12 13:03:14.975');
INSERT INTO links VALUES (851, 'UC Berkeley museums', 'http://bnhm.berkeley.edu/', 'Berkeley''s national history museums ', true, '2014-05-12 13:03:15.009', '2014-05-12 13:03:15.009');
INSERT INTO links VALUES (852, 'Emergency Preparedness', 'http://oep.berkeley.edu/', 'How to be prepared and ready for emergencies', true, '2014-05-12 13:03:15.04', '2014-05-12 13:03:15.04');
INSERT INTO links VALUES (853, '511.org (Bay Area Transportation Planner)', 'http://www.511.org/', 'Calculates transportation options for traveling', true, '2014-05-12 13:03:15.069', '2014-05-12 13:03:15.069');
INSERT INTO links VALUES (854, 'Campus Shuttles', 'http://pt.berkeley.edu/around/transit/routes/', 'Bus routes around the Berkeley campus (most are free)', true, '2014-05-12 13:03:15.098', '2014-05-12 13:03:15.098');
INSERT INTO links VALUES (857, 'Newscenter', 'http://newscenter.berkeley.edu', 'News affiliated with UC Berkeley', true, '2014-05-12 13:03:15.183', '2014-05-12 13:03:15.183');
INSERT INTO links VALUES (858, 'Campaign for Berkeley', 'http://campaign.berkeley.edu/', 'The campaign to raise money to help Berkeley''s programs and affiliates', true, '2014-05-12 13:03:15.214', '2014-05-12 13:03:15.214');
INSERT INTO links VALUES (860, 'SARA - request system access', 'http://www.bai.berkeley.edu/BFS/systems/systemAccess.htm', 'Form that grants access to different systems for employees', true, '2014-05-12 13:03:15.308', '2014-05-12 13:03:15.308');
INSERT INTO links VALUES (861, 'AirBears', 'http://ist.berkeley.edu/airbears/', 'Berkeley''s free internet wifi for Berkeley affiliates with a calnet and passphrase', true, '2014-05-12 13:03:15.335', '2014-05-12 13:03:15.335');
INSERT INTO links VALUES (863, 'Payroll', 'http://controller.berkeley.edu/payroll/', 'Providing accurate paychecks to Berkeley employees', true, '2014-05-12 13:03:15.411', '2014-05-12 13:03:15.411');
INSERT INTO links VALUES (856, 'The Berkeley Blog', 'http://blogs.berkeley.edu', 'Issues that are being discussed by members of Berkeley''s academic community ', true, '2014-05-12 13:03:15.154', '2014-05-30 23:10:30.044');
INSERT INTO links VALUES (859, 'Blu', 'http://blu.berkeley.edu', 'Berkeley''s employee portal: work-related tools and information', true, '2014-05-12 13:03:15.277', '2014-05-30 23:11:26.962');
INSERT INTO links VALUES (819, 'Cal 1 Card', 'http://services.housing.berkeley.edu/c1c/static/index.htm', 'The campus identification, and optional, debit and meal points card.', true, '2014-05-12 13:03:13.795', '2014-05-30 23:13:11.66');
INSERT INTO links VALUES (862, 'Blu Card', 'http://businessservices.berkeley.edu/cards/blucard', 'A procurement card, issued to select employees, and used for purchasing work-related items and services', true, '2014-05-12 13:03:15.362', '2014-05-30 23:14:49.855');
INSERT INTO links VALUES (815, 'Executive Vice Chancellor & Provost', 'http://evcp.chance.berkeley.edu/', 'Meet Executive Vice Chancellor and Provost, Claude M. Steele', true, '2014-05-12 13:03:13.633', '2014-05-30 23:30:10.068');
INSERT INTO links VALUES (866, 'HR System', 'http://hrweb.berkeley.edu/hcm', 'Recording personal information and action for the Berkeley community', true, '2014-05-12 13:03:15.484', '2014-05-12 13:03:15.484');
INSERT INTO links VALUES (867, 'BFS', 'http://www.bai.berkeley.edu/', 'Berkeley''s Financial System', true, '2014-05-12 13:03:15.508', '2014-05-12 13:03:15.508');
INSERT INTO links VALUES (868, 'Software Central', 'http://ist.berkeley.edu/software-central/', 'Free software for Berkeley affiliates (ex. Adobe, Word, etc.)', true, '2014-05-12 13:03:15.533', '2014-05-12 13:03:15.533');
INSERT INTO links VALUES (869, 'IST Support', 'http://ist.berkeley.edu/support/', 'Information Technology support for services and systems', true, '2014-05-12 13:03:15.558', '2014-05-12 13:03:15.558');
INSERT INTO links VALUES (870, 'IST Knowledge Base', 'http://ist.berkeley.edu/support/kb', 'Contains answers to Berkeley computing and IT questions', true, '2014-05-12 13:03:15.586', '2014-05-12 13:03:15.586');
INSERT INTO links VALUES (872, 'Billing Services', 'http://studentbilling.berkeley.edu/', 'Billing and payment options for students and parents', true, '2014-05-12 13:03:15.658', '2014-05-12 13:03:15.658');
INSERT INTO links VALUES (874, 'MyFinAid', 'https://myfinaid.berkeley.edu/', 'Manage your Financial Aid Awards-grants, scholarships, work-study, loans, etc.', true, '2014-05-12 13:03:15.706', '2014-05-12 13:03:15.706');
INSERT INTO links VALUES (877, 'Summer Session', 'http://summer.berkeley.edu/', 'Various programs and courses offered during summer for Berkeley students', true, '2014-05-12 13:03:15.826', '2014-05-12 13:03:15.826');
INSERT INTO links VALUES (879, 'Schedule & Deadlines', 'http://summer.berkeley.edu/registration/schedule', 'Key dates and deadlines for summer sessions', true, '2014-05-12 13:03:15.902', '2014-05-12 13:03:15.902');
INSERT INTO links VALUES (880, 'Withdrawing or Canceling?', 'http://registrar.berkeley.edu/canwd.html ', 'Learn more about what you need to do if you are planning to cancel, withdraw and readmit to UC Berkeley', true, '2014-05-12 13:03:15.925', '2014-05-12 13:03:15.925');
INSERT INTO links VALUES (881, 'Tax 1098-T Form', 'http://studentbilling.berkeley.edu/taxpayer.htm', 'Start here to access your 1098-T form', true, '2014-05-12 13:03:15.947', '2014-05-12 13:03:15.947');
INSERT INTO links VALUES (882, 'Payment Options', 'http://studentbilling.berkeley.edu/carsPaymentOptions.htm', 'Learn more about the options for making payment either electronically or by check to your CARS account', true, '2014-05-12 13:03:15.97', '2014-05-12 13:03:15.97');
INSERT INTO links VALUES (883, 'e-bills', 'https://bearfacts.berkeley.edu/bearfacts/student/CARS/ebill.do?bfaction=accessEBill ', 'Pay your CARS bill online with either Electronic Billing (e-Bill) or Electronic Payment (e-Check)', true, '2014-05-12 13:03:15.992', '2014-05-12 13:03:15.992');
INSERT INTO links VALUES (875, 'Student Budgets', 'http://financialaid.berkeley.edu/cost-attendance', 'Estimated living expense amounts for students', true, '2014-05-12 13:03:15.73', '2014-05-30 22:46:33.044');
INSERT INTO links VALUES (871, 'Registration Fees', 'http://registrar.berkeley.edu/Registration/feesched.html', 'Required Berkeley fees to be a Registered Student', true, '2014-05-12 13:03:15.635', '2014-05-30 22:49:07.644');
INSERT INTO links VALUES (884, 'Financial Aid & Scholarships Office', 'http://financialaid.berkeley.edu', 'Start here to learn about Financial Aid and for step-by-step guidance about financial aid and select scholarships at UC Berkeley', true, '2014-05-12 13:03:16.015', '2014-05-30 22:51:45.135');
INSERT INTO links VALUES (873, 'FAFSA', 'https://fafsa.ed.gov/', 'Free Application for Federal Student Aid (FAFSA),annual form submission required to receive financial aid', true, '2014-05-12 13:03:15.683', '2014-05-30 22:54:14.846');
INSERT INTO links VALUES (876, 'Have a loan?', 'http://studentbilling.berkeley.edu/exitDirect.htm', 'Getting ready to graduate? Learn about your responsibilities for paying back your loans through the Exit Loan Counseling requirement', true, '2014-05-12 13:03:15.78', '2014-05-30 22:59:00.23');
INSERT INTO links VALUES (878, 'Work-Study', 'http://financialaid.berkeley.edu/work-study', 'A program that can help you lower your federal loan debt amount through work-study eligible jobs on campus', true, '2014-05-12 13:03:15.876', '2014-05-30 23:04:39.222');
INSERT INTO links VALUES (865, 'Campus Deposit System (CDS)', 'https://cdsonline.berkeley.edu', 'Financial system used by departments to make cash deposits to their accounts', true, '2014-05-12 13:03:15.461', '2014-05-30 23:18:36.518');
INSERT INTO links VALUES (751, 'Berkeley Student Cooperative', 'http://www.bsc.coop/', 'Berkeley''s co-operative student housing option, and an alternative to living in student dorms', true, '2014-05-12 13:03:10.844', '2014-05-30 23:34:03.522');


--
-- Name: links_id_seq; Type: SEQUENCE SET; Schema: public; Owner: calcentral
--

SELECT pg_catalog.setval('links_id_seq', 884, true);


--
-- Data for Name: links_user_roles; Type: TABLE DATA; Schema: public; Owner: calcentral
--

INSERT INTO links_user_roles VALUES (710, 1);
INSERT INTO links_user_roles VALUES (710, 3);
INSERT INTO links_user_roles VALUES (710, 2);
INSERT INTO links_user_roles VALUES (711, 1);
INSERT INTO links_user_roles VALUES (711, 3);
INSERT INTO links_user_roles VALUES (711, 2);
INSERT INTO links_user_roles VALUES (712, 1);
INSERT INTO links_user_roles VALUES (712, 3);
INSERT INTO links_user_roles VALUES (712, 2);
INSERT INTO links_user_roles VALUES (713, 3);
INSERT INTO links_user_roles VALUES (713, 2);
INSERT INTO links_user_roles VALUES (714, 3);
INSERT INTO links_user_roles VALUES (714, 2);
INSERT INTO links_user_roles VALUES (715, 3);
INSERT INTO links_user_roles VALUES (715, 2);
INSERT INTO links_user_roles VALUES (716, 3);
INSERT INTO links_user_roles VALUES (716, 2);
INSERT INTO links_user_roles VALUES (717, 1);
INSERT INTO links_user_roles VALUES (717, 3);
INSERT INTO links_user_roles VALUES (717, 2);
INSERT INTO links_user_roles VALUES (718, 1);
INSERT INTO links_user_roles VALUES (718, 3);
INSERT INTO links_user_roles VALUES (718, 2);
INSERT INTO links_user_roles VALUES (719, 3);
INSERT INTO links_user_roles VALUES (719, 2);
INSERT INTO links_user_roles VALUES (720, 3);
INSERT INTO links_user_roles VALUES (720, 2);
INSERT INTO links_user_roles VALUES (721, 1);
INSERT INTO links_user_roles VALUES (722, 1);
INSERT INTO links_user_roles VALUES (723, 1);
INSERT INTO links_user_roles VALUES (724, 1);
INSERT INTO links_user_roles VALUES (724, 3);
INSERT INTO links_user_roles VALUES (724, 2);
INSERT INTO links_user_roles VALUES (725, 1);
INSERT INTO links_user_roles VALUES (726, 1);
INSERT INTO links_user_roles VALUES (726, 3);
INSERT INTO links_user_roles VALUES (726, 2);
INSERT INTO links_user_roles VALUES (727, 3);
INSERT INTO links_user_roles VALUES (727, 2);
INSERT INTO links_user_roles VALUES (728, 1);
INSERT INTO links_user_roles VALUES (728, 3);
INSERT INTO links_user_roles VALUES (728, 2);
INSERT INTO links_user_roles VALUES (729, 1);
INSERT INTO links_user_roles VALUES (729, 3);
INSERT INTO links_user_roles VALUES (729, 2);
INSERT INTO links_user_roles VALUES (730, 1);
INSERT INTO links_user_roles VALUES (730, 3);
INSERT INTO links_user_roles VALUES (730, 2);
INSERT INTO links_user_roles VALUES (731, 1);
INSERT INTO links_user_roles VALUES (731, 3);
INSERT INTO links_user_roles VALUES (731, 2);
INSERT INTO links_user_roles VALUES (732, 1);
INSERT INTO links_user_roles VALUES (732, 3);
INSERT INTO links_user_roles VALUES (732, 2);
INSERT INTO links_user_roles VALUES (733, 3);
INSERT INTO links_user_roles VALUES (733, 2);
INSERT INTO links_user_roles VALUES (734, 3);
INSERT INTO links_user_roles VALUES (735, 3);
INSERT INTO links_user_roles VALUES (736, 1);
INSERT INTO links_user_roles VALUES (736, 3);
INSERT INTO links_user_roles VALUES (736, 2);
INSERT INTO links_user_roles VALUES (737, 1);
INSERT INTO links_user_roles VALUES (737, 3);
INSERT INTO links_user_roles VALUES (737, 2);
INSERT INTO links_user_roles VALUES (738, 1);
INSERT INTO links_user_roles VALUES (738, 3);
INSERT INTO links_user_roles VALUES (738, 2);
INSERT INTO links_user_roles VALUES (739, 1);
INSERT INTO links_user_roles VALUES (740, 1);
INSERT INTO links_user_roles VALUES (741, 1);
INSERT INTO links_user_roles VALUES (741, 3);
INSERT INTO links_user_roles VALUES (741, 2);
INSERT INTO links_user_roles VALUES (742, 1);
INSERT INTO links_user_roles VALUES (742, 3);
INSERT INTO links_user_roles VALUES (742, 2);
INSERT INTO links_user_roles VALUES (743, 1);
INSERT INTO links_user_roles VALUES (743, 3);
INSERT INTO links_user_roles VALUES (743, 2);
INSERT INTO links_user_roles VALUES (744, 1);
INSERT INTO links_user_roles VALUES (744, 3);
INSERT INTO links_user_roles VALUES (744, 2);
INSERT INTO links_user_roles VALUES (745, 1);
INSERT INTO links_user_roles VALUES (745, 3);
INSERT INTO links_user_roles VALUES (745, 2);
INSERT INTO links_user_roles VALUES (746, 1);
INSERT INTO links_user_roles VALUES (747, 3);
INSERT INTO links_user_roles VALUES (747, 2);
INSERT INTO links_user_roles VALUES (748, 3);
INSERT INTO links_user_roles VALUES (748, 2);
INSERT INTO links_user_roles VALUES (749, 1);
INSERT INTO links_user_roles VALUES (749, 3);
INSERT INTO links_user_roles VALUES (749, 2);
INSERT INTO links_user_roles VALUES (750, 1);
INSERT INTO links_user_roles VALUES (751, 1);
INSERT INTO links_user_roles VALUES (752, 1);
INSERT INTO links_user_roles VALUES (753, 1);
INSERT INTO links_user_roles VALUES (754, 1);
INSERT INTO links_user_roles VALUES (755, 1);
INSERT INTO links_user_roles VALUES (755, 3);
INSERT INTO links_user_roles VALUES (755, 2);
INSERT INTO links_user_roles VALUES (756, 1);
INSERT INTO links_user_roles VALUES (756, 3);
INSERT INTO links_user_roles VALUES (756, 2);
INSERT INTO links_user_roles VALUES (757, 3);
INSERT INTO links_user_roles VALUES (757, 2);
INSERT INTO links_user_roles VALUES (758, 3);
INSERT INTO links_user_roles VALUES (758, 2);
INSERT INTO links_user_roles VALUES (759, 3);
INSERT INTO links_user_roles VALUES (759, 2);
INSERT INTO links_user_roles VALUES (760, 3);
INSERT INTO links_user_roles VALUES (760, 2);
INSERT INTO links_user_roles VALUES (761, 1);
INSERT INTO links_user_roles VALUES (761, 3);
INSERT INTO links_user_roles VALUES (761, 2);
INSERT INTO links_user_roles VALUES (762, 1);
INSERT INTO links_user_roles VALUES (763, 3);
INSERT INTO links_user_roles VALUES (763, 2);
INSERT INTO links_user_roles VALUES (764, 2);
INSERT INTO links_user_roles VALUES (765, 1);
INSERT INTO links_user_roles VALUES (765, 3);
INSERT INTO links_user_roles VALUES (765, 2);
INSERT INTO links_user_roles VALUES (766, 1);
INSERT INTO links_user_roles VALUES (766, 3);
INSERT INTO links_user_roles VALUES (766, 2);
INSERT INTO links_user_roles VALUES (767, 1);
INSERT INTO links_user_roles VALUES (767, 3);
INSERT INTO links_user_roles VALUES (767, 2);
INSERT INTO links_user_roles VALUES (768, 1);
INSERT INTO links_user_roles VALUES (768, 3);
INSERT INTO links_user_roles VALUES (768, 2);
INSERT INTO links_user_roles VALUES (769, 1);
INSERT INTO links_user_roles VALUES (769, 3);
INSERT INTO links_user_roles VALUES (769, 2);
INSERT INTO links_user_roles VALUES (770, 1);
INSERT INTO links_user_roles VALUES (771, 1);
INSERT INTO links_user_roles VALUES (771, 3);
INSERT INTO links_user_roles VALUES (771, 2);
INSERT INTO links_user_roles VALUES (772, 1);
INSERT INTO links_user_roles VALUES (773, 1);
INSERT INTO links_user_roles VALUES (774, 1);
INSERT INTO links_user_roles VALUES (774, 3);
INSERT INTO links_user_roles VALUES (774, 2);
INSERT INTO links_user_roles VALUES (775, 1);
INSERT INTO links_user_roles VALUES (775, 3);
INSERT INTO links_user_roles VALUES (775, 2);
INSERT INTO links_user_roles VALUES (776, 1);
INSERT INTO links_user_roles VALUES (776, 3);
INSERT INTO links_user_roles VALUES (776, 2);
INSERT INTO links_user_roles VALUES (777, 1);
INSERT INTO links_user_roles VALUES (777, 3);
INSERT INTO links_user_roles VALUES (777, 2);
INSERT INTO links_user_roles VALUES (778, 1);
INSERT INTO links_user_roles VALUES (778, 3);
INSERT INTO links_user_roles VALUES (778, 2);
INSERT INTO links_user_roles VALUES (779, 1);
INSERT INTO links_user_roles VALUES (779, 3);
INSERT INTO links_user_roles VALUES (779, 2);
INSERT INTO links_user_roles VALUES (780, 1);
INSERT INTO links_user_roles VALUES (780, 3);
INSERT INTO links_user_roles VALUES (781, 1);
INSERT INTO links_user_roles VALUES (781, 3);
INSERT INTO links_user_roles VALUES (781, 2);
INSERT INTO links_user_roles VALUES (782, 1);
INSERT INTO links_user_roles VALUES (782, 3);
INSERT INTO links_user_roles VALUES (782, 2);
INSERT INTO links_user_roles VALUES (783, 1);
INSERT INTO links_user_roles VALUES (783, 3);
INSERT INTO links_user_roles VALUES (783, 2);
INSERT INTO links_user_roles VALUES (784, 1);
INSERT INTO links_user_roles VALUES (784, 3);
INSERT INTO links_user_roles VALUES (784, 2);
INSERT INTO links_user_roles VALUES (785, 1);
INSERT INTO links_user_roles VALUES (785, 3);
INSERT INTO links_user_roles VALUES (785, 2);
INSERT INTO links_user_roles VALUES (786, 1);
INSERT INTO links_user_roles VALUES (786, 3);
INSERT INTO links_user_roles VALUES (786, 2);
INSERT INTO links_user_roles VALUES (787, 2);
INSERT INTO links_user_roles VALUES (788, 3);
INSERT INTO links_user_roles VALUES (788, 2);
INSERT INTO links_user_roles VALUES (789, 2);
INSERT INTO links_user_roles VALUES (790, 3);
INSERT INTO links_user_roles VALUES (790, 2);
INSERT INTO links_user_roles VALUES (791, 3);
INSERT INTO links_user_roles VALUES (791, 2);
INSERT INTO links_user_roles VALUES (792, 3);
INSERT INTO links_user_roles VALUES (793, 1);
INSERT INTO links_user_roles VALUES (793, 3);
INSERT INTO links_user_roles VALUES (793, 2);
INSERT INTO links_user_roles VALUES (794, 1);
INSERT INTO links_user_roles VALUES (794, 3);
INSERT INTO links_user_roles VALUES (794, 2);
INSERT INTO links_user_roles VALUES (795, 1);
INSERT INTO links_user_roles VALUES (795, 3);
INSERT INTO links_user_roles VALUES (795, 2);
INSERT INTO links_user_roles VALUES (796, 3);
INSERT INTO links_user_roles VALUES (796, 2);
INSERT INTO links_user_roles VALUES (797, 2);
INSERT INTO links_user_roles VALUES (798, 1);
INSERT INTO links_user_roles VALUES (798, 3);
INSERT INTO links_user_roles VALUES (798, 2);
INSERT INTO links_user_roles VALUES (799, 1);
INSERT INTO links_user_roles VALUES (800, 1);
INSERT INTO links_user_roles VALUES (800, 3);
INSERT INTO links_user_roles VALUES (800, 2);
INSERT INTO links_user_roles VALUES (801, 1);
INSERT INTO links_user_roles VALUES (801, 3);
INSERT INTO links_user_roles VALUES (801, 2);
INSERT INTO links_user_roles VALUES (802, 1);
INSERT INTO links_user_roles VALUES (802, 3);
INSERT INTO links_user_roles VALUES (802, 2);
INSERT INTO links_user_roles VALUES (803, 1);
INSERT INTO links_user_roles VALUES (803, 3);
INSERT INTO links_user_roles VALUES (803, 2);
INSERT INTO links_user_roles VALUES (804, 3);
INSERT INTO links_user_roles VALUES (804, 2);
INSERT INTO links_user_roles VALUES (805, 1);
INSERT INTO links_user_roles VALUES (806, 3);
INSERT INTO links_user_roles VALUES (807, 3);
INSERT INTO links_user_roles VALUES (808, 3);
INSERT INTO links_user_roles VALUES (809, 1);
INSERT INTO links_user_roles VALUES (810, 3);
INSERT INTO links_user_roles VALUES (811, 3);
INSERT INTO links_user_roles VALUES (812, 1);
INSERT INTO links_user_roles VALUES (813, 1);
INSERT INTO links_user_roles VALUES (813, 3);
INSERT INTO links_user_roles VALUES (813, 2);
INSERT INTO links_user_roles VALUES (814, 1);
INSERT INTO links_user_roles VALUES (814, 3);
INSERT INTO links_user_roles VALUES (814, 2);
INSERT INTO links_user_roles VALUES (815, 1);
INSERT INTO links_user_roles VALUES (815, 3);
INSERT INTO links_user_roles VALUES (815, 2);
INSERT INTO links_user_roles VALUES (816, 1);
INSERT INTO links_user_roles VALUES (816, 3);
INSERT INTO links_user_roles VALUES (816, 2);
INSERT INTO links_user_roles VALUES (817, 1);
INSERT INTO links_user_roles VALUES (818, 3);
INSERT INTO links_user_roles VALUES (818, 2);
INSERT INTO links_user_roles VALUES (819, 1);
INSERT INTO links_user_roles VALUES (819, 3);
INSERT INTO links_user_roles VALUES (819, 2);
INSERT INTO links_user_roles VALUES (820, 1);
INSERT INTO links_user_roles VALUES (820, 3);
INSERT INTO links_user_roles VALUES (820, 2);
INSERT INTO links_user_roles VALUES (821, 1);
INSERT INTO links_user_roles VALUES (821, 3);
INSERT INTO links_user_roles VALUES (821, 2);
INSERT INTO links_user_roles VALUES (822, 1);
INSERT INTO links_user_roles VALUES (822, 3);
INSERT INTO links_user_roles VALUES (822, 2);
INSERT INTO links_user_roles VALUES (823, 1);
INSERT INTO links_user_roles VALUES (823, 3);
INSERT INTO links_user_roles VALUES (823, 2);
INSERT INTO links_user_roles VALUES (824, 1);
INSERT INTO links_user_roles VALUES (824, 3);
INSERT INTO links_user_roles VALUES (824, 2);
INSERT INTO links_user_roles VALUES (825, 1);
INSERT INTO links_user_roles VALUES (825, 3);
INSERT INTO links_user_roles VALUES (825, 2);
INSERT INTO links_user_roles VALUES (826, 1);
INSERT INTO links_user_roles VALUES (826, 3);
INSERT INTO links_user_roles VALUES (826, 2);
INSERT INTO links_user_roles VALUES (827, 1);
INSERT INTO links_user_roles VALUES (827, 3);
INSERT INTO links_user_roles VALUES (827, 2);
INSERT INTO links_user_roles VALUES (828, 1);
INSERT INTO links_user_roles VALUES (828, 3);
INSERT INTO links_user_roles VALUES (828, 2);
INSERT INTO links_user_roles VALUES (829, 1);
INSERT INTO links_user_roles VALUES (829, 3);
INSERT INTO links_user_roles VALUES (829, 2);
INSERT INTO links_user_roles VALUES (830, 1);
INSERT INTO links_user_roles VALUES (830, 3);
INSERT INTO links_user_roles VALUES (830, 2);
INSERT INTO links_user_roles VALUES (831, 1);
INSERT INTO links_user_roles VALUES (832, 1);
INSERT INTO links_user_roles VALUES (833, 1);
INSERT INTO links_user_roles VALUES (834, 1);
INSERT INTO links_user_roles VALUES (835, 1);
INSERT INTO links_user_roles VALUES (836, 1);
INSERT INTO links_user_roles VALUES (836, 3);
INSERT INTO links_user_roles VALUES (836, 2);
INSERT INTO links_user_roles VALUES (837, 3);
INSERT INTO links_user_roles VALUES (837, 2);
INSERT INTO links_user_roles VALUES (838, 1);
INSERT INTO links_user_roles VALUES (839, 1);
INSERT INTO links_user_roles VALUES (839, 3);
INSERT INTO links_user_roles VALUES (839, 2);
INSERT INTO links_user_roles VALUES (840, 1);
INSERT INTO links_user_roles VALUES (840, 3);
INSERT INTO links_user_roles VALUES (840, 2);
INSERT INTO links_user_roles VALUES (841, 1);
INSERT INTO links_user_roles VALUES (842, 1);
INSERT INTO links_user_roles VALUES (843, 1);
INSERT INTO links_user_roles VALUES (844, 1);
INSERT INTO links_user_roles VALUES (845, 1);
INSERT INTO links_user_roles VALUES (846, 1);
INSERT INTO links_user_roles VALUES (847, 1);
INSERT INTO links_user_roles VALUES (848, 1);
INSERT INTO links_user_roles VALUES (849, 1);
INSERT INTO links_user_roles VALUES (850, 1);
INSERT INTO links_user_roles VALUES (850, 3);
INSERT INTO links_user_roles VALUES (850, 2);
INSERT INTO links_user_roles VALUES (851, 1);
INSERT INTO links_user_roles VALUES (851, 3);
INSERT INTO links_user_roles VALUES (851, 2);
INSERT INTO links_user_roles VALUES (852, 1);
INSERT INTO links_user_roles VALUES (852, 3);
INSERT INTO links_user_roles VALUES (852, 2);
INSERT INTO links_user_roles VALUES (853, 1);
INSERT INTO links_user_roles VALUES (853, 3);
INSERT INTO links_user_roles VALUES (853, 2);
INSERT INTO links_user_roles VALUES (854, 1);
INSERT INTO links_user_roles VALUES (854, 3);
INSERT INTO links_user_roles VALUES (854, 2);
INSERT INTO links_user_roles VALUES (855, 1);
INSERT INTO links_user_roles VALUES (855, 3);
INSERT INTO links_user_roles VALUES (855, 2);
INSERT INTO links_user_roles VALUES (856, 1);
INSERT INTO links_user_roles VALUES (856, 3);
INSERT INTO links_user_roles VALUES (856, 2);
INSERT INTO links_user_roles VALUES (857, 1);
INSERT INTO links_user_roles VALUES (857, 3);
INSERT INTO links_user_roles VALUES (857, 2);
INSERT INTO links_user_roles VALUES (858, 1);
INSERT INTO links_user_roles VALUES (858, 3);
INSERT INTO links_user_roles VALUES (858, 2);
INSERT INTO links_user_roles VALUES (859, 3);
INSERT INTO links_user_roles VALUES (859, 2);
INSERT INTO links_user_roles VALUES (860, 3);
INSERT INTO links_user_roles VALUES (860, 2);
INSERT INTO links_user_roles VALUES (861, 1);
INSERT INTO links_user_roles VALUES (861, 3);
INSERT INTO links_user_roles VALUES (861, 2);
INSERT INTO links_user_roles VALUES (862, 3);
INSERT INTO links_user_roles VALUES (862, 2);
INSERT INTO links_user_roles VALUES (863, 3);
INSERT INTO links_user_roles VALUES (863, 2);
INSERT INTO links_user_roles VALUES (864, 3);
INSERT INTO links_user_roles VALUES (864, 2);
INSERT INTO links_user_roles VALUES (865, 2);
INSERT INTO links_user_roles VALUES (866, 3);
INSERT INTO links_user_roles VALUES (866, 2);
INSERT INTO links_user_roles VALUES (867, 3);
INSERT INTO links_user_roles VALUES (867, 2);
INSERT INTO links_user_roles VALUES (868, 3);
INSERT INTO links_user_roles VALUES (868, 2);
INSERT INTO links_user_roles VALUES (869, 1);
INSERT INTO links_user_roles VALUES (869, 3);
INSERT INTO links_user_roles VALUES (869, 2);
INSERT INTO links_user_roles VALUES (870, 1);
INSERT INTO links_user_roles VALUES (870, 3);
INSERT INTO links_user_roles VALUES (870, 2);
INSERT INTO links_user_roles VALUES (871, 1);
INSERT INTO links_user_roles VALUES (872, 1);
INSERT INTO links_user_roles VALUES (873, 1);
INSERT INTO links_user_roles VALUES (874, 1);
INSERT INTO links_user_roles VALUES (875, 1);
INSERT INTO links_user_roles VALUES (876, 1);
INSERT INTO links_user_roles VALUES (877, 1);
INSERT INTO links_user_roles VALUES (878, 1);
INSERT INTO links_user_roles VALUES (879, 1);
INSERT INTO links_user_roles VALUES (880, 1);
INSERT INTO links_user_roles VALUES (881, 1);
INSERT INTO links_user_roles VALUES (882, 1);
INSERT INTO links_user_roles VALUES (883, 1);
INSERT INTO links_user_roles VALUES (884, 1);


--
-- Data for Name: user_auths; Type: TABLE DATA; Schema: public; Owner: calcentral
--

INSERT INTO user_auths VALUES (158, '1022796', true, true, '2014-05-22 21:52:49.751', '2014-05-22 21:52:49.751', false, false);
INSERT INTO user_auths VALUES (159, '1078671', true, true, '2014-06-02 13:02:01.548', '2014-06-02 13:02:01.548', false, false);
INSERT INTO user_auths VALUES (155, '1051063', false, true, '2014-01-06 23:21:28.171', '2014-01-06 23:21:28.171', false, true);
INSERT INTO user_auths VALUES (157, '943220', false, true, '2014-02-11 23:41:46.792', '2014-02-11 23:41:46.792', false, true);
INSERT INTO user_auths VALUES (2, '323487', true, true, '2013-03-04 17:06:18.281', '2013-03-04 17:06:18.281', false, false);
INSERT INTO user_auths VALUES (4, '238382', true, true, '2013-03-04 17:06:18.296', '2013-03-04 17:06:18.296', false, false);
INSERT INTO user_auths VALUES (5, '208861', true, true, '2013-03-04 17:06:18.304', '2013-03-04 17:06:18.304', false, false);
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
INSERT INTO user_auths VALUES (7, '322279', true, true, '2013-03-04 17:06:18.32', '2013-03-04 17:06:21.74', false, false);
INSERT INTO user_auths VALUES (143, '53791', true, true, '2013-08-15 23:09:30.345', '2013-08-15 23:09:30.345', false, false);
INSERT INTO user_auths VALUES (145, '1049291', true, true, '2013-09-16 17:35:01.896', '2013-09-16 17:35:01.896', false, false);
INSERT INTO user_auths VALUES (144, '163093', false, true, '2013-09-16 17:34:22.616', '2013-09-16 17:34:22.616', false, true);
INSERT INTO user_auths VALUES (146, '177473', false, true, '2013-09-16 17:35:47.59', '2013-09-16 17:35:47.59', false, true);
INSERT INTO user_auths VALUES (147, '95509', false, true, '2013-09-16 17:35:58.498', '2013-09-16 17:35:58.498', false, true);
INSERT INTO user_auths VALUES (148, '160965', false, true, '2013-09-17 20:27:15.383', '2013-09-17 20:27:15.383', false, true);
INSERT INTO user_auths VALUES (152, '162721', false, true, '2013-10-01 23:58:44.14', '2013-10-01 23:58:44.14', false, true);
INSERT INTO user_auths VALUES (153, '19609', false, true, '2013-10-01 23:59:42.527', '2013-10-01 23:59:42.527', false, true);
INSERT INTO user_auths VALUES (154, '975226', false, true, '2013-10-02 00:00:05.933', '2013-10-02 00:00:05.933', false, true);
INSERT INTO user_auths VALUES (142, '12492', false, true, '2013-06-24 13:34:20.219', '2014-06-04 18:37:57.922', false, true);


--
-- Name: user_auths_id_seq; Type: SEQUENCE SET; Schema: public; Owner: calcentral
--

SELECT pg_catalog.setval('user_auths_id_seq', 159, true);


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
-- Name: fin_aid_years_pkey; Type: CONSTRAINT; Schema: public; Owner: calcentral; Tablespace: 
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
-- Name: index_fin_aid_years_on_current_year; Type: INDEX; Schema: public; Owner: calcentral; Tablespace: 
--

CREATE UNIQUE INDEX index_fin_aid_years_on_current_year ON fin_aid_years USING btree (current_year);


--
-- Name: index_user_auths_on_uid; Type: INDEX; Schema: public; Owner: calcentral; Tablespace: 
--

CREATE UNIQUE INDEX index_user_auths_on_uid ON user_auths USING btree (uid);

--
-- PostgreSQL database dump complete
--

