-- =============================================================================
-- Script de test de performance
-- =============================================================================
-- Ce script mesure les performances des requêtes et opérations
-- sur un grand volume de données
-- =============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET TIMING ON;
SET LINESIZE 200;

PROMPT =========================================
PROMPT TESTS DE PERFORMANCE
PROMPT =========================================

-- -----------------------------------------------------------------------------
-- Création de la table pour stocker les résultats de benchmark
-- -----------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE BENCHMARK_RESULTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE BENCHMARK_RESULTS (
    test_id NUMBER,
    test_name VARCHAR2(200),
    execution_time_ms NUMBER,
    rows_affected NUMBER,
    test_date TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE SEQUENCE seq_benchmark START WITH 1 INCREMENT BY 1;

-- -----------------------------------------------------------------------------
-- Procédure de mesure de performance
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE benchmark_query(
    p_name IN VARCHAR2,
    p_sql IN VARCHAR2
) AS
    v_start TIMESTAMP;
    v_end TIMESTAMP;
    v_time_ms NUMBER;
    v_rows NUMBER;
    v_cursor SYS_REFCURSOR;
BEGIN
    v_start := SYSTIMESTAMP;
    
    EXECUTE IMMEDIATE p_sql;
    v_rows := SQL%ROWCOUNT;
    
    v_end := SYSTIMESTAMP;
    v_time_ms := EXTRACT(SECOND FROM (v_end - v_start)) * 1000 +
                 EXTRACT(MINUTE FROM (v_end - v_start)) * 60000;
    
    INSERT INTO BENCHMARK_RESULTS (test_id, test_name, execution_time_ms, rows_affected)
    VALUES (seq_benchmark.NEXTVAL, p_name, v_time_ms, v_rows);
    
    DBMS_OUTPUT.PUT_LINE('✓ ' || RPAD(p_name, 50) || ' | ' || 
                         LPAD(ROUND(v_time_ms, 2) || ' ms', 15) || ' | ' ||
                         LPAD(v_rows || ' rows', 12));
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ ' || p_name || ': ' || SQLERRM);
END;
/

-- -----------------------------------------------------------------------------
-- Tests de performance SELECT
-- -----------------------------------------------------------------------------
PROMPT
PROMPT [1] TESTS DE REQUETES SELECT
PROMPT -----------------------------------------

DECLARE
    v_start TIMESTAMP;
    v_end TIMESTAMP;
    v_count NUMBER;
    v_time_ms NUMBER;
BEGIN
    -- Test 1: Comptage simple
    v_start := SYSTIMESTAMP;
    SELECT COUNT(*) INTO v_count FROM Image;
    v_end := SYSTIMESTAMP;
    v_time_ms := EXTRACT(SECOND FROM (v_end - v_start)) * 1000;
    DBMS_OUTPUT.PUT_LINE('1.1 COUNT(*) sur Image: ' || v_time_ms || ' ms (' || v_count || ' lignes)');
    
    -- Test 2: Jointure simple
    v_start := SYSTIMESTAMP;
    SELECT COUNT(*) INTO v_count 
    FROM Image i 
    JOIN Album a ON i.idAlbum = a.idAlbum;
    v_end := SYSTIMESTAMP;
    v_time_ms := EXTRACT(SECOND FROM (v_end - v_start)) * 1000;
    DBMS_OUTPUT.PUT_LINE('1.2 JOIN Image-Album: ' || v_time_ms || ' ms (' || v_count || ' lignes)');
    
    -- Test 3: Jointure multiple
    v_start := SYSTIMESTAMP;
    SELECT COUNT(*) INTO v_count 
    FROM Image i 
    JOIN Album a ON i.idAlbum = a.idAlbum
    JOIN Utilisateur u ON a.idUtilisateur = u.idUtilisateur
    JOIN Categorie c ON i.idCategorie = c.idCategorie;
    v_end := SYSTIMESTAMP;
    v_time_ms := EXTRACT(SECOND FROM (v_end - v_start)) * 1000;
    DBMS_OUTPUT.PUT_LINE('1.3 JOIN multiple (4 tables): ' || v_time_ms || ' ms (' || v_count || ' lignes)');
    
    -- Test 4: Agrégation GROUP BY
    v_start := SYSTIMESTAMP;
    SELECT COUNT(*) INTO v_count FROM (
        SELECT c.nom, COUNT(*) as nb_images
        FROM Image i
        JOIN Categorie c ON i.idCategorie = c.idCategorie
        GROUP BY c.nom
    );
    v_end := SYSTIMESTAMP;
    v_time_ms := EXTRACT(SECOND FROM (v_end - v_start)) * 1000;
    DBMS_OUTPUT.PUT_LINE('1.4 GROUP BY avec COUNT: ' || v_time_ms || ' ms (' || v_count || ' groupes)');
    
    -- Test 5: Sous-requête corrélée
    v_start := SYSTIMESTAMP;
    SELECT COUNT(*) INTO v_count FROM (
        SELECT i.idImage, i.titre,
               (SELECT COUNT(*) FROM Aime a WHERE a.idImage = i.idImage) as nb_likes
        FROM Image i
        WHERE ROWNUM <= 1000
    );
    v_end := SYSTIMESTAMP;
    v_time_ms := EXTRACT(SECOND FROM (v_end - v_start)) * 1000;
    DBMS_OUTPUT.PUT_LINE('1.5 Sous-requête corrélée (1000 images): ' || v_time_ms || ' ms');
    
    -- Test 6: Requête avec ORDER BY et LIMIT
    v_start := SYSTIMESTAMP;
    SELECT COUNT(*) INTO v_count FROM (
        SELECT i.*, 
               (SELECT COUNT(*) FROM Aime a WHERE a.idImage = i.idImage) as nb_likes
        FROM Image i
        WHERE i.visibilite = 'public'
        ORDER BY nb_likes DESC
        FETCH FIRST 100 ROWS ONLY
    );
    v_end := SYSTIMESTAMP;
    v_time_ms := EXTRACT(SECOND FROM (v_end - v_start)) * 1000;
    DBMS_OUTPUT.PUT_LINE('1.6 Top 100 images par likes: ' || v_time_ms || ' ms');
    
    -- Test 7: LIKE pattern matching
    v_start := SYSTIMESTAMP;
    SELECT COUNT(*) INTO v_count 
    FROM Image 
    WHERE titre LIKE '%photo%' OR description LIKE '%nature%';
    v_end := SYSTIMESTAMP;
    v_time_ms := EXTRACT(SECOND FROM (v_end - v_start)) * 1000;
    DBMS_OUTPUT.PUT_LINE('1.7 Recherche LIKE: ' || v_time_ms || ' ms (' || v_count || ' résultats)');
    
END;
/

-- -----------------------------------------------------------------------------
-- Tests de performance INSERT
-- -----------------------------------------------------------------------------
PROMPT
PROMPT [2] TESTS D INSERTIONS
PROMPT -----------------------------------------

DECLARE
    v_start TIMESTAMP;
    v_end TIMESTAMP;
    v_time_ms NUMBER;
    v_user_id NUMBER;
    v_album_id NUMBER;
    v_cat_id NUMBER;
BEGIN
    -- Obtenir des IDs valides
    SELECT idUtilisateur INTO v_user_id FROM Utilisateur WHERE ROWNUM = 1;
    SELECT idAlbum INTO v_album_id FROM Album WHERE ROWNUM = 1;
    SELECT idCategorie INTO v_cat_id FROM Categorie WHERE ROWNUM = 1;
    
    -- Test: Insertion de 100 images
    v_start := SYSTIMESTAMP;
    FOR i IN 1..100 LOOP
        INSERT INTO Image (
            idImage, titre, description, date_publication, format,
            taille, visibilite, pays_origine, telechargeable, idAlbum, idCategorie
        ) VALUES (
            seq_image.NEXTVAL,
            'Test Performance Image ' || i,
            'Description test',
            SYSTIMESTAMP,
            'JPG',
            1000,
            'public',
            'France',
            1,
            v_album_id,
            v_cat_id
        );
    END LOOP;
    v_end := SYSTIMESTAMP;
    v_time_ms := EXTRACT(SECOND FROM (v_end - v_start)) * 1000;
    DBMS_OUTPUT.PUT_LINE('2.1 INSERT 100 images: ' || v_time_ms || ' ms (' || 
                         ROUND(100000/v_time_ms, 0) || ' inserts/sec)');
    ROLLBACK;
    
    -- Test: Insertion batch de 1000 images
    v_start := SYSTIMESTAMP;
    INSERT INTO Image (
        idImage, titre, description, date_publication, format,
        taille, visibilite, pays_origine, telechargeable, idAlbum, idCategorie
    )
    SELECT 
        seq_image.NEXTVAL,
        'Batch Image ' || ROWNUM,
        'Description batch',
        SYSTIMESTAMP,
        'JPG',
        1000,
        'public',
        'France',
        1,
        v_album_id,
        v_cat_id
    FROM DUAL
    CONNECT BY LEVEL <= 1000;
    v_end := SYSTIMESTAMP;
    v_time_ms := EXTRACT(SECOND FROM (v_end - v_start)) * 1000;
    DBMS_OUTPUT.PUT_LINE('2.2 INSERT batch 1000 images: ' || v_time_ms || ' ms (' || 
                         ROUND(1000000/v_time_ms, 0) || ' inserts/sec)');
    ROLLBACK;
END;
/

-- -----------------------------------------------------------------------------
-- Tests de performance UPDATE
-- -----------------------------------------------------------------------------
PROMPT
PROMPT [3] TESTS DE MISE A JOUR
PROMPT -----------------------------------------

DECLARE
    v_start TIMESTAMP;
    v_end TIMESTAMP;
    v_time_ms NUMBER;
    v_count NUMBER;
BEGIN
    -- Test: UPDATE simple sur 1000 lignes
    v_start := SYSTIMESTAMP;
    UPDATE Image 
    SET taille = taille + 1 
    WHERE ROWNUM <= 1000;
    v_count := SQL%ROWCOUNT;
    v_end := SYSTIMESTAMP;
    v_time_ms := EXTRACT(SECOND FROM (v_end - v_start)) * 1000;
    DBMS_OUTPUT.PUT_LINE('3.1 UPDATE 1000 images (taille): ' || v_time_ms || ' ms');
    ROLLBACK;
    
    -- Test: UPDATE avec condition
    v_start := SYSTIMESTAMP;
    UPDATE Image 
    SET visibilite = 'public' 
    WHERE visibilite = 'prive' AND ROWNUM <= 500;
    v_count := SQL%ROWCOUNT;
    v_end := SYSTIMESTAMP;
    v_time_ms := EXTRACT(SECOND FROM (v_end - v_start)) * 1000;
    DBMS_OUTPUT.PUT_LINE('3.2 UPDATE conditionnel (visibilite): ' || v_time_ms || ' ms (' || v_count || ' lignes)');
    ROLLBACK;
END;
/

-- -----------------------------------------------------------------------------
-- Tests de performance DELETE
-- -----------------------------------------------------------------------------
PROMPT
PROMPT [4] TESTS DE SUPPRESSION
PROMPT -----------------------------------------

DECLARE
    v_start TIMESTAMP;
    v_end TIMESTAMP;
    v_time_ms NUMBER;
    v_count NUMBER;
BEGIN
    -- Créer des données temporaires pour les tests de suppression
    INSERT INTO Utilisateur (idUtilisateur, login, mot_de_passe, nom, prenom, email, pays, abonne_newsletter)
    SELECT seq_utilisateur.NEXTVAL, 'temp_user_' || ROWNUM, 'pwd', 'Temp', 'User', 
           'temp' || ROWNUM || '@test.com', 'France', 0
    FROM DUAL CONNECT BY LEVEL <= 100;
    COMMIT;
    
    -- Test: DELETE avec condition
    v_start := SYSTIMESTAMP;
    DELETE FROM Utilisateur WHERE login LIKE 'temp_user_%';
    v_count := SQL%ROWCOUNT;
    v_end := SYSTIMESTAMP;
    v_time_ms := EXTRACT(SECOND FROM (v_end - v_start)) * 1000;
    DBMS_OUTPUT.PUT_LINE('4.1 DELETE 100 utilisateurs: ' || v_time_ms || ' ms');
    COMMIT;
END;
/

-- -----------------------------------------------------------------------------
-- Tests des procédures et fonctions
-- -----------------------------------------------------------------------------
PROMPT
PROMPT [5] TESTS DES PROCEDURES/FONCTIONS
PROMPT -----------------------------------------

DECLARE
    v_start TIMESTAMP;
    v_end TIMESTAMP;
    v_time_ms NUMBER;
    v_result CLOB;
    v_image_id NUMBER;
BEGIN
    -- Obtenir un ID d'image valide
    SELECT idImage INTO v_image_id FROM Image WHERE ROWNUM = 1;
    
    -- Test: Fonction image_to_json
    v_start := SYSTIMESTAMP;
    FOR i IN 1..100 LOOP
        v_result := image_to_json(v_image_id);
    END LOOP;
    v_end := SYSTIMESTAMP;
    v_time_ms := EXTRACT(SECOND FROM (v_end - v_start)) * 1000;
    DBMS_OUTPUT.PUT_LINE('5.1 image_to_json x100: ' || v_time_ms || ' ms (' || 
                         ROUND(v_time_ms/100, 2) || ' ms/appel)');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('5.1 image_to_json: Fonction non disponible');
END;
/

-- -----------------------------------------------------------------------------
-- Affichage du rapport final
-- -----------------------------------------------------------------------------
PROMPT
PROMPT =========================================
PROMPT RAPPORT DE PERFORMANCE
PROMPT =========================================

-- Statistiques sur les données
DECLARE
    v_users NUMBER;
    v_albums NUMBER;
    v_images NUMBER;
    v_likes NUMBER;
    v_comments NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_users FROM Utilisateur;
    SELECT COUNT(*) INTO v_albums FROM Album;
    SELECT COUNT(*) INTO v_images FROM Image;
    SELECT COUNT(*) INTO v_likes FROM Aime;
    SELECT COUNT(*) INTO v_comments FROM Commentaire;
    
    DBMS_OUTPUT.PUT_LINE('Volume de données testé:');
    DBMS_OUTPUT.PUT_LINE('  - Utilisateurs: ' || v_users);
    DBMS_OUTPUT.PUT_LINE('  - Albums: ' || v_albums);
    DBMS_OUTPUT.PUT_LINE('  - Images: ' || v_images);
    DBMS_OUTPUT.PUT_LINE('  - Likes: ' || v_likes);
    DBMS_OUTPUT.PUT_LINE('  - Commentaires: ' || v_comments);
END;
/

PROMPT
PROMPT Tests de performance terminés.
PROMPT =========================================
