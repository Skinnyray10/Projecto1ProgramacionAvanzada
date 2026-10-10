-- Rol para cuentas creadas desde la app móvil: solo consultan productos.
-- Ejecutar en Supabase: SQL Editor → New query → Run
alter type public.user_role add value if not exists 'customer';
