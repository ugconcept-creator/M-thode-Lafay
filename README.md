# Lafay Body

Application de suivi d'entraînement au poids de corps (méthode Olivier Lafay), à héberger toi-même. Un seul fichier `index.html`, aucune installation, fonctionne dans Safari sur iPhone (ou n'importe quel navigateur).

## Fonctionnement

- **Sans rien configurer** : l'appli fonctionne tout de suite en stockant les données dans le navigateur (`localStorage`). Pratique pour tester, mais les données restent sur un seul appareil et un seul navigateur.
- **Avec Supabase configuré** : les données (profils, progression, historique de séances) sont synchronisées dans le cloud et accessibles depuis n'importe quel appareil avec la même URL.

## 1. Créer le projet Supabase (gratuit)

1. Va sur [supabase.com](https://supabase.com) → crée un compte → **New project**.
2. Une fois le projet créé, ouvre **SQL Editor** → **New query**, colle le contenu du fichier `schema.sql` fourni ici, et exécute-le. Cela crée les 3 tables (`profiles`, `progress`, `sessions`).
3. Va dans **Project Settings → API**. Note :
   - **Project URL** (ex : `https://abcdefgh.supabase.co`)
   - **anon public key** (une longue chaîne de caractères)

## 2. Configurer `index.html`

Ouvre `index.html`, tout en haut du `<script>` final, remplace :

```js
const SUPABASE_URL = "https://YOUR-PROJECT.supabase.co";
const SUPABASE_ANON_KEY = "YOUR-ANON-KEY";
```

par tes propres valeurs. Sauvegarde. C'est tout — l'appli bascule automatiquement en mode "cloud" dès que ces valeurs sont valides (tu verras un badge **☁️ Cloud** dans l'onglet Réglages au lieu de **📱 Local**).

⚠️ **Note de sécurité** : la clé `anon` est publique par nature (elle est visible dans le code source de la page) et les policies du schéma autorisent toute personne possédant cette clé à lire/écrire les données. C'est adapté à un usage personnel avec une URL non partagée. Si tu veux restreindre davantage, ajoute l'authentification Supabase (email/mot de passe) et adapte les policies RLS avec `auth.uid()`.

## 3. Mettre le code sur GitHub

### Méthode simple — sans terminal, tout depuis le site GitHub

1. Crée un compte sur [github.com](https://github.com) si besoin (**Sign up**).
2. Clique sur le **+** en haut à droite → **New repository**.
   - **Repository name** : `lafay-body` (ou ce que tu veux)
   - Laisse tout décoché (pas de README, pas de .gitignore)
   - Clique **Create repository**
3. Sur la page suivante, clique le lien **"uploading an existing file"** dans le texte d'aide.
4. Fais glisser tes 3 fichiers (`index.html`, `schema.sql`, `README.md`) dans la zone de dépôt.
5. En bas de page, clique **Commit changes**.

Ton code est en ligne sur `https://github.com/TON-COMPTE/lafay-body`. Passe à l'étape 4 (Cloudflare Pages).

**Pour modifier `index.html` plus tard** (par ex. après avoir ajouté tes clés Supabase) : ouvre le fichier dans GitHub → icône **crayon** (Edit) en haut à droite → modifie → **Commit changes** en bas de page. Cloudflare redéploiera automatiquement.

### Méthode terminal (si tu es à l'aise avec git)

```bash
git init
git add index.html schema.sql README.md
git commit -m "Lafay Body"
git branch -M main
git remote add origin https://github.com/TON-COMPTE/lafay-body.git
git push -u origin main
```

## 4. Déployer sur Cloudflare Pages

1. Sur le [dashboard Cloudflare](https://dash.cloudflare.com) → **Workers & Pages** → **Create application** → **Pages** → **Connect to Git**.
2. Sélectionne ton dépôt GitHub.
3. Paramètres de build : laisse tout vide / **Framework preset: None**, **Build command: (aucune)**, **Build output directory: /** (racine, puisque `index.html` est à la racine).
4. Déploie. Cloudflare te donne une URL du type `https://lafay-body.pages.dev`.

## 5. Ajouter l'appli à l'écran d'accueil (iPhone)

Dans Safari, ouvre l'URL Cloudflare → bouton **Partager** → **Sur l'écran d'accueil**. L'appli s'ouvrira ensuite en plein écran, sans barre Safari, comme une vraie app.

## Mettre à jour l'appli plus tard

Modifie `index.html`, puis :

```bash
git add index.html
git commit -m "update"
git push
```

Cloudflare Pages redéploie automatiquement à chaque push.

## Structure des données

- **profiles** : un profil par personne (prénom, emoji, réglages : temps de repos, nombre de séries, son, couleur d'accent).
- **progress** : le niveau actuel (nombre de répétitions cible) pour chacun des 7 exercices Lafay, par profil.
- **sessions** : chaque séance (Lafay ou Abdos) enregistrée avec le détail série par série.

## Logique de progression (méthode Lafay simplifiée)

Pour chaque exercice, tu t'entraînes sur **6 séries** (réglable) à un nombre de répétitions cible **x**. Avant de démarrer une séance, tu choisis pour chaque exercice : **Même niveau** ou **+1 répétition**, quel que soit le résultat de la séance précédente.

Si les 6 séries sont toutes réussies (répétitions réalisées ≥ objectif), l'exercice passe en statut **✅ prêt** et le niveau enregistré devient celui utilisé pendant la séance. Sinon, le niveau enregistré ne change pas — tu restes libre de retenter un palier supérieur à la séance suivante si tu veux.
