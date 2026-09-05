-- Esquema inicial del sistema de administración HMDP.
-- Ejecutar en Supabase: SQL Editor → New query → Run.
create extension if not exists "pgcrypto";
do $$ begin if not exists (
  select 1
  from pg_type
  where typname = 'user_role'
) then create type public.user_role as enum ('super_admin', 'admin', 'operator');
end if;
end $$;
create table if not exists public.users (
  id uuid primary key default gen_random_uuid(),
  email text not null unique,
  password_hash text not null,
  full_name text not null,
  role public.user_role not null default 'operator',
  is_active boolean not null default true,
  last_login_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint users_email_format check (email ~* '^[^@]+@[^@]+\.[^@]+$')
);
create index if not exists users_role_idx on public.users (role);
create index if not exists users_is_active_idx on public.users (is_active);
create or replace function public.set_updated_at() returns trigger language plpgsql as $$ begin new.updated_at = now();
return new;
end;
$$;
drop trigger if exists users_set_updated_at on public.users;
create trigger users_set_updated_at before
update on public.users for each row execute function public.set_updated_at();
alter table public.users enable row level security;
-- El API de Node usa la service role key y omite RLS.
-- Anon/authenticated no deben leer hashes de contraseña.
revoke all on public.users
from anon,
  authenticated;
grant all on public.users to service_role;