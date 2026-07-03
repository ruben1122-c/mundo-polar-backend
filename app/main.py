from fastapi import Depends, FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.api.routers import auth, orders, products
from app.core.config import settings
from app.core.database import get_db

app = FastAPI(
    title="Mundo Polar API",
    version="1.0.0",
    description="Catálogo y pedidos pendientes de Mundo Polar.",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_origin_regex=settings.cors_origin_regex,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PATCH", "OPTIONS"],
    allow_headers=["Content-Type", "Authorization"],
)

app.include_router(products.router, prefix="/api")
app.include_router(orders.router, prefix="/api")
app.include_router(auth.router, prefix="/api")


@app.get("/api/health", tags=["Sistema"])
def health_check(db: Session = Depends(get_db)):
    db.execute(text("select 1"))
    return {"status": "ok", "database": "connected"}
