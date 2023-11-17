CREATE TABLE VILLES (
    VILLE VARCHAR2(50) PRIMARY KEY
);

CREATE TABLE SPORTIFS (
    IDSPORTIF INT PRIMARY KEY,
    NOM VARCHAR2(50),
    PRENOM VARCHAR2(50),
    SEXE CHAR(1),
    AGE INT,
    IDSPORTIFCONSEILLER INT,
    CONSTRAINT C_SEXE CHECK (SEXE IN('M','F'))
);

CREATE TABLE SPORTS (
    IDSPORT INT PRIMARY KEY,
    LIBELLE VARCHAR2(50)
);

CREATE TABLE GYMNASES (
    IDGYMNASE INT PRIMARY KEY,
    NOMGYMNASE VARCHAR2(50),
    ADRESSE VARCHAR2(100),
    VILLE VARCHAR2(50),
    SURFACE INT,
    FOREIGN KEY (VILLE) REFERENCES VILLES(VILLE)
);

CREATE TABLE ARBITRER (
    IDSPORTIF INT,
    IDSPORT INT,
    PRIMARY KEY (IDSPORTIF, IDSPORT),
    FOREIGN KEY (IDSPORTIF) REFERENCES SPORTIFS(IDSPORTIF),
    FOREIGN KEY (IDSPORT) REFERENCES SPORTS(IDSPORT)
);

CREATE TABLE ENTRAINER (
    IDSPORTIFENTRAINEUR INT,
    IDSPORT INT,
    PRIMARY KEY (IDSPORTIFENTRAINEUR, IDSPORT),
    FOREIGN KEY (IDSPORTIFENTRAINEUR) REFERENCES SPORTIFS(IDSPORTIF),
    FOREIGN KEY (IDSPORT) REFERENCES SPORTS(IDSPORT)
);

CREATE TABLE JOUER (
    IDSPORTIF INT,
    IDSPORT INT,
    PRIMARY KEY (IDSPORTIF, IDSPORT),
    FOREIGN KEY (IDSPORTIF) REFERENCES SPORTIFS(IDSPORTIF),
    FOREIGN KEY (IDSPORT) REFERENCES SPORTS(IDSPORT)
);

CREATE TABLE SEANCES (
    IDGYMNASE INT,
    IDSPORT INT,
    IDSPORTIFENTRAINEUR INT,
    JOUR VARCHAR2(20),
    HORAIRE FLOAT,
    DUREE INT,
    PRIMARY KEY (IDGYMNASE, IDSPORT, IDSPORTIFENTRAINEUR, JOUR, HORAIRE),
    FOREIGN KEY (IDGYMNASE) REFERENCES GYMNASES(IDGYMNASE),
    FOREIGN KEY (IDSPORT) REFERENCES SPORTS(IDSPORT),
    FOREIGN KEY (IDSPORTIFENTRAINEUR) REFERENCES SPORTIFS(IDSPORTIF),
    CONSTRAINT C_JOUR CHECK (JOUR IN('Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi','Dimanche'))
);

--disable forgien key constraint in sportifs 
ALTER TABLE SPORTIFS
ADD CONSTRAINT FK_IDSPORTIF_CONSEILLER
FOREIGN KEY (IDSPORTIFCONSEILLER) REFERENCES SPORTIFS(IDSPORTIF)
DISABLE;
--enable foregien key constraint in sportifts after insertions 
ALTER TABLE SPORTIFS
ENABLE CONSTRAINT FK_IDSPORTIF_CONSEILLER;

This relationship means that a single record in the ARBITRER table can have multiple IDSPORTIF* values (referring to multiple sportspeople), and multiple IDSPORT* values (referring to multiple sports) associated with it. Similarly, each sports person and each sport can be associated with multiple records in the ARBITRER table.



SELECT LPAD(IDSPORTIF, 5) AS IDSPORTIF,
       LPAD(NOM, 6)AS NOM,
       LPAD(PRENOM, 8) AS PRENOM,
       LPAD(SEXE, 1) AS SEXE,
       LPAD(AGE, 3) AS AGE,
       LPAD(IDSPORTIFCONSEILLER, 3) AS IDSPORTIFCONSEILLER
FROM SPORTIFS;





-- Définition des types incomplets
CREATE TYPE tSportif;
/
CREATE TYPE tGymnase;
/
CREATE TYPE tVille;
/
CREATE TYPE tArbitrer;
/
CREATE TYPE tSports;
/
CREATE TYPE tEntrainer;
/
CREATE TYPE tJouer;
/
CREATE TYPE tSeance;
/

CREATE TYPE tSportif AS OBJECT (
    idSportif INT,
    nom VARCHAR2(50),
    prenom VARCHAR2(50),
    sexe CHAR(1),
    age INT,
    idSportifConseiller INT
);
/

CREATE TYPE tGymnase AS OBJECT (
    idGymnase INT,
    nomGymnase VARCHAR2(50),
    adresse VARCHAR2(100),
    surface INT
);
/

CREATE TYPE tVille AS OBJECT (
     ville_gymnases t_set_ref_gymnases
);
/

CREATE TYPE tArbitrer AS OBJECT (
    idSportif  INT,
    idSport  INT
);
/
CREATE TYPE tSports AS OBJECT (
    idSport INT,
    libelle VARCHAR2(50)
);
/

CREATE TYPE tEntrainer AS OBJECT (
    idSportifEntraineur INT ,
    idSport INT 
);
/

CREATE TYPE tJouer AS OBJECT (
    idSportif INT ,
    idSport INT 
);
/

CREATE TYPE  tSeance AS OBJECT (
    idGymnase INT,
      IDSPORT INT,
    IDSPORTIFENTRAINEUR INT,
    jour VARCHAR2(20),
    horaire FLOAT,
    duree INT
);
/

ALTER TYPE tSeance ADD ATTRIBUTE idGymnase  INT ;

ALTER TYPE tSeance ADD ATTRIBUTE IDSPORT  INT ;

ALTER TYPE tSeance ADD ATTRIBUTE IDSPORTIFENTRAINEUR  INT ;


-- Relation CONS TO SPORTIFS : un sportif a un seul consultant
--one 
ALTER TYPE tSportif ADD ATTRIBUTE sportif_consultant REF tSportif CASCADE;
--many
ALTER TYPE tSportif ADD ATTRIBUTE consultant_sportifs SET OF REF tSportif;
----------VILLE------------------------------------------------
--RELATIONSHIP VILLES TO GYMNAES
--VILLE TO GYM  MANY


----------GYM------------------------------------------------
ALTER TYPE tGymnase ADD ATTRIBUTE GYMNASES_ville REF tville cascade ;
ALTER TYPE tGymnase ADD ATTRIBUTE GYMNASES_seances REF tseance cascade;
----------GYM------------------------------------------------


----------VILLE------------------------------------------------
CREATE TYPE t_set_ref_gymnases AS TABLE OF REF tGymnase ;
ALTER TYPE tVille ADD ATTRIBUTE ville_gymnases t_set_ref_gymnases cascade;

----------VILLE------------------------------------------------

----------SEANCE------------------------------------------------
--RELATIONSHIP SEANES TO EVERYTHING
CREATE TYPE t_set_ref_gymnases AS TABLE OF REF tGymnase;
/
CREATE TYPE t_set_ref_sports AS TABLE OF REF tSports;
/
CREATE TYPE t_set_ref_sportif AS TABLE OF REF tsportif;
/

ALTER TYPE tseance ADD ATTRIBUTE seances_gymnases t_set_ref_gymnases cascade
ALTER TYPE tseance ADD ATTRIBUTE seances_sport t_set_ref_sports cascade;
ALTER TYPE tseance ADD ATTRIBUTE seances_sportifs t_set_ref_sportif cascade;
----------SEANCE------------------------------------------------

----------SPORTIFS------------------------------------------------
CREATE TYPE t_set_ref_arbiter AS TABLE OF REF tarbitrer;
/
CREATE TYPE t_set_ref_entrainer AS TABLE OF REF tentrainer;
/
CREATE TYPE t_set_ref_jouer AS TABLE OF REF tjouer;
/
CREATE TYPE t_set_ref_sportif AS TABLE OF REF tsportif;
/

ALTER TYPE tsportif ADD ATTRIBUTE sportif_arbitres t_set_ref_arbiter cascade;
ALTER TYPE tsportif ADD ATTRIBUTE sportif_entraineurs t_set_ref_entrainer cascade;
ALTER TYPE tsportif ADD ATTRIBUTE sportif_jouer t_set_ref_jouer cascade;
ALTER TYPE tsportif ADD ATTRIBUTE consultant_sportifs t_set_ref_sportif cascade;
ALTER TYPE tsportif ADD ATTRIBUTE sportif_consultant REF tsportif cascade;

----------SPORTIFS------------------------------------------------

----------JOUER------------------------------------------------
CREATE TYPE t_set_ref_sports AS TABLE OF REF tsport;
/
CREATE TYPE t_set_ref_sportif AS TABLE OF REF tsportif;
/

ALTER TYPE tjouer ADD ATTRIBUTE jouer_sports t_set_ref_sports cascade;
ALTER TYPE tjouer ADD ATTRIBUTE jouer_sportifs t_set_ref_sportif cascade;
----------JOUER------------------------------------------------

----------ENTRAINER------------------------------------------------
ALTER TYPE tentrainer ADD ATTRIBUTE entrainer_sports t_set_ref_sports cascade;
ALTER TYPE tentrainer ADD ATTRIBUTE entrainer_sportifs t_set_ref_sportif cascade;
----------ENTRAINER------------------------------------------------

----------ARBITER------------------------------------------------
ALTER TYPE tArbitrer ADD ATTRIBUTE arbitrer_sports t_set_ref_sports cascade;
ALTER TYPE tArbitrer ADD ATTRIBUTE arbitrer_sportifs t_set_ref_sportif cascade;
----------ENTRAINER------------------------------------------------


--example of creating of a table with nested tables

create  table cours of tcours (PRIMARY KEY(numero_cours))
nested table est_pre_requis store as table_est_pre_requis,
nested table a_pre_requis store as table_a_pre_requis,
nested table cours_etudiant store as table_cours_etudiant,
nested table cours_enseignant store as table_cours_enseignant,
nested table cours_evaluation store as table_cours_evaluation;

--example of creating a table with nested column
create table  evaluations of tevaluation (
foreign key(ref_cours) references cours, 
foreign key (ref_etudiant) references personne);

--creating VILLE table which as nested table of gymnase

CREATE TABLE VILLE OF tVille (PRIMARY KEY(VILLE))

--creating GYMNASE table with has column of  VILLE






-- Relation ARBITRER : un arbitre peut arbitrer plusieurs sportifs et plusieurs sports
CREATE TYPE t_set_ref_sportif AS TABLE OF REF tSportif;
CREATE TYPE t_set_ref_sports AS TABLE OF REF tSports;
ALTER TYPE tArbitrer ADD ATTRIBUTE arbitrer_sportifs t_set_ref_sportif CASCADE;
ALTER TYPE tArbitrer ADD ATTRIBUTE sportif_arbitres SET OF REF tSportif;
ALTER TYPE tArbitrer ADD ATTRIBUTE arbitrer_sports t_set_ref_sports CASCADE;
ALTER TYPE tArbitrer ADD ATTRIBUTE sport_arbitres SET OF REF tSports;

-- Relation ENTRAINER : un entraineur peut entrainer plusieurs sportifs et plusieurs sports
ALTER TYPE tEntrainer ADD ATTRIBUTE entrainer_sportifs t_set_ref_sportif CASCADE;
ALTER TYPE tEntrainer ADD ATTRIBUTE sportif_entraineurs SET OF REF tSportif;
ALTER TYPE tEntrainer ADD ATTRIBUTE entrainer_sports t_set_ref_sports CASCADE;
ALTER TYPE tEntrainer ADD ATTRIBUTE sport_entraineurs SET OF REF tSports;

-- Relation JOUER : un sportif peut jouer plusieurs sports et plusieurs jeux
ALTER TYPE tJouer ADD ATTRIBUTE jouer_sports t_set_ref_sports CASCADE;
ALTER TYPE tJouer ADD ATTRIBUTE sport_joueurs SET OF REF tSports;
ALTER TYPE tJouer ADD ATTRIBUTE jouer_jeux t_set_ref_sportif CASCADE;
ALTER TYPE tJouer ADD ATTRIBUTE joueur_jeux SET OF REF tSportif;

-- Relation SEANCES : une séance est organisée dans un seul gymnase, pour un seul sport, et peut accueillir plusieurs sportifs
ALTER TYPE tSeance ADD ATTRIBUTE seance_gymnase REF tGymnase CASCADE;
ALTER TYPE tGymnase ADD ATTRIBUTE gymnase_seances SET OF REF tSeance;
ALTER TYPE tSeance ADD ATTRIBUTE seance_sport REF tSports CASCADE;
ALTER TYPE tSports ADD ATTRIBUTE sport_seances SET OF REF tSeance;
ALTER TYPE tSeance ADD ATTRIBUTE seance_sportifs t_set_ref_sportif CASCADE;
ALTER TYPE tSportif ADD ATTRIBUTE sportif_seances SET OF REF tSeance;


--types of each class with thier repsective attributes
CREATE OR replace TYPE tville AS OBJECT (
ville VARCHAR2(50),
ville_gymnases t_set_ref_gymnases
);
/

CREATE  TYPE tville AS OBJECT (
ville VARCHAR2(50),
);
/

CREATE TABLE  VILLE OF tVille (primary key(VILLE))
nested table ville_gymnases store as table_t_set_ref_gymnases;


CREATE OR REPLACE TYPE tgymnase AS OBJECT (
idgymnase INT,
nomgymnase VARCHAR2(50),
adresse VARCHAR2(100),
ville ref tville,
surface INT,
GYMNASES_ville ref tville,
GYMNASES_seances ref tseance
);
/


CREATE  TYPE tgymnase AS OBJECT (
idgymnase INT,
nomgymnase VARCHAR2(50),
adresse VARCHAR2(100),
ville ref tville,
surface INT
);
/


CREATE TABLE GYMNASES OF tGymnase(primary key(idgymnase),foreign key(GYMNASES_ville) references VILLE);

create table  evaluations of tevaluation (foreign key(ref_cours) references cours, 
foreign key (ref_etudiant) references personne);


CREATE TYPE tsportif AS OBJECT (
idsportif INT,
nom VARCHAR2(50),
prenom VARCHAR2(50),
sexe CHAR(1),
age INT,
idsportifconseiller INT
);

CREATE TYPE tsport AS OBJECT (
idsport INT,
libelle VARCHAR2(50)
);



CREATE TYPE tarbitrer AS OBJECT (
idsportif INT,
idsport INT
);

CREATE TYPE tentrainer AS OBJECT (
idsportifentraineur INT,
idsport INT
);

CREATE TYPE tjouer AS OBJECT (
idsportif INT,
idsport INT
);

CREATE TYPE tseance AS OBJECT (
idgymnase INT,
idsport INT,
idsportifentraineur INT,
jour VARCHAR2(20),
horaire FLOAT,
duree INT
);
/

CREATE TABLE SEANCE OF tSeance (PRIMARY KEY(idgymnase,idsport,idsportifentraineur));



CREATE TABLE  VILLE OF tVille (primary key(VILLE))
nested table ville_gymnases store as table_t_set_ref_gymnases;

CREATE TABLE SPORTIF OF tSportif (PRIMARY KEY(IDSPORTIF),foreign key(IDSPORTIFCONSEILLER) references SPORTIF )
NESTED TABLE consultant_sportifs STORE AS TABLE_t_set_ref_sportifs,
NESTED TABLE sportif_entraineurs STORE AS TABLE_t_set_ref_entraineurs;


CREATE OR REPLACE TYPE tgymnase AS OBJECT (
idgymnase INT,
nomgymnase VARCHAR2(50),
adresse VARCHAR2(100),
ville ref tville,
surface INT,
GYMNASES_ville ref tville,
GYMNASES_seances ref tseance
);
/


CREATE  TYPE tgymnase AS OBJECT (
idgymnase INT,
nomgymnase VARCHAR2(50),
adresse VARCHAR2(100),
ville ref tville,
surface INT
);
/

