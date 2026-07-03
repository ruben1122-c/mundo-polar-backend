create extension if not exists pgcrypto;

create table public.categories (
  id uuid primary key default gen_random_uuid(),
  slug varchar(80) not null unique,
  name varchar(100) not null,
  description text,
  is_active boolean not null default true,
  sort_order integer not null default 0 check (sort_order >= 0)
);

create table public.products (
  id uuid primary key default gen_random_uuid(),
  category_id uuid not null
    references public.categories(id) on delete restrict,
  slug varchar(120) not null unique,
  sku varchar(80) unique,
  name varchar(160) not null,
  description text,
  image_url text not null,
  image_alt varchar(200),
  price numeric(12, 2) not null check (price >= 0),
  compare_at_price numeric(12, 2)
    check (compare_at_price is null or compare_at_price >= price),
  currency varchar(3) not null default 'PEN'
    check (char_length(currency) = 3),
  badge varchar(60),
  stock_quantity integer not null default 0
    check (stock_quantity >= 0),
  is_active boolean not null default true,
  is_featured boolean not null default false,
  is_new boolean not null default false,
  is_on_sale boolean not null default false,
  sort_order integer not null default 0 check (sort_order >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number varchar(32) not null unique,
  customer_name varchar(160) not null,
  customer_email varchar(254) not null,
  customer_phone varchar(30),
  shipping_method varchar(30) not null
    check (shipping_method in ('delivery', 'store_pickup')),
  shipping_address jsonb,
  payment_method varchar(30) not null
    check (payment_method in ('card', 'yape', 'plin')),
  notes text check (notes is null or char_length(notes) <= 1000),
  status varchar(30) not null default 'pending'
    check (
      status in (
        'pending',
        'confirmed',
        'preparing',
        'shipped',
        'completed',
        'cancelled'
      )
    ),
  payment_status varchar(30) not null default 'unpaid'
    check (
      payment_status in ('unpaid', 'pending', 'paid', 'failed', 'refunded')
    ),
  subtotal numeric(12, 2) not null check (subtotal >= 0),
  shipping_amount numeric(12, 2) not null default 0
    check (shipping_amount >= 0),
  total numeric(12, 2) not null check (total >= 0),
  currency varchar(3) not null default 'PEN'
    check (char_length(currency) = 3),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (total = subtotal + shipping_amount)
);

create table public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  product_name varchar(160) not null,
  product_slug varchar(120) not null,
  sku varchar(80),
  image_url text,
  unit_price numeric(12, 2) not null check (unit_price >= 0),
  quantity integer not null check (quantity between 1 and 20),
  line_total numeric(12, 2) not null check (line_total >= 0),
  created_at timestamptz not null default now(),
  check (line_total = unit_price * quantity)
);

create index products_category_id_idx
  on public.products(category_id);
create index products_active_sort_idx
  on public.products(sort_order, created_at desc)
  where is_active;
create index products_featured_idx
  on public.products(sort_order)
  where is_active and is_featured;
create index products_new_idx
  on public.products(sort_order)
  where is_active and is_new;
create index products_sale_idx
  on public.products(sort_order)
  where is_active and is_on_sale;
create index orders_email_created_idx
  on public.orders(lower(customer_email), created_at desc);
create index orders_status_created_idx
  on public.orders(status, created_at desc);
create index order_items_order_id_idx
  on public.order_items(order_id);
create index order_items_product_id_idx
  on public.order_items(product_id);

alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;

revoke all on table
  public.categories,
  public.products,
  public.orders,
  public.order_items
from anon, authenticated, service_role;

alter default privileges for role postgres in schema public
  revoke select, insert, update, delete on tables
  from anon, authenticated, service_role;

alter default privileges for role postgres in schema public
  revoke usage, select on sequences
  from anon, authenticated, service_role;

alter default privileges for role postgres in schema public
  revoke execute on functions
  from anon, authenticated, service_role;

alter default privileges for role postgres in schema public
  revoke execute on functions from public;
