# Base de données - Site de partage d'images

## Prérequis

- Oracle Database (ou Oracle XE)
- SQL\*Plus ou un client Oracle (SQL Developer, etc.)

## Structure du projet

```
Scripts/
├── 00_run.sql                      # Script principal (exécute tout)
├── 01_creation_tables.sql          # Création des tables
├── 02_suppression_tables.sql       # Suppression des tables
├── 03_insertion_donnees.sql        # Insertion des données
├── 04_requetes.sql                 # Requêtes SQL
├── 05_procedures_fonctions.sql     # Procédures et fonctions PL/SQL
├── 06_triggers.sql                 # Déclencheurs (triggers)
├── 07_tests.sql                    # Tests unitaires
├── 08_generation_donnees_massives.sql  # Génération de données volumineuses
├── 09_test_performance.sql         # Tests de performance
├── generate_test_data.py           # Script Python avec Faker
└── init_all.sql                    # Initialisation (tables + données)
```

## Comment exécuter le projet

### Option 1 : Initialisation complète (recommandé)

Exécutez le script principal qui crée les tables, insère les données, et configure les procédures/triggers :

```sql
@Scripts/00_run.sql
```

### Option 2 : Initialisation des tables et données uniquement

```sql
@Scripts/init_all.sql
```

### Option 3 : Exécution manuelle étape par étape

1. Créer les tables :

   ```sql
   @Scripts/01_creation_tables.sql
   ```

2. Insérer les données :

   ```sql
   @Scripts/03_insertion_donnees.sql
   ```

3. Créer les procédures et fonctions :

   ```sql
   @Scripts/05_procedures_fonctions.sql
   ```

4. Créer les triggers :
   ```sql
   @Scripts/06_triggers.sql
   ```

## Réinitialiser la base

Pour supprimer toutes les tables :

```sql
@Scripts/02_suppression_tables.sql
```

## Tester les fonctionnalités

```sql
@Scripts/07_tests.sql
```

## Exécuter les requêtes

```sql
@Scripts/04_requetes.sql
```

## Tests de charge et performance

### Génération de données massives (PL/SQL)

Le script `08_generation_donnees_massives.sql` permet de générer un grand volume de données directement en PL/SQL :

```sql
-- Charger les procédures de génération
@Scripts/08_generation_donnees_massives.sql

-- Petit jeu de données (test rapide)
EXEC generer_donnees_test(100, 20, 50, 3, 10, 15, 5);

-- Jeu de données moyen
EXEC generer_donnees_test(500, 25, 75, 5, 20, 25, 10);

-- Grand jeu de données (test de charge)
EXEC generer_donnees_test(1000, 30, 100, 5, 30, 30, 15);

-- Voir les statistiques
EXEC afficher_statistiques;
```

### Génération avec Python/Faker

Pour des données plus réalistes, utilisez le script Python :

```bash
# Installation
pip install faker

# Générer un fichier SQL (100 utilisateurs)
python Scripts/generate_test_data.py --users 100 --output generated_data.sql

# Grand volume (1000 utilisateurs)
python Scripts/generate_test_data.py --users 1000 --albums 5 --images 20 --output big_data.sql
```

### Tests de performance

```sql
@Scripts/09_test_performance.sql
```

### Outils externes de génération de données

- **[Mockaroo](https://www.mockaroo.com/)** - Générateur en ligne, export CSV/SQL
- **[GenerateData](http://generatedata.com/)** - Interface web, personnalisable
- **[Faker](https://faker.readthedocs.io/)** - Librairie Python puissante
