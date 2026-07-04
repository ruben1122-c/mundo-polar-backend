insert into public.categories (slug, name, description, sort_order)
values
  ('ninos', 'NiÃ±os y niÃ±as', 'ColecciÃ³n de invierno para niÃ±os y niÃ±as', 3),
  ('mascotas', 'Mascotas', 'Prendas de invierno para mascotas', 4),
  ('ofertas', 'Ofertas', 'Productos con precio de temporada', 5)
on conflict (slug) do update set
  name = excluded.name,
  description = excluded.description,
  sort_order = excluded.sort_order;

with seed (category_slug, slug, name, image_url, price, compare_at_price, badge, sort_order) as (
  values
    ('mujer', 'abrigo-largo-beige-mujer', 'Abrigo largo beige', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/abrigo-largo-beige-mujer', 329, 389, '-15%', 0),
    ('hombre', 'casaca-puffer-negra', 'Casaca puffer negra', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/casaca-puffer-negra', 259, 309, '-16%', 0),
    ('hombre', 'sueter-nordico-azul-marino', 'SuÃ©ter nÃ³rdico azul marino', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/sueter-nordico-azul-marino', 189, 229, '-17%', 1),
    ('hombre', 'sueter-gris-tejido', 'SuÃ©ter gris tejido', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/sueter-gris-tejido', 169, null, null, 2),
    ('ninos', 'conjunto-infantil-azul-marino', 'Conjunto infantil azul marino', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/conjunto-infantil-azul-marino', 239, 289, '-17%', 0),
    ('ninos', 'conjunto-infantil-rosa', 'Conjunto infantil rosa', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/conjunto-infantil-rosa', 229, 279, '-18%', 1),
    ('ninos', 'conjunto-infantil-negro', 'Conjunto infantil negro', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/conjunto-infantil-negro', 249, 299, '-17%', 2),
    ('ninos', 'casaca-infantil-roja', 'Casaca infantil roja', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/casaca-infantil-roja', 219, 259, '-15%', 3),
    ('ninos', 'botas-termicas-rosa', 'Botas tÃ©rmicas rosas', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/botas-termicas-rosa', 119, 149, '-20%', 4),
    ('ninos', 'botas-invierno-camel', 'Botas de invierno camel', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/botas-invierno-camel', 179, 219, '-18%', 5),
    ('mascotas', 'sueter-mascota-pinguino-azul', 'SuÃ©ter para mascota pingÃ¼ino', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/sueter-mascota-pinguino-azul', 84, 99, '-15%', 0),
    ('mascotas', 'sueter-mascota-crema-celeste', 'SuÃ©ter crema para mascota', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/sueter-mascota-crema-celeste', 79, 95, '-17%', 1),
    ('mascotas', 'chaleco-mascota-verde', 'Chaleco verde para mascota', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/chaleco-mascota-verde', 82, 98, '-16%', 2),
    ('mascotas', 'sueter-mascota-verde', 'SuÃ©ter tejido verde para mascota', 'https://res.cloudinary.com/jyonna8m/image/upload/mundo-polar/products/sueter-mascota-verde', 76, 92, '-17%', 3)
)
insert into public.products (
  category_id, slug, name, image_url, image_alt, price, compare_at_price,
  badge, stock_quantity, is_active, is_featured, is_new, is_on_sale, sort_order
)
select
  categories.id, seed.slug, seed.name, seed.image_url, seed.name, seed.price,
  seed.compare_at_price, seed.badge, 100, true, false, false, false, seed.sort_order
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
  stock_quantity = excluded.stock_quantity,
  is_active = excluded.is_active,
  is_featured = excluded.is_featured,
  is_new = excluded.is_new,
  is_on_sale = excluded.is_on_sale,
  sort_order = excluded.sort_order;
