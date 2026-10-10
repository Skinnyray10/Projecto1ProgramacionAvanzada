-- Última ubicación reportada por la app móvil de cada usuario.
-- Ejecutar en Supabase: SQL Editor → New query → Run
create table if not exists public.user_locations (
  user_id uuid primary key references public.users (id) on delete cascade,
  latitude double precision not null check (latitude between -90 and 90),
  longitude double precision not null check (longitude between -180 and 180),
  accuracy double precision,
  recorded_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.user_locations enable row level security;
revoke all on public.user_locations from anon, authenticated;
grant all on public.user_locations to service_role;
