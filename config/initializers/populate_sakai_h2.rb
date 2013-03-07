# encoding: utf-8
module Calcentral

  class PopulateSakaiH2 < ActiveRecord::Base
    Rails.application.config.after_initialize do
      if Settings.campusdb.adapter == "h2"
        establish_connection "campusdb"
        sql = <<-SQL

        DROP TABLE IF EXISTS SAKAI_PREFERENCES;
        -- Original Oracle table uses LONG instead of CLOB
        CREATE TABLE SAKAI_PREFERENCES(
        "PREFERENCES_ID" VARCHAR2(99),
        "XML" CLOB
        );

        -- Only includes the columns we use.
        DROP TABLE IF EXISTS SAKAI_SITE;
        CREATE TABLE SAKAI_SITE(
        "SITE_ID" VARCHAR2(99),
        "TITLE" VARCHAR2(99),
        "TYPE" VARCHAR2(99),
        "SHORT_DESC" CLOB,
        "DESCRIPTION" CLOB,
        "PUBLISHED" NUMBER(38)
        );

        DROP TABLE IF EXISTS SAKAI_SITE_PROPERTY;
        CREATE TABLE SAKAI_SITE_PROPERTY(
        "SITE_ID" VARCHAR2(99),
        "NAME" VARCHAR2(99),
        "VALUE" CLOB
        );

        DROP TABLE IF EXISTS SAKAI_SITE_TOOL;
        CREATE TABLE SAKAI_SITE_TOOL(
        "TOOL_ID" VARCHAR2(99),
        "PAGE_ID" VARCHAR2(99),
        "SITE_ID" VARCHAR2(99),
        "REGISTRATION" VARCHAR2(99),
        "PAGE_ORDER" NUMBER(38),
        "TITLE" VARCHAR2(99),
        "LAYOUT_HINTS" VARCHAR2(99)
        );

        DROP TABLE IF EXISTS SAKAI_SITE_USER;
        CREATE TABLE SAKAI_SITE_USER(
        "SITE_ID" VARCHAR2(99),
        "USER_ID" VARCHAR2(99),
        "PERMISSION" NUMBER(38)
        );

        DROP TABLE IF EXISTS SAKAI_USER_ID_MAP;
        CREATE TABLE SAKAI_USER_ID_MAP(
        "USER_ID" VARCHAR2(99),
        "EID" VARCHAR2(255)
        );

        -- Test UTF-8 handling.
        Insert into SAKAI_SITE (SITE_ID,TITLE,TYPE,SHORT_DESC,PUBLISHED,DESCRIPTION) values ('29fc31ae-ff14-419f-a132-5576cae2474e','RUSSWIKI 2B Sp13','course','Добро пожаловать в Русский 1!',1,'<p>' || char(10) || '	<strong>Знаете ли вы?</strong></p>' || char(10) || '<ul>' || char(10) || '	<li>' || char(10) || '		Кузен Петра I был произведён в генералы только после смерти императора.</li>' || char(10) || '</ul>' || char(10) || '<p>' || char(10) || '	&nbsp;</p>');
        Insert into SAKAI_SITE_PROPERTY (SITE_ID,NAME,VALUE) values ('29fc31ae-ff14-419f-a132-5576cae2474e','term','Spring 2013');
        Insert into SAKAI_SITE_PROPERTY (SITE_ID,NAME,VALUE) values ('29fc31ae-ff14-419f-a132-5576cae2474e','term_eid','2013-B');
        Insert into SAKAI_SITE_USER (SITE_ID,USER_ID,PERMISSION) values ('29fc31ae-ff14-419f-a132-5576cae2474e','211159',-1);
        Insert into SAKAI_SITE_USER (SITE_ID,USER_ID,PERMISSION) values ('29fc31ae-ff14-419f-a132-5576cae2474e','575bc12b-929f-4485-b2a2-50c69d8c06c7',1);

        -- Test null short description.
        Insert into SAKAI_SITE (SITE_ID,TITLE,TYPE,SHORT_DESC,PUBLISHED,DESCRIPTION) values ('45042d5d-9b88-43cf-a83a-464e1f0444fc','MATH 1853 Sp13','course','',1,'<p>' || char(10) || '	The following work is not a republication of a former treatise by the Author, entitled, &ldquo;The Mathematical Analysis of Logic.&rdquo; Its earlier portion is indeed devoted to the same object, and it begins by establishing the same system of fundamental laws, but its methods are more general, and its range of applica- tions far wider. It exhibits the results, matured by some years of study and reflection, of a principle of investigation relating to the intellectual operations, the previous exposition of which was written within a few weeks after its idea had been conceived.</p>' || char(10) || '<p>' || char(10) || '	That portion of this work which relates to Logic presupposes in its reader a knowledge of the most important terms of the science, as usually treated, and of its general object. Some acquaintance with the principles of Algebra is also requisite, but it is not necessary that this application should have been carried beyond the solution of simple equations. For the study of those chapters which relate to the theory of probabilities, a somewhat larger knowledge of Algebra is required, and especially of the doctrine of Elimination, and of the solution of Equations containing more than one unknown quantity.</p>' || char(10) || '<p>' || char(10) || '	&nbsp;</p>');
        Insert into SAKAI_SITE_PROPERTY (SITE_ID,NAME,VALUE) values ('45042d5d-9b88-43cf-a83a-464e1f0444fc','term','Spring 2013');
        Insert into SAKAI_SITE_PROPERTY (SITE_ID,NAME,VALUE) values ('45042d5d-9b88-43cf-a83a-464e1f0444fc','term_eid','2013-B');
        Insert into SAKAI_SITE_USER (SITE_ID,USER_ID,PERMISSION) values ('45042d5d-9b88-43cf-a83a-464e1f0444fc','211159',-1);
        Insert into SAKAI_SITE_USER (SITE_ID,USER_ID,PERMISSION) values ('45042d5d-9b88-43cf-a83a-464e1f0444fc','575bc12b-929f-4485-b2a2-50c69d8c06c7',1);

        -- Test unpublished site.
        Insert into SAKAI_SITE (SITE_ID,TITLE,TYPE,SHORT_DESC,PUBLISHED,DESCRIPTION) values ('cc56df9a-3ae1-4362-a4a0-6c5133ec8750','Copyright Trolling 101','course', '',0, '');
        Insert into SAKAI_SITE_PROPERTY (SITE_ID,NAME,VALUE) values ('cc56df9a-3ae1-4362-a4a0-6c5133ec8750','term','Spring 2013');
        Insert into SAKAI_SITE_PROPERTY (SITE_ID,NAME,VALUE) values ('cc56df9a-3ae1-4362-a4a0-6c5133ec8750','term_eid','2013-B');
        Insert into SAKAI_SITE_USER (SITE_ID,USER_ID,PERMISSION) values ('cc56df9a-3ae1-4362-a4a0-6c5133ec8750','211159',-1);
        Insert into SAKAI_SITE_USER (SITE_ID,USER_ID,PERMISSION) values ('cc56df9a-3ae1-4362-a4a0-6c5133ec8750','575bc12b-929f-4485-b2a2-50c69d8c06c7',1);

        -- Test course site from old term.
        Insert into SAKAI_SITE (SITE_ID,TITLE,TYPE,SHORT_DESC,PUBLISHED,DESCRIPTION) values ('19fc31ae-ff14-419f-a132-5576cae2474e','MATH 1827 Fa12','course','Archbishop Whately’s “Elements of Logic”',1,'');
        Insert into SAKAI_SITE_PROPERTY (SITE_ID,NAME,VALUE) values ('19fc31ae-ff14-419f-a132-5576cae2474e','term','Fall 2012');
        Insert into SAKAI_SITE_PROPERTY (SITE_ID,NAME,VALUE) values ('19fc31ae-ff14-419f-a132-5576cae2474e','term_eid','2012-D');
        Insert into SAKAI_SITE_USER (SITE_ID,USER_ID,PERMISSION) values ('19fc31ae-ff14-419f-a132-5576cae2474e','211159',-1);
        Insert into SAKAI_SITE_USER (SITE_ID,USER_ID,PERMISSION) values ('19fc31ae-ff14-419f-a132-5576cae2474e','575bc12b-929f-4485-b2a2-50c69d8c06c7',1);

        -- Test project site.
        Insert into SAKAI_SITE (SITE_ID,TITLE,TYPE,SHORT_DESC,PUBLISHED,DESCRIPTION) values ('29d475ae-a1c1-493f-b721-fcfeebdb038d','Digital Library Project','project', '',1, '');
        Insert into SAKAI_SITE_USER (SITE_ID,USER_ID,PERMISSION) values ('29d475ae-a1c1-493f-b721-fcfeebdb038d','211159',1);
        Insert into SAKAI_SITE_USER (SITE_ID,USER_ID,PERMISSION) values ('29d475ae-a1c1-493f-b721-fcfeebdb038d','575bc12b-929f-4485-b2a2-50c69d8c06c7',1);

        -- Test user-hidden project site.
        Insert into SAKAI_SITE (SITE_ID,TITLE,TYPE,SHORT_DESC,PUBLISHED,DESCRIPTION) values ('47449ea5-6826-4826-807d-af49a5d222fb','ITMF','project','The Information Technology Manager''s Forum',1,'This site is a place for the Information Technology Manager''s Forum (ITMF) to share documents and discussions.');
        Insert into SAKAI_SITE_USER (SITE_ID,USER_ID,PERMISSION) values ('47449ea5-6826-4826-807d-af49a5d222fb','211159',1);
        Insert into SAKAI_SITE_USER (SITE_ID,USER_ID,PERMISSION) values ('47449ea5-6826-4826-807d-af49a5d222fb','575bc12b-929f-4485-b2a2-50c69d8c06c7',1);
        -- Original Oracle export embeds line break rather than char(10).
        Insert into SAKAI_PREFERENCES (PREFERENCES_ID,XML) values ('211159','<?xml version="1.0" encoding="UTF-8"?>' || char(10) || '<preferences id="211159"><properties/><prefs key="sakai:portal:sitenav"><properties><property enc="BASE64" list="list" name="order" value="IWFkbWlu"/><property enc="BASE64" list="list" name="order" value="MGI0ZDZlZjUtZWI0Ni00Y2U3LTgwODMtNjYwZTAyZjBmNmUw"/></properties></prefs></preferences>');
        Insert into SAKAI_PREFERENCES (PREFERENCES_ID,XML) values ('575bc12b-929f-4485-b2a2-50c69d8c06c7','<?xml version="1.0" encoding="UTF-8"?>' || char(10) || '<preferences id="575bc12b-929f-4485-b2a2-50c69d8c06c7"><properties/><prefs key="sakai:portal:sitenav"><properties><property enc="BASE64" list="list" name="order" value="MjlmYzMxYWUtZmYxNC00MTlmLWExMzItNTU3NmNhZTI0NzRl"/><property enc="BASE64" list="list" name="exclude" value="NDc0NDllYTUtNjgyNi00ODI2LTgwN2QtYWY0OWE1ZDIyMmZi"/><property enc="BASE64" name="tabs" value="NA=="/></properties></prefs></preferences>');

        -- Test "My Dashboard" and admin sites.
        Insert into SAKAI_SITE (SITE_ID,TITLE,TYPE,SHORT_DESC,PUBLISHED,DESCRIPTION) values ('!admin','Administration Workspace',null, '',1,'<p>Administration Workspace</p>');
        Insert into SAKAI_SITE (SITE_ID,TITLE,TYPE,SHORT_DESC,PUBLISHED,DESCRIPTION) values ('~211159','My Workspace',null, '',1,'MyWorkspace Site');
        Insert into SAKAI_SITE (SITE_ID,TITLE,TYPE,SHORT_DESC,PUBLISHED,DESCRIPTION) values ('~575bc12b-929f-4485-b2a2-50c69d8c06c7','My Workspace',null, '',1,'<p>MyWorkspace Site</p>');
        Insert into SAKAI_SITE_USER (SITE_ID,USER_ID,PERMISSION) values ('!admin','211159',-1);
        Insert into SAKAI_SITE_USER (SITE_ID,USER_ID,PERMISSION) values ('~211159','211159',-1);
        Insert into SAKAI_SITE_USER (SITE_ID,USER_ID,PERMISSION) values ('~575bc12b-929f-4485-b2a2-50c69d8c06c7','575bc12b-929f-4485-b2a2-50c69d8c06c7',-1);

        -- Test users.
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('12005','12005');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('d610e475-8227-43cd-9ad0-0f5f494e3e48','177473');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('18437','18437');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('191779','191779');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('192517','192517');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('2040','2040');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('208861','208861');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('211159','211159');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('52dcac24-0373-4669-80ba-6fb9f8d101dc','212372');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('212373','212373');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('8e08ba8f-0658-43d1-8f5b-b51fc8cdbe65','212379');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('212380','212380');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('3f469171-68c0-4fea-00fa-51494c799244','212381');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('212383','212383');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('281d82bb-2d0d-4d78-be3f-5fb801370603','212384');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('212386','212386');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('226144','226144');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('7e18d288-7248-4e6b-b220-e29cb0c85bc0','232588');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('238382','238382');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('266945','266945');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('271592','271592');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('87ad32dd-99ee-42f7-8713-460e331f99a1','300846');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('575bc12b-929f-4485-b2a2-50c69d8c06c7','300939');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('3c8692d1-6507-4096-9b9e-48ae633c561e','300943');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('3060','3060');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('0da2049c-5673-47cc-8038-4b446f370fbd','313561');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('74606373-b5f8-4d49-0057-3344f7d930cc','322279');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('49c9bb35-0e1f-49b1-bd34-dab3e5e751f9','322586');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('f4a2cc08-21d9-4de3-8050-e59ff6c30a06','322590');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('db871c49-536b-43bf-80f4-108cc134e7d3','323487');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('53791','53791');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('5698','5698');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('fbe4d4e5-06b0-4dad-9957-b5d64e1cdaa7','592722');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('61889','61889');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('53debd0f-b0fb-465a-0016-79277fc29f02','6576');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('0857d56c-a4cb-4675-9429-5e613bb8cd8f','675750');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('2ea6733e-ad33-47c6-9585-946f4b4890ec','730057');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('94266206-d027-4e55-a21f-e8cc002bc25f','741134');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('4b705221-2562-418a-a8af-dbcb87bf1128','863980');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('15517d64-4079-4f3b-9515-968ab660db7d','904715');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('95509','95509');
        Insert into SAKAI_USER_ID_MAP (USER_ID,EID) values ('ecf46471-b566-47c9-8caa-4155b9ba7ac0','978966');
        SQL

        connection.execute sql
      end
    end
  end
end
