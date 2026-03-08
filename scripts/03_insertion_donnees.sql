-- =============================================================================
-- Script d'insertion de donnees de test
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Insertion des UTILISATEURS
-- -----------------------------------------------------------------------------
INSERT INTO Utilisateur VALUES (seq_utilisateur.NEXTVAL, 'jean_photo', 'mdp123hash', 'Dupont', 'Jean', TO_DATE('1990-05-15', 'YYYY-MM-DD'), 'jean.dupont@email.com', 'France', 1);
INSERT INTO Utilisateur VALUES (seq_utilisateur.NEXTVAL, 'marie_art', 'mdp456hash', 'Martin', 'Marie', TO_DATE('1985-08-22', 'YYYY-MM-DD'), 'marie.martin@email.com', 'France', 1);
INSERT INTO Utilisateur VALUES (seq_utilisateur.NEXTVAL, 'alex_nature', 'mdp789hash', 'Bernard', 'Alexandre', TO_DATE('1995-12-03', 'YYYY-MM-DD'), 'alex.bernard@email.com', 'Belgique', 0);
INSERT INTO Utilisateur VALUES (seq_utilisateur.NEXTVAL, 'sophie_travel', 'mdp101hash', 'Leroy', 'Sophie', TO_DATE('1992-03-10', 'YYYY-MM-DD'), 'sophie.leroy@email.com', 'Suisse', 1);
INSERT INTO Utilisateur VALUES (seq_utilisateur.NEXTVAL, 'thomas_urban', 'mdp202hash', 'Moreau', 'Thomas', TO_DATE('1988-07-28', 'YYYY-MM-DD'), 'thomas.moreau@email.com', 'Canada', 0);
INSERT INTO Utilisateur VALUES (seq_utilisateur.NEXTVAL, 'emma_portrait', 'mdp303hash', 'Garcia', 'Emma', TO_DATE('1998-01-17', 'YYYY-MM-DD'), 'emma.garcia@email.com', 'Espagne', 1);
INSERT INTO Utilisateur VALUES (seq_utilisateur.NEXTVAL, 'lucas_wild', 'mdp404hash', 'Petit', 'Lucas', TO_DATE('1993-09-05', 'YYYY-MM-DD'), 'lucas.petit@email.com', 'France', 0);
INSERT INTO Utilisateur VALUES (seq_utilisateur.NEXTVAL, 'chloe_macro', 'mdp505hash', 'Robert', 'Chloe', TO_DATE('1991-11-20', 'YYYY-MM-DD'), 'chloe.robert@email.com', 'Allemagne', 1);

-- -----------------------------------------------------------------------------
-- Insertion des CATEGORIES
-- -----------------------------------------------------------------------------
INSERT INTO Categorie VALUES (seq_categorie.NEXTVAL, 'Nature');
INSERT INTO Categorie VALUES (seq_categorie.NEXTVAL, 'Architecture');
INSERT INTO Categorie VALUES (seq_categorie.NEXTVAL, 'Art');
INSERT INTO Categorie VALUES (seq_categorie.NEXTVAL, 'Portrait');
INSERT INTO Categorie VALUES (seq_categorie.NEXTVAL, 'Animaux');
INSERT INTO Categorie VALUES (seq_categorie.NEXTVAL, 'Voyage');
INSERT INTO Categorie VALUES (seq_categorie.NEXTVAL, 'Urbain');
INSERT INTO Categorie VALUES (seq_categorie.NEXTVAL, 'Macro');

-- -----------------------------------------------------------------------------
-- Insertion des LABELS
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- Insertion des ALBUMS
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- Insertion des IMAGES
-- -----------------------------------------------------------------------------
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
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Gratte-ciels NYC', 'Skyline de Manhattan', SYSTIMESTAMP - INTERVAL '4' DAY, 'JPG', 3100, 'public', 'USA', 1, 7, 7);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Colisee Rome', 'Monument antique au coucher du soleil', SYSTIMESTAMP - INTERVAL '2' DAY, 'JPG', 2400, 'public', 'Italie', 1, 7, 2);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Portrait artistique', 'Portrait en studio avec eclairage dramatique', SYSTIMESTAMP - INTERVAL '6' DAY, 'JPG', 1400, 'public', 'Espagne', 1, 8, 4);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Musicien de rue', 'Artiste jouant de la guitare', SYSTIMESTAMP - INTERVAL '3' DAY, 'JPG', 1600, 'public', 'Espagne', 1, 8, 4);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Lion au repos', 'Lion dans la savane tanzanienne', SYSTIMESTAMP - INTERVAL '7' DAY, 'JPG', 4500, 'public', 'Tanzanie', 1, 9, 5);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Elephants au point d''eau', 'Famille d''elephants', SYSTIMESTAMP - INTERVAL '5' DAY, 'JPG', 3800, 'public', 'Tanzanie', 1, 9, 5);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Girafe au coucher du soleil', 'Silhouette de girafe', SYSTIMESTAMP - INTERVAL '2' DAY, 'JPG', 2700, 'public', 'Tanzanie', 1, 9, 5);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Gouttes de rosee', 'Macro sur feuille avec rosee', SYSTIMESTAMP - INTERVAL '4' DAY, 'JPG', 1200, 'public', 'Allemagne', 1, 10, 8);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Abeille sur fleur', 'Abeille butinant une fleur de lavande', SYSTIMESTAMP - INTERVAL '1' DAY, 'JPG', 1500, 'public', 'Allemagne', 1, 10, 8);
INSERT INTO Image VALUES (seq_image.NEXTVAL, 'Papillon monarque', 'Gros plan sur un papillon', SYSTIMESTAMP - INTERVAL '3' DAY, 'JPG', 1800, 'public', 'Allemagne', 1, 10, 8);

-- -----------------------------------------------------------------------------
-- Insertion des AIME (likes)
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- Insertion des COMMENTAIRES
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- Insertion des PREFERE (categories preferees)
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- Insertion des ETIQUETTES (labels sur images)
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- Insertion des NEWSLETTERS
-- -----------------------------------------------------------------------------
INSERT INTO Newsletter VALUES (seq_newsletter.NEXTVAL, TO_DATE('2024-12-01', 'YYYY-MM-DD'), 'Newsletter de decembre 2024 - Decouvrez les plus belles images de la semaine !');
INSERT INTO Newsletter VALUES (seq_newsletter.NEXTVAL, TO_DATE('2024-12-08', 'YYYY-MM-DD'), 'Newsletter semaine 2 decembre - Les coups de coeur de la communaute');

-- -----------------------------------------------------------------------------
-- Insertion des MET_EN_AVANT (images dans newsletters)
-- -----------------------------------------------------------------------------
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
-- Fin du script d'insertion
-- =============================================================================
