-- =============================================================================
-- Script principal - Creation et initialisation complete de la base de donnees
-- =============================================================================

-- Desactiver les messages d'information
SET SERVEROUTPUT ON;

-- =============================================================================
-- ETAPE 1 : SUPPRESSION DES TABLES ET SEQUENCES EXISTANTES
-- =============================================================================

-- Suppression des tables d'association
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Met_en_avant CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Etiquette CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Prefere CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Commentaire CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Aime CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- Suppression de la table de tracking
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Upload_Tracking CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- Suppression des tables principales
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Image_archive CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Image CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Album CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Newsletter CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Label CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Categorie CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Utilisateur CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- Suppression des sequences
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_utilisateur'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_categorie'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_label'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_album'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_image'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_image_archive'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_newsletter'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_commentaire'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- =============================================================================
-- ETAPE 2 : CREATION DES TABLES
-- =============================================================================

-- Table UTILISATEUR
CREATE TABLE Utilisateur (
    idUtilisateur       NUMBER PRIMARY KEY,
    login               VARCHAR2(50) NOT NULL UNIQUE,
    mot_de_passe        VARCHAR2(255) NOT NULL,
    nom                 VARCHAR2(100),
    prenom              VARCHAR2(100),
    date_naissance      DATE,
    email               VARCHAR2(150) NOT NULL UNIQUE,
    pays                VARCHAR2(100),
    abonne_newsletter   NUMBER(1) DEFAULT 0 NOT NULL,
    CONSTRAINT chk_abonne_newsletter CHECK (abonne_newsletter IN (0, 1))
);

-- Table CATEGORIE
CREATE TABLE Categorie (
    idCategorie     NUMBER PRIMARY KEY,
    nom             VARCHAR2(100) NOT NULL UNIQUE
);

-- Table LABEL
CREATE TABLE Label (
    idLabel     NUMBER PRIMARY KEY,
    nom         VARCHAR2(100) NOT NULL UNIQUE
);

-- Table ALBUM
CREATE TABLE Album (
    idAlbum         NUMBER PRIMARY KEY,
    titre           VARCHAR2(200) NOT NULL,
    description     CLOB,
    date_creation   TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    visibilite      VARCHAR2(10) NOT NULL,
    idUtilisateur   NUMBER NOT NULL,
    CONSTRAINT fk_album_utilisateur FOREIGN KEY (idUtilisateur) 
        REFERENCES Utilisateur(idUtilisateur) ON DELETE CASCADE,
    CONSTRAINT chk_album_visibilite CHECK (visibilite IN ('public', 'prive'))
);

-- Table IMAGE
CREATE TABLE Image (
    idImage             NUMBER PRIMARY KEY,
    titre               VARCHAR2(200) NOT NULL,
    description         CLOB,
    date_publication    TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    format              VARCHAR2(20),
    taille              NUMBER,
    visibilite          VARCHAR2(10) NOT NULL,
    pays_origine        VARCHAR2(100),
    telechargeable      NUMBER(1) DEFAULT 1 NOT NULL,
    idAlbum             NUMBER NOT NULL,
    idCategorie         NUMBER NOT NULL,
    CONSTRAINT fk_image_album FOREIGN KEY (idAlbum) 
        REFERENCES Album(idAlbum) ON DELETE CASCADE,
    CONSTRAINT fk_image_categorie FOREIGN KEY (idCategorie) 
        REFERENCES Categorie(idCategorie),
    CONSTRAINT chk_image_visibilite CHECK (visibilite IN ('public', 'prive')),
    CONSTRAINT chk_image_telechargeable CHECK (telechargeable IN (0, 1))
);

-- Table IMAGE_ARCHIVE
CREATE TABLE Image_archive (
    idImageArchive      NUMBER PRIMARY KEY,
    titre               VARCHAR2(200),
    description         CLOB,
    date_publication    TIMESTAMP,
    format              VARCHAR2(20),
    taille              NUMBER,
    visibilite          VARCHAR2(10),
    pays_origine        VARCHAR2(100),
    telechargeable      NUMBER(1),
    date_archivage      TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_archive_visibilite CHECK (visibilite IN ('public', 'prive')),
    CONSTRAINT chk_archive_telechargeable CHECK (telechargeable IN (0, 1))
);

-- Table NEWSLETTER
CREATE TABLE Newsletter (
    idNewsletter    NUMBER PRIMARY KEY,
    date_envoi      DATE NOT NULL,
    contenu         CLOB NOT NULL
);

-- Table AIME (Association Utilisateur - Image)
CREATE TABLE Aime (
    idUtilisateur   NUMBER NOT NULL,
    idImage         NUMBER NOT NULL,
    date_aime       TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_aime PRIMARY KEY (idUtilisateur, idImage),
    CONSTRAINT fk_aime_utilisateur FOREIGN KEY (idUtilisateur) 
        REFERENCES Utilisateur(idUtilisateur) ON DELETE CASCADE,
    CONSTRAINT fk_aime_image FOREIGN KEY (idImage) 
        REFERENCES Image(idImage) ON DELETE CASCADE
);

-- Table COMMENTAIRE
CREATE TABLE Commentaire (
    idCommentaire       NUMBER PRIMARY KEY,
    texte_commentaire   CLOB NOT NULL,
    date_commentaire    TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    idUtilisateur       NUMBER NOT NULL,
    idImage             NUMBER NOT NULL,
    CONSTRAINT fk_commentaire_utilisateur FOREIGN KEY (idUtilisateur) 
        REFERENCES Utilisateur(idUtilisateur) ON DELETE CASCADE,
    CONSTRAINT fk_commentaire_image FOREIGN KEY (idImage) 
        REFERENCES Image(idImage) ON DELETE CASCADE
);

-- Table PREFERE (Association Utilisateur - Categorie)
CREATE TABLE Prefere (
    idUtilisateur   NUMBER NOT NULL,
    idCategorie     NUMBER NOT NULL,
    CONSTRAINT pk_prefere PRIMARY KEY (idUtilisateur, idCategorie),
    CONSTRAINT fk_prefere_utilisateur FOREIGN KEY (idUtilisateur) 
        REFERENCES Utilisateur(idUtilisateur) ON DELETE CASCADE,
    CONSTRAINT fk_prefere_categorie FOREIGN KEY (idCategorie) 
        REFERENCES Categorie(idCategorie) ON DELETE CASCADE
);

-- Table ETIQUETTE (Association Image - Label)
CREATE TABLE Etiquette (
    idImage     NUMBER NOT NULL,
    idLabel     NUMBER NOT NULL,
    CONSTRAINT pk_etiquette PRIMARY KEY (idImage, idLabel),
    CONSTRAINT fk_etiquette_image FOREIGN KEY (idImage) 
        REFERENCES Image(idImage) ON DELETE CASCADE,
    CONSTRAINT fk_etiquette_label FOREIGN KEY (idLabel) 
        REFERENCES Label(idLabel) ON DELETE CASCADE
);

-- Table MET_EN_AVANT (Association Newsletter - Image)
CREATE TABLE Met_en_avant (
    idNewsletter    NUMBER NOT NULL,
    idImage         NUMBER NOT NULL,
    CONSTRAINT pk_met_en_avant PRIMARY KEY (idNewsletter, idImage),
    CONSTRAINT fk_met_en_avant_newsletter FOREIGN KEY (idNewsletter) 
        REFERENCES Newsletter(idNewsletter) ON DELETE CASCADE,
    CONSTRAINT fk_met_en_avant_image FOREIGN KEY (idImage) 
        REFERENCES Image(idImage) ON DELETE CASCADE
);

-- Table UPLOAD_TRACKING (Pour anti-spam des images)
CREATE TABLE Upload_Tracking (
    idUtilisateur       NUMBER PRIMARY KEY,
    derniere_upload     TIMESTAMP,
    nb_uploads_seconde  NUMBER DEFAULT 0,
    CONSTRAINT fk_upload_tracking_utilisateur FOREIGN KEY (idUtilisateur)
        REFERENCES Utilisateur(idUtilisateur) ON DELETE CASCADE
);

-- =============================================================================
-- ETAPE 3 : CREATION DES SEQUENCES
-- =============================================================================

CREATE SEQUENCE seq_utilisateur START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_categorie START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_label START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_album START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_image START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_image_archive START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_newsletter START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_commentaire START WITH 1 INCREMENT BY 1;

-- =============================================================================
-- ETAPE 4 : CREATION DES INDEX POUR OPTIMISER LES REQUETES
-- =============================================================================
-- Index sur la table Image
-- Pour Requete 1 : Images par categorie (2 dernieres semaines)
CREATE INDEX idx_image_categorie ON Image(idCategorie);
CREATE INDEX idx_image_date_pub ON Image(date_publication);
CREATE INDEX idx_image_cat_date ON Image(idCategorie, date_publication);
-- Pour Requete 2 : Images publiees par utilisateur
CREATE INDEX idx_image_album ON Image(idAlbum);
-- Pour les procedures PL/SQL : filtrage par visibilite
CREATE INDEX idx_image_visibilite ON Image(visibilite);
CREATE INDEX idx_image_visibilite_date ON Image(visibilite, date_publication);

-- Index sur la table Album
-- Pour Requete 2 : Albums et images par utilisateur
CREATE INDEX idx_album_utilisateur ON Album(idUtilisateur);

-- Index sur la table Aime
-- Pour Requete 2 : Likes donnes et recus par utilisateur
CREATE INDEX idx_aime_utilisateur ON Aime(idUtilisateur);
CREATE INDEX idx_aime_image ON Aime(idImage);
-- Pour les procedures PL/SQL : filtrage des likes recents (2 semaines)
CREATE INDEX idx_aime_date ON Aime(date_aime);
CREATE INDEX idx_aime_image_date ON Aime(idImage, date_aime);

-- Index sur la table Commentaire
-- Pour procedure image_to_json : comptage des commentaires par image
CREATE INDEX idx_commentaire_image ON Commentaire(idImage);
CREATE INDEX idx_commentaire_utilisateur ON Commentaire(idUtilisateur);

-- Index sur la table Prefere
-- Pour procedures images_conseillees et generer_newsletter_utilisateur
CREATE INDEX idx_prefere_utilisateur ON Prefere(idUtilisateur);
CREATE INDEX idx_prefere_categorie ON Prefere(idCategorie);

-- Index sur la table Etiquette
-- Pour procedure image_to_json : recuperation des labels
CREATE INDEX idx_etiquette_image ON Etiquette(idImage);
CREATE INDEX idx_etiquette_label ON Etiquette(idLabel);

-- Index sur la table Met_en_avant
-- Pour optimiser les recherches dans les newsletters
CREATE INDEX idx_met_en_avant_newsletter ON Met_en_avant(idNewsletter);
CREATE INDEX idx_met_en_avant_image ON Met_en_avant(idImage);

-- Index sur la table Utilisateur
-- Pour Requete 3 : Likes par pays des utilisateurs
CREATE INDEX idx_utilisateur_pays ON Utilisateur(pays);
-- Pour procedure generer_toutes_newsletters : filtrage des abonnes
CREATE INDEX idx_utilisateur_newsletter ON Utilisateur(abonne_newsletter);

-- =============================================================================
-- ETAPE 5 : INSERTION DES DONNEES DE TEST
-- =============================================================================

-- Insertion des UTILISATEURS
INSERT INTO Utilisateur VALUES (seq_utilisateur.NEXTVAL, 'jean_photo', 'mdp123hash', 'Dupont', 'Jean', TO_DATE('1990-05-15', 'YYYY-MM-DD'), 'jean.dupont@email.com', 'France', 1);
INSERT INTO Utilisateur VALUES (seq_utilisateur.NEXTVAL, 'marie_art', 'mdp456hash', 'Martin', 'Marie', TO_DATE('1985-08-22', 'YYYY-MM-DD'), 'marie.martin@email.com', 'France', 1);
INSERT INTO Utilisateur VALUES (seq_utilisateur.NEXTVAL, 'alex_nature', 'mdp789hash', 'Bernard', 'Alexandre', TO_DATE('1995-12-03', 'YYYY-MM-DD'), 'alex.bernard@email.com', 'Belgique', 0);
INSERT INTO Utilisateur VALUES (seq_utilisateur.NEXTVAL, 'sophie_travel', 'mdp101hash', 'Leroy', 'Sophie', TO_DATE('1992-03-10', 'YYYY-MM-DD'), 'sophie.leroy@email.com', 'Suisse', 1);
INSERT INTO Utilisateur VALUES (seq_utilisateur.NEXTVAL, 'thomas_urban', 'mdp202hash', 'Moreau', 'Thomas', TO_DATE('1988-07-28', 'YYYY-MM-DD'), 'thomas.moreau@email.com', 'Canada', 0);
INSERT INTO Utilisateur VALUES (seq_utilisateur.NEXTVAL, 'emma_portrait', 'mdp303hash', 'Garcia', 'Emma', TO_DATE('1998-01-17', 'YYYY-MM-DD'), 'emma.garcia@email.com', 'Espagne', 1);
INSERT INTO Utilisateur VALUES (seq_utilisateur.NEXTVAL, 'lucas_wild', 'mdp404hash', 'Petit', 'Lucas', TO_DATE('1993-09-05', 'YYYY-MM-DD'), 'lucas.petit@email.com', 'France', 0);
INSERT INTO Utilisateur VALUES (seq_utilisateur.NEXTVAL, 'chloe_macro', 'mdp505hash', 'Robert', 'Chloe', TO_DATE('1991-11-20', 'YYYY-MM-DD'), 'chloe.robert@email.com', 'Allemagne', 1);

-- Insertion des CATEGORIES
INSERT INTO Categorie VALUES (seq_categorie.NEXTVAL, 'Nature');
INSERT INTO Categorie VALUES (seq_categorie.NEXTVAL, 'Architecture');
INSERT INTO Categorie VALUES (seq_categorie.NEXTVAL, 'Art');
INSERT INTO Categorie VALUES (seq_categorie.NEXTVAL, 'Portrait');
INSERT INTO Categorie VALUES (seq_categorie.NEXTVAL, 'Animaux');
INSERT INTO Categorie VALUES (seq_categorie.NEXTVAL, 'Voyage');
INSERT INTO Categorie VALUES (seq_categorie.NEXTVAL, 'Urbain');
INSERT INTO Categorie VALUES (seq_categorie.NEXTVAL, 'Macro');

-- Insertion des LABELS
INSERT INTO Label VALUES (seq_label.NEXTVAL, 'paysage');
INSERT INTO Label VALUES (seq_label.NEXTVAL, 'montagne');
INSERT INTO Label VALUES (seq_label.NEXTVAL, 'mer');
INSERT INTO Label VALUES (seq_label.NEXTVAL, 'foret');
INSERT INTO Label VALUES (seq_label.NEXTVAL, 'ville');
INSERT INTO Label VALUES (seq_label.NEXTVAL, 'noir_et_blanc');
INSERT INTO Label VALUES (seq_label.NEXTVAL, 'coucher_soleil');
INSERT INTO Label VALUES (seq_label.NEXTVAL, 'hiver');
INSERT INTO Label VALUES (seq_label.NEXTVAL, 'ete');
INSERT INTO Label VALUES (seq_label.NEXTVAL, 'fleurs');
INSERT INTO Label VALUES (seq_label.NEXTVAL, 'oiseaux');
INSERT INTO Label VALUES (seq_label.NEXTVAL, 'street_art');

-- Insertion des ALBUMS
INSERT INTO Album VALUES (seq_album.NEXTVAL, 'Mes photos de vacances', 'Photos prises pendant mes vacances ete 2024', SYSTIMESTAMP, 'public', 1);
INSERT INTO Album VALUES (seq_album.NEXTVAL, 'Nature sauvage', 'Collection de photos de la nature', SYSTIMESTAMP, 'public', 1);
INSERT INTO Album VALUES (seq_album.NEXTVAL, 'Art moderne', 'Mes creations artistiques', SYSTIMESTAMP, 'public', 2);
INSERT INTO Album VALUES (seq_album.NEXTVAL, 'Portraits famille', 'Photos de famille', SYSTIMESTAMP, 'prive', 2);
INSERT INTO Album VALUES (seq_album.NEXTVAL, 'Faune europeenne', 'Animaux rencontres en Europe', SYSTIMESTAMP, 'public', 3);
INSERT INTO Album VALUES (seq_album.NEXTVAL, 'Voyages 2024', 'Mes aventures autour du monde', SYSTIMESTAMP, 'public', 4);
INSERT INTO Album VALUES (seq_album.NEXTVAL, 'Architecture urbaine', 'Batiments et structures', SYSTIMESTAMP, 'public', 5);
INSERT INTO Album VALUES (seq_album.NEXTVAL, 'Moments de vie', 'Portraits et scenes de rue', SYSTIMESTAMP, 'public', 6);
INSERT INTO Album VALUES (seq_album.NEXTVAL, 'Safari Afrique', 'Photos de safari en Tanzanie', SYSTIMESTAMP, 'public', 7);
INSERT INTO Album VALUES (seq_album.NEXTVAL, 'Monde miniature', 'Photographie macro', SYSTIMESTAMP, 'public', 8);

-- Insertion des IMAGES
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Coucher de soleil sur la plage', 'Magnifique coucher de soleil capture a Nice', SYSTIMESTAMP - INTERVAL '10' DAY, 'JPG', 2500, 'public', 'France', 1, 1, 1);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Vue sur les Alpes', 'Panorama alpin depuis Chamonix', SYSTIMESTAMP - INTERVAL '8' DAY, 'JPG', 3200, 'public', 'France', 1, 1, 1);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'La mer Mediterranee', 'Eau cristalline de la cote d''Azur', SYSTIMESTAMP - INTERVAL '5' DAY, 'PNG', 1800, 'public', 'France', 1, 1, 1);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Foret de Fontainebleau', 'Automne dans la foret', SYSTIMESTAMP - INTERVAL '12' DAY, 'JPG', 2100, 'public', 'France', 1, 2, 1);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Cascade en montagne', 'Cascade naturelle dans les Pyrenees', SYSTIMESTAMP - INTERVAL '3' DAY, 'JPG', 2800, 'public', 'France', 1, 2, 1);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Abstraction coloree', 'Oeuvre abstraite originale', SYSTIMESTAMP - INTERVAL '7' DAY, 'PNG', 1500, 'public', 'France', 0, 3, 3);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Sculpture moderne', 'Photo d''une sculpture contemporaine', SYSTIMESTAMP - INTERVAL '2' DAY, 'JPG', 1900, 'public', 'France', 1, 3, 3);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Cerf en foret', 'Cerf majestueux au petit matin', SYSTIMESTAMP - INTERVAL '6' DAY, 'JPG', 3500, 'public', 'Belgique', 1, 5, 5);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Renard roux', 'Renard photographie dans son habitat', SYSTIMESTAMP - INTERVAL '4' DAY, 'JPG', 2900, 'public', 'Belgique', 1, 5, 5);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Aigle royal', 'Aigle en plein vol', SYSTIMESTAMP - INTERVAL '1' DAY, 'JPG', 4100, 'public', 'France', 1, 5, 5);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Tokyo de nuit', 'Vue nocturne de Shibuya', SYSTIMESTAMP - INTERVAL '9' DAY, 'JPG', 2200, 'public', 'Japon', 1, 6, 6);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Temples de Kyoto', 'Temple dore Kinkaku-ji', SYSTIMESTAMP - INTERVAL '8' DAY, 'JPG', 2600, 'public', 'Japon', 1, 6, 6);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Santorini', 'Maisons blanches et domes bleus', SYSTIMESTAMP - INTERVAL '5' DAY, 'JPG', 2000, 'public', 'Grece', 1, 6, 6);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Tour Eiffel', 'La dame de fer au crepuscule', SYSTIMESTAMP - INTERVAL '11' DAY, 'JPG', 1700, 'public', 'France', 1, 7, 2);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Gratte-ciels NYC', 'Skyline de Manhattan', SYSTIMESTAMP - INTERVAL '4' DAY, 'JPG', 3100, 'public', 'USA', 1, 7, 2);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Colisee Rome', 'Monument antique au coucher du soleil', SYSTIMESTAMP - INTERVAL '2' DAY, 'JPG', 2400, 'public', 'Italie', 1, 7, 2);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Portrait artistique', 'Portrait en studio avec eclairage dramatique', SYSTIMESTAMP - INTERVAL '6' DAY, 'JPG', 1400, 'public', 'Espagne', 1, 8, 4);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Musicien de rue', 'Artiste jouant de la guitare', SYSTIMESTAMP - INTERVAL '3' DAY, 'JPG', 1600, 'public', 'Espagne', 1, 8, 4);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Lion au repos', 'Lion dans la savane tanzanienne', SYSTIMESTAMP - INTERVAL '7' DAY, 'JPG', 4500, 'public', 'Tanzanie', 1, 9, 5);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Elephants au point d''eau', 'Famille d''elephants', SYSTIMESTAMP - INTERVAL '5' DAY, 'JPG', 3800, 'public', 'Tanzanie', 1, 9, 5);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Girafe au coucher du soleil', 'Silhouette de girafe', SYSTIMESTAMP - INTERVAL '2' DAY, 'JPG', 2700, 'public', 'Tanzanie', 1, 9, 5);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Gouttes de rosee', 'Macro sur feuille avec rosee', SYSTIMESTAMP - INTERVAL '4' DAY, 'JPG', 1200, 'public', 'Allemagne', 1, 10, 8);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Abeille sur fleur', 'Abeille butinant une fleur de lavande', SYSTIMESTAMP - INTERVAL '1' DAY, 'JPG', 1500, 'public', 'Allemagne', 1, 10, 8);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Papillon monarque', 'Gros plan sur un papillon', SYSTIMESTAMP - INTERVAL '3' DAY, 'JPG', 1800, 'public', 'Allemagne', 1, 10, 8);

-- Insertion des AIME (likes)
INSERT INTO Aime VALUES (2, 1, SYSTIMESTAMP - INTERVAL '9' DAY);
INSERT INTO Aime VALUES (3, 1, SYSTIMESTAMP - INTERVAL '8' DAY);
INSERT INTO Aime VALUES (4, 1, SYSTIMESTAMP - INTERVAL '7' DAY);
INSERT INTO Aime VALUES (5, 1, SYSTIMESTAMP - INTERVAL '6' DAY);
INSERT INTO Aime VALUES (6, 1, SYSTIMESTAMP - INTERVAL '5' DAY);
INSERT INTO Aime VALUES (2, 2, SYSTIMESTAMP - INTERVAL '7' DAY);
INSERT INTO Aime VALUES (4, 2, SYSTIMESTAMP - INTERVAL '6' DAY);
INSERT INTO Aime VALUES (7, 2, SYSTIMESTAMP - INTERVAL '5' DAY);
INSERT INTO Aime VALUES (2, 5, SYSTIMESTAMP - INTERVAL '2' DAY);
INSERT INTO Aime VALUES (3, 5, SYSTIMESTAMP - INTERVAL '1' DAY);
INSERT INTO Aime VALUES (6, 5, SYSTIMESTAMP - INTERVAL '1' DAY);
INSERT INTO Aime VALUES (8, 5, SYSTIMESTAMP - INTERVAL '1' DAY);
INSERT INTO Aime VALUES (1, 8, SYSTIMESTAMP - INTERVAL '5' DAY);
INSERT INTO Aime VALUES (2, 8, SYSTIMESTAMP - INTERVAL '4' DAY);
INSERT INTO Aime VALUES (4, 8, SYSTIMESTAMP - INTERVAL '4' DAY);
INSERT INTO Aime VALUES (6, 8, SYSTIMESTAMP - INTERVAL '3' DAY);
INSERT INTO Aime VALUES (7, 8, SYSTIMESTAMP - INTERVAL '2' DAY);
INSERT INTO Aime VALUES (8, 8, SYSTIMESTAMP - INTERVAL '1' DAY);
INSERT INTO Aime VALUES (1, 10, SYSTIMESTAMP - INTERVAL '1' DAY);
INSERT INTO Aime VALUES (2, 10, SYSTIMESTAMP - INTERVAL '1' DAY);
INSERT INTO Aime VALUES (4, 10, SYSTIMESTAMP - INTERVAL '1' DAY);
INSERT INTO Aime VALUES (5, 10, SYSTIMESTAMP - INTERVAL '1' DAY);
INSERT INTO Aime VALUES (6, 10, SYSTIMESTAMP - INTERVAL '1' DAY);
INSERT INTO Aime VALUES (7, 10, SYSTIMESTAMP - INTERVAL '1' DAY);
INSERT INTO Aime VALUES (8, 10, SYSTIMESTAMP - INTERVAL '1' DAY);
INSERT INTO Aime VALUES (1, 11, SYSTIMESTAMP - INTERVAL '8' DAY);
INSERT INTO Aime VALUES (3, 11, SYSTIMESTAMP - INTERVAL '7' DAY);
INSERT INTO Aime VALUES (5, 11, SYSTIMESTAMP - INTERVAL '6' DAY);
INSERT INTO Aime VALUES (8, 11, SYSTIMESTAMP - INTERVAL '5' DAY);
INSERT INTO Aime VALUES (1, 14, SYSTIMESTAMP - INTERVAL '10' DAY);
INSERT INTO Aime VALUES (2, 14, SYSTIMESTAMP - INTERVAL '9' DAY);
INSERT INTO Aime VALUES (3, 14, SYSTIMESTAMP - INTERVAL '8' DAY);
INSERT INTO Aime VALUES (4, 14, SYSTIMESTAMP - INTERVAL '7' DAY);
INSERT INTO Aime VALUES (6, 14, SYSTIMESTAMP - INTERVAL '6' DAY);
INSERT INTO Aime VALUES (1, 19, SYSTIMESTAMP - INTERVAL '6' DAY);
INSERT INTO Aime VALUES (2, 19, SYSTIMESTAMP - INTERVAL '5' DAY);
INSERT INTO Aime VALUES (3, 19, SYSTIMESTAMP - INTERVAL '4' DAY);
INSERT INTO Aime VALUES (4, 19, SYSTIMESTAMP - INTERVAL '4' DAY);
INSERT INTO Aime VALUES (5, 19, SYSTIMESTAMP - INTERVAL '3' DAY);
INSERT INTO Aime VALUES (6, 19, SYSTIMESTAMP - INTERVAL '2' DAY);
INSERT INTO Aime VALUES (8, 19, SYSTIMESTAMP - INTERVAL '1' DAY);
INSERT INTO Aime VALUES (1, 21, SYSTIMESTAMP - INTERVAL '1' DAY);
INSERT INTO Aime VALUES (2, 21, SYSTIMESTAMP - INTERVAL '1' DAY);
INSERT INTO Aime VALUES (3, 21, SYSTIMESTAMP - INTERVAL '1' DAY);
INSERT INTO Aime VALUES (5, 21, SYSTIMESTAMP - INTERVAL '1' DAY);
INSERT INTO Aime VALUES (8, 21, SYSTIMESTAMP - INTERVAL '1' DAY);
INSERT INTO Aime VALUES (1, 23, SYSTIMESTAMP - INTERVAL '1' DAY);
INSERT INTO Aime VALUES (3, 23, SYSTIMESTAMP - INTERVAL '1' DAY);
INSERT INTO Aime VALUES (4, 23, SYSTIMESTAMP - INTERVAL '1' DAY);
INSERT INTO Aime VALUES (7, 23, SYSTIMESTAMP - INTERVAL '1' DAY);

-- Insertion des COMMENTAIRES
INSERT INTO Commentaire VALUES (seq_commentaire.NEXTVAL, 'Superbe photo ! Les couleurs sont magnifiques.', SYSTIMESTAMP - INTERVAL '9' DAY, 2, 1);
INSERT INTO Commentaire VALUES (seq_commentaire.NEXTVAL, 'Quel endroit paradisiaque !', SYSTIMESTAMP - INTERVAL '8' DAY, 3, 1);
INSERT INTO Commentaire VALUES (seq_commentaire.NEXTVAL, 'La composition est parfaite.', SYSTIMESTAMP - INTERVAL '7' DAY, 4, 1);
INSERT INTO Commentaire VALUES (seq_commentaire.NEXTVAL, 'Impressionnant ! Quel objectif as-tu utilise ?', SYSTIMESTAMP - INTERVAL '5' DAY, 1, 8);
INSERT INTO Commentaire VALUES (seq_commentaire.NEXTVAL, 'J''adore la lumiere du matin sur cette photo.', SYSTIMESTAMP - INTERVAL '4' DAY, 4, 8);
INSERT INTO Commentaire VALUES (seq_commentaire.NEXTVAL, 'Tokyo est magique de nuit !', SYSTIMESTAMP - INTERVAL '7' DAY, 3, 11);
INSERT INTO Commentaire VALUES (seq_commentaire.NEXTVAL, 'Je reve d''y aller un jour.', SYSTIMESTAMP - INTERVAL '6' DAY, 5, 11);
INSERT INTO Commentaire VALUES (seq_commentaire.NEXTVAL, 'Le roi de la savane dans toute sa splendeur !', SYSTIMESTAMP - INTERVAL '5' DAY, 2, 19);
INSERT INTO Commentaire VALUES (seq_commentaire.NEXTVAL, 'Photo incroyable, bravo !', SYSTIMESTAMP - INTERVAL '4' DAY, 4, 19);
INSERT INTO Commentaire VALUES (seq_commentaire.NEXTVAL, 'Quel safari chanceux !', SYSTIMESTAMP - INTERVAL '3' DAY, 6, 19);
INSERT INTO Commentaire VALUES (seq_commentaire.NEXTVAL, 'La macro est vraiment un art a part entiere.', SYSTIMESTAMP - INTERVAL '1' DAY, 1, 23);

-- Insertion des PREFERE (categories preferees)
INSERT INTO Prefere VALUES (1, 1);
INSERT INTO Prefere VALUES (1, 6);
INSERT INTO Prefere VALUES (2, 3);
INSERT INTO Prefere VALUES (2, 4);
INSERT INTO Prefere VALUES (3, 1);
INSERT INTO Prefere VALUES (3, 5);
INSERT INTO Prefere VALUES (4, 6);
INSERT INTO Prefere VALUES (4, 2);
INSERT INTO Prefere VALUES (5, 2);
INSERT INTO Prefere VALUES (5, 7);
INSERT INTO Prefere VALUES (6, 4);
INSERT INTO Prefere VALUES (6, 3);
INSERT INTO Prefere VALUES (7, 5);
INSERT INTO Prefere VALUES (7, 1);
INSERT INTO Prefere VALUES (8, 8);
INSERT INTO Prefere VALUES (8, 1);

-- Insertion des ETIQUETTES (labels sur images)
INSERT INTO Etiquette VALUES (1, 3);
INSERT INTO Etiquette VALUES (1, 7);
INSERT INTO Etiquette VALUES (1, 9);
INSERT INTO Etiquette VALUES (2, 1);
INSERT INTO Etiquette VALUES (2, 2);
INSERT INTO Etiquette VALUES (3, 3);
INSERT INTO Etiquette VALUES (3, 9);
INSERT INTO Etiquette VALUES (4, 1);
INSERT INTO Etiquette VALUES (4, 4);
INSERT INTO Etiquette VALUES (5, 2);
INSERT INTO Etiquette VALUES (8, 4);
INSERT INTO Etiquette VALUES (9, 4);
INSERT INTO Etiquette VALUES (10, 11);
INSERT INTO Etiquette VALUES (11, 5);
INSERT INTO Etiquette VALUES (12, 1);
INSERT INTO Etiquette VALUES (14, 5);
INSERT INTO Etiquette VALUES (15, 5);
INSERT INTO Etiquette VALUES (19, 7);
INSERT INTO Etiquette VALUES (21, 7);
INSERT INTO Etiquette VALUES (22, 10);
INSERT INTO Etiquette VALUES (23, 10);
INSERT INTO Etiquette VALUES (24, 10);

-- Insertion des NEWSLETTERS
INSERT INTO Newsletter VALUES (seq_newsletter.NEXTVAL, TO_DATE('2024-12-01', 'YYYY-MM-DD'), 'Newsletter de decembre 2024 - Decouvrez les plus belles images de la semaine !');
INSERT INTO Newsletter VALUES (seq_newsletter.NEXTVAL, TO_DATE('2024-12-08', 'YYYY-MM-DD'), 'Newsletter semaine 2 decembre - Les coups de coeur de la communaute');

-- Insertion des MET_EN_AVANT (images dans newsletters)
INSERT INTO Met_en_avant VALUES (1, 1);
INSERT INTO Met_en_avant VALUES (1, 8);
INSERT INTO Met_en_avant VALUES (1, 14);
INSERT INTO Met_en_avant VALUES (1, 19);
INSERT INTO Met_en_avant VALUES (2, 5);
INSERT INTO Met_en_avant VALUES (2, 10);
INSERT INTO Met_en_avant VALUES (2, 21);
INSERT INTO Met_en_avant VALUES (2, 23);

COMMIT;

-- =============================================================================
-- VERIFICATION DES DONNEES
-- =============================================================================

SELECT 'Utilisateurs' AS "Table", COUNT(*) AS "Nb lignes" FROM Utilisateur
UNION ALL SELECT 'Categories', COUNT(*) FROM Categorie
UNION ALL SELECT 'Labels', COUNT(*) FROM Label
UNION ALL SELECT 'Albums', COUNT(*) FROM Album
UNION ALL SELECT 'Images', COUNT(*) FROM Image
UNION ALL SELECT 'Likes (Aime)', COUNT(*) FROM Aime
UNION ALL SELECT 'Commentaires', COUNT(*) FROM Commentaire
UNION ALL SELECT 'Preferences', COUNT(*) FROM Prefere
UNION ALL SELECT 'Etiquettes', COUNT(*) FROM Etiquette
UNION ALL SELECT 'Newsletters', COUNT(*) FROM Newsletter
UNION ALL SELECT 'Met_en_avant', COUNT(*) FROM Met_en_avant;

-- =============================================================================
-- FIN DU SCRIPT
-- =============================================================================
