-- =============================================================================
-- Script de test des procedures, fonctions et declencheurs
-- =============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET LINESIZE 200;

-- Procedure utilitaire pour afficher les resultats de test dans un format uniforme
-- Exemple : Test 1 - description.................................... OK
-- Creation d'une table temporaire globale pour collecter les resultats de test
BEGIN
    EXECUTE IMMEDIATE '
        CREATE GLOBAL TEMPORARY TABLE TEST_RESULTS (
            test_id VARCHAR2(20),
            description VARCHAR2(4000),
            status VARCHAR2(10),
            ord NUMBER
        ) ON COMMIT PRESERVE ROWS
    ';
EXCEPTION
    WHEN OTHERS THEN
        NULL; -- la table existe peut-etre deja, ignorer l'erreur
END;
/

-- Vider les resultats precedents (si existants)
BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE TEST_RESULTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE OR REPLACE PROCEDURE print_test_result(p_test IN VARCHAR2, p_desc IN VARCHAR2, p_ok IN BOOLEAN, p_ord IN NUMBER) IS
    l_status VARCHAR2(10);
BEGIN
    l_status := CASE WHEN p_ok THEN 'OK' ELSE 'FAILED' END;
    INSERT INTO TEST_RESULTS(test_id, description, status, ord)
    VALUES(p_test, p_desc, l_status, p_ord);
    COMMIT;
END;
/

PROMPT =========================================
PROMPT TESTS DES PROCEDURES, FONCTIONS ET TRIGGERS
PROMPT =========================================

-- =============================================================================
-- TEST 1 : Fonction image_to_json
-- =============================================================================
PROMPT
PROMPT [TEST 1] Fonction image_to_json
PROMPT -----------------------------------------

DECLARE
    v_json_exist CLOB;
    v_json_missing CLOB;
    v_ok BOOLEAN := FALSE;
    v_has_idImage BOOLEAN := FALSE;
    v_has_titre BOOLEAN := FALSE;
    v_has_categorie BOOLEAN := FALSE;
    v_has_auteur BOOLEAN := FALSE;
    v_has_nb_likes BOOLEAN := FALSE;
    v_has_labels BOOLEAN := FALSE;
    v_is_error BOOLEAN := FALSE;
BEGIN
    -- Test : image existante -> JSON non null et structure valide
    v_json_exist := image_to_json(1);
    DBMS_OUTPUT.PUT_LINE('[OK] Test image existante (ID=1)');
    DBMS_OUTPUT.PUT_LINE('  JSON: ' || DBMS_LOB.SUBSTR(v_json_exist, 200, 1));

    -- Test : image inexistante -> doit retourner un message d'erreur JSON
    v_json_missing := image_to_json(9999);
    DBMS_OUTPUT.PUT_LINE('[OK] Test image inexistante (ID=9999)');
    DBMS_OUTPUT.PUT_LINE('  JSON: ' || v_json_missing);

    -- Valider que le JSON existe
    IF v_json_exist IS NOT NULL THEN
        -- Verification de la presence des champs essentiels
        v_has_idImage := INSTR(v_json_exist, '"idImage"') > 0;
        v_has_titre := INSTR(v_json_exist, '"titre"') > 0;
        v_has_categorie := INSTR(v_json_exist, '"categorie"') > 0;
        v_has_auteur := INSTR(v_json_exist, '"auteur"') > 0;
        v_has_nb_likes := INSTR(v_json_exist, '"nb_likes"') > 0;
        v_has_labels := INSTR(v_json_exist, '"labels"') > 0;

        -- Verifier que ce n'est pas un message d'erreur
        v_is_error := INSTR(v_json_exist, '"error"') > 0;

        DBMS_OUTPUT.PUT_LINE('  Champs valides: idImage=' || CASE WHEN v_has_idImage THEN '[OK]' ELSE '[ERREUR]' END ||
                             ', titre=' || CASE WHEN v_has_titre THEN '[OK]' ELSE '[ERREUR]' END ||
                             ', categorie=' || CASE WHEN v_has_categorie THEN '[OK]' ELSE '[ERREUR]' END ||
                             ', auteur=' || CASE WHEN v_has_auteur THEN '[OK]' ELSE '[ERREUR]' END ||
                             ', nb_likes=' || CASE WHEN v_has_nb_likes THEN '[OK]' ELSE '[ERREUR]' END ||
                             ', labels=' || CASE WHEN v_has_labels THEN '[OK]' ELSE '[ERREUR]' END);

        -- Valider que le JSON pour image inexistante contient une erreur
        IF v_json_missing IS NOT NULL AND INSTR(v_json_missing, '"error"') > 0 THEN
            DBMS_OUTPUT.PUT_LINE('[OK] Image inexistante retourne bien une erreur JSON');
            -- Test reussi si tous les champs requis sont presents et pas d'erreur pour image existante
            IF v_has_idImage AND v_has_titre AND v_has_categorie
               AND v_has_auteur AND v_has_nb_likes AND v_has_labels
               AND NOT v_is_error THEN
                v_ok := TRUE;
            END IF;
        END IF;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Resultat: ' || CASE WHEN v_ok THEN 'SUCCES' ELSE 'ECHEC' END);
    print_test_result('1', 'image_to_json - Conversion JSON complete et valide', v_ok, 1);
END;
/

-- =============================================================================
-- TEST 2 : Procedure images_conseillees
-- =============================================================================
PROMPT
PROMPT [TEST 2] Procedure images_conseillees
PROMPT -----------------------------------------

DECLARE
    v_ok BOOLEAN := TRUE;
    v_nom_user1 VARCHAR2(50);
    v_nom_user3 VARCHAR2(50);
BEGIN
    -- Recuperation des noms des utilisateurs
    SELECT nom || ' ' || prenom INTO v_nom_user1 FROM Utilisateur WHERE idUtilisateur = 1;
    SELECT nom || ' ' || prenom INTO v_nom_user3 FROM Utilisateur WHERE idUtilisateur = 3;

    -- Test pour l'utilisateur 1 (jean_photo)
    DBMS_OUTPUT.PUT_LINE('Test 1/2: Utilisateur 1 (' || v_nom_user1 || ')');
    BEGIN
        images_conseillees(1, 5);
        DBMS_OUTPUT.PUT_LINE('  [OK] Suggestions affichees pour ' || v_nom_user1);
    EXCEPTION WHEN OTHERS THEN
        v_ok := FALSE;
        DBMS_OUTPUT.PUT_LINE('  [ERREUR] Erreur: ' || SQLERRM);
    END;

    DBMS_OUTPUT.PUT_LINE('');

    -- Test pour l'utilisateur 3 (alex_nature)
    DBMS_OUTPUT.PUT_LINE('Test 2/2: Utilisateur 3 (' || v_nom_user3 || ')');
    BEGIN
        images_conseillees(3, 5);
        DBMS_OUTPUT.PUT_LINE('  [OK] Suggestions affichees pour ' || v_nom_user3);
    EXCEPTION WHEN OTHERS THEN
        v_ok := FALSE;
        DBMS_OUTPUT.PUT_LINE('  [ERREUR] Erreur: ' || SQLERRM);
    END;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Resultat: ' || CASE WHEN v_ok THEN 'SUCCES' ELSE 'ECHEC' END);
    print_test_result('2', 'images_conseillees - Suggestions personnalisees', v_ok, 2);
END;
/

-- =============================================================================
-- TEST 3 : Trigger limite albums (max 10)
-- =============================================================================
PROMPT
PROMPT [TEST 3] Trigger limite albums
PROMPT -----------------------------------------

DECLARE
    v_count NUMBER;
    v_raised BOOLEAN := FALSE;
BEGIN
    -- Comptage des albums actuels de l'utilisateur 1
    SELECT COUNT(*) INTO v_count FROM Album WHERE idUtilisateur = 1;
    DBMS_OUTPUT.PUT_LINE('Nombre d''albums actuels pour utilisateur 1: ' || v_count);

    -- Tentative de creation d'albums jusqu'a depasser la limite
    DBMS_OUTPUT.PUT_LINE('Tentative de creation de 12 albums...');
    FOR i IN 1..12 LOOP
        BEGIN
            INSERT INTO Album (idAlbum, titre, description, date_creation, visibilite, idUtilisateur)
            VALUES (seq_album.NEXTVAL, 'Album test ' || i, 'Description test', SYSTIMESTAMP, 'public', 1);
            DBMS_OUTPUT.PUT_LINE('  Album ' || i || ' cree');
        EXCEPTION
            WHEN OTHERS THEN
                v_raised := TRUE;
                DBMS_OUTPUT.PUT_LINE('[OK] Limite atteinte apres ' || (v_count + i - 1) || ' albums (erreur attendue)');
                EXIT;
        END;
    END LOOP;

    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Resultat: ' || CASE WHEN v_raised THEN 'SUCCES' ELSE 'ECHEC' END);
    print_test_result('3', 'trg_limite_albums - Limite de 10 albums par utilisateur', v_raised, 3);
END;
/

-- =============================================================================
-- TEST 4 : Trigger archivage image
-- =============================================================================
PROMPT
PROMPT [TEST 4] Trigger archivage image
PROMPT -----------------------------------------

DECLARE
    v_id_image NUMBER;
    v_count_avant NUMBER;
    v_count_apres NUMBER;
    v_archived_titre VARCHAR2(200);
    v_archived_format VARCHAR2(20);
    v_archived_taille NUMBER;
    v_archived_date TIMESTAMP;
    v_ok BOOLEAN := FALSE;
BEGIN
    -- Comptage des images archivees avant le test
    SELECT COUNT(*) INTO v_count_avant FROM Image_archive;
    DBMS_OUTPUT.PUT_LINE('Images archivees avant: ' || v_count_avant);

    -- Creation d'une image de test
    SELECT seq_image.NEXTVAL INTO v_id_image FROM DUAL;
    INSERT INTO Image (idImage, titre, description, date_publication, format, taille, visibilite, pays_origine, telechargeable, idAlbum, idCategorie)
    VALUES (v_id_image, 'Image test archivage', 'Test description', SYSTIMESTAMP, 'JPG', 1000, 'public', 'France', 1, 1, 1);
    DBMS_OUTPUT.PUT_LINE('[OK] Image de test creee (ID=' || v_id_image || ')');

    -- Suppression de l'image (devrait declencher l'archivage)
    DELETE FROM Image WHERE idImage = v_id_image;
    DBMS_OUTPUT.PUT_LINE('[OK] Image supprimee');

    -- Comptage des images archivees apres le test
    SELECT COUNT(*) INTO v_count_apres FROM Image_archive;
    DBMS_OUTPUT.PUT_LINE('Images archivees apres: ' || v_count_apres);

    -- Validation que l'archivage s'est bien produit
    IF v_count_apres > v_count_avant THEN
        -- Verification du contenu de l'archive (derniere entree)
        BEGIN
            SELECT titre, format, taille, date_archivage
            INTO v_archived_titre, v_archived_format, v_archived_taille, v_archived_date
            FROM Image_archive
            WHERE idImageArchive = (SELECT MAX(idImageArchive) FROM Image_archive);

            -- Validation des champs critiques
            IF v_archived_titre = 'Image test archivage'
               AND v_archived_format = 'JPG'
               AND v_archived_taille = 1000
               AND v_archived_date IS NOT NULL
            THEN
                v_ok := TRUE;
                DBMS_OUTPUT.PUT_LINE('[OK] Donnees archivees valides');
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_ok := FALSE;
                DBMS_OUTPUT.PUT_LINE('[ERREUR] Image non trouvee dans l''archive');
        END;
    ELSE
        DBMS_OUTPUT.PUT_LINE('[ERREUR] Aucune nouvelle image archivee');
    END IF;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Resultat: ' || CASE WHEN v_ok THEN 'SUCCES' ELSE 'ECHEC' END);
    print_test_result('4', 'trg_archivage_image - Archivage automatique complet', v_ok, 4);
END;
/

-- =============================================================================
-- TEST 5 : Trigger anti-spam
-- =============================================================================
PROMPT
PROMPT [TEST 5] Trigger anti-spam
PROMPT -----------------------------------------

DECLARE
    v_id_image NUMBER;
    v_blocked NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test insertion rapide de 6 images (limite: 5/seconde)');
    DBMS_OUTPUT.PUT_LINE('');

    FOR i IN 1..6 LOOP
        BEGIN
            SELECT seq_image.NEXTVAL INTO v_id_image FROM DUAL;
            INSERT INTO Image (idImage, titre, description, date_publication, format, taille, visibilite, pays_origine, telechargeable, idAlbum, idCategorie)
            VALUES (v_id_image, 'Spam test ' || i, 'Test', SYSTIMESTAMP, 'JPG', 100, 'public', 'France', 1, 1, 1);
            DBMS_OUTPUT.PUT_LINE('  Image ' || i || '/6: [OK] Inseree (ID=' || v_id_image || ')');
        EXCEPTION
            WHEN OTHERS THEN
                v_blocked := v_blocked + 1;
                DBMS_OUTPUT.PUT_LINE('  Image ' || i || '/6: [BLOQUE] BLOQUEE par anti-spam');
        END;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('');

    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Images bloquees: ' || v_blocked);
    DBMS_OUTPUT.PUT_LINE('Resultat: ' || CASE WHEN v_blocked > 0 THEN 'SUCCES' ELSE 'ECHEC' END);
    print_test_result('5', 'trg_anti_spam_images - Limite 5 images/seconde', (v_blocked > 0), 5);
END;
/

-- =============================================================================
-- TEST 6 : Trigger no_self_like
-- =============================================================================
PROMPT
PROMPT [TEST 6] Trigger no_self_like
PROMPT -----------------------------------------

DECLARE
    v_proprietaire NUMBER;
    v_ok BOOLEAN := FALSE;
BEGIN
    -- Recherche du proprietaire de l'image 1
    SELECT a.idUtilisateur INTO v_proprietaire
    FROM Album a
    JOIN Image i ON a.idAlbum = i.idAlbum
    WHERE i.idImage = 1;
    DBMS_OUTPUT.PUT_LINE('Tentative de like par le proprietaire (user ' || v_proprietaire || ')...');

    BEGIN
        INSERT INTO Aime (idUtilisateur, idImage, date_aime)
        VALUES (v_proprietaire, 1, SYSTIMESTAMP);
        DBMS_OUTPUT.PUT_LINE('[ERREUR] Like autorise (erreur!)');
    EXCEPTION
        WHEN OTHERS THEN
            v_ok := TRUE; -- exception attendue
            DBMS_OUTPUT.PUT_LINE('[OK] Like bloque (trigger actif)');
    END;

    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Resultat: ' || CASE WHEN v_ok THEN 'SUCCES' ELSE 'ECHEC' END);
    print_test_result('6', 'trg_no_self_like - Interdiction auto-like', v_ok, 6);
END;
/

-- =============================================================================
-- TEST 6B : Trigger no_self_comment
-- =============================================================================
PROMPT
PROMPT [TEST 6B] Trigger no_self_comment
PROMPT -----------------------------------------

DECLARE
    v_proprietaire NUMBER;
    v_ok BOOLEAN := FALSE;
BEGIN
    -- Recherche du proprietaire de l'image 1
    SELECT a.idUtilisateur INTO v_proprietaire
    FROM Album a
    JOIN Image i ON a.idAlbum = i.idAlbum
    WHERE i.idImage = 1;
    DBMS_OUTPUT.PUT_LINE('Tentative de commentaire par le proprietaire (user ' || v_proprietaire || ')...');

    BEGIN
        INSERT INTO Commentaire (idCommentaire, texte_commentaire, date_commentaire, idUtilisateur, idImage)
        VALUES (seq_commentaire.NEXTVAL, 'Tentative auto-commentaire', SYSTIMESTAMP, v_proprietaire, 1);
        DBMS_OUTPUT.PUT_LINE('[ERREUR] Commentaire autorise (erreur!)');
    EXCEPTION
        WHEN OTHERS THEN
            v_ok := TRUE; -- exception attendue
            DBMS_OUTPUT.PUT_LINE('[OK] Commentaire bloque (trigger actif)');
    END;

    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Resultat: ' || CASE WHEN v_ok THEN 'SUCCES' ELSE 'ECHEC' END);
    print_test_result('6B', 'trg_no_self_comment - Interdiction auto-comment', v_ok, 6.5);
END;
/

-- =============================================================================
-- TEST 7A : Procedure generer_newsletter_utilisateur (pour un seul utilisateur)
-- =============================================================================
PROMPT
PROMPT [TEST 7A] Procedure generer_newsletter_utilisateur
PROMPT -----------------------------------------

DECLARE
    v_ok BOOLEAN := TRUE;
    v_nom_user1 VARCHAR2(50);
    v_nom_user4 VARCHAR2(50);
    v_nb_newsletters_avant NUMBER;
    v_nb_newsletters_apres NUMBER;
BEGIN
    -- Comptage des newsletters avant le test
    SELECT COUNT(*) INTO v_nb_newsletters_avant FROM Newsletter;

    -- Recuperation des noms des utilisateurs
    SELECT nom || ' ' || prenom INTO v_nom_user1 FROM Utilisateur WHERE idUtilisateur = 1;
    SELECT nom || ' ' || prenom INTO v_nom_user4 FROM Utilisateur WHERE idUtilisateur = 4;

    DBMS_OUTPUT.PUT_LINE('Generation de newsletters personnalisees...');
    DBMS_OUTPUT.PUT_LINE('');

    -- Test pour l'utilisateur 1 (jean_photo - abonne)
    DBMS_OUTPUT.PUT_LINE('Test 1/2: Newsletter pour ' || v_nom_user1);
    BEGIN
        generer_newsletter_utilisateur(1);
        DBMS_OUTPUT.PUT_LINE('  [OK] Newsletter generee');
    EXCEPTION WHEN OTHERS THEN
        v_ok := FALSE;
        DBMS_OUTPUT.PUT_LINE('  [ERREUR] Erreur: ' || SQLERRM);
    END;

    DBMS_OUTPUT.PUT_LINE('');

    -- Test pour l'utilisateur 4 (sophie_travel - abonne)
    DBMS_OUTPUT.PUT_LINE('Test 2/2: Newsletter pour ' || v_nom_user4);
    BEGIN
        generer_newsletter_utilisateur(4);
        DBMS_OUTPUT.PUT_LINE('  [OK] Newsletter generee');
    EXCEPTION WHEN OTHERS THEN
        v_ok := FALSE;
        DBMS_OUTPUT.PUT_LINE('  [ERREUR] Erreur: ' || SQLERRM);
    END;

    -- Comptage des newsletters apres le test
    SELECT COUNT(*) INTO v_nb_newsletters_apres FROM Newsletter;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Newsletters creees: ' || (v_nb_newsletters_apres - v_nb_newsletters_avant));
    DBMS_OUTPUT.PUT_LINE('Resultat: ' || CASE WHEN v_ok THEN 'SUCCES' ELSE 'ECHEC' END);
    print_test_result('7A', 'generer_newsletter_utilisateur - Newsletter personnalisee', v_ok, 7.1);
END;
/

-- Affichage de la derniere newsletter generee
PROMPT
PROMPT Derniere newsletter personnalisee generee:
SELECT idNewsletter, date_envoi, DBMS_LOB.SUBSTR(contenu, 500, 1) AS contenu_extrait
FROM Newsletter
WHERE idNewsletter = (SELECT MAX(idNewsletter) FROM Newsletter);

-- =============================================================================
-- TEST 7B : Procedure generer_toutes_newsletters (pour tous les abonnes)
-- =============================================================================
PROMPT
PROMPT [TEST 7B] Procedure generer_toutes_newsletters
PROMPT -----------------------------------------

DECLARE
    v_ok BOOLEAN := TRUE;
    v_nb_abonnes NUMBER;
    v_nb_newsletters_avant NUMBER;
    v_nb_newsletters_apres NUMBER;
BEGIN
    -- Comptage des abonnes
    SELECT COUNT(*) INTO v_nb_abonnes FROM Utilisateur WHERE abonne_newsletter = 1;
    DBMS_OUTPUT.PUT_LINE('Nombre d''utilisateurs abonnes: ' || v_nb_abonnes);

    -- Comptage des newsletters avant le test
    SELECT COUNT(*) INTO v_nb_newsletters_avant FROM Newsletter;
    DBMS_OUTPUT.PUT_LINE('Generation de newsletters pour tous les abonnes...');
    DBMS_OUTPUT.PUT_LINE('');

    BEGIN
        generer_toutes_newsletters();
        DBMS_OUTPUT.PUT_LINE('[OK] Newsletters generees avec succes');
    EXCEPTION WHEN OTHERS THEN
        v_ok := FALSE;
        DBMS_OUTPUT.PUT_LINE('[ERREUR] Erreur: ' || SQLERRM);
    END;

    -- Comptage des newsletters apres le test
    SELECT COUNT(*) INTO v_nb_newsletters_apres FROM Newsletter;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Newsletters creees: ' || (v_nb_newsletters_apres - v_nb_newsletters_avant));
    DBMS_OUTPUT.PUT_LINE('Resultat: ' || CASE WHEN v_ok THEN 'SUCCES' ELSE 'ECHEC' END);
    print_test_result('7B', 'generer_toutes_newsletters - Newsletters pour tous les abonnes', v_ok, 7.2);
END;
/

-- Affichage des newsletters generees
PROMPT
PROMPT Newsletters generees (top 3 plus recentes):
SELECT idNewsletter, date_envoi, DBMS_LOB.SUBSTR(contenu, 200, 1) AS contenu_extrait
FROM Newsletter
ORDER BY idNewsletter DESC
FETCH FIRST 3 ROWS ONLY;

-- =============================================================================
-- TEST 7C : Procedure generer_newsletter (newsletter hebdomadaire generique)
-- =============================================================================
PROMPT
PROMPT [TEST 7C] Procedure generer_newsletter (hebdomadaire)
PROMPT -----------------------------------------

DECLARE
    v_ok BOOLEAN := TRUE;
    v_nb_newsletters_avant NUMBER;
    v_nb_newsletters_apres NUMBER;
    v_nb_images_avant NUMBER;
    v_nb_images_apres NUMBER;
BEGIN
    -- Comptage des newsletters et images mises en avant avant le test
    SELECT COUNT(*) INTO v_nb_newsletters_avant FROM Newsletter;
    SELECT COUNT(*) INTO v_nb_images_avant FROM Met_en_avant;

    DBMS_OUTPUT.PUT_LINE('Generation de la newsletter hebdomadaire...');
    DBMS_OUTPUT.PUT_LINE('');

    BEGIN
        generer_newsletter();
        DBMS_OUTPUT.PUT_LINE('[OK] Newsletter hebdomadaire generee avec succes');
    EXCEPTION WHEN OTHERS THEN
        v_ok := FALSE;
        DBMS_OUTPUT.PUT_LINE('[ERREUR] Erreur: ' || SQLERRM);
    END;

    -- Comptage des newsletters et images apres le test
    SELECT COUNT(*) INTO v_nb_newsletters_apres FROM Newsletter;
    SELECT COUNT(*) INTO v_nb_images_apres FROM Met_en_avant;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Newsletters creees: ' || (v_nb_newsletters_apres - v_nb_newsletters_avant));
    DBMS_OUTPUT.PUT_LINE('Images mises en avant: ' || (v_nb_images_apres - v_nb_images_avant));
    DBMS_OUTPUT.PUT_LINE('Resultat: ' || CASE WHEN v_ok THEN 'SUCCES' ELSE 'ECHEC' END);
    print_test_result('7C', 'generer_newsletter - Newsletter hebdomadaire', v_ok, 7.3);
END;
/

-- Affichage de la newsletter hebdomadaire generee
PROMPT
PROMPT Newsletter hebdomadaire generee:
SELECT idNewsletter, date_envoi, DBMS_LOB.SUBSTR(contenu, 400, 1) AS contenu_extrait
FROM Newsletter
WHERE idNewsletter = (SELECT MAX(idNewsletter) FROM Newsletter);

-- Affichage des images mises en avant dans cette newsletter
PROMPT
PROMPT Images mises en avant dans la derniere newsletter:
SELECT COUNT(*) AS nb_images_mises_en_avant
FROM Met_en_avant
WHERE idNewsletter = (SELECT MAX(idNewsletter) FROM Newsletter);

-- =============================================================================
-- TEST 8 : Fonction get_images_conseillees (curseur)
-- =============================================================================
PROMPT
PROMPT [TEST 8] Fonction get_images_conseillees
PROMPT -----------------------------------------

DECLARE
    v_cursor SYS_REFCURSOR;
    v_idImage NUMBER;
    v_titre VARCHAR2(200);
    v_categorie VARCHAR2(100);
    v_auteur VARCHAR2(50);
    v_likes NUMBER;
    v_nb NUMBER := 0;
    v_ok BOOLEAN := FALSE;
BEGIN
    v_cursor := get_images_conseillees(2, 5);

    DBMS_OUTPUT.PUT_LINE('Images conseillees pour utilisateur 2:');
    DBMS_OUTPUT.PUT_LINE('');

    LOOP
        FETCH v_cursor INTO v_idImage, v_titre, v_categorie, v_auteur, v_likes;
        EXIT WHEN v_cursor%NOTFOUND;
        v_nb := v_nb + 1;
        DBMS_OUTPUT.PUT_LINE('- ' || v_titre || ' (' || v_categorie || ') par ' || v_auteur);
    END LOOP;
    
    CLOSE v_cursor;
    IF v_nb > 0 THEN
        v_ok := TRUE;
        DBMS_OUTPUT.PUT_LINE('[OK] ' || v_nb || ' suggestions retournees');
    ELSE
        DBMS_OUTPUT.PUT_LINE('[ERREUR] Aucune suggestion');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Resultat: ' || CASE WHEN v_ok THEN 'SUCCES' ELSE 'ECHEC' END);
    print_test_result('8', 'get_images_conseillees - Curseur suggestions', v_ok, 8);
END;
/

-- =============================================================================
-- TEST 9 : Trigger date_publication_auto
-- =============================================================================
PROMPT
PROMPT [TEST 9] Trigger date_publication_auto
PROMPT -----------------------------------------

DECLARE
    v_id_image NUMBER;
    v_date_pub TIMESTAMP;
    v_ok BOOLEAN := FALSE;
BEGIN
    -- Insertion d'une image SANS specifier date_publication (NULL)
    SELECT seq_image.NEXTVAL INTO v_id_image FROM DUAL;
    DBMS_OUTPUT.PUT_LINE('Insertion image sans date_publication...');
    INSERT INTO Image (idImage, titre, date_publication, visibilite, telechargeable, idAlbum, idCategorie)
    VALUES (v_id_image, 'Test auto-date', NULL, 'public', 1, 1, 1);

    -- Verification que date_publication a ete auto-remplie
    SELECT date_publication INTO v_date_pub
    FROM Image
    WHERE idImage = v_id_image;

    IF v_date_pub IS NOT NULL THEN
        v_ok := TRUE;
        DBMS_OUTPUT.PUT_LINE('[OK] Date auto-generee: ' || TO_CHAR(v_date_pub, 'DD/MM/YY HH24:MI:SS'));
    ELSE
        DBMS_OUTPUT.PUT_LINE('[ERREUR] Date NULL (trigger non active)');
    END IF;

    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Resultat: ' || CASE WHEN v_ok THEN 'SUCCES' ELSE 'ECHEC' END);
    print_test_result('9', 'trg_date_publication_auto - Date auto-generee', v_ok, 9);
END;
/

-- =============================================================================
-- Affichage du resume des resultats de test
SET SERVEROUTPUT ON SIZE UNLIMITED;

DECLARE
    CURSOR c IS SELECT test_id, description, status, ord FROM TEST_RESULTS ORDER BY ord NULLS LAST;
    v_test_id TEST_RESULTS.test_id%TYPE;
    v_desc TEST_RESULTS.description%TYPE;
    v_status TEST_RESULTS.status%TYPE;
    l_base VARCHAR2(4000);
    l_total CONSTANT NUMBER := 80;
    l_dots_count NUMBER;
    l_line VARCHAR2(4000);
BEGIN
    FOR r IN c LOOP
        v_test_id := r.test_id;
        v_desc := r.description;
        v_status := r.status;
        l_base := 'Test ' || v_test_id || ' - ' || v_desc;
        l_dots_count := l_total - LENGTH(l_base) - LENGTH(v_status);
        IF l_dots_count < 1 THEN
            l_dots_count := 1;
        END IF;
        l_line := l_base || RPAD('.', l_dots_count, '.') || v_status;
        DBMS_OUTPUT.PUT_LINE(l_line);
    END LOOP;
END;
/

-- Nettoyage des resultats temporaires
BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE TEST_RESULTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
