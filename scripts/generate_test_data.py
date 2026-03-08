#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de génération de données massives avec Faker
===================================================
Ce script utilise la librairie Faker pour générer des données réalistes
pour tester la base de données Oracle.

Installation requise:
    pip install faker cx_Oracle

Usage:
    python generate_test_data.py --users 1000 --albums 5 --images 20
    
    ou pour générer uniquement les fichiers SQL:
    python generate_test_data.py --output-sql --users 500
"""

import argparse
import random
from datetime import datetime, timedelta
from typing import List, Dict, Any

try:
    from faker import Faker
    FAKER_AVAILABLE = True
except ImportError:
    FAKER_AVAILABLE = False
    print("⚠️  Faker non installé. Installez-le avec: pip install faker")

# Initialisation de Faker avec locale française
fake = Faker(['fr_FR', 'en_US']) if FAKER_AVAILABLE else None

# =============================================================================
# Configuration des données
# =============================================================================

CATEGORIES = [
    'Nature', 'Architecture', 'Art', 'Portrait', 'Animaux', 'Voyage',
    'Urbain', 'Macro', 'Sport', 'Mode', 'Gastronomie', 'Musique',
    'Cinema', 'Technologie', 'Science', 'Histoire', 'Culture', 'Famille',
    'Evenements', 'Paysage'
]

LABELS = [
    'paysage', 'montagne', 'mer', 'foret', 'ville', 'noir_et_blanc',
    'coucher_soleil', 'hiver', 'ete', 'fleurs', 'oiseaux', 'street_art',
    'portrait', 'macro', 'architecture', 'voyage', 'nature', 'animaux',
    'nuit', 'jour', 'aube', 'crepuscule', 'reflet', 'silhouette',
    'minimaliste', 'colorful', 'vintage', 'moderne', 'classique', 'HDR',
    'long_exposure', 'high_speed', 'panorama', 'drone', 'timelapse',
    'bokeh', 'golden_hour', 'blue_hour', 'storm', 'rainbow', 'fog'
]

FORMATS_IMAGE = ['JPG', 'PNG', 'RAW', 'TIFF', 'WEBP', 'HEIC']

PAYS = [
    'France', 'Belgique', 'Suisse', 'Canada', 'Espagne', 'Allemagne',
    'Italie', 'Portugal', 'Royaume-Uni', 'Pays-Bas', 'Japon', 'USA',
    'Australie', 'Bresil', 'Maroc', 'Tanzanie', 'Grece', 'Norvege'
]

COMMENTAIRES_TEMPLATES = [
    "Superbe photo!", "Magnifique capture!", "J'adore les couleurs!",
    "Très belle composition", "Impressionnant!", "Bravo pour cette image",
    "Quelle qualité!", "Très inspirant", "Moment parfait",
    "Excellent travail!", "Belle lumière!", "Très poétique",
    "Fantastique!", "Sublime!", "Vraiment magnifique",
    "Les détails sont incroyables", "Photo à couper le souffle",
    "Très artistique", "J'aurais aimé prendre cette photo",
    "Quel talent!", "Continue comme ça!"
]

# =============================================================================
# Générateurs de données
# =============================================================================

def generate_user(user_id: int) -> Dict[str, Any]:
    """Génère un utilisateur avec des données réalistes."""
    if not FAKER_AVAILABLE:
        return {
            'id': user_id,
            'login': f'user_{user_id}',
            'password': f'pwd{user_id}hash',
            'nom': f'Nom{user_id}',
            'prenom': f'Prenom{user_id}',
            'date_naissance': '1990-01-01',
            'email': f'user{user_id}@test.com',
            'pays': random.choice(PAYS),
            'newsletter': random.randint(0, 1)
        }
    
    prenom = fake.first_name()
    nom = fake.last_name()
    return {
        'id': user_id,
        'login': f"{prenom.lower()}_{nom.lower()}_{user_id}",
        'password': fake.sha256()[:60],
        'nom': nom,
        'prenom': prenom,
        'date_naissance': fake.date_of_birth(minimum_age=18, maximum_age=70).strftime('%Y-%m-%d'),
        'email': f"{prenom.lower()}.{nom.lower()}.{user_id}@{fake.free_email_domain()}",
        'pays': random.choice(PAYS),
        'newsletter': random.randint(0, 1)
    }

def generate_album(album_id: int, user_id: int) -> Dict[str, Any]:
    """Génère un album avec des données réalistes."""
    titres = [
        "Mes photos de vacances", "Nature sauvage", "Art moderne",
        "Portraits famille", "Faune européenne", "Voyages",
        "Architecture urbaine", "Moments de vie", "Safari",
        "Monde miniature", "Street Photography", "Paysages"
    ]
    
    return {
        'id': album_id,
        'titre': f"{random.choice(titres)} #{album_id}",
        'description': fake.paragraph(nb_sentences=3) if FAKER_AVAILABLE else f"Description album {album_id}",
        'visibilite': 'prive' if random.random() < 0.2 else 'public',
        'user_id': user_id
    }

def generate_image(image_id: int, album_id: int, cat_id: int) -> Dict[str, Any]:
    """Génère une image avec des données réalistes."""
    titres = [
        "Coucher de soleil", "Vue panoramique", "Portrait",
        "Paysage urbain", "Nature morte", "Action", "Macro",
        "Reflet", "Silhouette", "HDR", "Long exposure"
    ]
    
    days_ago = random.randint(1, 365)
    
    return {
        'id': image_id,
        'titre': f"{random.choice(titres)} #{image_id}",
        'description': fake.sentence(nb_words=10) if FAKER_AVAILABLE else f"Description image {image_id}",
        'date_offset_days': days_ago,
        'format': random.choice(FORMATS_IMAGE),
        'taille': random.randint(500, 15000),  # Ko
        'visibilite': 'prive' if random.random() < 0.1 else 'public',
        'pays': random.choice(PAYS),
        'telechargeable': 0 if random.random() < 0.15 else 1,
        'album_id': album_id,
        'categorie_id': cat_id
    }

# =============================================================================
# Génération SQL
# =============================================================================

def escape_sql(value: str) -> str:
    """Échappe les apostrophes pour SQL."""
    if value is None:
        return 'NULL'
    return value.replace("'", "''")

def generate_sql_file(
    nb_users: int = 100,
    nb_albums_per_user: int = 3,
    nb_images_per_album: int = 10,
    nb_likes_per_image: int = 15,
    nb_comments_per_image: int = 5,
    output_file: str = 'generated_data.sql'
):
    """Génère un fichier SQL avec toutes les insertions."""
    
    print(f"📝 Génération du fichier SQL: {output_file}")
    print(f"   - {nb_users} utilisateurs")
    print(f"   - {nb_users * nb_albums_per_user} albums")
    print(f"   - {nb_users * nb_albums_per_user * nb_images_per_album} images")
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("-- =============================================================================\n")
        f.write("-- Données générées automatiquement avec Faker\n")
        f.write(f"-- Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write("-- =============================================================================\n\n")
        f.write("SET DEFINE OFF;\n\n")
        
        # Catégories
        f.write("-- Catégories\n")
        for i, cat in enumerate(CATEGORIES, 1):
            f.write(f"INSERT INTO Categorie VALUES (seq_categorie.NEXTVAL, '{cat}');\n")
        f.write("COMMIT;\n\n")
        
        # Labels
        f.write("-- Labels\n")
        for i, label in enumerate(LABELS, 1):
            f.write(f"INSERT INTO Label VALUES (seq_label.NEXTVAL, '{label}');\n")
        f.write("COMMIT;\n\n")
        
        # Utilisateurs
        f.write("-- Utilisateurs\n")
        users = []
        for i in range(1, nb_users + 1):
            user = generate_user(i)
            users.append(user)
            f.write(f"INSERT INTO Utilisateur VALUES (seq_utilisateur.NEXTVAL, "
                   f"'{escape_sql(user['login'])}', '{escape_sql(user['password'])}', "
                   f"'{escape_sql(user['nom'])}', '{escape_sql(user['prenom'])}', "
                   f"TO_DATE('{user['date_naissance']}', 'YYYY-MM-DD'), "
                   f"'{escape_sql(user['email'])}', '{user['pays']}', {user['newsletter']});\n")
            if i % 100 == 0:
                f.write("COMMIT;\n")
        f.write("COMMIT;\n\n")
        
        # Albums
        f.write("-- Albums\n")
        album_id = 0
        albums = []
        for user_idx in range(1, nb_users + 1):
            for _ in range(nb_albums_per_user):
                album_id += 1
                album = generate_album(album_id, user_idx)
                albums.append(album)
                f.write(f"INSERT INTO Album VALUES (seq_album.NEXTVAL, "
                       f"'{escape_sql(album['titre'])}', '{escape_sql(album['description'])}', "
                       f"SYSTIMESTAMP, '{album['visibilite']}', {user_idx});\n")
            if user_idx % 50 == 0:
                f.write("COMMIT;\n")
        f.write("COMMIT;\n\n")
        
        # Images
        f.write("-- Images\n")
        image_id = 0
        images = []
        for alb_idx in range(1, len(albums) + 1):
            for _ in range(nb_images_per_album):
                image_id += 1
                cat_id = random.randint(1, len(CATEGORIES))
                image = generate_image(image_id, alb_idx, cat_id)
                images.append(image)
                f.write(f"INSERT INTO Image VALUES (seq_image.NEXTVAL, "
                       f"'{escape_sql(image['titre'])}', '{escape_sql(image['description'])}', "
                       f"SYSTIMESTAMP - INTERVAL '{image['date_offset_days']}' DAY, "
                       f"'{image['format']}', {image['taille']}, '{image['visibilite']}', "
                       f"'{image['pays']}', {image['telechargeable']}, {alb_idx}, {cat_id});\n")
            if alb_idx % 50 == 0:
                f.write("COMMIT;\n")
        f.write("COMMIT;\n\n")
        
        # Likes (Aime)
        f.write("-- Likes\n")
        like_count = 0
        for img_idx in range(1, len(images) + 1):
            nb_likes = random.randint(0, min(nb_likes_per_image, nb_users))
            likers = random.sample(range(1, nb_users + 1), nb_likes)
            for user_idx in likers:
                days_ago = random.randint(1, 90)
                f.write(f"INSERT INTO Aime VALUES ({user_idx}, {img_idx}, "
                       f"SYSTIMESTAMP - INTERVAL '{days_ago}' DAY);\n")
                like_count += 1
            if img_idx % 100 == 0:
                f.write("COMMIT;\n")
        f.write("COMMIT;\n\n")
        
        # Commentaires
        f.write("-- Commentaires\n")
        comment_count = 0
        for img_idx in range(1, len(images) + 1):
            nb_comments = random.randint(0, nb_comments_per_image)
            for _ in range(nb_comments):
                user_idx = random.randint(1, nb_users)
                comment = random.choice(COMMENTAIRES_TEMPLATES)
                if FAKER_AVAILABLE and random.random() < 0.3:
                    comment += " " + fake.sentence(nb_words=5)
                days_ago = random.randint(1, 60)
                f.write(f"INSERT INTO Commentaire VALUES (seq_commentaire.NEXTVAL, "
                       f"'{escape_sql(comment)}', SYSTIMESTAMP - INTERVAL '{days_ago}' DAY, "
                       f"{user_idx}, {img_idx});\n")
                comment_count += 1
            if img_idx % 100 == 0:
                f.write("COMMIT;\n")
        f.write("COMMIT;\n\n")
        
        # Étiquettes
        f.write("-- Étiquettes (Image-Label)\n")
        for img_idx in range(1, len(images) + 1):
            nb_tags = random.randint(2, 6)
            tags = random.sample(range(1, len(LABELS) + 1), nb_tags)
            for tag_id in tags:
                f.write(f"INSERT INTO Etiquette VALUES ({img_idx}, {tag_id});\n")
            if img_idx % 100 == 0:
                f.write("COMMIT;\n")
        f.write("COMMIT;\n\n")
        
        # Préférences
        f.write("-- Préférences utilisateur\n")
        for user_idx in range(1, nb_users + 1):
            nb_prefs = random.randint(1, 5)
            prefs = random.sample(range(1, len(CATEGORIES) + 1), nb_prefs)
            for cat_id in prefs:
                f.write(f"INSERT INTO Prefere VALUES ({user_idx}, {cat_id});\n")
        f.write("COMMIT;\n\n")
        
        f.write("-- Fin du script\n")
    
    print(f"✅ Fichier généré: {output_file}")
    print(f"   Total: {nb_users} users, {len(albums)} albums, {len(images)} images")
    print(f"   {like_count} likes, {comment_count} commentaires")

# =============================================================================
# Point d'entrée
# =============================================================================

def main():
    parser = argparse.ArgumentParser(description='Générateur de données de test')
    parser.add_argument('--users', type=int, default=100, help='Nombre d\'utilisateurs')
    parser.add_argument('--albums', type=int, default=3, help='Albums par utilisateur')
    parser.add_argument('--images', type=int, default=10, help='Images par album')
    parser.add_argument('--likes', type=int, default=15, help='Likes max par image')
    parser.add_argument('--comments', type=int, default=5, help='Commentaires max par image')
    parser.add_argument('--output', type=str, default='generated_data.sql', help='Fichier de sortie')
    
    args = parser.parse_args()
    
    if not FAKER_AVAILABLE:
        print("⚠️  Faker non disponible - utilisation de données basiques")
        print("   Pour des données plus réalistes: pip install faker")
    
    generate_sql_file(
        nb_users=args.users,
        nb_albums_per_user=args.albums,
        nb_images_per_album=args.images,
        nb_likes_per_image=args.likes,
        nb_comments_per_image=args.comments,
        output_file=args.output
    )

if __name__ == '__main__':
    main()
