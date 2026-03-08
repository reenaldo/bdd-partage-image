-- =============================================================================
-- Requetes SQL
-- =============================================================================

-- REQUETE 1 : Nombre d'images publiées par catégorie au cours des 2 dernières semaines
SELECT
    c.nom AS categorie,
    COUNT(i.idImage) AS nb_images_publiees
FROM
    Categorie c
LEFT JOIN
    Image i ON c.idCategorie = i.idCategorie
    AND i.date_publication >= SYSTIMESTAMP - INTERVAL '14' DAY
GROUP BY
    c.idCategorie, c.nom
ORDER BY
    nb_images_publiees DESC;

-- REQUETE 2 : Par utilisateur, le nombre d'albums, d'images publiées, de likes donnés et reçus
SELECT 
    u.idUtilisateur,
    u.login,
    u.nom,
    u.prenom,
    (SELECT COUNT(*) FROM Album a WHERE a.idUtilisateur = u.idUtilisateur) AS nb_albums,
    (SELECT COUNT(*) 
     FROM Image i 
     JOIN Album a ON i.idAlbum = a.idAlbum 
     WHERE a.idUtilisateur = u.idUtilisateur) AS nb_images_publiees,
    (SELECT COUNT(*) FROM Aime ai WHERE ai.idUtilisateur = u.idUtilisateur) AS likes_donnes,
    (SELECT COUNT(*) 
     FROM Aime ai 
     JOIN Image i ON ai.idImage = i.idImage
     JOIN Album a ON i.idAlbum = a.idAlbum
     WHERE a.idUtilisateur = u.idUtilisateur) AS likes_recus
FROM 
    Utilisateur u
ORDER BY 
    likes_recus DESC;

-- REQUETE 3 : Pour chaque image, le nombre de likes par pays des utilisateurs
SELECT 
    i.idImage,
    i.titre AS titre_image,
    u.pays,
    COUNT(*) AS nb_likes_pays
FROM 
    Image i
JOIN Aime a ON i.idImage = a.idImage
JOIN Utilisateur u ON a.idUtilisateur = u.idUtilisateur
GROUP BY 
    i.idImage, i.titre, u.pays
ORDER BY 
    i.idImage, nb_likes_pays DESC;

-- REQUETE 3 : Version optimisee - Pour chaque image, le nombre de likes par pays
-- avec la difference entre le pays ayant le plus de likes et celui en ayant le moins
-- Optimisation : Utilisation de fonctions analytiques pour eliminer une sous-requete
SELECT 
    idImage,
    titre,
    MAX(nb_likes) AS max_likes,
    MIN(nb_likes) AS min_likes,
    MAX(nb_likes) - MIN(nb_likes) AS difference,
    ABS(MAX(nb_likes) - MIN(nb_likes)) AS diff_absolue
FROM (
    SELECT 
        i.idImage,
        i.titre,
        u.pays,
        COUNT(*) AS nb_likes
    FROM 
        Image i
    JOIN Aime a ON i.idImage = a.idImage
    JOIN Utilisateur u ON a.idUtilisateur = u.idUtilisateur
    GROUP BY 
        i.idImage, i.titre, u.pays
)
GROUP BY 
    idImage, titre
ORDER BY 
    ABS(MAX(nb_likes) - MIN(nb_likes)) DESC;

-- REQUETE 4 : Les images qui ont au moins deux fois plus de likes que la moyenne de leur categorie
SELECT 
    l.idImage,
    l.titre,
    c.nom AS categorie,
    l.nb_likes,
    ROUND(m.moyenne_likes, 2) AS moyenne_categorie,
    ROUND(l.nb_likes / NULLIF(m.moyenne_likes, 0), 2) AS ratio
FROM (
    SELECT 
        i.idImage,
        i.titre,
        i.idCategorie,
        COUNT(a.idUtilisateur) AS nb_likes
    FROM 
        Image i
    LEFT JOIN Aime a ON i.idImage = a.idImage
    GROUP BY 
        i.idImage, i.titre, i.idCategorie
) l
JOIN (
    SELECT 
        likes_count.idCategorie,
        AVG(likes_count.nb_likes) AS moyenne_likes
    FROM (
        SELECT 
            i.idImage,
            i.idCategorie,
            COUNT(a.idUtilisateur) AS nb_likes
        FROM 
            Image i
        LEFT JOIN Aime a ON i.idImage = a.idImage
        GROUP BY 
            i.idImage, i.idCategorie
    ) likes_count
    GROUP BY 
        likes_count.idCategorie
) m ON l.idCategorie = m.idCategorie
JOIN Categorie c ON l.idCategorie = c.idCategorie
WHERE 
    l.nb_likes >= 2 * m.moyenne_likes
    AND m.moyenne_likes > 0
ORDER BY 
    ratio DESC;

-- REQUETE 5 : Les 10 couples d'images les plus souvent likées ensemble par un même utilisateur
SELECT
    image1,
    image2,
    titre_image1,
    titre_image2,
    nb_utilisateurs_communs
FROM (
    SELECT
        a1.idImage AS image1,
        a2.idImage AS image2,
        i1.titre AS titre_image1,
        i2.titre AS titre_image2,
        COUNT(DISTINCT a1.idUtilisateur) AS nb_utilisateurs_communs
    FROM
        Aime a1
    JOIN Aime a2 ON a1.idUtilisateur = a2.idUtilisateur
        AND a1.idImage < a2.idImage
    JOIN Image i1 ON a1.idImage = i1.idImage
    JOIN Image i2 ON a2.idImage = i2.idImage
    GROUP BY
        a1.idImage, a2.idImage, i1.titre, i2.titre
    ORDER BY
        nb_utilisateurs_communs DESC
)
WHERE ROWNUM <= 10;

-- =============================================================================
-- Les index pour optimiser ces requetes sont crees automatiquement
-- dans init_all.sql lors de l'initialisation de la base de donnees.
-- =============================================================================
