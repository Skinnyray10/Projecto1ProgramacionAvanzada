-- HMDP Refaccionaria — usuarios, piezas y autos
-- Ejecutar en Supabase: SQL Editor → New query → Run

create extension if not exists "pgcrypto";

do $$
begin
  if not exists (select 1 from pg_type where typname = 'user_role') then
    create type public.user_role as enum ('super_admin', 'admin', 'operator');
  end if;
end
$$;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- Usuarios del sistema
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

drop trigger if exists users_set_updated_at on public.users;
create trigger users_set_updated_at
before update on public.users
for each row execute function public.set_updated_at();

-- Piezas / refacciones
create table if not exists public.parts (
  id uuid primary key default gen_random_uuid(),
  sku text not null unique,
  name text not null,
  brand text not null default '',
  category text not null default 'General',
  stock integer not null default 0 check (stock >= 0),
  unit_price numeric(12, 2) not null default 0 check (unit_price >= 0),
  description text not null default '',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists parts_category_idx on public.parts (category);
create index if not exists parts_brand_idx on public.parts (brand);
create index if not exists parts_is_active_idx on public.parts (is_active);

drop trigger if exists parts_set_updated_at on public.parts;
create trigger parts_set_updated_at
before update on public.parts
for each row execute function public.set_updated_at();

-- Autos / vehículos
create table if not exists public.cars (
  id uuid primary key default gen_random_uuid(),
  brand text not null,
  model text not null,
  year integer not null check (year >= 1950 and year <= 2100),
  plates text not null unique,
  color text not null default '',
  owner_name text not null default '',
  vin text not null default '',
  notes text not null default '',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists cars_brand_idx on public.cars (brand);
create index if not exists cars_year_idx on public.cars (year);
create index if not exists cars_is_active_idx on public.cars (is_active);

drop trigger if exists cars_set_updated_at on public.cars;
create trigger cars_set_updated_at
before update on public.cars
for each row execute function public.set_updated_at();

alter table public.users enable row level security;
alter table public.parts enable row level security;
alter table public.cars enable row level security;

revoke all on public.users from anon, authenticated;
revoke all on public.parts from anon, authenticated;
revoke all on public.cars from anon, authenticated;

grant all on public.users to service_role;
grant all on public.parts to service_role;
grant all on public.cars to service_role;
