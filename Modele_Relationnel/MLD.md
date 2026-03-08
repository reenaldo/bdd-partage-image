# Modèle Relationnel

> **Base de données 2 - Galerie d’images**

---

## Légende

| Symbole | Signification         |
| :-----: | --------------------- |
| **PK**  | Clé primaire          |
| **FK**  | Clé étrangère         |
|  **#**  | Préfixe clé étrangère |

---

## Tables

### 1. Utilisateur

```sql
Utilisateur(
    idUtilisateur : Int,
    login : String,
    mot_de_passe : String,
    nom : String,
    prenom : String,
    date_naissance : Date,
    email : String,
    pays : String,
    abonne_newsletter : Boolean
)
```

| Contrainte | Attributs                                             |
| ---------- | ----------------------------------------------------- |
| PK         | `idUtilisateur`                                       |
| UNIQUE     | `login`, `email`                                      |
| NOT NULL   | `login`, `mot_de_passe`, `email`, `abonne_newsletter` |

---

### 2. Album

```sql
Album(
    idAlbum : Int,
    titre : String,
    description : Text,
    date_creation : Timestamp,
    visibilite : String,
    #idUtilisateur : Int
)
```

| Contrainte | Attributs                                               |
| ---------- | ------------------------------------------------------- |
| PK         | `idAlbum`                                               |
| FK         | `idUtilisateur` → `Utilisateur(idUtilisateur)`          |
| NOT NULL   | `titre`, `date_creation`, `visibilite`, `idUtilisateur` |

---

### 3. Categorie

```sql
Categorie(
    idCategorie : Int,
    nom : String
)
```

| Contrainte | Attributs     |
| ---------- | ------------- |
| PK         | `idCategorie` |
| UNIQUE     | `nom`         |
| NOT NULL   | `nom`         |

---

### 4. Label

```sql
Label(
    idLabel : Int,
    nom : String
)
```

| Contrainte | Attributs |
| ---------- | --------- |
| PK         | `idLabel` |
| UNIQUE     | `nom`     |
| NOT NULL   | `nom`     |

---

### 5. Image

```sql
Image(
    idImage : Int,
    titre : String,
    description : Text,
    date_publication : Timestamp,
    format : String,
    taille : Int,
    visibilite : String,
    pays_origine : String,
    telechargeable : Boolean,
    #idAlbum : Int,
    #idCategorie : Int
)
```

| Contrainte | Attributs                                                                             |
| ---------- | ------------------------------------------------------------------------------------- |
| PK         | `idImage`                                                                             |
| FK         | `idAlbum` → `Album(idAlbum)`                                                          |
| FK         | `idCategorie` → `Categorie(idCategorie)`                                              |
| NOT NULL   | `titre`, `date_publication`, `visibilite`, `telechargeable`, `idAlbum`, `idCategorie` |

---

### 6. Image_archive

```sql
Image_archive(
    idImageArchive : Int,
    titre : String,
    description : Text,
    date_publication : Timestamp,
    format : String,
    taille : Int,
    visibilite : String,
    pays_origine : String,
    telechargeable : Boolean,
    date_archivage : Timestamp
)
```

| Contrainte | Attributs        |
| ---------- | ---------------- |
| PK         | `idImageArchive` |
| NOT NULL   | `date_archivage` |

> **Note** : Table indépendante. Les données sont copiées par un trigger `BEFORE DELETE` sur la table `Image`.

---

### 7. Newsletter

```sql
Newsletter(
    idNewsletter : Int,
    date_envoi : Date,
    contenu : Text
)
```

| Contrainte | Attributs               |
| ---------- | ----------------------- |
| PK         | `idNewsletter`          |
| NOT NULL   | `date_envoi`, `contenu` |

---

### 8. Aime

```sql
Aime(
    #idUtilisateur : Int,
    #idImage : Int,
    date_aime : Timestamp
)
```

| Contrainte | Attributs                                      |
| ---------- | ---------------------------------------------- |
| PK         | `(idUtilisateur, idImage)`                     |
| FK         | `idUtilisateur` → `Utilisateur(idUtilisateur)` |
| FK         | `idImage` → `Image(idImage)`                   |
| NOT NULL   | `idUtilisateur`, `idImage`, `date_aime`        |

---

### 9. Commentaire

```sql
Commentaire(
    idCommentaire : Int,
    texte_commentaire : Text,
    date_commentaire : Timestamp,
    #idUtilisateur : Int,
    #idImage : Int
)
```

| Contrainte | Attributs                                                           |
| ---------- | ------------------------------------------------------------------- |
| PK         | `idCommentaire`                                                     |
| FK         | `idUtilisateur` → `Utilisateur(idUtilisateur)`                      |
| FK         | `idImage` → `Image(idImage)`                                        |
| NOT NULL   | `texte_commentaire`, `date_commentaire`, `idUtilisateur`, `idImage` |

---

### 10. Prefere

```sql
Prefere(
    #idUtilisateur : Int,
    #idCategorie : Int
)
```

| Contrainte | Attributs                                      |
| ---------- | ---------------------------------------------- |
| PK         | `(idUtilisateur, idCategorie)`                 |
| FK         | `idUtilisateur` → `Utilisateur(idUtilisateur)` |
| FK         | `idCategorie` → `Categorie(idCategorie)`       |

---

### 11. Etiquette

```sql
Etiquette(
    #idImage : Int,
    #idLabel : Int
)
```

| Contrainte | Attributs                    |
| ---------- | ---------------------------- |
| PK         | `(idImage, idLabel)`         |
| FK         | `idImage` → `Image(idImage)` |
| FK         | `idLabel` → `Label(idLabel)` |

---

### 12. Met_en_avant

```sql
Met_en_avant(
    #idNewsletter : Int,
    #idImage : Int
)
```

| Contrainte | Attributs                                   |
| ---------- | ------------------------------------------- |
| PK         | `(idNewsletter, idImage)`                   |
| FK         | `idNewsletter` → `Newsletter(idNewsletter)` |
| FK         | `idImage` → `Image(idImage)`                |

---

## Résumé des Relations

|  #  | Relation          | Clé Primaire                   | Clés Étrangères                |
| :-: | ----------------- | ------------------------------ | ------------------------------ |
|  1  | **Utilisateur**   | `idUtilisateur`                | —                              |
|  2  | **Album**         | `idAlbum`                      | `idUtilisateur`                |
|  3  | **Categorie**     | `idCategorie`                  | —                              |
|  4  | **Label**         | `idLabel`                      | —                              |
|  5  | **Image**         | `idImage`                      | `idAlbum`, `idCategorie`       |
|  6  | **Image_archive** | `idImageArchive`               | —                              |
|  7  | **Newsletter**    | `idNewsletter`                 | —                              |
|  8  | **Aime**          | `(idUtilisateur, idImage)`     | `idUtilisateur`, `idImage`     |
|  9  | **Commentaire**   | `idCommentaire`                | `idUtilisateur`, `idImage`     |
| 10  | **Prefere**       | `(idUtilisateur, idCategorie)` | `idUtilisateur`, `idCategorie` |
| 11  | **Etiquette**     | `(idImage, idLabel)`           | `idImage`, `idLabel`           |
| 12  | **Met_en_avant**  | `(idNewsletter, idImage)`      | `idNewsletter`, `idImage`      |

---

## Contraintes de Domaine

| Attribut            |   Type    | Valeurs possibles       |
| ------------------- | :-------: | ----------------------- |
| `visibilite`        |  `ENUM`   | `'public'` \| `'prive'` |
| `abonne_newsletter` | `BOOLEAN` | `TRUE` \| `FALSE`       |
| `telechargeable`    | `BOOLEAN` | `TRUE` \| `FALSE`       |
