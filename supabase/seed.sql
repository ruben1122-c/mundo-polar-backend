insert into public.categories (slug, name, description, sort_order)
values
  ('destacados', 'Destacados', 'Selección principal de Mundo Polar', 0),
  ('mujer', 'Mujer', 'Colección de invierno para mujer', 1),
  ('hombre', 'Hombre', 'Colección de invierno para hombre', 2),
  ('mascotas', 'Mascotas', 'Prendas de invierno para mascotas', 3),
  ('ofertas', 'Ofertas', 'Productos con precio de temporada', 4)
on conflict (slug) do update set
  name = excluded.name,
  description = excluded.description,
  sort_order = excluded.sort_order;

with seed (category_slug, slug, name, image_url, price, compare_at_price, badge, is_featured, is_new, is_on_sale, sort_order) as (
  values
    ('destacados', 'chaqueta-capucha', 'Chaqueta con capucha marrón', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/chaqueta-capucha-marron', 50, null, null, true, true, false, 0),
    ('destacados', 'abrigo-corto', 'Abrigo corto marrón', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/abrigo-corto-marron', 500, null, null, true, true, false, 1),
    ('destacados', 'sueter-beige', 'Suéter de poliéster beige', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/sweater-poliester-beige', 400, null, null, true, true, false, 2),
    ('destacados', 'camiseta-algodon', 'Camiseta de algodón grueso', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/camiseta-gildan-heavy-cotton', 189, 200, '-6%', true, true, false, 3),
    ('destacados', 'sueter-cuello-alto', 'Suéter de cuello alto', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/sweater-cuello-alto', 125, null, null, true, true, false, 4),
    ('ofertas', 'casaca-impermeable', 'Casaca impermeable', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/casaca-impermeable', 248, 299, '-17%', false, false, true, 5),
    ('ofertas', 'capa-termica', 'Capa térmica de cuello alto', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/turtleneck-base-layer', 50, 60, null, false, false, true, 6),
    ('ofertas', 'polo-cuello-alto', 'Polo térmico de cuello alto', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/turtleneck-slim-fit', 76, 85, '-10%', false, false, true, 7),
    ('ofertas', 'vestido-tejido', 'Vestido tejido de invierno', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/vestido-tejido', 99, 118, null, false, false, true, 8),
    ('ofertas', 'top-rayas', 'Top tejido a rayas', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/top-rayas-marron', 89, null, null, false, false, true, 9),
    ('ofertas', 'medias-lana', 'Medias de lana', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/medias-lana', 45, null, null, false, false, true, 10),
    ('ofertas', 'botas-invierno', 'Botas de invierno', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/botas-invierno', 249, null, null, false, false, true, 11),
    ('ofertas', 'polo-azul', 'Polo azul para hombre', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/polo-azul-hombre', 79, null, null, false, false, true, 12),
    ('ofertas', 'gorro-lana', 'Gorro de lana', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/gorro-lana', 50, null, null, false, false, true, 13),
    ('ofertas', 'orejeras', 'Orejeras de invierno', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/vincha-invierno', 60, null, null, false, false, true, 14),
    ('ofertas', 'top-tejido', 'Top tejido', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/top-tejido', 89, null, null, false, false, true, 15),
    ('ofertas', 'sueter-invierno', 'Suéter de invierno', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/sweater-invierno', 149, 179, null, false, false, true, 16),
    ('mujer', 'w1', 'Botas altas', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/mujer/42', 90, 200, '-17%', false, false, false, 17),
    ('mujer', 'w2', 'Conjunto de invierno chic', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/mujer/w-om-en-sr-ib-be-dt-ur-tl-en-ec-kb-as-el-ay-er-un-de-rs-hi-rt-s', 210, 400, null, false, false, false, 18),
    ('mujer', 'w3', 'Polo térmico', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/mujer/a-da-gr-ow-om-en-st-sh-ir-ts-tu-rt-le-ne-ck-sl-im-fi-tt-ee', 76, 85, null, false, false, false, 19),
    ('mujer', 'w4', 'Vestido tejido', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/mujer/t-om-my-hi-lf-ig-er-wo-me-ns-kn-it-sh-ea-th-dr-es-s', 129, null, null, false, false, false, 20),
    ('mujer', 'w5', 'Guantes de invierno', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/mujer/o-dd-co-ol-sl-ee-ve-ve-nt-co-ll-ar-kn-it', 50, null, null, false, false, false, 21),
    ('mujer', 'w6', 'Botas polares', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/mujer/o-dd-co-ol-sl-ee-ve-ve-nt-co-ll-ar-kn-it1', 100, null, null, false, false, false, 22),
    ('mujer', 'w7', 'Casaca de invierno', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/mujer/o-dd-co-ol-sl-ee-ve-ve-nt-co-ll-ar-kn-it2', 160, null, null, false, false, false, 23),
    ('mujer', 'w8', 'Conjunto polar', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/mujer/o-dd-co-ol-sl-ee-ve-ve-nt-co-ll-ar-kn-it3', 300, null, null, false, false, false, 24),
    ('hombre', 'm1', 'Casaca térmica andina', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/hombre/i-ma-ge46', 248, 299, '-17%', false, false, false, 25),
    ('hombre', 'm2', 'Polar clásico para hombre', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/hombre/i-ma-ge45', 50, 60, null, false, false, false, 26),
    ('hombre', 'm3', 'Chaqueta impermeable ártica', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/hombre/i-ma-ge48', 76, 85, null, false, false, false, 27),
    ('hombre', 'm4', 'Suéter nórdico de cuello alto', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/hombre/i-ma-ge49', 58, null, null, false, false, false, 28),
    ('hombre', 'm5', 'Casaca polar expedición', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/hombre/i-ma-ge50', 279, null, null, false, false, false, 29),
    ('hombre', 'm6', 'Chaqueta térmica Everest', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/hombre/i-ma-ge54', 150, null, null, false, false, false, 30),
    ('hombre', 'm7', 'Chaleco polar explorador', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/hombre/i-ma-ge55', 249, null, null, false, false, false, 31),
    ('hombre', 'm8', 'Suéter alpino prémium', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/hombre/i-ma-ge51', 250, null, null, false, false, false, 32),
    ('mascotas', 'p1', 'Bufanda polar para mascota', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/mascotas/i-ma-ge46', 35, null, null, false, false, false, 33),
    ('mascotas', 'p2', 'Suéter tejido beige para mascota', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/mascotas/i-ma-ge45', 55, null, null, false, false, false, 34),
    ('mascotas', 'p3', 'Impermeable gris con capucha', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/mascotas/i-ma-ge48', 75, null, null, false, false, false, 35),
    ('mascotas', 'p4', 'Chaleco acolchado azul marino', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/mascotas/i-ma-ge49', 65, null, null, false, false, false, 36),
    ('mascotas', 'p5', 'Botitas térmicas camel', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/mascotas/o-dd-co-ol-sl-ee-ve-ve-nt-co-ll-ar-kn-it', 60, null, null, false, false, false, 37),
    ('mascotas', 'p6', 'Gorro tejido con pompón', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/mascotas/o-dd-co-ol-sl-ee-ve-ve-nt-co-ll-ar-kn-it1', 40, null, null, false, false, false, 38),
    ('mascotas', 'p7', 'Conjunto térmico crema', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/mascotas/o-dd-co-ol-sl-ee-ve-ve-nt-co-ll-ar-kn-it2', 70, null, null, false, false, false, 39),
    ('mascotas', 'p8', 'Abrigo acolchado rosa', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/mascotas/o-dd-co-ol-sl-ee-ve-ve-nt-co-ll-ar-kn-it3', 85, null, null, false, false, false, 40)
)
insert into public.products (
  category_id, slug, name, image_url, image_alt, price, compare_at_price,
  badge, stock_quantity, is_active, is_featured, is_new, is_on_sale, sort_order
)
select
  categories.id, seed.slug, seed.name, seed.image_url, seed.name, seed.price,
  seed.compare_at_price, seed.badge, 100, true, seed.is_featured, seed.is_new,
  seed.is_on_sale, seed.sort_order
from seed
join public.categories on categories.slug = seed.category_slug
on conflict (slug) do update set
  category_id = excluded.category_id,
  name = excluded.name,
  image_url = excluded.image_url,
  image_alt = excluded.image_alt,
  price = excluded.price,
  compare_at_price = excluded.compare_at_price,
  badge = excluded.badge,
  is_active = excluded.is_active,
  is_featured = excluded.is_featured,
  is_new = excluded.is_new,
  is_on_sale = excluded.is_on_sale,
  sort_order = excluded.sort_order;
