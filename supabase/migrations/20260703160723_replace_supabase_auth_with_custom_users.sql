alter table public.orders
  drop constraint if exists orders_user_id_fkey;

update public.orders
set user_id = null
where user_id is not null;

drop trigger if exists on_auth_user_created on auth.users;
drop function if exists private.handle_new_user();

delete from auth.users;

drop table if exists public.user_profiles;

create table public.users (
  id uuid primary key default gen_random_uuid(),
  first_name varchar(80) not null,
  last_name varchar(80) not null,
  email varchar(254) not null,
  password_hash varchar(255) not null,
  phone varchar(30),
  document_type varchar(20) not null default 'dni'
    check (document_type in ('dni', 'ce', 'passport')),
  document_number varchar(20),
  gender varchar(30)
    check (
      gender is null
      or gender in ('female', 'male', 'non_binary', 'prefer_not_to_say')
    ),
  role varchar(20) not null default 'customer'
    check (role in ('customer', 'admin')),
  is_active boolean not null default true,
  last_login_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (char_length(btrim(first_name)) between 1 and 80),
  check (char_length(btrim(last_name)) between 1 and 80),
  check (email = lower(btrim(email))),
  check (
    document_number is null
    or char_length(btrim(document_number)) between 1 and 20
  )
);

create unique index users_email_unique_idx
  on public.users(lower(email));

create unique index users_document_unique_idx
  on public.users(document_type, document_number)
  where document_number is not null and btrim(document_number) <> '';

create index users_role_active_idx
  on public.users(role)
  where is_active;

create table public.auth_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null
    references public.users(id) on delete cascade,
  expires_at timestamptz not null,
  revoked_at timestamptz,
  created_at timestamptz not null default now(),
  last_seen_at timestamptz not null default now(),
  check (expires_at > created_at)
);

create index auth_sessions_user_active_idx
  on public.auth_sessions(user_id, expires_at desc)
  where revoked_at is null;

create index auth_sessions_expiry_idx
  on public.auth_sessions(expires_at)
  where revoked_at is null;

create trigger set_users_updated_at
  before update on public.users
  for each row execute function private.set_updated_at();

alter table public.orders
  add constraint orders_user_id_fkey
  foreign key (user_id)
  references public.users(id)
  on delete set null;

alter table public.users enable row level security;
alter table public.auth_sessions enable row level security;

revoke all on table public.users, public.auth_sessions
  from anon, authenticated, service_role;
