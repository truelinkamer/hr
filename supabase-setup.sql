-- True Link salary app: database setup (run once in Supabase > SQL Editor > New query)
-- Use a NEW Supabase project, separate from the cashbook.

create table if not exists public.employees (
  id uuid primary key,
  data jsonb not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.salary_slips (
  sl text primary key,
  data jsonb not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.certificates (
  id bigint primary key,
  data jsonb not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.app_settings (
  key text primary key,
  value jsonb not null,
  updated_at timestamptz not null default now()
);

-- Lock everything: only signed-in users can read or write. Anonymous visitors get nothing.
alter table public.employees     enable row level security;
alter table public.salary_slips  enable row level security;
alter table public.certificates  enable row level security;
alter table public.app_settings  enable row level security;

drop policy if exists "signed in users only" on public.employees;
drop policy if exists "signed in users only" on public.salary_slips;
drop policy if exists "signed in users only" on public.certificates;
drop policy if exists "signed in users only" on public.app_settings;

create policy "signed in users only" on public.employees    for all to authenticated using (true) with check (true);
create policy "signed in users only" on public.salary_slips for all to authenticated using (true) with check (true);
create policy "signed in users only" on public.certificates for all to authenticated using (true) with check (true);
create policy "signed in users only" on public.app_settings for all to authenticated using (true) with check (true);

-- Belt and braces: remove all access for the public (anon) role.
revoke all on public.employees    from anon;
revoke all on public.salary_slips from anon;
revoke all on public.certificates from anon;
revoke all on public.app_settings from anon;

-- Let signed-in users use the tables through the Data API, then refresh the API cache.
grant usage on schema public to authenticated;
grant select, insert, update, delete on public.employees, public.salary_slips, public.certificates, public.app_settings to authenticated;
notify pgrst, 'reload schema';
