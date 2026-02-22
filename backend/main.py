"""
Sentinelle Backend - API de veille cybersécurité
Agrège : flux RSS, CVE (NVD/CIRCL), menaces (MalwareBazaar)
"""

from fastapi import FastAPI, Query, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

from routers import feed, incidents, threats, stats

app = FastAPI(
    title="Sentinelle API",
    description="Veille cybersécurité temps réel",
    version="1.0.0",
)

# CORS - autoriser l'app Flutter (web + mobile)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["GET"],
    allow_headers=["*"],
)

# Routes
app.include_router(feed.router, prefix="/api/v1/feed", tags=["feed"])
app.include_router(incidents.router, prefix="/api/v1/incidents", tags=["incidents"])
app.include_router(threats.router, prefix="/api/v1/threats", tags=["threats"])
app.include_router(stats.router, prefix="/api/v1/stats", tags=["stats"])


@app.get("/health")
async def health():
    return {"status": "ok", "service": "sentinelle-backend"}


if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
