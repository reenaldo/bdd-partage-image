-- =============================================================================
-- Script de generation de donnees massives pour tests de performance
-- =============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET TIMING ON;

PROMPT =========================================
PROMPT GENERATION DE DONNEES MASSIVES
PROMPT =========================================

-- -----------------------------------------------------------------------------
-- Procedure de generation d'utilisateurs
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE generer_utilisateurs(p_nb IN NUMBER) AS
    v_login VARCHAR2(50);
    v_email VARCHAR2(150);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Generation de ' || p_nb || ' utilisateurs...');
    
    FOR i IN 1..p_nb LOOP
        v_login := 'user_gen_' || i;
        v_email := 'user_gen_' || i || '@test.com';
        
        BEGIN
            INSERT INTO Utilisateur (
                idUtilisateur, login, mot_de_passe, nom, prenom, 
                date_naissance, email, pays, abonne_newsletter
            ) VALUES (
                seq_utilisateur.NEXTVAL, 
                v_login,
                'hash_pwd_' || i,
                'Nom' || MOD(i, 30),
                'Prenom' || MOD(i, 30),
                ADD_MONTHS(DATE '1970-01-01', MOD(i * 7, 480)),
                v_email,
                CASE MOD(i, 5) 
                    WHEN 0 THEN 'France'
                    WHEN 1 THEN 'Belgique'
                    WHEN 2 THEN 'Suisse'
                    WHEN 3 THEN 'Canada'
                    ELSE 'Espagne'
                END,
                MOD(i, 2)
            );
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN NULL;
        END;
        
        IF MOD(i, 100) = 0 THEN
            COMMIT;
        END IF;
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('[OK] Utilisateurs generes');
END;
/

-- -----------------------------------------------------------------------------
-- Procedure de generation de categories
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE generer_categories(p_nb IN NUMBER) AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Generation de categories...');
    
    FOR i IN 1..p_nb LOOP
        BEGIN
            INSERT INTO Categorie (idCategorie, nom)
            VALUES (seq_categorie.NEXTVAL, 'Categorie_' || i);
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN NULL;
        END;
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('[OK] Categories generees');
END;
/

-- -----------------------------------------------------------------------------
-- Procedure de generation de labels
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE generer_labels(p_nb IN NUMBER) AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Generation de labels...');
    
    FOR i IN 1..p_nb LOOP
        BEGIN
            INSERT INTO Label (idLabel, nom)
            VALUES (seq_label.NEXTVAL, 'tag_' || i);
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN NULL;
        END;
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('[OK] Labels generes');
END;
/

-- -----------------------------------------------------------------------------
-- Procedure de generation d'albums
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE generer_albums(p_nb_par_user IN NUMBER) AS
    v_count NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Generation d''albums...');
    
    FOR rec IN (SELECT idUtilisateur FROM Utilisateur) LOOP
        FOR i IN 1..p_nb_par_user LOOP
            INSERT INTO Album (
                idAlbum, titre, description, date_creation, 
                visibilite, idUtilisateur
            ) VALUES (
                seq_album.NEXTVAL,
                'Album ' || v_count || ' - ' || i,
                'Description album genere',
                SYSTIMESTAMP - MOD(v_count, 365),
                CASE WHEN MOD(i, 5) = 0 THEN 'prive' ELSE 'public' END,
                rec.idUtilisateur
            );
            v_count := v_count + 1;
        END LOOP;
        
        IF MOD(v_count, 500) = 0 THEN
            COMMIT;
        END IF;
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('[OK] ' || v_count || ' albums generes');
END;
/

-- -----------------------------------------------------------------------------
-- Procedure de generation d'images
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE generer_images(p_nb_par_album IN NUMBER) AS
    v_count NUMBER := 0;
    v_cat_id NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Generation d''images...');
    
    -- Recuperer une categorie existante
    SELECT MIN(idCategorie) INTO v_cat_id FROM Categorie;
    
    IF v_cat_id IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Erreur: Aucune categorie');
        RETURN;
    END IF;
    
    FOR rec IN (SELECT idAlbum FROM Album) LOOP
        FOR i IN 1..p_nb_par_album LOOP
            -- Varier la categorie
            SELECT idCategorie INTO v_cat_id 
            FROM Categorie 
            WHERE ROWNUM = 1;
            
            INSERT INTO Image (
                idImage, titre, description, date_publication, format,
                taille, visibilite, pays_origine, telechargeable,
                idAlbum, idCategorie
            ) VALUES (
                seq_image.NEXTVAL,
                'Image #' || rec.idAlbum || '-' || i,
                'Image generee pour tests',
                SYSTIMESTAMP - MOD(v_count, 180),
                CASE MOD(i, 4) WHEN 0 THEN 'JPG' WHEN 1 THEN 'PNG' WHEN 2 THEN 'RAW' ELSE 'TIFF' END,
                500 + MOD(v_count * 7, 9500),
                CASE WHEN MOD(i, 10) = 0 THEN 'prive' ELSE 'public' END,
                'France',
                CASE WHEN MOD(i, 8) = 0 THEN 0 ELSE 1 END,
                rec.idAlbum,
                v_cat_id
            );
            
            v_count := v_count + 1;
        END LOOP;
        
        IF MOD(v_count, 1000) = 0 THEN
            COMMIT;
        END IF;
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('[OK] ' || v_count || ' images generees');
END;
/

-- -----------------------------------------------------------------------------
-- Procedure de generation de likes (table Aime)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE generer_likes(p_nb_par_image IN NUMBER) AS
    v_count NUMBER := 0;
    v_user_id NUMBER;
    v_offset NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Generation de likes...');
    
    FOR img IN (SELECT idImage FROM Image WHERE visibilite = 'public') LOOP
        v_offset := 0;
        FOR usr IN (SELECT idUtilisateur FROM Utilisateur WHERE ROWNUM <= p_nb_par_image) LOOP
            BEGIN
                INSERT INTO Aime (idUtilisateur, idImage, date_aime)
                VALUES (usr.idUtilisateur, img.idImage, SYSTIMESTAMP - MOD(v_count, 90));
                v_count := v_count + 1;
            EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN NULL;
            END;
            v_offset := v_offset + 1;
            EXIT WHEN v_offset >= p_nb_par_image;
        END LOOP;
        
        IF MOD(v_count, 5000) = 0 THEN
            COMMIT;
        END IF;
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('[OK] ' || v_count || ' likes generes');
END;
/

-- -----------------------------------------------------------------------------
-- Procedure de generation de commentaires
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE generer_commentaires(p_nb_par_image IN NUMBER) AS
    v_count NUMBER := 0;
    v_offset NUMBER := 0;
    v_comments VARCHAR2(500);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Generation de commentaires...');
    
    FOR img IN (SELECT idImage FROM Image WHERE visibilite = 'public') LOOP
        v_offset := 0;
        FOR usr IN (SELECT idUtilisateur FROM Utilisateur WHERE ROWNUM <= p_nb_par_image) LOOP
            IF MOD(v_count, 10) = 0 THEN v_comments := 'Superbe photo!';
            ELSIF MOD(v_count, 10) = 1 THEN v_comments := 'Magnifique!';
            ELSIF MOD(v_count, 10) = 2 THEN v_comments := 'J''adore!';
            ELSIF MOD(v_count, 10) = 3 THEN v_comments := 'Tres belle composition';
            ELSIF MOD(v_count, 10) = 4 THEN v_comments := 'Impressionnant!';
            ELSIF MOD(v_count, 10) = 5 THEN v_comments := 'Bravo!';
            ELSIF MOD(v_count, 10) = 6 THEN v_comments := 'Quelle qualite!';
            ELSIF MOD(v_count, 10) = 7 THEN v_comments := 'Tres inspirant';
            ELSIF MOD(v_count, 10) = 8 THEN v_comments := 'Excellent travail!';
            ELSE v_comments := 'Fantastique!';
            END IF;
            
            INSERT INTO Commentaire (
                idCommentaire, texte_commentaire, date_commentaire,
                idUtilisateur, idImage
            ) VALUES (
                seq_commentaire.NEXTVAL,
                v_comments,
                SYSTIMESTAMP - MOD(v_count, 60),
                usr.idUtilisateur,
                img.idImage
            );
            v_count := v_count + 1;
            v_offset := v_offset + 1;
            EXIT WHEN v_offset >= p_nb_par_image;
        END LOOP;
        
        IF MOD(v_count, 5000) = 0 THEN
            COMMIT;
        END IF;
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('[OK] ' || v_count || ' commentaires generes');
END;
/

-- -----------------------------------------------------------------------------
-- Procedure de generation d'etiquettes
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE generer_etiquettes AS
    v_count NUMBER := 0;
    v_nb_labels NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Generation d''etiquettes...');
    
    FOR img IN (SELECT idImage FROM Image) LOOP
        v_nb_labels := 0;
        FOR lbl IN (SELECT idLabel FROM Label WHERE ROWNUM <= 5) LOOP
            BEGIN
                INSERT INTO Etiquette (idImage, idLabel)
                VALUES (img.idImage, lbl.idLabel);
                v_count := v_count + 1;
            EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN NULL;
            END;
            v_nb_labels := v_nb_labels + 1;
            EXIT WHEN v_nb_labels >= MOD(v_count, 4) + 2;
        END LOOP;
        
        IF MOD(v_count, 5000) = 0 THEN
            COMMIT;
        END IF;
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('[OK] ' || v_count || ' etiquettes generees');
END;
/

-- -----------------------------------------------------------------------------
-- Procedure de generation des preferences
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE generer_preferences AS
    v_count NUMBER := 0;
    v_nb_prefs NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Generation des preferences...');
    
    FOR usr IN (SELECT idUtilisateur FROM Utilisateur) LOOP
        v_nb_prefs := 0;
        FOR cat IN (SELECT idCategorie FROM Categorie WHERE ROWNUM <= 5) LOOP
            BEGIN
                INSERT INTO Prefere (idUtilisateur, idCategorie)
                VALUES (usr.idUtilisateur, cat.idCategorie);
                v_count := v_count + 1;
            EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN NULL;
            END;
            v_nb_prefs := v_nb_prefs + 1;
            EXIT WHEN v_nb_prefs >= MOD(v_count, 4) + 1;
        END LOOP;
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('[OK] ' || v_count || ' preferences generees');
END;
/

-- -----------------------------------------------------------------------------
-- Procedure principale
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE generer_donnees_test(
    p_nb_utilisateurs IN NUMBER DEFAULT 100,
    p_nb_categories IN NUMBER DEFAULT 20,
    p_nb_labels IN NUMBER DEFAULT 50,
    p_nb_albums_par_user IN NUMBER DEFAULT 3,
    p_nb_images_par_album IN NUMBER DEFAULT 10,
    p_nb_likes_par_image IN NUMBER DEFAULT 15,
    p_nb_commentaires_par_image IN NUMBER DEFAULT 5
) AS
    v_start TIMESTAMP;
    v_end TIMESTAMP;
BEGIN
    v_start := SYSTIMESTAMP;
    
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('DEBUT GENERATION - ' || TO_CHAR(SYSDATE, 'HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('==========================================');
    
    -- Desactiver les triggers anti-spam pour les insertions massives
    DBMS_OUTPUT.PUT_LINE('Desactivation des triggers anti-spam...');
    BEGIN
        EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_ANTI_SPAM_IMAGES DISABLE';
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
    BEGIN
        EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_ANTI_SPAM_COMMENTAIRES DISABLE';
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
    
    generer_categories(p_nb_categories);
    generer_labels(p_nb_labels);
    generer_utilisateurs(p_nb_utilisateurs);
    generer_albums(p_nb_albums_par_user);
    generer_images(p_nb_images_par_album);
    generer_etiquettes;
    generer_preferences;
    generer_likes(p_nb_likes_par_image);
    generer_commentaires(p_nb_commentaires_par_image);
    
    -- Reactiver les triggers
    DBMS_OUTPUT.PUT_LINE('Reactivation des triggers anti-spam...');
    BEGIN
        EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_ANTI_SPAM_IMAGES ENABLE';
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
    BEGIN
        EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_ANTI_SPAM_COMMENTAIRES ENABLE';
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
    
    v_end := SYSTIMESTAMP;
    
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('GENERATION TERMINEE');
    DBMS_OUTPUT.PUT_LINE('==========================================');
END;
/

-- -----------------------------------------------------------------------------
-- Procedure d'affichage des statistiques
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE afficher_statistiques AS
    v_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('STATISTIQUES DE LA BASE DE DONNEES');
    DBMS_OUTPUT.PUT_LINE('==========================================');
    
    SELECT COUNT(*) INTO v_count FROM Utilisateur;
    DBMS_OUTPUT.PUT_LINE('Utilisateurs:     ' || LPAD(v_count, 10));
    
    SELECT COUNT(*) INTO v_count FROM Categorie;
    DBMS_OUTPUT.PUT_LINE('Categories:       ' || LPAD(v_count, 10));
    
    SELECT COUNT(*) INTO v_count FROM Label;
    DBMS_OUTPUT.PUT_LINE('Labels:           ' || LPAD(v_count, 10));
    
    SELECT COUNT(*) INTO v_count FROM Album;
    DBMS_OUTPUT.PUT_LINE('Albums:           ' || LPAD(v_count, 10));
    
    SELECT COUNT(*) INTO v_count FROM Image;
    DBMS_OUTPUT.PUT_LINE('Images:           ' || LPAD(v_count, 10));
    
    SELECT COUNT(*) INTO v_count FROM Aime;
    DBMS_OUTPUT.PUT_LINE('Likes (Aime):     ' || LPAD(v_count, 10));
    
    SELECT COUNT(*) INTO v_count FROM Commentaire;
    DBMS_OUTPUT.PUT_LINE('Commentaires:     ' || LPAD(v_count, 10));
    
    SELECT COUNT(*) INTO v_count FROM Etiquette;
    DBMS_OUTPUT.PUT_LINE('Etiquettes:       ' || LPAD(v_count, 10));
    
    SELECT COUNT(*) INTO v_count FROM Prefere;
    DBMS_OUTPUT.PUT_LINE('Preferences:      ' || LPAD(v_count, 10));
    
    DBMS_OUTPUT.PUT_LINE('==========================================');
END;
/

-- =============================================================================
-- INSTRUCTIONS
-- =============================================================================

PROMPT
PROMPT Toutes les procedures sont creees.
PROMPT
PROMPT Pour generer des donnees:
PROMPT   EXEC generer_donnees_test(100, 20, 50, 3, 10, 15, 5);
PROMPT
PROMPT Pour voir les statistiques:
PROMPT   EXEC afficher_statistiques;
PROMPT

EXEC afficher_statistiques;
