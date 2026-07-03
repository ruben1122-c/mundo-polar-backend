import os
from dataclasses import dataclass

from dotenv import load_dotenv

load_dotenv()


def _required_env(name: str) -> str:
    value = os.getenv(name, "").strip()
    if not value:
        raise RuntimeError(
            f"{name} no está configurada. Copia .env.example como .env."
        )
    return value


@dataclass(frozen=True)
class Settings:
    database_url: str
    supabase_url: str
    cors_origins: list[str]
    cors_origin_regex: str | None


def load_settings() -> Settings:
    origins = [
        origin.strip()
        for origin in os.getenv(
            "CORS_ORIGINS",
            "http://localhost:5173,http://127.0.0.1:5173",
        ).split(",")
        if origin.strip()
    ]
    origin_regex = os.getenv("CORS_ORIGIN_REGEX", "").strip() or None
    return Settings(
        database_url=_required_env("DATABASE_URL"),
        supabase_url=_required_env("SUPABASE_URL").rstrip("/"),
        cors_origins=origins,
        cors_origin_regex=origin_regex,
    )


settings = load_settings()
