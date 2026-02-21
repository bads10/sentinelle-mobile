"""
Menaces - sources : URLhaus (URLs malveillantes) + Feodo Tracker (botnets C2)
Toutes deux gratuites et sans clé API (abuse.ch)
"""

import hashlib
from datetime import datetime
from typing import Optional

import httpx
from fastapi import APIRouter, Query, HTTPException

router = APIRouter()

URLHAUS_API = "https://urlhaus-api.abuse.ch/v1/urls/recent/limit/100/"
FEODO_API = "https://feodotracker.abuse.ch/downloads/ipblocklist.json"

_cache: dict = {}
CACHE_TTL = 900  # 15 min


def _cache_get(key: str):
    entry = _cache.get(key)
    if entry and (datetime.now().timestamp() - entry["ts"]) < CACHE_TTL:
        return entry["data"]
    return None


def _cache_set(key: str, data):
    _cache[key] = {"data": data, "ts": datetime.now().timestamp()}


def _urlhaus_severity(threat_type: str, tags: list[str]) -> str:
    text = (threat_type + " ".join(tags)).lower()
    if any(k in text for k in ["ransomware", "locker", "wiper"]):
        return "critical"
    if any(k in text for k in ["rat", "trojan", "backdoor", "stealer", "banking"]):
        return "high"
    if any(k in text for k in ["dropper", "loader", "downloader", "exploit"]):
        return "medium"
    return "low"


def _feodo_severity(malware: str) -> str:
    text = malware.lower()
    if any(k in text for k in ["dridex", "emotet", "trickbot", "qbot", "bumblebee"]):
        return "critical"
    if any(k in text for k in ["cobalt", "metasploit", "havoc"]):
        return "high"
    return "medium"


def _format_urlhaus(entry: dict) -> dict | None:
    url = entry.get("url", "")
    if not url:
        return None
    uid = entry.get("id") or hashlib.md5(url.encode()).hexdigest()
    threat_type = entry.get("threat", "malware_download")
    tags = entry.get("tags") or []
    severity = _urlhaus_severity(threat_type, tags)
    added = entry.get("date_added", datetime.now().isoformat())
    host = entry.get("host", "")
    return {
        "id": f"urlhaus-{uid}",
        "name": f"URL malveillante : {host}",
        "family": threat_type.replace("_", " ").title(),
        "severity": severity,
        "description": f"URL malveillante détectée sur {host}. Type : {threat_type}.",
        "reported_at": added,
        "tags": [str(t) for t in tags][:8],
        "ioc_count": 1,
        "is_active": entry.get("url_status", "online") == "online",
        "source": "URLhaus",
        "source_url": f"https://urlhaus.abuse.ch/url/{uid}/",
    }


def _format_feodo(entry: dict) -> dict | None:
    ip = entry.get("ip_address", "")
    if not ip:
        return None
    malware = entry.get("malware", "Botnet C2")
    severity = _feodo_severity(malware)
    first_seen = entry.get("first_seen", datetime.now().isoformat())
    country = entry.get("country", "?")
    return {
        "id": f"feodo-{hashlib.md5(ip.encode()).hexdigest()}",
        "name": f"Botnet C2 : {malware} ({ip})",
        "family": malware,
        "severity": severity,
        "description": f"Serveur C2 du botnet {malware} détecté sur {ip} ({country}).",
        "reported_at": first_seen,
        "tags": [malware, "botnet", "C2", country],
        "ioc_count": 1,
        "is_active": entry.get("last_online") is not None,
        "source": "Feodo Tracker",
        "source_url": f"https://feodotracker.abuse.ch/",
    }


@router.get("/")
async def get_threats(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    severity: Optional[str] = None,
):
    cache_key = "threats_recent"
    all_threats = _cache_get(cache_key)

    if all_threats is None:
        all_threats = []

        async with httpx.AsyncClient(timeout=20) as client:
            # URLhaus
            try:
                r = await client.post(URLHAUS_API, headers={"User-Agent": "Sentinelle-App/1.0"})
                if r.status_code == 200:
                    data = r.json()
                    for entry in data.get("urls", []):
                        formatted = _format_urlhaus(entry)
                        if formatted:
                            all_threats.append(formatted)
            except Exception as e:
                print(f"[threats] URLhaus erreur: {e}")

            # Feodo Tracker
            try:
                r2 = await client.get(FEODO_API, headers={"User-Agent": "Sentinelle-App/1.0"})
                if r2.status_code == 200:
                    feodo_list = r2.json()
                    for entry in feodo_list[:60]:
                        formatted = _format_feodo(entry)
                        if formatted:
                            all_threats.append(formatted)
            except Exception as e:
                print(f"[threats] Feodo erreur: {e}")

        if not all_threats:
            raise HTTPException(status_code=503, detail="Sources de menaces indisponibles")

        # Tri : critiques en premier
        severity_order = {"critical": 0, "high": 1, "medium": 2, "low": 3}
        all_threats.sort(key=lambda x: severity_order.get(x["severity"], 4))
        _cache_set(cache_key, all_threats)

    # Filtre sévérité
    filtered = all_threats
    if severity:
        filtered = [t for t in filtered if t["severity"] == severity.lower()]

    # Pagination
    total = len(filtered)
    start = (page - 1) * page_size
    end = start + page_size

    return {
        "items": filtered[start:end],
        "total": total,
        "page": page,
        "page_size": page_size,
        "has_more": end < total,
    }


@router.get("/{threat_id}")
async def get_threat(threat_id: str):
    cache_key = "threats_recent"
    all_threats = _cache_get(cache_key)

    if all_threats:
        for threat in all_threats:
            if threat["id"] == threat_id:
                return threat

    raise HTTPException(status_code=404, detail="Menace non trouvée")
