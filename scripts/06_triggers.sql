-- =============================================================================
-- Declencheurs (Triggers) PL/SQL
-- =============================================================================

SET SERVEROUTPUT ON;

-- =============================================================================
-- TRIGGER 1 : Un utilisateur ne peut pas creer plus de X albums (X=10)
-- =============================================================================
CREATE OR REPLACE TRIGGER trg_limite_albums
BEFORE INSERT ON Album
FOR EACH ROW
DECLARE
    v_nb_albums NUMBER;
    v_max_albums CONSTANT NUMBER := 10;
BEGIN
    -- Compter le nombre d'albums existants pour cet utilisateur
    SELECT COUNT(*)
    INTO v_nb_albums
    FROM Album
    WHERE idUtilisateur = :NEW.idUtilisateur;
    
    -- Verifier la limite
    IF v_nb_albums >= v_max_albums THEN
        RAISE_APPLICATION_ERROR(-20001, 
            'Limite atteinte: Un utilisateur ne peut pas avoir plus de ' || 
            v_max_albums || ' albums. Vous en avez deja ' || v_nb_albums || '.');
    END IF;
END trg_limite_albums;
/

-- =============================================================================
-- TRIGGER 2 : Archivage automatique lors de la suppression d'une image
-- =============================================================================
CREATE OR REPLACE TRIGGER trg_archivage_image
BEFORE DELETE ON Image
FOR EACH ROW
BEGIN
    -- Inserer l'image dans la table d'archive
    INSERT INTO Image_archive (
        idImageArchive,
        titre,
        description,
        date_publication,
        format,
        taille,
        visibilite,
        pays_origine,
        telechargeable,
        date_archivage
    ) VALUES (
        seq_image_archive.NEXTVAL,
        :OLD.titre,
        :OLD.description,
        :OLD.date_publication,
        :OLD.format,
        :OLD.taille,
        :OLD.visibilite,
        :OLD.pays_origine,
        :OLD.telechargeable,
        SYSTIMESTAMP
    );

    DBMS_OUTPUT.PUT_LINE('Image archivee: ' || :OLD.titre);
END trg_archivage_image;
/

-- =============================================================================
-- TRIGGER 3 : Anti-spam - Un utilisateur ne peut pas ajouter plus de Y images
--             par seconde (Y=5)
-- =============================================================================
CREATE OR REPLACE TRIGGER trg_anti_spam_images
BEFORE INSERT ON Image
FOR EACH ROW
DECLARE
    v_idUtilisateur NUMBER;
    v_derniere_upload TIMESTAMP;
    v_nb_uploads NUMBER;
    v_max_uploads CONSTANT NUMBER := 5;
    v_intervalle NUMBER;
BEGIN
    -- Recuperer l'ID de l'utilisateur proprietaire de l'album
    SELECT idUtilisateur INTO v_idUtilisateur
    FROM Album
    WHERE idAlbum = :NEW.idAlbum;
    
    -- Verifier si l'utilisateur existe dans la table de tracking
    BEGIN
        SELECT derniere_upload, nb_uploads_seconde
        INTO v_derniere_upload, v_nb_uploads
        FROM Upload_Tracking
        WHERE idUtilisateur = v_idUtilisateur;
        
        -- Calculer l'intervalle en secondes
        v_intervalle := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_derniere_upload)) +
                        EXTRACT(MINUTE FROM (SYSTIMESTAMP - v_derniere_upload)) * 60 +
                        EXTRACT(HOUR FROM (SYSTIMESTAMP - v_derniere_upload)) * 3600 +
                        EXTRACT(DAY FROM (SYSTIMESTAMP - v_derniere_upload)) * 86400;
        
        IF v_intervalle < 1 THEN
            -- Moins d'une seconde depuis le dernier upload
            IF v_nb_uploads >= v_max_uploads THEN
                RAISE_APPLICATION_ERROR(-20002,
                    'Anti-spam: Vous ne pouvez pas ajouter plus de ' || 
                    v_max_uploads || ' images par seconde. Veuillez patienter.');
            ELSE
                -- Incrementer le compteur
                UPDATE Upload_Tracking
                SET nb_uploads_seconde = v_nb_uploads + 1,
                    derniere_upload = SYSTIMESTAMP
                WHERE idUtilisateur = v_idUtilisateur;
            END IF;
        ELSE
            -- Plus d'une seconde, reinitialiser le compteur
            UPDATE Upload_Tracking
            SET nb_uploads_seconde = 1,
                derniere_upload = SYSTIMESTAMP
            WHERE idUtilisateur = v_idUtilisateur;
        END IF;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Premier upload de cet utilisateur
            INSERT INTO Upload_Tracking (idUtilisateur, derniere_upload, nb_uploads_seconde)
            VALUES (v_idUtilisateur, SYSTIMESTAMP, 1);
    END;
END trg_anti_spam_images;
/

-- =============================================================================
-- TRIGGER 4 : Empecher un utilisateur de liker sa propre image
-- =============================================================================
CREATE OR REPLACE TRIGGER trg_no_self_like
BEFORE INSERT ON Aime
FOR EACH ROW
DECLARE
    v_proprietaire NUMBER;
BEGIN
    -- Trouver le proprietaire de l'image
    SELECT a.idUtilisateur INTO v_proprietaire
    FROM Album a
    JOIN Image i ON a.idAlbum = i.idAlbum
    WHERE i.idImage = :NEW.idImage;
    
    IF v_proprietaire = :NEW.idUtilisateur THEN
        RAISE_APPLICATION_ERROR(-20005,
            'Vous ne pouvez pas liker votre propre image.');
    END IF;
END trg_no_self_like;
/

-- =============================================================================
-- TRIGGER 5 : Empecher un utilisateur de commenter sa propre image
-- =============================================================================
CREATE OR REPLACE TRIGGER trg_no_self_comment
BEFORE INSERT ON Commentaire
FOR EACH ROW
DECLARE
    v_proprietaire NUMBER;
BEGIN
    -- Trouver le proprietaire de l'image
    SELECT a.idUtilisateur INTO v_proprietaire
    FROM Album a
    JOIN Image i ON a.idAlbum = i.idAlbum
    WHERE i.idImage = :NEW.idImage;

    IF v_proprietaire = :NEW.idUtilisateur THEN
        RAISE_APPLICATION_ERROR(-20006,
            'Vous ne pouvez pas commenter votre propre image.');
    END IF;
END trg_no_self_comment;
/

-- =============================================================================
-- TRIGGER 6 : Mise a jour automatique de la date de publication
-- =============================================================================
CREATE OR REPLACE TRIGGER trg_date_publication_auto
BEFORE INSERT ON Image
FOR EACH ROW
BEGIN
    IF :NEW.date_publication IS NULL THEN
        :NEW.date_publication := SYSTIMESTAMP;
    END IF;
END trg_date_publication_auto;
/

-- =============================================================================
-- Fin des declencheurs
-- =============================================================================
