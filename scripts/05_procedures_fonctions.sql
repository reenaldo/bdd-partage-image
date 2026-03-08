-- =============================================================================
-- Procedures et Fonctions PL/SQL
-- =============================================================================

SET SERVEROUTPUT ON;

-- =============================================================================
-- FONCTION 1 : Convertir les informations d'une image au format JSON
-- =============================================================================
CREATE OR REPLACE FUNCTION image_to_json(p_idImage IN NUMBER)
RETURN CLOB
IS
    v_json CLOB;
    v_titre VARCHAR2(200);
    v_description CLOB;
    v_date_publication TIMESTAMP;
    v_format VARCHAR2(20);
    v_taille NUMBER;
    v_visibilite VARCHAR2(10);
    v_pays_origine VARCHAR2(100);
    v_telechargeable NUMBER(1);
    v_categorie VARCHAR2(100);
    v_auteur_login VARCHAR2(50);
    v_auteur_nom VARCHAR2(100);
    v_auteur_prenom VARCHAR2(100);
    v_nb_likes NUMBER;
    v_nb_commentaires NUMBER;
    v_labels CLOB;
BEGIN
    -- Recuperer les informations de l'image
    SELECT 
        i.titre,
        i.description,
        i.date_publication,
        i.format,
        i.taille,
        i.visibilite,
        i.pays_origine,
        i.telechargeable,
        c.nom,
        u.login,
        u.nom,
        u.prenom
    INTO 
        v_titre,
        v_description,
        v_date_publication,
        v_format,
        v_taille,
        v_visibilite,
        v_pays_origine,
        v_telechargeable,
        v_categorie,
        v_auteur_login,
        v_auteur_nom,
        v_auteur_prenom
    FROM Image i
    JOIN Album a ON i.idAlbum = a.idAlbum
    JOIN Utilisateur u ON a.idUtilisateur = u.idUtilisateur
    JOIN Categorie c ON i.idCategorie = c.idCategorie
    WHERE i.idImage = p_idImage;
    
    -- Compter les likes
    SELECT COUNT(*) INTO v_nb_likes
    FROM Aime WHERE idImage = p_idImage;
    
    -- Compter les commentaires
    SELECT COUNT(*) INTO v_nb_commentaires
    FROM Commentaire WHERE idImage = p_idImage;
    
    -- Recuperer les labels
    SELECT LISTAGG('"' || l.nom || '"', ', ') WITHIN GROUP (ORDER BY l.nom)
    INTO v_labels
    FROM Etiquette e
    JOIN Label l ON e.idLabel = l.idLabel
    WHERE e.idImage = p_idImage;
    
    IF v_labels IS NULL THEN
        v_labels := '';
    END IF;
    
    -- Construire le JSON
    v_json := '{' || CHR(10);
    v_json := v_json || '  "idImage": ' || p_idImage || ',' || CHR(10);
    v_json := v_json || '  "titre": "' || REPLACE(v_titre, '"', '\"') || '",' || CHR(10);
    v_json := v_json || '  "description": "' || REPLACE(NVL(DBMS_LOB.SUBSTR(v_description, 4000, 1), ''), '"', '\"')|| '",' || CHR(10);
    v_json := v_json || '  "date_publication": "' || TO_CHAR(v_date_publication, 'YYYY-MM-DD HH24:MI:SS') || '",' || CHR(10);
    v_json := v_json || '  "format": "' || NVL(v_format, '') || '",' || CHR(10);
    v_json := v_json || '  "taille": ' || NVL(v_taille, 0) || ',' || CHR(10);
    v_json := v_json || '  "visibilite": "' || v_visibilite || '",' || CHR(10);
    v_json := v_json || '  "pays_origine": "' || NVL(v_pays_origine, '') || '",' || CHR(10);
    v_json := v_json || '  "telechargeable": ' || CASE WHEN v_telechargeable = 1 THEN 'true' ELSE 'false' END || ',' || CHR(10);
    v_json := v_json || '  "categorie": "' || v_categorie || '",' || CHR(10);
    v_json := v_json || '  "auteur": {' || CHR(10);
    v_json := v_json || '    "login": "' || v_auteur_login || '",' || CHR(10);
    v_json := v_json || '    "nom": "' || NVL(v_auteur_nom, '') || '",' || CHR(10);
    v_json := v_json || '    "prenom": "' || NVL(v_auteur_prenom, '') || '"' || CHR(10);
    v_json := v_json || '  },' || CHR(10);
    v_json := v_json || '  "nb_likes": ' || v_nb_likes || ',' || CHR(10);
    v_json := v_json || '  "nb_commentaires": ' || v_nb_commentaires || ',' || CHR(10);
    v_json := v_json || '  "labels": [' || v_labels || ']' || CHR(10);
    v_json := v_json || '}';
    
    RETURN v_json;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN '{"error": "Image non trouvee", "idImage": ' || p_idImage || '}';
    WHEN OTHERS THEN
        RETURN '{"error": "' || SQLERRM || '"}';
END image_to_json;
/

-- =============================================================================
-- PROCEDURE 2 : Generer une newsletter personnalisee pour un utilisateur
--               avec les 20 images les plus populaires de ses categories preferees
-- =============================================================================
CREATE OR REPLACE PROCEDURE generer_newsletter_utilisateur(
    p_idUtilisateur IN NUMBER
)
IS
    v_idNewsletter NUMBER;
    v_contenu CLOB;
    v_date_envoi DATE := TRUNC(SYSDATE);
    v_compteur NUMBER := 0;
    v_login VARCHAR2(50);
    v_nom VARCHAR2(100);
    v_prenom VARCHAR2(100);
    v_abonne NUMBER(1);
    
    -- Curseur pour les 20 images les plus populaires des categories preferees
    CURSOR c_images_populaires IS
        SELECT 
            i.idImage,
            i.titre,
            c.nom AS categorie,
            u.login AS auteur,
            COUNT(a.idUtilisateur) AS nb_likes
        FROM Image i
        JOIN Album al ON i.idAlbum = al.idAlbum
        JOIN Utilisateur u ON al.idUtilisateur = u.idUtilisateur
        JOIN Categorie c ON i.idCategorie = c.idCategorie
        LEFT JOIN Aime a ON i.idImage = a.idImage
            AND a.date_aime >= SYSTIMESTAMP - INTERVAL '14' DAY
        WHERE i.visibilite = 'public'
            -- Filtrer par categories preferees de l'utilisateur
            AND i.idCategorie IN (
                SELECT idCategorie 
                FROM Prefere 
                WHERE idUtilisateur = p_idUtilisateur
            )
        GROUP BY i.idImage, i.titre, c.nom, u.login
        ORDER BY nb_likes DESC
        FETCH FIRST 20 ROWS ONLY;
        
BEGIN
    -- Verifier que l'utilisateur existe et est abonne
    SELECT login, nom, prenom, abonne_newsletter
    INTO v_login, v_nom, v_prenom, v_abonne
    FROM Utilisateur
    WHERE idUtilisateur = p_idUtilisateur;
    
    -- Verifier si l'utilisateur est abonne a la newsletter
    IF v_abonne = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Utilisateur ' || v_login || ' n''est pas abonne a la newsletter.');
        RETURN;
    END IF;
    
    -- Generer l'ID de la newsletter
    SELECT seq_newsletter.NEXTVAL INTO v_idNewsletter FROM DUAL;
    
    -- Construire le contenu de la newsletter
    v_contenu := '=========================================' || CHR(10);
    v_contenu := v_contenu || 'NEWSLETTER PERSONNALISEE' || CHR(10);
    v_contenu := v_contenu || 'Pour: ' || v_prenom || ' ' || v_nom || ' (' || v_login || ')' || CHR(10);
    v_contenu := v_contenu || 'Date: ' || TO_CHAR(v_date_envoi, 'DD/MM/YYYY') || CHR(10);
    v_contenu := v_contenu || '=========================================' || CHR(10) || CHR(10);
    v_contenu := v_contenu || 'Vos categories preferees cette semaine !' || CHR(10) || CHR(10);
    v_contenu := v_contenu || '-----------------------------------------' || CHR(10);
    
    FOR rec IN c_images_populaires LOOP
        v_compteur := v_compteur + 1;
        v_contenu := v_contenu || CHR(10);
        v_contenu := v_contenu || v_compteur || '. ' || rec.titre || CHR(10);
        v_contenu := v_contenu || '   Categorie: ' || rec.categorie || CHR(10);
        v_contenu := v_contenu || '   Auteur: ' || rec.auteur || CHR(10);
        v_contenu := v_contenu || '   Likes (2 semaines): ' || rec.nb_likes || CHR(10);
    END LOOP;

    v_contenu := v_contenu || CHR(10) || '-----------------------------------------' || CHR(10);
    v_contenu := v_contenu || CHR(10) || 'Merci de votre fidelite !' || CHR(10);
    v_contenu := v_contenu || '@renaldo' || CHR(10);

    -- Inserer la newsletter AVANT d'inserer dans Met_en_avant (FK constraint)
    INSERT INTO Newsletter (idNewsletter, date_envoi, contenu)
    VALUES (v_idNewsletter, v_date_envoi, v_contenu);

    -- Maintenant inserer les images mises en avant
    FOR rec IN c_images_populaires LOOP
        INSERT INTO Met_en_avant (idNewsletter, idImage)
        VALUES (v_idNewsletter, rec.idImage);
    END LOOP;
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Newsletter personnalisee generee avec succes !');
    DBMS_OUTPUT.PUT_LINE('ID Newsletter: ' || v_idNewsletter);
    DBMS_OUTPUT.PUT_LINE('Utilisateur: ' || v_login);
    DBMS_OUTPUT.PUT_LINE('Nombre d''images mises en avant: ' || v_compteur);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Erreur: Utilisateur non trouve (ID: ' || p_idUtilisateur || ')');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Erreur lors de la generation de la newsletter: ' || SQLERRM);
        RAISE;
END generer_newsletter_utilisateur;
/

-- =============================================================================
-- PROCEDURE 3 : Generer les newsletters pour tous les abonnes
-- =============================================================================
CREATE OR REPLACE PROCEDURE generer_toutes_newsletters
IS
    v_compteur NUMBER := 0;
    
    CURSOR c_abonnes IS
        SELECT idUtilisateur, login
        FROM Utilisateur
        WHERE abonne_newsletter = 1;
BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Generation des newsletters pour tous les abonnes');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('');
    
    FOR rec IN c_abonnes LOOP
        v_compteur := v_compteur + 1;
        DBMS_OUTPUT.PUT_LINE('Traitement de l''utilisateur: ' || rec.login);
        generer_newsletter_utilisateur(rec.idUtilisateur);
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Total newsletters generees: ' || v_compteur);
    DBMS_OUTPUT.PUT_LINE('========================================');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
        RAISE;
END generer_toutes_newsletters;
/

-- =============================================================================
-- PROCEDURE 4 : Generer une newsletter hebdomadaire avec les 20 images
--               les plus populaires publiees dans la semaine
-- =============================================================================
CREATE OR REPLACE PROCEDURE generer_newsletter
IS
    v_idNewsletter NUMBER;
    v_contenu CLOB;
    v_date_envoi DATE := TRUNC(SYSDATE);
    v_compteur NUMBER := 0;

    -- Curseur pour les 20 images les plus populaires publiees dans la semaine
    CURSOR c_images_populaires IS
        SELECT
            i.idImage,
            i.titre,
            c.nom AS categorie,
            u.login AS auteur,
            i.date_publication,
            COUNT(a.idUtilisateur) AS nb_likes
        FROM Image i
        JOIN Album al ON i.idAlbum = al.idAlbum
        JOIN Utilisateur u ON al.idUtilisateur = u.idUtilisateur
        JOIN Categorie c ON i.idCategorie = c.idCategorie
        LEFT JOIN Aime a ON i.idImage = a.idImage
            AND a.date_aime >= SYSTIMESTAMP - INTERVAL '14' DAY
        WHERE i.visibilite = 'public'
            -- Images publiees dans la semaine (7 jours)
            AND i.date_publication >= SYSTIMESTAMP - INTERVAL '7' DAY
        GROUP BY i.idImage, i.titre, c.nom, u.login, i.date_publication
        ORDER BY nb_likes DESC, i.date_publication DESC
        FETCH FIRST 20 ROWS ONLY;

BEGIN
    -- Generer l'ID de la newsletter
    SELECT seq_newsletter.NEXTVAL INTO v_idNewsletter FROM DUAL;

    -- Construire le contenu de la newsletter
    v_contenu := '=========================================' || CHR(10);
    v_contenu := v_contenu || 'NEWSLETTER HEBDOMADAIRE' || CHR(10);
    v_contenu := v_contenu || 'Date: ' || TO_CHAR(v_date_envoi, 'DD/MM/YYYY') || CHR(10);
    v_contenu := v_contenu || '=========================================' || CHR(10) || CHR(10);
    v_contenu := v_contenu || 'LES 20 IMAGES LES PLUS POPULAIRES DE LA SEMAINE' || CHR(10) || CHR(10);
    v_contenu := v_contenu || '-----------------------------------------' || CHR(10);

    FOR rec IN c_images_populaires LOOP
        v_compteur := v_compteur + 1;
        v_contenu := v_contenu || CHR(10);
        v_contenu := v_contenu || v_compteur || '. ' || rec.titre || CHR(10);
        v_contenu := v_contenu || '   Categorie: ' || rec.categorie || CHR(10);
        v_contenu := v_contenu || '   Auteur: ' || rec.auteur || CHR(10);
        v_contenu := v_contenu || '   Nombre de likes: ' || rec.nb_likes || CHR(10);
    END LOOP;

    IF v_compteur = 0 THEN
        v_contenu := v_contenu || CHR(10);
        v_contenu := v_contenu || 'Aucune image publiee cette semaine.' || CHR(10);
    END IF;

    v_contenu := v_contenu || CHR(10) || '-----------------------------------------' || CHR(10);
    v_contenu := v_contenu || CHR(10) || 'Merci de votre fidelite !' || CHR(10);
    v_contenu := v_contenu || '@renaldo' || CHR(10);

    -- Inserer la newsletter AVANT d'inserer dans Met_en_avant (FK constraint)
    INSERT INTO Newsletter (idNewsletter, date_envoi, contenu)
    VALUES (v_idNewsletter, v_date_envoi, v_contenu);

    -- Maintenant inserer les images mises en avant
    FOR rec IN c_images_populaires LOOP
        INSERT INTO Met_en_avant (idNewsletter, idImage)
        VALUES (v_idNewsletter, rec.idImage);
    END LOOP;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Newsletter hebdomadaire generee avec succes !');
    DBMS_OUTPUT.PUT_LINE('ID Newsletter: ' || v_idNewsletter);
    DBMS_OUTPUT.PUT_LINE('Nombre d''images mises en avant: ' || v_compteur);
    DBMS_OUTPUT.PUT_LINE('========================================');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Erreur lors de la generation de la newsletter: ' || SQLERRM);
        RAISE;
END generer_newsletter;
/

-- =============================================================================
-- PROCEDURE 5 : Generer une liste d'images conseillees pour un utilisateur
-- =============================================================================
CREATE OR REPLACE PROCEDURE images_conseillees(
    p_idUtilisateur IN NUMBER,
    p_nb_suggestions IN NUMBER DEFAULT 10
)
IS
    v_login VARCHAR2(50);
    v_compteur NUMBER := 0;
    
    CURSOR c_suggestions IS
        SELECT 
            i.idImage,
            i.titre,
            c.nom AS categorie,
            u.login AS auteur,
            COUNT(a.idUtilisateur) AS nb_likes_recents
        FROM Image i
        JOIN Categorie c ON i.idCategorie = c.idCategorie
        JOIN Album al ON i.idAlbum = al.idAlbum
        JOIN Utilisateur u ON al.idUtilisateur = u.idUtilisateur
        LEFT JOIN Aime a ON i.idImage = a.idImage
            AND a.date_aime >= SYSTIMESTAMP - INTERVAL '14' DAY
        WHERE 
            -- Images dans les categories preferees de l'utilisateur
            i.idCategorie IN (
                SELECT idCategorie FROM Prefere WHERE idUtilisateur = p_idUtilisateur
            )
            -- Exclure les images deja likees par l'utilisateur
            AND i.idImage NOT IN (
                SELECT idImage FROM Aime WHERE idUtilisateur = p_idUtilisateur
            )
            -- Images publiques uniquement
            AND i.visibilite = 'public'
            -- Exclure les propres images de l'utilisateur
            AND al.idUtilisateur != p_idUtilisateur
        GROUP BY i.idImage, i.titre, c.nom, u.login
        ORDER BY nb_likes_recents DESC
        FETCH FIRST p_nb_suggestions ROWS ONLY;
        
BEGIN
    -- Recuperer le login de l'utilisateur
    SELECT login INTO v_login
    FROM Utilisateur WHERE idUtilisateur = p_idUtilisateur;
    
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Images conseillees pour: ' || v_login);
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('');
    
    FOR rec IN c_suggestions LOOP
        v_compteur := v_compteur + 1;
        DBMS_OUTPUT.PUT_LINE(v_compteur || '. ' || rec.titre);
        DBMS_OUTPUT.PUT_LINE('   Categorie: ' || rec.categorie);
        DBMS_OUTPUT.PUT_LINE('   Auteur: ' || rec.auteur);
        DBMS_OUTPUT.PUT_LINE('   Popularite recente: ' || rec.nb_likes_recents || ' likes');
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
    
    IF v_compteur = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Aucune suggestion disponible.');
        DBMS_OUTPUT.PUT_LINE('Ajoutez des categories preferees pour recevoir des suggestions !');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Total: ' || v_compteur || ' suggestion(s)');
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Erreur: Utilisateur non trouve (ID: ' || p_idUtilisateur || ')');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
END images_conseillees;
/

-- =============================================================================
-- FONCTION auxiliaire : Recuperer les images conseillees sous forme de curseur
-- =============================================================================
CREATE OR REPLACE FUNCTION get_images_conseillees(
    p_idUtilisateur IN NUMBER,
    p_nb_suggestions IN NUMBER DEFAULT 10
)
RETURN SYS_REFCURSOR
IS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT
            i.idImage,
            i.titre,
            c.nom AS categorie,
            u.login AS auteur,
            COUNT(a.idUtilisateur) AS nb_likes_recents
        FROM Image i
        JOIN Categorie c ON i.idCategorie = c.idCategorie
        JOIN Album al ON i.idAlbum = al.idAlbum
        JOIN Utilisateur u ON al.idUtilisateur = u.idUtilisateur
        LEFT JOIN Aime a ON i.idImage = a.idImage
            AND a.date_aime >= SYSTIMESTAMP - INTERVAL '14' DAY
        WHERE
            i.idCategorie IN (
                SELECT idCategorie FROM Prefere WHERE idUtilisateur = p_idUtilisateur
            )
            AND i.idImage NOT IN (
                SELECT idImage FROM Aime WHERE idUtilisateur = p_idUtilisateur
            )
            AND i.visibilite = 'public'
            AND al.idUtilisateur != p_idUtilisateur
        GROUP BY i.idImage, i.titre, c.nom, u.login
        ORDER BY nb_likes_recents DESC
        FETCH FIRST p_nb_suggestions ROWS ONLY;
    
    RETURN v_cursor;
END get_images_conseillees;
/

-- =============================================================================
-- Fin des procedures et fonctions
-- =============================================================================