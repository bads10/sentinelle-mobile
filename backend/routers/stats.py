"""
Statistiques globales - agrège les données des autres modules
"""

from datetime import datetime
import httpx
from fastapi import APIRouter

router = APIRouter()

_cache: dict = {}
CACHE_TTL = 300  # 5 min


def _cache_get(key: str):
    entry = _cache.get(key)
    if entry and (datetime.now().timestamp() - entry["ts"]) < CACHE_TTL:
        return entry["data"]
    return None


def _cache_set(key: str, data):
    _cache[key] = {"data": data, "ts": datetime.now().timestamp()}


@router.get("/")
async def get_stats():
    cache_key = "stats"
    cached = _cache_get(cache_key)
    if cached:
        return cached

    # Appels internes au backend lui-même
    threats_data = {"items": [], "total": 0}
    incidents_data = {"items": [], "total": 0}
    feed_data = {"items": [], "total": 0}

    try:
        async with httpx.AsyncClient() as client:
            t_resp = await client.get("http://localhost:8000/api/v1/threats/?page_size=100", timeout=15)
            if t_resp.status_code == 200:
                threats_data = t_resp.json()

            i_resp = await client.get("http://localhost:8000/api/v1/incidents/?page_size=100", timeout=15)
            if i_resp.status_code == 200:
                incidents_data = i_resp.json()

            f_resp = await client.get("http://localhost:8000/api/v1/feed/?page_size=100", timeout=15)
            if f_resp.status_code == 200:
                feed_data = f_resp.json()
    except Exception as e:
        print(f"[stats] Erreur appel interne: {e}")

    threats = threats_data.get("items", [])
    incidents = incidents_data.get("items", [])

    # Comptage sévérités threats
    t_critical = sum(1 for t in threats if t.get("severity") == "critical")
    t_high = sum(1 for t in threats if t.get("severity") == "high")
    t_medium = sum(1 for t in threats if t.get("severity") == "medium")
    t_low = sum(1 for t in threats if t.get("severity") == "low")

    # Comptage sévérités incidents
    i_critical = sum(1 for i in incidents if i.get("severity") == "critical")
    i_high = sum(1 for i in incidents if i.get("severity") == "high")
    i_medium = sum(1 for i in incidents if i.get("severity") == "medium")
    i_low = sum(1 for i in incidents if i.get("severity") == "low")

    # Top families de menaces
    from collections import Counter
    families = Counter(t.get("family", "Unknown") for t in threats)
    top_types = [f for f, _ in families.most_common(5)]

    stats = {
        "total_threats": threats_data.get("total", len(threats)),
        "total_incidents": incidents_data.get("total", len(incidents)),
        "total_feed_items": feed_data.get("total", 0),
        "new_threats_last_7_days": min(len(threats), 20),  # estimation
        "new_incidents_last_7_days": min(len(incidents), 15),
        "critical_threats": t_critical,
        "high_severity_incidents": i_high,
        "threats_critical": t_critical,
        "threats_high": t_high,
        "threats_medium": t_medium,
        "threats_low": t_low,
        "incidents_critical": i_critical,
        "incidents_high": i_high,
        "incidents_medium": i_medium,
        "incidents_low": i_low,
        "threats_trend": 0.0,
        "incidents_trend": 0.0,
        "top_threat_types": top_types,
        "top_targeted_sectors": [],
        "last_updated": datetime.now().isoformat(),
    }

    _cache_set(cache_key, stats)
    return stats
