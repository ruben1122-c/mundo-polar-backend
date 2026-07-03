create schema if not exists private;

create table public.user_profiles (
  id uuid primary key
    references auth.users(id) on delete cascade,
  first_name varchar(80) not null,
  last_name varchar(80) not null,
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
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (char_length(btrim(first_name)) between 1 and 80),
  check (char_length(btrim(last_name)) between 1 and 80),
  check (
    document_number is null
    or char_length(btrim(document_number)) between 1 and 20
  )
);

create unique index user_profiles_document_unique_idx
  on public.user_profiles(document_type, document_number)
  where document_number is not null and btrim(document_number) <> '';

create index user_profiles_role_active_idx
  on public.user_profiles(role)
  where is_active;

create or replace function private.set_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger set_user_profiles_updated_at
  before update on public.user_profiles
  for each row execute function private.set_updated_at();

create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.user_profiles (
    id,
    first_name,
    last_name,
    phone,
    document_type,
    document_number,
    gender,
    role
  )
  values (
    new.id,
    coalesce(nullif(btrim(new.raw_user_meta_data ->> 'first_name'), ''), 'Cliente'),
    coalesce(nullif(btrim(new.raw_user_meta_data ->> 'last_name'), ''), 'Mundo Polar'),
    nullif(btrim(new.raw_user_meta_data ->> 'phone'), ''),
    case
      when new.raw_user_meta_data ->> 'document_type' in ('dni', 'ce', 'passport')
        then new.raw_user_meta_data ->> 'document_type'
      else 'dni'
    end,
    nullif(btrim(new.raw_user_meta_data ->> 'document_number'), ''),
    case
      when new.raw_user_meta_data ->> 'gender'
        in ('female', 'male', 'non_binary', 'prefer_not_to_say')
        then new.raw_user_meta_data ->> 'gender'
      else null
    end,
    'customer'
  );
  return new;
end;
$$;

revoke all on function private.set_updated_at() from public;
revoke all on function private.handle_new_user() from public;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function private.handle_new_user();

insert into public.user_profiles (
  id,
  first_name,
  last_name,
  phone,
  document_type,
  document_number,
  gender,
  role
)
select
  users.id,
  coalesce(nullif(btrim(users.raw_user_meta_data ->> 'first_name'), ''), 'Cliente'),
  coalesce(nullif(btrim(users.raw_user_meta_data ->> 'last_name'), ''), 'Mundo Polar'),
  nullif(btrim(users.raw_user_meta_data ->> 'phone'), ''),
  case
    when users.raw_user_meta_data ->> 'document_type' in ('dni', 'ce', 'passport')
      then users.raw_user_meta_data ->> 'document_type'
    else 'dni'
  end,
  nullif(btrim(users.raw_user_meta_data ->> 'document_number'), ''),
  case
    when users.raw_user_meta_data ->> 'gender'
      in ('female', 'male', 'non_binary', 'prefer_not_to_say')
      then users.raw_user_meta_data ->> 'gender'
    else null
  end,
  'customer'
from auth.users as users
on conflict (id) do nothing;

alter table public.orders
  add column user_id uuid
    references auth.users(id) on delete set null;

create index orders_user_created_idx
  on public.orders(user_id, created_at desc);

alter table public.user_profiles enable row level security;

revoke all on table public.user_profiles
  from anon, authenticated, service_role;

revoke usage on schema private
  from public, anon, authenticated, service_role;
