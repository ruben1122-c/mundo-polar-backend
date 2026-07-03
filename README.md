# Mundo Polar Backend

API FastAPI para el catálogo y los pedidos pendientes de Mundo Polar.

## Arquitectura

```text
React/Vite -> FastAPI -> PostgreSQL (Supabase)
```

Supabase funciona como PostgreSQL administrado. Las tablas no se exponen a
`anon`, `authenticated` ni `service_role`; todas las operaciones de la tienda
pasan por FastAPI.

## Configuración

1. Copia `.env.example` como `.env`.
2. Configura `DATABASE_URL` con Supavisor en puerto `6543`.
3. Instala dependencias:

   ```powershell
   python -m venv .venv
   .\.venv\Scripts\Activate.ps1
   pip install -r requirements.txt
   ```

4. Aplica migraciones:

   ```powershell
   npx supabase db push --db-url "$env:DATABASE_URL" --include-all
   ```

5. Ejecuta:

   ```powershell
   uvicorn main:app --reload --host 127.0.0.1 --port 8000
   ```

## Endpoints

- `GET /api/health`
- `GET /api/products`
- `POST /api/orders`

`POST /api/orders` no procesa pagos. Recalcula los precios desde la base de
datos y registra el pedido con estado `pending` y pago `unpaid`.
