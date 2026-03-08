-- =============================================================================
-- Script de création des tables
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Table UTILISATEUR
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- 2. Table CATEGORIE
-- -----------------------------------------------------------------------------
CREATE TABLE Categorie (
    idCategorie     NUMBER PRIMARY KEY,
    nom             VARCHAR2(100) NOT NULL UNIQUE
);

-- -----------------------------------------------------------------------------
-- 3. Table LABEL
-- -----------------------------------------------------------------------------
CREATE TABLE Label (
    idLabel     NUMBER PRIMARY KEY,
    nom         VARCHAR2(100) NOT NULL UNIQUE
);

-- -----------------------------------------------------------------------------
-- 4. Table ALBUM
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- 5. Table IMAGE
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- 6. Table IMAGE_ARCHIVE
-- -----------------------------------------------------------------------------
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
-- -----------------------------------------------------------------------------
-- 7. Table NEWSLETTER
-- -----------------------------------------------------------------------------
CREATE TABLE Newsletter (
    idNewsletter    NUMBER PRIMARY KEY,
    date_envoi      DATE NOT NULL,
    contenu         CLOB NOT NULL
);

-- -----------------------------------------------------------------------------
-- 8. Table AIME (Association Utilisateur - Image)
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- 9. Table COMMENTAIRE
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- 10. Table PREFERE (Association Utilisateur - Categorie)
-- -----------------------------------------------------------------------------
CREATE TABLE Prefere (
    idUtilisateur   NUMBER NOT NULL,
    idCategorie     NUMBER NOT NULL,
    CONSTRAINT pk_prefere PRIMARY KEY (idUtilisateur, idCategorie),
    CONSTRAINT fk_prefere_utilisateur FOREIGN KEY (idUtilisateur) 
        REFERENCES Utilisateur(idUtilisateur) ON DELETE CASCADE,
    CONSTRAINT fk_prefere_categorie FOREIGN KEY (idCategorie) 
        REFERENCES Categorie(idCategorie) ON DELETE CASCADE
);

-- -----------------------------------------------------------------------------
-- 11. Table ETIQUETTE (Association Image - Label)
-- -----------------------------------------------------------------------------
CREATE TABLE Etiquette (
    idImage     NUMBER NOT NULL,
    idLabel     NUMBER NOT NULL,
    CONSTRAINT pk_etiquette PRIMARY KEY (idImage, idLabel),
    CONSTRAINT fk_etiquette_image FOREIGN KEY (idImage) 
        REFERENCES Image(idImage) ON DELETE CASCADE,
    CONSTRAINT fk_etiquette_label FOREIGN KEY (idLabel) 
        REFERENCES Label(idLabel) ON DELETE CASCADE
);

-- -----------------------------------------------------------------------------
-- 12. Table MET_EN_AVANT (Association Newsletter - Image)
-- -----------------------------------------------------------------------------
CREATE TABLE Met_en_avant (
    idNewsletter    NUMBER NOT NULL,
    idImage         NUMBER NOT NULL,
    CONSTRAINT pk_met_en_avant PRIMARY KEY (idNewsletter, idImage),
    CONSTRAINT fk_met_en_avant_newsletter FOREIGN KEY (idNewsletter)
        REFERENCES Newsletter(idNewsletter) ON DELETE CASCADE,
    CONSTRAINT fk_met_en_avant_image FOREIGN KEY (idImage)
        REFERENCES Image(idImage) ON DELETE CASCADE
);

-- -----------------------------------------------------------------------------
-- 13. Table UPLOAD_TRACKING (Pour anti-spam des images)
-- -----------------------------------------------------------------------------
CREATE TABLE Upload_Tracking (
    idUtilisateur       NUMBER PRIMARY KEY,
    derniere_upload     TIMESTAMP,
    nb_uploads_seconde  NUMBER DEFAULT 0,
    CONSTRAINT fk_upload_tracking_utilisateur FOREIGN KEY (idUtilisateur)
        REFERENCES Utilisateur(idUtilisateur) ON DELETE CASCADE
);

-- =============================================================================
-- Création des séquences pour auto-incrément
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
-- Fin du script de création
-- =============================================================================
