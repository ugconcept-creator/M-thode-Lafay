-- ============================================================
-- Lafay Body — schéma Supabase
-- À exécuter une fois dans : Supabase > SQL Editor > New query
-- ============================================================

create extension if not exists pgcrypto;

-- Profils (plusieurs personnes peuvent utiliser la même appli)
create table if not exists profiles (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  emoji text default '💪',
  settings jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

-- Niveau de progression courant, un enregistrement par exercice Lafay et par profil
create table if not exists progress (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles(id) on delete cascade,
  exercise_key text not null,
  current_reps int not null default 1,
  ready boolean not null default false,
  updated_at timestamptz not null default now(),
  unique (profile_id, exercise_key)
);

-- Séances (Lafay et Abdos), le détail des séries est stocké en JSON
create table if not exists sessions (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles(id) on delete cascade,
  type text not null default 'lafay', -- 'lafay' ou 'abdos'
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  duration_sec int,
  exercises jsonb not null default '[]'::jsonb
);

create index if not exists idx_progress_profile on progress(profile_id);
create index if not exists idx_sessions_profile on sessions(profile_id, started_at desc);

-- ------------------------------------------------------------
-- Sécurité (RLS)
-- ------------------------------------------------------------
-- Cette appli est prévue pour un usage perso/familial sans compte
-- utilisateur : elle utilise la clé "anon" publique de Supabase.
-- Les policies ci-dessous ouvrent l'accès à quiconque possède
-- cette clé (visible dans le code source de la page). C'est
-- suffisant pour un usage privé (URL non partagée), mais si tu
-- veux une vraie confidentialité, ajoute plus tard l'authentification
-- Supabase (email/mot de passe) et restreins ces policies avec
-- auth.uid().
-- ------------------------------------------------------------

alter table profiles enable row level security;
alter table progress enable row level security;
alter table sessions enable row level security;

drop policy if exists "allow all profiles" on profiles;
create policy "allow all profiles" on profiles for all using (true) with check (true);

drop policy if exists "allow all progress" on progress;
create policy "allow all progress" on progress for all using (true) with check (true);

drop policy if exists "allow all sessions" on sessions;
create policy "allow all sessions" on sessions for all using (true) with check (true);
